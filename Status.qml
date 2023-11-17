import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "common.js" as Common

import "./view"

Rectangle {
    color: Qt.rgba(100, 100, 100, 100)
    width: parent.width
    height: 70

    property bool starting: false

    //    property var data
    function dataChanged(obj) {
        trace_umd1_temp.value = obj[Common.TRACE_UMD1_TEMP] / 100.0
        func_name.value = obj[Common.FUNC_NAME]
        func_status.value = _status
        ambient_temp.value = obj[Common.AMBIENT_TEMP] / 100.0
        ambient_humi.value = obj[Common.AMBIENT_HUMI]
        flow_rt.value = obj[Common.FLOW_RT] / 10.0
        trace_umd1.value = obj[Common.TRACE_UMD1]
        starting = !Common.is_helxa_finish(func_status.value)
        update_time.value = Common.formatDate2(new Date(obj["update_time"]))
    }

    Column {
        anchors.fill: parent

        Rectangle {
            height: 20
            width: parent.width

            Row {
                anchors.centerIn: parent
                spacing: 8
                MyLabel {
                    id: trace_umd1_temp
                    name: "检测器环境温度1"
                    value: "0"
                    unit: "°C"
                }

                MyLabel {
                    id: ambient_temp
                    name: "环境温度"
                    value: "0"
                    unit: "°C"
                }
                MyLabel {
                    id: ambient_humi
                    name: "环境湿度"
                    value: "0"
                    unit: "%"
                }

                MyLabel {
                    id: flow_rt
                    name: "实时采样流量"
                    value: "0"
                    unit: "mL/s"
                }

                MyLabel {
                    id: trace_umd1
                    name: "检测器1实时"
                    value: "0"
                    unit: ""
                }

                MyLabel {
                    id: func_name
                    name: "呼气功能指令"
                    value: ""
                    unit: ""
                }
            }
        }

        Rectangle {
            height: 20
            width: parent.width

            MyLabel {
                anchors.centerIn: parent
                id: update_time
                name: "更新时间"
                value: ""
                unit: ""
            }
        }

        Rectangle {
            height: 20
            width: parent.width

            MyLabel {
                anchors.centerIn: parent
                id: func_status
                name: "呼气功能状态"
                value: ""
                unit: ""
            }

            BusyIndicator {
                visible: starting
                anchors.right: func_status.left
                anchors.rightMargin: 4
                height: parent.height
            }
        }
    }
}
