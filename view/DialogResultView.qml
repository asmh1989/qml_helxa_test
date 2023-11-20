import QtQuick
import QtQuick.Controls

Dialog {
    id: messageDialog

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: 400
    height: 300
    parent: Overlay.overlay
    modal: true

    title: "测试成功"

    closePolicy: Popup.NoAutoClose
    property alias text: dialogText.text

    footer: DialogButtonBox {
        Button {
            text: "打印"
            font.pixelSize: 20
            onClicked: {
                messageDialog.accept()
            }
        }
        Button {
            text: "返回"
            font.pixelSize: 20
            onClicked: {
                messageDialog.reject()
            }
        }
    }

    Item {
        anchors.fill: parent
        Text {
            id: dialogText
            text: qsTr("text")
            font.pixelSize: 24
            anchors.centerIn: parent
        }
    }
}
