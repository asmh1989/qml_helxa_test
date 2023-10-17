import QtQuick
import QtQuick.Controls


Rectangle{
    color:Qt.rgba(100,100, 100, 100)
    height: 32
    width: parent.width

    property bool is_open: false
    Row {
        spacing: 6
        height: parent.height
        anchors.centerIn: parent

        TextField {
            text: "ws://192.168.2.184:8080"
            height: parent.height
            width: 188
            font.pixelSize: 14
            placeholderText: qsTr("URL")
        }


        Button {
            height: parent.height
            text: is_open ? "断开": "连接"
            onClicked: {
                root.start_websocket(!is_open)
            }
        }

        Button {
            height: parent.height
            text: "刷新"
            onClicked: {
                root.refresh();
            }
        }
        ComboBox {
            id: cb
            height: parent.height
            width: 192
            currentIndex: 7
            model: [
                "NONE",
                "FENO50_TRAIN1",
                "FENO50_TRAIN2",
                "FENO50_MODE1",
                "FENO50_MODE2",
                "FENO200_MODE1",
                "FENO200_MODE2",
                "SNO",
                "NNO_MODE1",
                "NNO_MODE2",
                "ECO",
                "SCO",
                "CLEAN",
            ]

        }


        Button {
            height: parent.height
            text: "开始测试"
            onClicked: {
                root.start_helxa_test(cb.currentText);
            }
        }

        Button {
            height: parent.height
            text: "手动停止"
            onClicked: {
                root.stop_helxa_test();
            }
        }

    }
}

