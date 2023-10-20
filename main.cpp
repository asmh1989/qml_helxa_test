#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QApplication>
#include "fileio.h"

int main(int argc, char *argv[])
{
    qputenv("QT_SCALE_FACTOR", "1.2");

    QApplication app(argc, argv);

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
