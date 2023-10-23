#include "fileio.h"
#include <QFile>
#include <QTextStream>
#include <QDir>

FileIO::FileIO(QObject *parent) :
    QObject(parent)
{

}

QString FileIO::read()
{
    if (mSource.isEmpty()){
        emit error("source is empty");
        return QString();
    }

    QFile file(mSource);
    QString fileContent;
    if ( file.open(QIODevice::ReadOnly) ) {
        QString line;
        QTextStream t( &file );
        do {
            line = t.readLine();
            fileContent += line;
        } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        return QString();
    }
    return fileContent;
}

int FileIO::getNumberOfLines(){

    if (mSource.isEmpty()){
        emit error("source is empty");
        return -1;
    }

    QFile file(mSource);
    int numberOfLines=0;

    if ( file.open(QIODevice::ReadOnly) ) {
        QString line;
        QTextStream t( &file );
        do {
            line = t.readLine();
            numberOfLines++;
        } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        return -1;
    }
    return numberOfLines-1;
}

bool FileIO::write(const QString& data)
{
    if (mSource.isEmpty())
        return false;

    QFile file(mSource);

    //"append" allows adding a new line instead of rewriting the file
    if (!file.open(QFile::WriteOnly | QIODevice::Text | QFile::Append))
        return false;

    QTextStream out(&file);
    out << data <<"\n";
    file.close();

    return true;
}


QString FileIO::saveToCsv(const QString &filePath, const QStringList &headers, const QList<QStringList> &data) {

    QFile file(filePath);

    QFileInfo fileInfo(filePath);
    QDir dir(fileInfo.dir().absolutePath());
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    if (file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        QTextStream stream(&file);
        stream.setEncoding(QStringConverter::Utf8);

        // 写入表头
        if (file.size() == 0) {
            for (auto i = 0; i < headers.size(); i++) {

                stream << headers[i];
                if(i != headers.size() - 1){
                    stream<< ",";
                }
            }
            stream << "\n";
        }

        // 写入数据
        for (const QStringList &row : data) {
            for (auto i = 0; i < row.size(); i++) {

                stream << row[i];
                if(i != row.size() - 1){
                    stream<< ",";
                }
            }
            stream << "\n";
        }

        file.close();
        return tr("文件已保存: %1").arg(fileInfo.absoluteFilePath());
    } else {
        return tr("文件写入错误: %1").arg(fileInfo.absoluteFilePath());
    }

}
