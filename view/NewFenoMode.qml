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
    property int flow_x: 0
    property int flow_min_y: 0
    property int av_flow_rt: 0

    function finish() {
        if (chart_timer.running) {
            txt.text = getResultMsg("FENO50_MODE1")
            console.log("chart  stop!!")
            chart_timer.stop()
            reset_data()
            _start_time = 0
            smile.append(0)
        }
    }

    function start() {
        set_success_text(Common.HELXA_TIPS.init)

        av_flow_rt = 0
        flow_datas.splice(0, flow_datas.length)
        chart.clear()
        chart_timer.start()
        status_timer.start()
    }

    function reset_data() {
        flow_x = 0
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
        id: status_timer
        repeat: true
        interval: 100
        onTriggered: () => {
                         if (!exhaleStarting) {
                             if (Common.is_helxa_failed(_status)) {
                                 set_failed_text(Common.HELXA_TIPS.failed)
                             } else {
                                 set_success_text(Common.HELXA_TIPS.init)
                             }

                             status_timer.stop()
                             return
                         }

                         var now = new Date().getTime()
                         var diff = now - prev_time
                         if (_status === Common.STATUS_FLOW1) {
                             console.log("准备开始吸气")
                             set_success_text(Common.HELXA_TIPS.ready)
                             prev_time = 0
                         } else if (_status === Common.STATUS_FLOW2) {
                             set_success_text(Common.HELXA_TIPS.start_inhale)
                             if (diff > 1000000) {
                                 console.log("已经开始开始吸气")
                                 prev_time = now
                             } else if (diff < 2500) {

                             } else {
                                 console.log("请开始呼气")
                                 set_failed_text(Common.HELXA_TIPS.start_exhale)
                             }
                         } else if (Common.is_exhale(_status)) {

                             if (diff > 3000) {
                                 prev_time = now
                             } else if (diff > 500) {
                                 if (av_flow_rt > 55) {
                                     set_failed_text(Common.HELXA_TIPS.ex_flow)
                                 } else if (av_flow_rt < 45) {
                                     set_failed_text(Common.HELXA_TIPS.low_flow)
                                 } else {
                                     set_success_text(Common.HELXA_TIPS.keep)
                                 }
                                 prev_time = now
                             }
                         } else if (Common.is_helxa_analy(_status)) {
                             set_success_text(Common.HELXA_TIPS.done)
                             status_timer.stop()
                         }
                     }
    }

    Timer {
        id: chart_timer
        repeat: true
        interval: _interval
        onTriggered: () => {
                         var obj = sample_data
                         var func_ack = obj[Common.FUNC_ACK]

                         // 未准备好
                         if (func_ack === 0 && flow_x === 0) {
                             return
                         }
                         // 结束
                         if (flow_x > 10 && Common.is_helxa_finish(_status)) {
                             console.log(
                                 "测试结束 : " + Common.get_status_info(_status))
                             finish()
                             return
                         }

                         if (_start_time === 0) {
                             var update_time = new Date(obj[Common.UPDATE_TIME]).getTime()
                             _start_time = update_time
                             reset_data()
                             return
                         }

                         addFlowRt(obj)
                     }
    }

    function addFlowRt(obj) {
        var flow_rt = obj[Common.FLOW_RT] / 10.0

        arr_flow_rt.push(flow_rt)

        var trace_umd1 = obj[Common.TRACE_UMD1]
        arr_umd1.push(trace_umd1)

        var len = Math.min(arr_flow_rt.length, appSettings.aver_num)
        let lastElements = arr_flow_rt.slice(-len)
        let sum = lastElements.reduce(
                (accumulator, currentValue) => accumulator + currentValue, 0)
        let average = sum / len

        av_flow_rt = average
        flow_x += 1

        if (Common.is_helxa_sample(_status)) {

            if (flow_x > xAxis.max) {
                xAxis.max += 10
            }

            if (appSettings.use_real_red_line) {
                chart.append(flow_x, Common.mapValue(average))
                smile.append(Common.mapValue(average))
            } else {
                chart.append(flow_x, Common.mapValue2(average))
                smile.append(Common.mapValue2(average))
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: 6

        Status {
            id: my_satatus
            timeValue: false
        }

        Rectangle {
            id: r1
            height: 40
            width: parent.width
            anchors.topMargin: 6
            color: '#f0ffff'
            Button {
                text: "返回"
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                onClicked: {
                    pop()
                }
            }

            Text {
                id: txt
                anchors.centerIn: parent
                text: Common.HELXA_TIPS.init
                font.pixelSize: 16
                font.bold: true
                color: 'black'
            }
        }

        Row {
            width: parent.width
            height: parent.height - r1.height - 6

            Item {
                width: parent.width
                height: parent.height

                Item {
                    anchors.fill: parent
                    anchors.margins: 10

                    Smile {
                        id: smile
                        y: 28
                        height: parent.height - 78
                    }

                    ChartView {
                        anchors {
                            left: smile.right
                            right: parent.right
                        }
                        height: parent.height

                        id: char_view
                        antialiasing: true
                        legend.visible: false

                        SplineSeries {
                            color: '#0da7ad'
                            XYPoint {
                                x: 0
                                y: 30
                            }
                            XYPoint {
                                x: 200
                                y: 30
                            }
                            axisX: xAxis
                            axisY: yAxis
                        }

                        SplineSeries {
                            color: '#0da7ad'
                            XYPoint {
                                x: 0
                                y: 70
                            }
                            XYPoint {
                                x: 120
                                y: 70
                            }
                            axisX: xAxis
                            axisY: yAxis
                        }

                        LineSeries {
                            id: chart
                            axisX: xAxis
                            axisY: yAxis
                            color: 'blue'
                        }

                        ValueAxis {
                            id: xAxis
                            min: 0
                            max: 12 * 1000 / _interval
                            tickCount: 11
                            labelFormat: "%.0f"
                        }

                        CategoryAxis {
                            id: yAxis
                            min: -15 // 最小值，避免出现0值
                            max: 85 // 最大值
                            labelFormat: "%.0f"
                            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
                            titleText: "FLOW_RT (ml/s)"

                            CategoryRange {
                                label: ""
                                endValue: -15
                            }
                            CategoryRange {
                                label: "0"
                                endValue: 0
                            }
                            //                            CategoryRange {
                            //                                label: "30"
                            //                                endValue: 15
                            //                            }
                            CategoryRange {
                                label: "45"
                                endValue: 30
                            }

                            //                            CategoryRange {
                            //                                label: "47"
                            //                                endValue: 40
                            //                            }
                            //                            CategoryRange {
                            //                                label: "50"
                            //                                endValue: 50
                            //                            }
                            //                            CategoryRange {
                            //                                label: "53"
                            //                                endValue: 60
                            //                            }
                            CategoryRange {
                                label: "55"
                                endValue: 70
                            }

                            //                            CategoryRange {
                            //                                label: "70"
                            //                                endValue: 85
                            //                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {

    }

    Component.onDestruction: {
        reset_data()
        forceExhaleStop = !forceExhaleStop
    }

    Connections {
        target: window
        function onExhaleStartingChanged() {
            if (whichView === 3) {
                console.log("newFnoView onexhaleStartingChanged")
                if (exhaleStarting) {
                    start()
                } else {
                    finish()
                }
            }
        }
    }
}
