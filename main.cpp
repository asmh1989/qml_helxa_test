#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QApplication>
#include "fileio.h"
#include <QFile>
#include <QMutex>
#include <QDir>
//some constants to parameterize.
const qint64 LOG_FILE_LIMIT = 3000000;
const QString LOG_PATH = "log/";

//thread safety
QMutex mutex;

void redirectDebugMessages(QtMsgType type, const QMessageLogContext & context, const QString & str)
{
    QString datetime = QDateTime::currentDateTime().toString("yyyy.MM.dd hh:mm:ss");
    QString txt;
    //prepend a log level label to every message
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

    //thread safety
    mutex.lock();

    //prepend timestamp to every message
    QString datetime2 = QDateTime::currentDateTime().toString("yyyy-MM-dd");
    QString filePath = LOG_PATH+ "log-"+datetime2+".log";
    QFile outFile(filePath);

    //if file reached the limit, rotate to filename.1
    if(outFile.size() > LOG_FILE_LIMIT){
        //roll the log file.
        QFile::remove(filePath + ".1");
        QFile::rename(filePath, filePath + ".1");
        QFile::resize(filePath, 0);
    }

    //write message
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);
    ts << datetime << txt << str << Qt::endl;

    //close fd
    outFile.close();
    mutex.unlock();
}

int main(int argc, char *argv[])
{
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

    qmlRegisterType<FileIO,1>("FileIO",1,0,"FileIO");

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/qt-websockerts/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
