#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QApplication>

int main(int argc, char *argv[])
{
    qputenv("QT_SCALE_FACTOR", "1.2");

    QApplication app(argc, argv);
//    QQuickStyle::setStyle("Material");

    QQuickStyle::setStyle("Universal");

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/qt-websockerts_demo/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
