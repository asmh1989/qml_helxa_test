#include <QApplication>
#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QMutex>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

#include "fileio.h"
#include "qmlemsocket.h"
#include "singletonmanager.h"

// some constants to parameterize.
const qint64 LOG_FILE_LIMIT = 300000;
const QString LOG_PATH = "log/";

// thread safety
QMutex mutex;

void redirectDebugMessages(QtMsgType type, const QMessageLogContext &context,
                           const QString &str) {
  QString datetime =
      QDateTime::currentDateTime().toString("yyyy.MM.dd hh:mm:ss");
  QString txt;
  // prepend a log level label to every message
  switch (type) {
    case QtDebugMsg:
      txt = QString("[Debug] ");
      break;
    case QtWarningMsg:
      txt = QString("[Warning] ");
      break;
    case QtInfoMsg:
      txt = QString("[Info] ");
      break;
    case QtCriticalMsg:
      txt = QString("[Critical] ");
      break;
    case QtFatalMsg:
      txt = QString("[Fatal] ");
  }

  QDir dir(LOG_PATH);
  if (!dir.exists()) {
    dir.mkpath(".");
  }

  // thread safety
  mutex.lock();

  // prepend timestamp to every message
  QString datetime2 = QDateTime::currentDateTime().toString("yyyy-MM-dd");
  QString filePath = LOG_PATH + "log-" + datetime2 + ".log";
  QFile outFile(filePath);

  // if file reached the limit, rotate to filename.1
  if (outFile.size() > LOG_FILE_LIMIT) {
    // roll the log file.
    QFile::remove(filePath + ".1");
    QFile::rename(filePath, filePath + ".1");
    QFile::resize(filePath, 0);
  }

  // write message
  outFile.open(QIODevice::WriteOnly | QIODevice::Append);
  QTextStream ts(&outFile);
  ts << datetime << txt << str << Qt::endl;

  // close fd
  outFile.close();
  mutex.unlock();
}

int main(int argc, char *argv[]) {
  qputenv("QT_SCALE_FACTOR", "1.25");

  QApplication app(argc, argv);

#ifndef QT_DEBUG
  qInstallMessageHandler(redirectDebugMessages);
#endif

  app.setOrganizationName("em");
  app.setOrganizationDomain("em.com");
  app.setApplicationName("em");
  //    QQuickStyle::setStyle("Material");

  QQuickStyle::setStyle("Universal");

  qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
  qmlRegisterType<QmlEmSocket>("EmSockets", 1 /*major*/, 0 /*minor*/,
                               "EmSocket");

  QQmlApplicationEngine engine;
  // 设置C++对象的所有权为QQmlEngine::CppOwnership
  engine.rootContext()->setContextProperty("sm", SingletonManager::instance());

  SingletonManager::instance()->init(&engine);

  engine.setObjectOwnership(SingletonManager::instance(),
                            QQmlEngine::CppOwnership);

  const QUrl url(u"qrc:/qt-websockerts/Main.qml"_qs);
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreated, &app,
      [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) QCoreApplication::exit(-1);
      },
      Qt::QueuedConnection);
  engine.load(url);

  return app.exec();
}
