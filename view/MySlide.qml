import QtQuick
import QtQuick.Controls

Row {
    property alias first: rs.first
    property alias second: rs.second
    property alias from: rs.from
    property alias to: rs.to
    property int l_value: 0
    property int r_value: 0

    signal valueChanged

    TextField {
        id: left
        width: 48
        //        text: first.value
        horizontalAlignment: Qt.AlignRight
        anchors.verticalCenter: parent.verticalCenter
        onTextChanged: {
            l_value = parseInt(text)
            valueChanged()
        }
    }

    RangeSlider {
        id: rs
        height: parent.height
        width: 100
        anchors.verticalCenter: parent.verticalCenter
        first {
            onMoved: {
                left.text = Math.ceil(first.value)
            }
        }
        second {
            onMoved: {
                right.text = Math.ceil(second.value)
            }
        }
    }

    TextField {
        id: right
        width: left.width
        //        text: second.value
        horizontalAlignment: Qt.AlignRight
        anchors.verticalCenter: parent.verticalCenter
        onTextChanged: {
            r_value = parseInt(text)
            valueChanged()
        }
    }

    function setValues(v1, v2) {
        console.log("setValues " + v1 + " ," + v2)
        rs.setValues(v1, v2)
    }

    Component.onCompleted: {
        left.text = rs.first.value
        right.text = rs.second.value
    }
}
