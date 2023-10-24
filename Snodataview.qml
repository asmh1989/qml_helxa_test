import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QtCharts

import "common.js" as Common
import FileIO

Item {

    property string dir_name: data_dir_name
    property var arr_result: []
    property var arr_data: []
    property var arr_ids: []
    property var arr_ids_enable: []
    property var test_umd_av: []

    Action {
        id: navigateBackAction
        icon.source: "/img/back.png"
        onTriggered: {
            pop()
        }
    }

    Action {
        id: optionsMenuAction
        icon.source: "/img/menu.png"
        onTriggered: optionsMenu.open()
    }

    ToolBar {
        id: bar
        width: parent.width
        RowLayout {
            spacing: 20
            anchors.fill: parent

            ToolButton {
                action: navigateBackAction
                visible: true
            }

            Label {
                id: titleLabel
                text: "离线数据分析"
                font.pixelSize: 20
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                action: optionsMenuAction

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight

                    Action {
                        text: qsTr("导入数据")
                        onTriggered: {
                            fileDialog.open()
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        width: window.width
        anchors {
            top: bar.bottom
            bottom: parent.bottom
        }

        spacing: 6

        Label {
            text: "当前分析目录: " + dir_name
            Layout.alignment: Qt.AlignHCenter
        }

        Row {
            visible: arr_ids.length > 0
            width: parent.width
            Layout.alignment: Qt.AlignHCenter
            height: 30
            spacing: 6

            Repeater {
                model: arr_ids.length // 这里的10可以替换为你的数据数组的长度
                CheckBox {
                    required property int index
                    checked: true
                    text: arr_ids[index]
                    onClicked: {
                        var u = umd_chart.series(arr_ids[index] + "")
                        if (u) {
                            u.visible = !u.visible
                        }

                        var f = flow_chart.series(arr_ids[index] + "")
                        if (f) {
                            f.visible = !f.visible
                        }
                        arr_ids_enable[index] = !arr_ids_enable[index]

                        refresh_label()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            width: parent.width
            //            color: 'green'
            ChartView {
                width: parent.width
                height: parent.height / 2
                id: flow_chart
                antialiasing: true
                legend {
                    alignment: Qt.AlignRight
                }

                ValueAxis {
                    id: valueAxisX
                    min: 0
                    max: 720
                    tickCount: 10
                    labelFormat: "%.0f"
                }

                ValueAxis {
                    id: valueAxisY
                    min: -10
                    max: 60
                    tickCount: 6
                    labelFormat: "%.0f"
                    titleText: "FLOW_RT (ml/s)"
                }
            }

            Label {
                id: pdd
                color: 'red'
                anchors.centerIn: parent
            }

            ChartView {
                anchors.top: flow_chart.bottom
                width: parent.width
                height: parent.height / 2
                id: umd_chart
                antialiasing: true
                legend {
                    alignment: Qt.AlignRight
                }

                ValueAxis {
                    id: umdAxisX
                    min: 0
                    max: 720
                    tickCount: 10
                    labelFormat: "%.0f"
                }

                ValueAxis {
                    id: umdAxisY
                    min: -10
                    max: 60
                    tickCount: 6
                    labelFormat: "%.0f"
                    titleText: "UMD1 (pbb)"
                }
            }
        }
    }

    FileIO {
        id: myFile
        onError: {
            console.log(msg)
            showToast(msg)
        }
    }

    FileDialog {
        id: fileDialog
        title: "请选择离线测试数据文件result.csv"
        nameFilters: ["csv files (result.csv)"]
        onAccepted: {
            // 用户选择了文件
            console.log("Selected file:", fileDialog.selectedFile)
            dir_name = myFile.selectFile(fileDialog.selectedFile)
            load_data()
            if (arr_ids.length > 0) {
                showToast("载入成功: " + dir_name)
            }
        }

        onRejected: {
            // 用户取消选择文件
            console.log("File selection canceled")
        }
    }

    function refresh_label() {
        var dd = test_umd_av.filter((e, i) => arr_ids_enable[i]).join("/")

        pdd.text = "均值差: " + dd
    }

    function refresh() {
        var test_ids = []
        umd_chart.removeAllSeries()
        flow_chart.removeAllSeries()
        arr_ids_enable.splice(0, arr_ids_enable.length)
        test_umd_av.splice(0, test_umd_av.length)
        for (var i = 0; i < arr_result.length; i++) {
            var v = arr_result[i].slice(-2)
            test_ids.push(v[1])
            umd_chart.createSeries(ChartView.SeriesTypeLine, v[1],
                                   umdAxisX, umdAxisY)
            flow_chart.createSeries(ChartView.SeriesTypeLine, v[1], valueAxisX,
                                    valueAxisY)
            test_umd_av.push(v[0])
            arr_ids_enable.push(true)
        }

        arr_ids = test_ids

        refresh_label()

        var pre_id = 0
        var x = 0
        for (var j = 0; j < arr_data.length; j++) {
            var d = arr_data[j]
            var id = d[0]
            var flow = parseFloat(d[1])
            var umd = parseInt(d[2])

            if (pre_id !== id) {
                x = 0
                pre_id = id
            }

            var f = flow_chart.series(id)
            if (!f) {
                continue
            }

            f.append(x, flow)
            var u = umd_chart.series(id)
            u.append(x, umd)

            if (umd > umdAxisY.max - 10) {
                umdAxisY.max = umd + 10
            }

            if (umd < umdAxisY.min + 10) {
                umdAxisY.min = umd - 10
            }
            x += 1
        }
    }

    function load_data() {
        myFile.readCsv(dir_name)
        console.log(myFile.data.length + "/" + myFile.result.length)
        arr_data = myFile.data
        arr_result = myFile.result
        refresh()
    }

    Component.onCompleted: {
        load_data()
    }
}
