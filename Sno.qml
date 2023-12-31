import QtQuick
import QtQuick.Controls

import QtCharts

import "common.js" as Common

import "./view"

Rectangle {
    property int umd1_x: 0
    property int umd1_min_y: 0
    property int umd1_max_y: 0

    /// 用于画chart
    readonly property int _interval: 100
    property int _start_time: 0
    property int flow_x: 0
    property int flow_min_y: 0

    function finish() {
        if (chart_timer.running) {
            result.text = getResultMsg("Sno")
            console.log("chart  stop!!")
            chart_timer.stop()
            reset_data()
            _start_time = 0
        }
    }

    function reset_data() {
        flow_x = 0
        umd1_x = 0
        arr_flow_rt.splice(0, arr_flow_rt.length)
        arr_umd1.splice(0, arr_umd1.length)
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
                         addUmd1(obj)
                     }
    }

    function addFlowRt(obj) {
        var flow_rt = obj[Common.FLOW_RT] / 10.0

        // 从头加到尾
        //        if(Common.is_helxa_analy(_status)) {
        //            arr_flow_rt.splice(0, arr_flow_rt.length);
        //            return;
        //        }
        arr_flow_rt.push(flow_rt)

        var nums = _interval / 100
        var len = Math.min(arr_flow_rt.length, nums)
        let lastElements = arr_flow_rt.slice(-len)
        let sum = lastElements.reduce(
                (accumulator, currentValue) => accumulator + currentValue, 0)
        let average = sum / len
        flow_x += 1

        if (flow_x > valueAxisX.max - 10) {
            valueAxisX.max += 10
        }

        if (average > valueAxisY.max - 5) {
            valueAxisY.max += 10
        }

        if (average < valueAxisY.min + 5) {
            valueAxisY.min -= 10
        }

        chart.append(flow_x, average)
    }

    function addUmd1(obj) {
        var trace_umd1 = obj[Common.TRACE_UMD1]
        arr_umd1.push(trace_umd1)

        var nums = _interval / 100
        var len = Math.min(arr_umd1.length, nums)
        let lastElements = arr_umd1.slice(-len)
        let sum = lastElements.reduce(
                (accumulator, currentValue) => accumulator + currentValue, 0)
        let average = sum / len
        umd1_x += 1

        if (umd1_x > umdAxisX.max - 10) {
            umdAxisX.max += 10
        }

        if (umd1_min_y > average) {
            umd1_min_y = average
        }

        if (average > umd1_max_y) {
            umd1_max_y = average
        }

        umd1AxisY.min = Math.round(umd1_min_y - Math.abs(umd1_min_y) / 10 - 1)
        umd1AxisY.max = Math.ceil(umd1_max_y + Math.abs(umd1_max_y) / 10 + 1)

        lines_umd1.append(umd1_x, average)
    }

    function start() {
        result.text = ""
        lines_umd1.clear()
        chart.clear()
        umd1_min_y = 100000
        umd1_max_y = 0
        chart_timer.start()
    }

    Item {
        anchors.fill: parent

        Row {
            height: 28
            //            width:400
            anchors.horizontalCenter: parent.horizontalCenter
            z: 2
            spacing: 6

            MyEdit {
                id: ed1
                name: "室内/箱内温度值"
                value: appSettings.indoor_temp
                height: parent.height
                edWidth: 48
                onValueChanged: {
                    appSettings.indoor_temp = value
                }
            }
            MyEdit {
                id: ed2
                name: "气袋编号"
                value: appSettings.puppet_num
                height: parent.height
                edWidth: 72
                onValueChanged: {
                    appSettings.puppet_num = value
                }
            }
            MyEdit {
                name: "气袋浓度"
                value: appSettings.puppet_con
                height: parent.height
                edWidth: 48
                onValueChanged: {
                    appSettings.puppet_con = value
                }
            }
            MyEdit {
                name: "仪器码"
                value: appSettings.mac_code
                height: parent.height
                edWidth: 48
                onValueChanged: {
                    appSettings.mac_code = value
                }
            }
        }

        ChartView {
            width: parent.width
            height: parent.height / 2
            id: char_view
            antialiasing: true
            legend.visible: false

            LineSeries {
                id: chart
                axisX: valueAxisX
                axisY: valueAxisY
            }

            ValueAxis {
                id: valueAxisX
                min: 0
                max: 100
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

        ChartView {
            anchors.top: char_view.bottom
            width: parent.width
            height: parent.height / 2
            id: chart_umd1
            antialiasing: true
            legend.visible: false

            LineSeries {
                id: lines_umd1
                axisX: umdAxisX
                axisY: umd1AxisY
            }

            ValueAxis {
                id: umdAxisX
                min: 0
                max: 100
                tickCount: 10
                labelFormat: "%.0f"
            }

            ValueAxis {
                id: umd1AxisY
                min: -10
                max: 60
                tickCount: 6
                labelFormat: "%.0f"
                titleText: "UMD1 (pbb)"
            }
        }

        Text {
            text: ""
            color: 'red'
            id: result
            anchors.centerIn: parent
        }
    }

    Connections {
        target: window
        function onExhaleStartingChanged() {
            if (whichView === 0 && header.is_sno()) {
                console.log("Sno onexhaleStartingChanged")
                if (exhaleStarting) {
                    start()
                } else {
                    finish()
                }
            }
        }
    }
}
