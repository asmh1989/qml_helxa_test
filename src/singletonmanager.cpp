// SingletonManager.cpp
#include "singletonmanager.h"

#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>

#include "model.h"
#include "qaesencryption.h"
#include "utils.h"

SingletonManager *SingletonManager::m_instance = nullptr;

SingletonManager::SingletonManager() {
  customThreadPool.setMaxThreadCount(2);  // 设置最大线程数

  // 连接readyRead()信号，当串口有可用数据时触发
  QObject::connect(&serial, &QSerialPort::readyRead, this,
                   &SingletonManager::receive);

  init();
}

SingletonManager::~SingletonManager() {}

SerialData parseCrc(const QByteArray &inputByteArray) {
  SerialData parsedData;

  auto size = inputByteArray.size();
  // 解析Address（前两个字节）
  parsedData.addr =
      QString("%1")
          .arg(static_cast<quint8>(inputByteArray[0]), 2, 16, QLatin1Char('0'))
          .toUpper();

  // 解析Code（第三个字节）
  parsedData.code =
      QString("%1")
          .arg(static_cast<quint8>(inputByteArray[1]), 2, 16, QLatin1Char('0'))
          .toUpper();

  qint16 status = (static_cast<quint8>(inputByteArray[2]) << 8) +
                  static_cast<quint8>(inputByteArray[3]);
  quint16 data_len = status & 0x0FFF;

  // 解析Quantity（第四和第五个字节）
  parsedData.quantity =
      QString("%1")
          .arg(static_cast<quint16>(status), 4, 16, QLatin1Char('0'))
          .toUpper();

  // 解析TimeStamp（接下来的四个字节）
  QByteArray timeStampArray = inputByteArray.mid(4, 4);
  parsedData.time = QString(timeStampArray.toHex()).toUpper();

  // 解析Data（接下来的八个字节）
  QByteArray dataArray = inputByteArray.mid(8, data_len - 4);
  parsedData.data = QString(dataArray.toHex()).toUpper();

  auto crc_c = inputByteArray.mid(0, size - 2);
  auto crc_cc = utils::calculate_modbus_crc(crc_c);
  parsedData.circle = crc_cc == inputByteArray;

  return parsedData;
}

void SingletonManager::receive() {
  QByteArray receivedData = serial.readAll();
  buffer.append(receivedData);

  // 寻找帧头'$'
  int startIndex = buffer.indexOf('$');
  while (startIndex != -1) {
    // 寻找帧尾'\r'
    int endIndex = buffer.indexOf('\r', startIndex);
    if (endIndex != -1) {
      // 提取一帧内容
      QByteArray frameData =
          buffer.mid(startIndex + 1, endIndex - startIndex - 1);

      // 使用Lambda函数在线程池中处理数据
      auto processor = [frameData, this]() {
        // 在这里进行数据处理逻辑
        qDebug() << "Processing data: " << frameData;
        QDateTime currentDateTime = QDateTime::currentDateTime();
        QString formattedTime = currentDateTime.toString("hh:mm:ss.zzz");
        QString log;

        log.append("Receive: Time:      " + formattedTime + "\n");
        log.append("Receive: Base64:    " + frameData + "\n");
        QByteArray encode = QByteArray::fromBase64(frameData);
        log.append("Receive: Hex:       " + utils::formatQByte(encode) +
                   " 解密前\n");
        QAESEncryption decryption(QAESEncryption::AES_128, QAESEncryption::ECB,
                                  QAESEncryption::PKCS7);
        QByteArray crcData2 =
            decryption.decode(encode, globalReadOnlyKey->toUtf8());
        QByteArray crcData =
            QAESEncryption::RemovePadding(crcData2, QAESEncryption::PKCS7);
        log.append("Receive: Hex:       " + utils::formatQByte(crcData) + "\n");
        //                qDebug()<<log.toUtf8().constData();

        auto s = parseCrc(crcData);
        if (s.circle) {
          log.append(QString("Receive: Data:      Address:%1   Code:%2   "
                             "Quantity:%3   TimeStamp:%4   Data:%5\n")
                         .arg(s.addr, s.code, s.quantity, s.time, s.data));
        } else {
          log.append("Receive: Data:      ERROR!!\n");
        }

        emit serialData(log);
      };

      QThreadPool::globalInstance()->start(std::bind(processor));

      // 从缓存中移除已处理的数据
      buffer.remove(0, endIndex + 1);
    } else {
      // 如果没有找到帧尾，保留剩余数据到缓存中
      buffer = buffer.mid(startIndex);
      break;
    }

    // 寻找下一个帧头
    startIndex = buffer.indexOf('$');
  }
}

