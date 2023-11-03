// SingletonManager.cpp
#include "singletonmanager.h"

#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QPainter>
#include <QPrintDialog>
#include <QPrintPreviewDialog>
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
  QPrintPreviewDialog *dialog2 = new QPrintPreviewDialog(&m_printer);
  //  m_printDialog.reset(dialog);
  //  m_printDialog2.reset(dialog2);

  QObject::connect(dialog2, &QPrintPreviewDialog::paintRequested, this,
                   &SingletonManager::printer);

  dialog2->exec();
  return false;
}

void SingletonManager::printer(QPrinter *printer) {
  // 创建QImage对象从文件加载图片
  QImage image(m_PicPath);
  if (image.isNull()) {
    qDebug() << "Failed to load image.";
    return;
  }

  // 将图片缩放到A4纸的大小
  QSizeF paperSize = printer->pageRect(QPrinter::Point).size();  // A4纸的大小
  qDebug() << "paperSize: " << paperSize;

  qDebug() << "image.size: " << image.size();
  // 打印图片
  QPainter painter;
  painter.begin(printer);
  painter.drawImage(0, 0, image);
  painter.end();
}

void SingletonManager::openPreview() {}

QString SingletonManager::picPath() const { return m_PicPath; }
