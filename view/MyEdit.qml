import QtQuick
import QtQuick.Controls

Row {
    property string name: ""
    property alias value: ed.text
    property alias edWidth: ed.width
    Text {
        text: name+": "
        anchors.verticalCenter: parent.verticalCenter
    }

    TextField {
        id: ed
        text: value
        height: parent.height - 2
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 14
    }
}
