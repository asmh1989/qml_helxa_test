import QtQuick
import QtQuick.Window
import QtQuick.Controls

import "common.js" as Common
import Qt.labs.settings 1.0

ApplicationWindow {
    id: window
    width: dp(860)
    height: dp(680)
    minimumWidth: dp(760)
    //    minimumHeight: dp(600)
    visible: true
    title: qsTr("em-exhale")
    x: appSettings.sceen_x
    y: appSettings.sceen_y

    property bool is_open: false

    property real dpScale: 1.5
    readonly property real dpi: Math.max(
                                    Screen.pixelDensity * 25.4 / 160 * dpScale,
                                    1)

    property string data_dir_name: ""

    property string _time_name: ""
    property var arr_data_header: ["测试ID", "实时流量", "检测器实时"]
    property var result_header: ["仪器编号", "测试日期", "室内/箱内温度/℃", "环境温度/℃", "环境湿度RH/%", "检测器温度/℃", "检测类型", "修正测量均值差", "测量值", "气袋编号", "气袋浓度/ppb", "测量均值差", "测试ID"]
    property var arr_flow_rt: []
    property var arr_umd1: []

    property string _status: ""
    property var sample_data

    function get_result_prefix() {
        return "record_sno/" + appSettings.mac_code + "-" + _time_name
    }

    function get_result_path() {
        return get_result_prefix() + "/result.csv"
    }

    function get_flow_rt_path() {
        return get_result_prefix() + "/data.csv"
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

    function dp(v) {
        return v * dpi
    }

    function fix_umd(trace_umd1_temp, umd1) {
        var x = trace_umd1_temp - appSettings.umd_standard_temp
        var fix_xs = appSettings.standard_arg1 * x * x * x + appSettings.standard_arg2 * x
                * x + appSettings.standard_arg3 * x + appSettings.standard_arg4

        return (fix_xs * umd1).toFixed(2)
    }

    function fix_umd2(umd1) {
        return (umd1 / appSettings.umd_standard).toFixed(2)
    }

    ToastManager {
        id: toast
    }

    Component.onDestruction: {
        appSettings.sceen_x = window.x
        appSettings.sceen_y = window.y
    }

    Rectangle {
        anchors.fill: parent
        color: '#F3F9FF'

        StackView {
            id: stack
            initialItem: mainView
            anchors.fill: parent

            //            pushEnter: Transition {
            //                PropertyAnimation {
            //                    property: "y"
            //                    from: window.height
            //                    to: 0
            //                    duration: 200
            //                }
            //            }
            //            popExit: Transition {
            //                PropertyAnimation {
            //                    property: "y"
            //                    from: 0
            //                    to: window.height
            //                    duration: 200
            //                }
            //            }
            Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                }
            }
        }

        Component {
            id: mainView

            Rootview {}
        }

        Component {
            id: snoview

            Snodataview {
                id: sno_data_view
            }
        }
    }

    function pushSnoView() {
        stack.push(snoview)
    }

    function pop() {
        stack.pop()
    }

    function showToast(msg) {
        toast.show(msg, 3000)
    }

    function setTimeout(func, interval, ...params) {
        return setTimeoutComponent.createObject(window, {
                                                    "func": func,
                                                    "interval": interval,
                                                    "params": params
                                                })
    }

    function clearTimeout(timerObj) {
        timerObj.stop()
        timerObj.destroy()
    }

    Component {
        id: setTimeoutComponent
        Timer {
            property var func
            property var params
            running: true
            repeat: false
            onTriggered: {
                func(...params)
                destroy()
            }
        }
    }

    Settings {
        id: appSettings
        fileName: "./config.txt"
        property string url: "ws://192.168.2.33:8080"
        property int umd_state1: 201
        property int umd_state2: 250
        property int umd_state3: 451
        property int umd_state4: 500

        property int offline_times: 10
        property int offline_interval: 2

        property int helxa_type: 0

        property int aver_num: 3
        property bool use_real_red_line: true

        property bool use_anim_ball: true

        property int sceen_x: 0
        property int sceen_y: 0
        property string indoor_temp: ""
        property string puppet_num: ""
        property string puppet_con: ""
        property string mac_code: ""
        property int test_id: 1

        property bool use_serialport: false

        property real umd_standard: 3.8612
        property real umd_standard_temp: 26.7
        property real standard_arg1: 0.00004
        property real standard_arg2: 0.0009
        property real standard_arg3: -0.0126
        property real standard_arg4: 1
    }

    function showPrintDialog() {
        sm.showPrintDialog()
    }

    Connections {
        target: sm
    }
}
