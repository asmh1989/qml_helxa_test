// SingletonManager.cpp
#include "singletonmanager.h"

#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QPainter>
#include <QPrintDialog>
#include <QPrintPreviewDialog>
#include <QPrinter>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QTextCursor>
#include <QTextDocument>

SingletonManager *SingletonManager::m_instance = nullptr;

SingletonManager::SingletonManager() : m_PicPath("print_preview.png") {}

SingletonManager::~SingletonManager() {}

SingletonManager *SingletonManager::instance() {
  if (!m_instance) {
    m_instance = new SingletonManager();
  }
  return m_instance;
}

QString readFileToString(const QString &filePath) {
  QFile file(filePath);
  QString fileContent;

  if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
    QTextStream in(&file);
    fileContent = in.readAll();
    file.close();
  } else {
    qDebug() << "Failed to open file:" << filePath;
  }

  return fileContent;
}

void SingletonManager::init(QObject *application) {
  qDebug() << "SingletonManager::init ... ";
  this->_application = application;
}

bool SingletonManager::showPrintDialog() {
  //  return m_printDialog2->exec() == QDialog::Accepted;

  QPrinter printer;
  //  QPrintDialog *dialog = new QPrintDialog(&printer);

  QPrintPreviewDialog *dialog2 = new QPrintPreviewDialog(&printer);
  //  m_printDialog.reset(dialog);
  //  m_printDialog2.reset(dialog2);

  QObject::connect(
      dialog2, &QPrintPreviewDialog::paintRequested, [=](QPrinter *printer) {
        // 创建QImage对象从文件加载图片
        QImage image(m_PicPath);
        if (image.isNull()) {
          qDebug() << "Failed to load image.";
          return -1;
        }

        // 将图片缩放到A4纸的大小
        QSizeF paperSize =
            printer->pageRect(QPrinter::Point).size();  // A4纸的大小
        qDebug() << "paperSize: " << paperSize;

        qDebug() << "image.size: " << image.size();
        // 打印图片
        QPainter painter;
        painter.begin(printer);
        painter.drawImage(0, 0, image);
        painter.end();
      });

  dialog2->exec();

  //  printer.setDocName("Printed Document");
  //  QTextDocument doc;

  //  QPainter painter;

  //  QImage pm = QImage(m_PicPath);
  //  if (pm.isNull()) {
  //    qDebug() << m_PicPath << " not exist!";
  //    return false;
  //  }

  //  QTextCursor cursor(&doc);
  //  cursor.insertImage(pm);
  //  doc.print(&printer);
  return false;
}

void SingletonManager::openPreview() {}

void SingletonManager::print(QString html) {
  //  printer.setOutputFormat(QPrinter::NativeFormat);
  //  printer.setPrinterName(m_printDialog->printer()->printerName());
  //  printer.setPageSize(QPageSize::A4);
  //  printer.setFullPage(true);
  //  printer.setPageOrientation(QPageLayout::Portrait);
  //  printer.setOutputFileName("test.pdf");  // 可以指定输出文件名
  //  printer.setDocName("Printed Document");
  //  QTextDocument doc;
  //  doc.setHtml(html);
  //  doc.print(&printer);
}

QString SingletonManager::picPath() const { return m_PicPath; }
