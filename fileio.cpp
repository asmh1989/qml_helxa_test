#include "fileio.h"
#include <QFile>
#include <QTextStream>

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
