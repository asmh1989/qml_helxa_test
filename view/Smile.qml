import QtQuick

Item {
    id: parent
    width: 44
    property real flow: 0.0
    clip: true

    Rectangle {
        anchors.fill: parent
        border {
            color: 'gray'
            width: 1
        }
        radius: 1
        color: 'white'
    }

    Rectangle {
        height: parent.height * 0.4
        width: parent.width
        y: parent.height * 0.15
        color: '#0da7ad'
    }

    Image {
        id: img
        source: "/img/cry.png"
        fillMode: Image.Stretch
        width: parent.width - 4
        height: width
        anchors.margins: 2
        anchors.horizontalCenter: parent.horizontalCenter
        z: 2

        // 定义动画效果
        //        Behavior on width {
        //            NumberAnimation { duration: 200 }
        //        }

        //                Behavior on x {
        //                    NumberAnimation { duration: 100 }
        //                }
        //        Behavior on y {
        //            NumberAnimation {
        //                duration: 100
        //            }
        //        }
    }

    onWidthChanged: {
        refresh()
    }

    onHeightChanged: {
        refresh()
    }

    Component.onCompleted: {

        //        refresh()
    }

    function append(f) {
        flow = f
        refresh()
    }

    function refresh() {
        var step = parent.height / 100
        var new_y = (100 - (flow + 15)) * step - parent.width / 2
        var s_t = 15 * step - parent.width / 2
        var s_b = 55 * step - parent.width / 2
        if (new_y > s_t && new_y < s_b) {
            img.source = "/img/smile.png"
        } else {
            img.source = "/img/cry.png"
        }
        if (new_y < 0) {
            new_y = 0
        } else if (new_y > parent.height - parent.width) {
            new_y = parent.height - parent.width
        }

        img.y = new_y

        //        console.log("smiles new_y = " + new_y + " source :" + img.source
        //                    + " s_t,s_b = " + s_t + "," + s_b)
    }
}
