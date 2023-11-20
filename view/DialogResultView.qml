import QtQuick
import QtQuick.Controls

Dialog {
    id: messageDialog

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: 300
    height: 300
    parent: Overlay.overlay
    modal: true

    property alias text: dialogText.text

    Rectangle {
        anchors.fill: parent

        //        border {
        //            color: "blue"
        //            width: 1
        //        }
        //        radius: 4
        Text {
            id: dialogText
            text: qsTr("text")
            font.pixelSize: 24
            anchors.centerIn: parent
        }

        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            spacing: 20

            Button {
                text: "打印"
            }

            Button {
                text: "返回"
                onClicked: {
                    messageDialog.close()
                    if (exhaleStarting) {
                        bus.sendMessage(Common.MESSAGE_STOP_EXHALE)
                    }
                    pop()
                }
            }
        }
    }
}
