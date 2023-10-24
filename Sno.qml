import QtQuick
import QtQuick.Controls

import QtCharts

import "common.js" as Common
import FileIO

import "./view"

Rectangle {
    property var arr_umd1: []
    property int umd1_x: 0
    property int umd1_min_y: 0

    /// 用于画chart
    readonly property int _interval: 100
    property var arr_flow_rt: []
    property int _start_time: 0
    property int flow_x: 0
    property int flow_min_y: 0

    property string _time_name: ""
    property var arr_data_header: ["测试ID", "实时流量", "检测器实时"]
    property var result_header: ["仪器编号", "测试日期", "室内/箱内温度/℃", "环境温度/℃", "环境湿度RH/%", "检测器温度/℃", "气袋编号", "气袋浓度/ppb", "测量均值差", "测试ID"]

    function save_to_file(diff) {
        var obj = root.sample_data
        var trace_umd1_temp = obj[Common.TRACE_UMD1_TEMP] / 100.0
        var ambient_temp = obj[Common.AMBIENT_TEMP] / 100.0
        var ambient_humi = obj[Common.AMBIENT_HUMI]
        var result_data = [appSettings.mac_code, Common.formatDate(
                               ), appSettings.indoor_temp, ambient_temp, ambient_humi, trace_umd1_temp, appSettings.puppet_num, appSettings.puppet_con, diff, appSettings.test_id]
        var res = myFile.saveToCsv(get_result_path(), result_header,
                                   [result_data])
        root.appendLog(res)

        var data_ = arr_flow_rt.map(
                    (element, index) => [appSettings.test_id, element, arr_umd1[index]])

        var res2 = myFile.saveToCsv(get_flow_rt_path(), arr_data_header, data_)
        root.appendLog(res2)
        appSettings.test_id += 1
    }

    function finish() {
        if (chart_timer.running) {
            showResult()
            console.log("chart  stop!!")
            chart_timer.stop()
            reset_data()
            _start_time = 0
        }
    }

    function get_result_prefix() {
        return "record_sno/" + appSettings.mac_code + "-" + _time_name
    }

    function get_result_path() {
        return get_result_prefix() + "/result.csv"
    }

    function get_flow_rt_path() {
        return get_result_prefix() + "/data.csv"
    }

    function showResult() {
        var success = _status === Common.STATUS_END_FINISH
        var msg = ""

        //        save_to_file(0)
        if (success) {
            // 测试完成
            var len = arr_umd1.length
            if (len > 501) {
                var lastElements = arr_umd1.slice(appSettings.umd_state1,
                                                  appSettings.umd_state2)
                var sum = lastElements.reduce(
                            (accumulator, currentValue) => accumulator + currentValue,
                            0)
                var av1 = sum / lastElements.length

                lastElements = arr_umd1.slice(appSettings.umd_state3,
                                              appSettings.umd_state4)
                sum = lastElements.reduce(
                            (accumulator, currentValue) => accumulator + currentValue,
                            0)
                var av2 = sum / lastElements.length
                var r = Math.abs(av1 - av2).toFixed(2)
                msg = "测试成功: 气袋浓度(" + appSettings.puppet_con + ") umd1均值差 = " + r + " (ppb)"
                save_to_file(r)
            } else {
                success = false
                msg = "帧数太少!"
            }
        } else {
            msg = Common.get_status_info(_status)
        }

        if (!success) {
            msg = "测试失败: " + msg + "! 请重试"
        }

        root.showToastAndLog(msg)
        result.text = msg
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
                         var obj = root.sample_data
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

        if (umd1_min_y < average) {
            umd1_min_y = average
        }

        if (umd1_min_y < umd1AxisY.min + 50) {
            umd1AxisY.min = Math.round(umd1_min_y) - 100
        }

        if (average > umd1AxisY.max - 50) {
            umd1AxisY.max = Math.ceil(average) + 100
        }

        lines_umd1.append(umd1_x, average)
    }

    function start() {
        result.text = ""
        lines_umd1.clear()
        chart.clear()
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

            Button {
                text: "数据分析"
                height: parent.height
                enabled: !root.in_helxa

                onClicked: {
                    data_dir_name = get_result_prefix()
                    pushSnoView()
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

    FileIO {
        id: myFile
        source: "test_file.txt"
        onError: console.log(msg)
    }

    Component.onCompleted: {
        var now = new Date()
        var year = now.getFullYear()
        var month = String(now.getMonth() + 1).padStart(2, '0')
        var day = String(now.getDate()).padStart(2, '0')
        var hours = String(now.getHours()).padStart(2, '0')
        var minutes = String(now.getMinutes()).padStart(2, '0')
        var seconds = String(now.getSeconds()).padStart(2, '0')
        _time_name = year + month + day + '-' + hours + minutes + seconds
    }
}
