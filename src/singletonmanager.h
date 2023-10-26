#ifndef SINGLETONMANAGER_H
#define SINGLETONMANAGER_H

#include <QJsonObject>
#include <QObject>
#include <QSettings>
#include <QStringList>
#include <QThreadPool>
#include <QtSerialPort/QSerialPort>
#include <QtSerialPort/QSerialPortInfo>
#include <functional>

class SingletonManager : public QObject {
  Q_OBJECT
 public:
  static SingletonManager* instance();

 public slots:
  void receive();

 signals:
  // 信号用于触发回调
  void serialData(const QString& msg);

 private:
  explicit SingletonManager();
  QString openSerialPort(const QString& port, int rate);

  QString sendData(QString addr, QString code, QString data,
                   bool circle = false);

  QStringList getSerialPortList();

  ~SingletonManager();
  void init();
  static SingletonManager* m_instance;
  QSerialPort serial;  // 定义全局串口对象
  QByteArray buffer;
  QThreadPool customThreadPool;
};

#endif  // SINGLETONMANAGER_H
