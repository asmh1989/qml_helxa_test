import QtQuick
import QtQuick.Controls

import QtCharts

import "common.js" as Common

Rectangle {
    property var arr_flow_rt: []
    property var arr_umd1: []
    property int _start_time: 0
    property int _interval: 100
    property int flow_x: 0
    property int umd1_x: 0
    property int umd1_min_y: 0
    property int flow_min_y: 0
    property string _status: ""
    function finish() {
        if(chart_timer.running){
            console.log("chart  stop!!");
            chart_timer.stop();
            reset_data()
            _start_time = 0
        }
    }

    function showResult() {
        var success = _status === Common.STATUS_END_FINISH
        var msg = ""
        if(success) {
            // 测试完成
            var len = arr_umd1.length;
            if (len > 501) {
                var lastElements = arr_umd1.slice(201,250);
                var sum = lastElements.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
                var av1 = sum / 50;

                lastElements = arr_umd1.slice(451,500);
                sum = lastElements.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
                var av2 = sum / 50;
                msg = "测试成功: umd1均值差 = " +Math.abs(av1 - av2).toFixed(2) + " (ppb)"
            } else {
                success = false;
                msg = "帧数太少!"
            }
        } else {
            msg = Common.get_status_info(_status)
        }

        if(!success) {
            msg = "测试失败: "+ msg + "! 请重试"
        }

        root.showToastAndLog(msg);
        result.text = msg;
    }

    function reset_data() {
        flow_x = 0
        umd1_x = 0
        arr_flow_rt.splice(0, arr_flow_rt.length);
        arr_umd1.splice(0, arr_umd1.length);
    }

    Timer {
        id: chart_timer
        repeat: true
        interval: _interval
        onTriggered: ()=>{
                         var obj = root.sample_data
                         var func_ack = obj[Common.FUNC_ACK];
                         _status = obj[Common.FUNC_STATUS];

                         // 未准备好
                         if(func_ack === 0 && flow_x === 0) {
                             return;
                         }
                         // 结束
                         if(flow_x > 10 && Common.is_helxa_finish(_status)) {
                             showResult();
                             finish();
                             return;
                         }


                         if (_start_time === 0) {
                             var update_time = new Date(obj[Common.UPDATE_TIME]).getTime();
                             _start_time = update_time;
                             reset_data()
                             return;
                         }

                         addFlowRt(obj)
                         addUmd1(obj)
                     }
    }

    function addFlowRt(obj) {
        var flow_rt = obj[Common.FLOW_RT] / 10.0
        if(Common.is_helxa_analy(_status)) {
            arr_flow_rt.splice(0, arr_flow_rt.length);
            return;
        }

        if(arr_flow_rt.length !== flow_x ){
            return;
        }

        arr_flow_rt.push(flow_rt)

        if (flow_rt > 55) {
            root.showToastAndLog("呼气流量过高 : " + flow_rt + " 请控制")
        }

        var nums = _interval / 100;
        var len = Math.min(arr_flow_rt.length, nums);
        let lastElements = arr_flow_rt.slice(-len);
        let sum = lastElements.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
        let average = sum / len;
        flow_x += 1;

        if(flow_x > valueAxisX.max -10 ){
            valueAxisX.max += 10
        }

        if(average > valueAxisY.max - 5 ){
            valueAxisY.max += 10
        }

        if (average < valueAxisY.min + 5) {
            valueAxisY.min -= 10
        }

        chart.append(flow_x, average);
    }


    function addUmd1(obj) {
        var trace_umd1 = obj[Common.TRACE_UMD1]
        arr_umd1.push(trace_umd1)

        var nums = _interval / 100;
        var len = Math.min(arr_umd1.length, nums);
        let lastElements = arr_umd1.slice(-len);
        let sum = lastElements.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
        let average = sum / len;
        umd1_x += 1;

        if(umd1_x > umdAxisX.max -50 ){
            umdAxisX.max += 50
        }

        if (umd1_min_y <average ) {
            umd1_min_y = average;
        }

        if ( umd1_min_y < umd1AxisY.min + 50 ) {
            umd1AxisY.min = Math.round(umd1_min_y) -100
        }

        if(average > umd1AxisY.max - 50) {
            umd1AxisY.max = Math.ceil(average) + 100
        }

        lines_umd1.append(umd1_x, average);

    }

    function start() {
        result.text =""
        lines_umd1.clear();
        chart.clear();
        chart_timer.start();
    }

    Item {
        anchors.fill: parent

        ChartView {
            width: parent.width
            height: parent.height / 2
            id: char_view
            //            backgroundColor: 'green'
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
            //            backgroundColor: 'blue'
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
            color:'red'
            id: result
            anchors.centerIn: parent
        }
    }

    Component.onCompleted: {
    }
}
