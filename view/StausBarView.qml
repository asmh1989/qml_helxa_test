import QtQuick

ElevationItem {
    width: parent.width
    height: 40

    elevation: 4
    Text {
        id: time
        text: ""
        font.pixelSize: 20
        anchors.centerIn: parent
    }

    Timer {
        id: t
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var hours = now.getHours().toString().padStart(2, '0')
            var minutes = now.getMinutes().toString().padStart(2, '0')

            var currentTime = hours + ':' + minutes
            time.text = currentTime
        }
    }

    Component.onCompleted: {
        t.start()
    }

    Component.onDestruction: {
        t.stop()
    }
}
