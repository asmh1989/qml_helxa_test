import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "common.js" as Common

Rectangle{
    color:Qt.rgba(100,100, 100, 100)
    width: parent.width
    height: 70

    property bool starting: false
    //    property var data
    anchors.margins: 4

    function dataChanged(obj) {
        trace_umd1_temp.value = obj[Common.TRACE_UMD1_TEMP] / 100.0
        func_name.value = obj[Common.FUNC_NAME]
        func_status.value = obj[Common.FUNC_STATUS]
        ambient_temp.value = obj[Common.AMBIENT_TEMP] / 100.0
        flow_rt.value = obj[Common.FLOW_RT] / 10.0
        trace_umd1.value = obj[Common.TRACE_UMD1]
        starting = !Common.is_helxa_finish(func_status.value)
        update_time.value = obj["update_time"]
    }

    Column  {
        anchors.fill: parent

        Rectangle {
            height: 20
            width: parent.width

            Row {
                anchors.centerIn: parent
                spacing: 8
                Mylabel {
                    id: trace_umd1_temp
                    name:"检测器环境温度1"
                    value:"0"
                    unit: "°C"
                }

                Mylabel {
                    id: ambient_temp
                    name:"环境温度值"
                    value:"0"
                    unit: "°C"
                }

                Mylabel {
                    id: flow_rt
                    name:"实时采样流量值"
                    value:"0"
                    unit: "mL/s"
                }

                Mylabel {
                    id: trace_umd1
                    name:"检测器1实时值"
                    value:"0"
                    unit: "ppb"
                }

                Mylabel {
                    id: func_name
                    name:"呼气功能指令"
                    value:""
                    unit: ""
                }


            }

        }

        Rectangle {
            height: 20
            width: parent.width

            Mylabel {
                anchors.centerIn: parent
                id: update_time
                name:"更新时间"
                value:""
                unit: ""
            }
        }

        Rectangle {
            height: 30
            width: parent.width
            anchors.margins: 4
            Row {
                anchors.centerIn: parent
                spacing: 4

                BusyIndicator {
                        visible: starting
                }

                Mylabel {
                    id: func_status
                    name:"呼气功能状态"
                    value:""
                    unit: ""
                }
            }
        }

    }
}
