import QtQuick
import QtQuick.Effects

Item {
    id: elevationItem
    property int elevation: 0

    Rectangle {
        id: contentItem
        anchors.fill: parent
        color: Qt.rgba(220 / 255, 220 / 255, 220 / 255, 0.3) // 设置内容的背景颜色
    }

    // 添加阴影效果
    MultiEffect {
        source: contentItem
        anchors.fill: contentItem
        paddingRect: Qt.rect(20, 20, 40, 30)
    }

    // 根据elevation属性设置阴影的偏移和模糊程度
    onElevationChanged: {

    }
}
