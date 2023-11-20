import QtQuick
import QtQuick.Controls
import QtCharts

import "../common.js" as Common
import ".."

Rectangle {
    property var flow_datas: []
    /// 用于画chart
    readonly property int _interval: 100
    //    property var arr_flow_rt: []
    property int _start_time: 0
    property double prev_time: 0.0
    property int umd1_x: 0
    property int umd1_min_y: 8000
    property int umd1_max_y: 0
    property int av_flow_rt: 0

    function finish() {
        if (chart_timer.running) {
            txt.text = "测试成功"
            dialogText.text = getResultMsg("FENO50_MODE1")
            messageDialog.open()
            console.log("chart  stop!!")
            chart_timer.stop()
            reset_data()
            _start_time = 0
        }
    }

    function start() {
        set_success_text("数据分析中， 请稍候")

        av_flow_rt = 0
        flow_datas.splice(0, flow_datas.length)
        chart.clear()
        chart_timer.start()
    }

    function reset_data() {
        umd1_x = 0
        arr_flow_rt.splice(0, arr_flow_rt.length)
        arr_umd1.splice(0, arr_umd1.length)
    }

    function set_success_text(text) {
        txt.text = text
        txt.color = 'black'
    }

    function set_failed_text(text) {
        txt.text = text
        txt.color = 'red'
    }

    Timer {
        id: chart_timer
        repeat: true
        interval: _interval
        onTriggered: () => {
                         var obj = sample_data
                         // 结束
                         if (umd1_x > 10 && Common.is_helxa_finish(_status)) {
                             console.log(
                                 "测试结束 : " + Common.get_status_info(_status))
                             finish()
                             bar.visible = false
                             return
                         }
                         if (Common.is_helxa_analy(_status)) {
                             bar.indeterminate = false
                             bar.value += 1 / 600
                         }

                         addFlowRt(obj)
                     }
    }

    function addFlowRt(obj) {
        var flow_rt = obj[Common.FLOW_RT] / 10.0

        arr_flow_rt.push(flow_rt)

        var trace_umd1 = obj[Common.TRACE_UMD1]
        arr_umd1.push(trace_umd1)

        var nums = _interval / 100
        var len = Math.min(arr_umd1.length, nums)
        let lastElements = arr_umd1.slice(-len)
        let sum = lastElements.reduce(
                (accumulator, currentValue) => accumulator + currentValue, 0)
        let average = sum / len
        umd1_x += 1

        //        if (umd1_x > umdAxisX.max - 10) {
        //            umdAxisX.max += 10
        //        }
        if (umd1_min_y > average) {
            umd1_min_y = average
        }

        if (average > umd1_max_y) {
            umd1_max_y = average
        }

        umd1AxisY.min = Math.round(umd1_min_y - Math.abs(umd1_min_y) / 20 - 1)
        umd1AxisY.max = Math.ceil(umd1_max_y + Math.abs(umd1_max_y) / 20 + 1)

        chart.append(umd1_x, average)
    }

    Dialog {
        id: messageDialog

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: 250
        height: 250
        parent: Overlay.overlay
        modal: true

        property alias text: dialogText.text

        Item {
            anchors.fill: parent

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
                    onClicked: {
                        bus.sendMessage(Common.MESSAGE_PRINT_RD,
                                        dialogText.text + "\r\n")
                        messageDialog.close()
                        pop()
                    }
                }

                Button {
                    text: "返回"
                    onClicked: {
                        messageDialog.close()
                        pop()
                    }
                }
            }
        }
    }

    Column {
        anchors.fill: parent
        //        spacing: 6

        //        Status {
        //            id: my_satatus
        //            timeValue: false
        //        }
        Rectangle {
            id: r1
            height: 40
            width: parent.width
            anchors.topMargin: 6
            color: '#f0ffff'

            //            Button {
            //                text: "返回"
            //                anchors.verticalCenter: parent.verticalCenter
            //                //                anchors.left: parent.left
            //                anchors.leftMargin: 10
            //                onClicked: {
            //                    if (exhaleStarting) {
            //                        bus.sendMessage(Common.MESSAGE_STOP_EXHALE)
            //                    }
            //                    pop()
            //                }
            //            }
            Text {
                id: txt
                anchors.centerIn: parent
                text: ""
                font.pixelSize: 18
                font.bold: true
                color: 'black'
            }
        }

        ProgressBar {
            width: parent.width
            height: 40
            implicitHeight: 40
            indeterminate: true
            id: bar
            visible: true

            background: Rectangle {
                color: "lightgray"
            }
            contentItem: Rectangle {
                width: bar.value * parent.width
                height: parent.height
                color: "#d2ebeb"
            }
        }

        Row {
            width: parent.width
            height: parent.height - r1.height - 26

            Item {
                width: parent.width
                height: parent.height
                anchors.margins: 20

                Image {
                    id: smile
                    source: "/img/feno.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    width: 200
                }

                ChartView {
                    id: char_view
                    anchors {
                        left: smile.right
                        right: parent.right
                    }
                    height: parent.height

                    antialiasing: true
                    legend.visible: false

                    SplineSeries {
                        id: chart
                        axisX: umdAxisX
                        axisY: umd1AxisY
                    }

                    CategoryAxis {
                        id: umdAxisX
                        min: 0
                        max: 600
                        gridVisible: false
                        labelsPosition: CategoryAxis.AxisLabelsPositionOnValue

                        //                            tickCount: 10
                        //                            labelFormat: "%.0f"
                        CategoryRange {
                            label: "0"
                            endValue: 0
                        }
                        CategoryRange {
                            label: "10"
                            endValue: 100
                        }
                        CategoryRange {
                            label: "20"
                            endValue: 200
                        }
                        CategoryRange {
                            label: "30"
                            endValue: 300
                        }
                        CategoryRange {
                            label: "40"
                            endValue: 400
                        }
                        CategoryRange {
                            label: "50"
                            endValue: 500
                        }
                        CategoryRange {
                            label: "60"
                            endValue: 600
                        }
                    }

                    ValueAxis {
                        id: umd1AxisY
                        min: 80
                        max: 160
                        tickCount: 6
                        labelFormat: "%.0f"
                        //                        titleText: "UMD1 (pbb)"
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        start()
    }

    Component.onDestruction: {
        finish()
    }

    Connections {
        target: window
        function onExhaleStartingChanged() {
            if (whichView === 4) {
                console.log("AnalysisView onexhaleStartingChanged")
                if (exhaleStarting) {
                    start()
                } else {
                    finish()
                }
            }
        }
    }
}
