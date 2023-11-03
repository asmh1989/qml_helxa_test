#ifndef SINGLETONMANAGER_H
#define SINGLETONMANAGER_H

#include <QObject>
#include <QPrinter>
#include <functional>

class SingletonManager : public QObject {
  Q_OBJECT
 public:
  static SingletonManager* instance();

  Q_PROPERTY(QString picPath READ picPath CONSTANT)

  Q_INVOKABLE bool showPrintDialog();
  Q_INVOKABLE void openPreview();
  QString picPath() const;
  void init(QObject* application);

 public slots:
  //  void receive();
  void printer(QPrinter* printer);

 signals:
  // 信号用于触发回调
  void serialData(const QString& msg);

 private:
  explicit SingletonManager();

  ~SingletonManager();
  static SingletonManager* m_instance;

  QObject* _application;
  QString m_PicPath;

  QPrinter m_printer;
};

#endif  // SINGLETONMANAGER_H
