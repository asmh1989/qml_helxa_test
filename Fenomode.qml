import QtQuick
import QtQuick.Controls
import QtCharts

import "common.js" as Common
import "./view"

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

    property bool show_result_chart: false

    function finish() {
        if (chart_timer.running) {
            txt.text = getResultMsg("FENO50_MODE1")
            console.log("chart  stop!!")
            chart_timer.stop()
            reset_data()
            _start_time = 0
            show_result_chart = true
            bar.visible = false
            smile.append(0)
        }
    }

    function start() {
        if (appSettings.use_anim_ball) {
            ball.reset()
        }
        set_success_text(Common.HELXA_TIPS.init)

        show_result_chart = false
        av_flow_rt = 0
        flow_datas.splice(0, flow_datas.length)
        chart.clear()
        chart2.clear()
        chart_timer.start()
        status_timer.start()
        bar.visible = true
        appendLog("灵敏度 = " + appSettings.aver_num + " 45-55 = " + appSettings.use_real_red_line)
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
                         if (!root.in_helxa) {
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
                             bar.indeterminate = true
                         } else if (_status === Common.STATUS_FLOW2) {
                             set_success_text(Common.HELXA_TIPS.start_inhale)
                             bar.indeterminate = false
                             if (diff > 1000000) {
                                 root.appendLog("已经开始开始吸气")
                                 prev_time = now
                             } else if (diff < 2500) {
                                 bar.value = diff / 2500
                                 if (appSettings.use_anim_ball) {
                                     ball.append_scale(300 / 2500)
                                 }
                             } else {
                                 root.appendLog("请开始呼气")
                                 set_failed_text(Common.HELXA_TIPS.start_exhale)
                                 bar.value = 0
                             }
                         } else if (Common.is_exhale(_status)) {
                             if (!bar.indeterminate) {
                                 bar.value += 1 / 30
                             }

                             if (diff > 3000) {
                                 prev_time = now
                             } else if (diff > 500) {
                                 bar.indeterminate = false
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
                             bar.indeterminate = true
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
                             root.appendLog(
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

        //        if (Common.is_helxa_analy(_status)) {
        //            arr_flow_rt.splice(0, arr_flow_rt.length)
        //            return
        //        }
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

            if (average > 0) {
                ball.append(average)
            }
            if (appSettings.use_real_red_line) {
                chart.append(flow_x, Common.mapValue(average))
                smile.append(Common.mapValue(average))
            } else {
                chart.append(flow_x, Common.mapValue2(average))
                smile.append(Common.mapValue2(average))
            }

            if (average > 0) {
                chart2.append(flow_x, flow_rt)
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: 6

        Rectangle {
            id: r1
            height: 40
            width: parent.width
            anchors.topMargin: 6
            color: '#f0ffff'

            Text {
                id: txt
                anchors.centerIn: parent
                text: Common.HELXA_TIPS.init
                font.pixelSize: 16
                font.bold: true
                color: 'black'
            }

            ProgressBar {
                width: parent.width
                height: 6
                indeterminate: true
                id: bar
                visible: false
            }
            ComboBox {
                id: cb
                currentIndex: appSettings.aver_num - 1
                height: parent.height * 2 / 3
                anchors.verticalCenter: parent.verticalCenter
                displayText: "灵敏度:" + currentText
                model: [1, 2, 3, 4, 5]
                onCurrentIndexChanged: {
                    appSettings.aver_num = currentIndex + 1
                }
            }

            CheckBox {
                id: cb2
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: appSettings.use_real_red_line
                text: "45-55"
                onCheckedChanged: {
                    appSettings.use_real_red_line = checked
                }
            }

            CheckBox {
                anchors.right: cb2.left
                anchors.verticalCenter: parent.verticalCenter
                checked: appSettings.use_anim_ball
                text: "ball"
                onCheckedChanged: {
                    appSettings.use_anim_ball = checked
                }
            }
        }

        Row {
            width: parent.width
            height: parent.height - r1.height - 6

            Item {
                width: show_result_chart ? parent.width / 2 : parent.width
                height: parent.height

                Ball {
                    id: ball
                    anchors.fill: parent
                    visible: appSettings.use_anim_ball
                }

                Item {
                    anchors.fill: parent
                    visible: !appSettings.use_anim_ball
                    anchors.margins: 10

                    Smile {
                        id: smile
                        height: parent.height
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
                            color: 'red'
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
                            color: 'red'
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
                                label: "-20"
                                endValue: -15
                            }
                            CategoryRange {
                                label: "0"
                                endValue: 0
                            }
                            CategoryRange {
                                label: "30"
                                endValue: 15
                            }
                            CategoryRange {
                                label: "45"
                                endValue: 30
                            }
                            CategoryRange {
                                label: "47"
                                endValue: 40
                            }
                            CategoryRange {
                                label: "50"
                                endValue: 50
                            }
                            CategoryRange {
                                label: "53"
                                endValue: 60
                            }

                            CategoryRange {
                                label: "55"
                                endValue: 70
                            }

                            CategoryRange {
                                label: "70"
                                endValue: 85
                            }
                        }
                    }
                }
            }

            ChartView {
                width: parent.width / 2
                height: parent.height
                id: char_view2
                antialiasing: true
                legend.visible: false

                visible: show_result_chart

                LineSeries {
                    id: chart2
                    axisX: xAxis2
                    axisY: yAxis2
                    color: 'blue'
                }

                ValueAxis {
                    id: xAxis2
                    min: 0
                    max: 12 * 1000 / _interval
                    tickCount: 11
                    labelFormat: "%.0f"
                }

                ValueAxis {
                    id: yAxis2
                    min: 20
                    max: 80
                    tickCount: 10
                    labelFormat: "%.0f"
                }
            }
        }
    }
}
