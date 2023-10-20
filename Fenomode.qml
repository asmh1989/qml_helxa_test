import QtQuick
import QtQuick.Controls
import "common.js" as Common

import QtCharts
Rectangle {
    property var flow_datas: []
    /// 用于画chart
    readonly property int _interval: 100
    property var arr_flow_rt: []
    property int _start_time: 0
    property int flow_x: 0
    property int flow_min_y: 0

    property bool show_result_chart: false


    function finish() {
        if(chart_timer.running){
            console.log("chart  stop!!");
            chart_timer.stop();
            reset_data()
            _start_time = 0
            show_result_chart = true
        }
    }

    function start() {
        show_result_chart = false
        flow_datas.splice(0, flow_datas.length);
        chart.clear();
        chart2.clear();
        chart_timer.start();
    }

    function reset_data() {
        flow_x = 0
        arr_flow_rt.splice(0, arr_flow_rt.length);
    }

    Timer {
        id: chart_timer
        repeat: true
        interval: _interval
        onTriggered: ()=>{
                         var obj = root.sample_data
                         var func_ack = obj[Common.FUNC_ACK];

                         // 未准备好
                         if(func_ack === 0 && flow_x === 0) {
                             return;
                         }
                         // 结束
                         if(flow_x > 10 && Common.is_helxa_finish(_status)) {
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
            //            root.showToastAndLog("呼气流量过高 : " + flow_rt + " 请控制")
        }

        var len = Math.min(arr_flow_rt.length, aver_num);
        let lastElements = arr_flow_rt.slice(-len);
        let sum = lastElements.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
        let average = sum / len;

        flow_x +=  1;

//        flow_datas.push({
//                            "status": _status,
//                            "x": flow_x,
//                            "y": average
//                        })

        chart.append(flow_x, Common.mapValue(average));
        if(average > 0) {
            chart2.append(flow_x, Common.mapValue(average));
        }
    }


    Column {
        anchors.fill: parent
        spacing: 6

        Row {
            id: r1
            height: 40
            width: parent.width
            anchors.topMargin: 6

            Text {
                id: progress
                text: ""
                font.pixelSize: 14
                color: 'red'
            }
        }


        Row {
            width: parent.width
            height: parent.height - r1.height - 6


            ChartView {
                width: show_result_chart ? parent.width/2 : parent.width
                height: parent.height
                id: char_view
                antialiasing: true
                legend.visible: false

                SplineSeries {
                    color: 'red'
                    XYPoint { x: 0; y: 30 }
                    XYPoint { x: 120; y: 30 }
                    axisX: xAxis
                    axisY: yAxis
                }

                SplineSeries {
                    color: 'red'
                    XYPoint { x: 0; y: 70 }
                    XYPoint { x: 120; y: 70 }
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
                    min: -15  // 最小值，避免出现0值
                    max: 85   // 最大值
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
                    max:  12 * 1000 / _interval
                    tickCount: 11
                    labelFormat: "%.0f"
                }

                ValueAxis {
                    id: yAxis2
                    min: 30
                    max: 70
                    tickCount: 10
                    labelFormat: "%.0f"
                }

            }
        }

    }

}