QStringList SingletonManager::getSerialPortList() {
  QStringList availablePorts;
  auto serialPortList = QSerialPortInfo::availablePorts();
  // 将串口信息添加到字符串列表
  foreach (const QSerialPortInfo &serialPortInfo, serialPortList) {
    availablePorts.append(serialPortInfo.description() + " (" +
                          serialPortInfo.portName() + ")");
  }

  qDebug() << "Available Serial Ports:" << availablePorts;

  return availablePorts;
}

QString SingletonManager::openSerialPort(const QString &port_name, int rate) {
  qDebug() << "openSerialPort port = " << port_name << " rate = " << rate;
  serial.setPortName(port_name);
  serial.setBaudRate(QSerialPort::Baud115200);
  serial.setDataBits(QSerialPort::Data8);
  serial.setFlowControl(QSerialPort::NoFlowControl);
  serial.setParity(QSerialPort::NoParity);
  serial.setStopBits(QSerialPort::OneStop);
  if (serial.isOpen()) {
    return tr("Can't open %1").arg(port_name);
  }
  if (!serial.open(QIODevice::ReadWrite)) {
    return tr("Can't open %1, error code %2")
        .arg(port_name)
        .arg(serial.error());
  } else {
    qDebug() << "openSerial success!";
  }

  return "";
}

SingletonManager *SingletonManager::instance() {
  if (!m_instance) {
    m_instance = new SingletonManager();
  }
  return m_instance;
}

QString SingletonManager::sendData(QString addr, QString code, QString data,
                                   bool circle) {
  addr.replace(" ", "");
  code.replace(" ", "");
  data.replace(" ", "");

  //    qDebug()<<"sendData: data = "<< data <<" circle = " <<circle;
  QString log;

  QDateTime currentDateTime = QDateTime::currentDateTime();
  QString formattedTime = currentDateTime.toString("hh:mm:ss.zzz");

  log.append("Send: Time:         " + formattedTime + "\n");

  uint32_t timeS =
      static_cast<uint32_t>(currentDateTime.toMSecsSinceEpoch() / 1000);
  auto time = QString("%1").arg(timeS, 4, 16, QLatin1Char('0')).toUpper();
  uint32_t len = (data.length() + time.length()) / 2;

  QString s_data;

  // 设备地址
  s_data.append(addr);
  // 功能码
  s_data.append(code);
  // 状态位和数据长度
  s_data.append(
      QString("%1").arg(len & 0x0FFF, 4, 16, QLatin1Char('0')).toUpper());
  // 时间戳
  s_data.append(time);
  // 数据
  s_data.append(data);

  auto s_byte = utils::convertQStringToByteArray(s_data);
  log.append("Send: Hex:          " + utils::formatQByte(s_byte) + "\n");

  QByteArray crcData = utils::calculate_modbus_crc(s_byte);

  // Encrypt data using AES in ECB mode
  QAESEncryption encryption(QAESEncryption::AES_128, QAESEncryption::ECB,
                            QAESEncryption::PKCS7);

  QByteArray encryptedData =
      encryption.encode(crcData, globalReadOnlyKey->toUtf8());
  //    qDebug()<<"aes: " << utils::formatQByte(encryptedData);
  log.append("Send: AllHex:       " + utils::formatQByte(encryptedData) + "\n");

  // Encode the encrypted data using base64 encoding
  QByteArray base64Data = encryptedData.toBase64();

  // Prepare final data packet
  QByteArray finalData = "$" + base64Data + "\r";
  //    qDebug() << "Final Data:" << finalData;

  log.append("Send: Base64:       " + finalData + "\n");

  //    qDebug()<<log.toUtf8().constData();

  emit serialData(log);

  if (serial.isOpen()) {
    serial.write(finalData);
    return "";
  } else {
    return "please open serial FIRST!!";
  }
}

void SingletonManager::init() { qDebug() << "SingletonManager::init ... "; }
