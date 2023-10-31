import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QtCharts

import "common.js" as Common
import FileIO
import "./view"

Item {

    property string dir_name: data_dir_name
    // 测试结果
    property var arr_result: []
    // 测试数据
    property var arr_data: []
    // 测试id 列表
    property var arr_ids: []
    // 测试任务id, 是否显示列表
    property var arr_ids_enable: []

    // 缓存
    property var test_umd_av: []

    // result 中的气袋浓度
    property var result_obj: []
    property int umds: 710

    property var result_header: ["仪器编号", "测试日期", "室内/箱内温度/℃", "环境温度/℃", "环境湿度RH/%", "检测器温度/℃", "气袋编号", "气袋浓度/ppb", "测量均值差", "测试ID", "state1", "state2", "state3", "state4"]

    // 新的数据
    property var new_result: []

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
                font.pixelSize: 16
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

                    Action {
                        enabled: row_slide.visible
                        text: qsTr("隐藏帧间隔")
                        onTriggered: {
                            row_slide.visible = false
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: co
        width: window.width
        anchors {
            top: bar.bottom
            bottom: parent.bottom
        }

        spacing: 6
        Label {
            id: label
            text: "当前分析目录: " + dir_name
            Layout.alignment: Qt.AlignHCenter
        }

        Row {
            clip: true
            Layout.alignment: Qt.AlignHCenter
            visible: arr_ids.length > 0
            width: parent.width
            height: 28 // 固定高度，用于显示一行
            //                width: parent.width
            //            height: parent.width
            spacing: 6

            Repeater {
                model: arr_ids.length // 这里的10可以替换为你的数据数组的长度
                CheckBox {
                    required property int index
                    checked: arr_ids_enable[index]
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
                        refresh_xy()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            width: parent.width

            ChartView {
                width: (row_slide.visible ? parent.width - row_slide.width : parent.width)
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

            Item {
                id: row_slide
                visible: show_umd_state
                height: 60
                width: 200
                anchors {
                    rightMargin: 6
                    right: parent.right
                    verticalCenter: flow_chart.verticalCenter
                }
                z: 2

                onVisibleChanged: {

                    //                    console.log("visible changed...")
                    //                    rs1.setValues(appSettings.umd_state1,
                    //                                  appSettings.umd_state2)
                    //                    rs1.setValues(appSettings.umd_state3,
                    //                                  appSettings.umd_state4)
                }

                MySlide {
                    height: 36
                    id: rs1
                    anchors.left: parent.left
                    anchors.top: parent.top
                    from: 50
                    to: umds - 200
                    first.value: appSettings.umd_state1
                    second.value: appSettings.umd_state2
                    onValueChanged: {
                        refresh_label()
                    }
                }

                MySlide {
                    id: rs2
                    height: rs1.height
                    anchors.left: parent.left
                    anchors.top: rs1.bottom
                    from: 200
                    to: umds - 1
                    first.value: appSettings.umd_state3
                    second.value: appSettings.umd_state4
                    onValueChanged: {
                        refresh_label()
                    }
                }

                Button {
                    text: "保存"
                    anchors {
                        top: rs2.bottom
                        horizontalCenter: rs2.horizontalCenter
                    }

                    onClicked: {

                        var res = myFile.saveToCsv(dir_name + "/umd_avg.csv",
                                                   result_header, [new_result])
                        console.log("save = " + res)
                    }
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
        onError: msg => {
                     console.log(msg)
                     showToast(msg)
                 }
    }

    function is_only_one() {
        row_slide.visible = arr_ids_enable.filter((e, i) => e).length === 1
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

    function refresh_xy() {
        var dd = arr_result.filter((e, i) => arr_ids_enable[i]).map(
                    e => e[e.length - 1])

        //        console.log("dd = " + JSON.stringify(dd))
        var min_y_f = 1000000
        var max_y_f = 0
        var min_y_u = 1000000
        var max_y_u = 0

        arr_data.filter(e => dd.includes(e[0] + "")).forEach(e => {
                                                                 var f = parseFloat(
                                                                     e[1])
                                                                 var u = parseInt(
                                                                     e[2])
                                                                 if (min_y_f > f) {
                                                                     min_y_f = f
                                                                 }

                                                                 if (max_y_f < f) {
                                                                     max_y_f = f
                                                                 }

                                                                 if (min_y_u > u) {
                                                                     min_y_u = u
                                                                 }

                                                                 if (max_y_u < u) {
                                                                     max_y_u = u
                                                                 }
                                                             })
        valueAxisY.min = Math.round(min_y_f - Math.abs(min_y_f) / 10 - 1)
        valueAxisY.max = Math.ceil(max_y_f + Math.abs(max_y_f) / 10 + 1)
        umdAxisY.min = Math.round(min_y_u - Math.abs(min_y_u) / 10 - 1)
        umdAxisY.max = Math.ceil(max_y_u + Math.abs(max_y_u) / 10 + 1)

        //        console.log("refresh_xy : valueAxisY.min = " + valueAxisY.min
        //                    + " valueAxisY.max=" + valueAxisY.max + " umdAxisY.min="
        //                    + umdAxisY.min + " umdAxisY.max = " + umdAxisY.max)
    }

    function refresh_label() {
        var dd = test_umd_av.map((e, i) => result_obj[i] + "-" + e).filter(
                    (e, i) => arr_ids_enable[i])

        if (dd.length === 0) {
            pdd.text = ""
        } else {
            if (dd.length === 1) {
                var state1 = rs1.l_value
                var state2 = rs1.r_value
                var state3 = rs2.l_value
                var state4 = rs2.r_value
                var test_id = arr_ids.filter((e, i) => arr_ids_enable[i])[0]
                var pup_con = result_obj.filter((e, i) => arr_ids_enable[i])[0]
                var umd_tmp = parseFloat(arr_result.filter(
                                             (e, i) => arr_ids_enable[i])[0][5])

                var arr_umd = arr_data.filter(e => e[0] === test_id).map(
                            e => parseInt(e[2]))
                umds = arr_umd.length

                dd[0] = Common.umd_avg(state1, state2, state3, state4, arr_umd)
                //                console.log("pup_con = " + pup_con + " " + state1 + "," + state2
                //                            + "," + state3 + "," + state4 + " length = " + umds
                //                            + " id = " + test_id + " avg = " + dd[0])
                var fix = fix_umd(umd_tmp, dd[0])
                var fix2 = fix_umd2(fix)
                pdd.text = "气袋浓度-均值差: " + pup_con + "-" + fix + "|" + fix2
                new_result = arr_result.filter(
                            (e, i) => arr_ids_enable[i])[0].map(e => e)
                new_result[new_result.length - 2] = dd[0]
                new_result.push(state1)
                new_result.push(state2)
                new_result.push(state3)
                new_result.push(state4)
                //                console.log("new_result = " + JSON.stringify(new_result))
            } else {
                pdd.text = "气袋浓度-均值差: " + dd.join("/")
            }
        }

        is_only_one()
    }

    function refresh() {
        var test_ids = []
        umd_chart.removeAllSeries()
        flow_chart.removeAllSeries()
        arr_ids_enable.splice(0, arr_ids_enable.length)
        test_umd_av.splice(0, test_umd_av.length)
        for (var i = 0; i < arr_result.length; i++) {
            var v = arr_result[i].slice(-3)
            test_ids.push(v[2])
            umd_chart.createSeries(ChartView.SeriesTypeLine, v[2],
                                   umdAxisX, umdAxisY)
            flow_chart.createSeries(ChartView.SeriesTypeLine, v[2], valueAxisX,
                                    valueAxisY)
            test_umd_av.push(v[1])
            arr_ids_enable.push(false)
            result_obj.push(v[0])
        }

        if (arr_ids_enable.length > 0) {
            arr_ids_enable[0] = true
        }
        arr_ids = test_ids

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

        refresh_label()
        refresh_xy()
        refresh_visible()
    }

    /// 刷新chart 可见
    function refresh_visible() {
        arr_result.forEach((e, i) => {
                               var id = e[e.length - 1]
                               var u = umd_chart.series(id + "")
                               if (u) {
                                   u.visible = arr_ids_enable[i]
                               }

                               var f = flow_chart.series(id + "")
                               if (f) {
                                   f.visible = arr_ids_enable[i]
                               }
                           })
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

    Component.onDestruction: {
        console.log("sno data view onDestruction ...")
    }
}
