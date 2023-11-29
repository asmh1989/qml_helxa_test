import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "common.js" as Common
import "./view"

import Qt.labs.settings 1.0
import FileIO

ApplicationWindow {
    id: window
    width: 1280
    height: 800
    minimumWidth: dp(840)
    //    minimumHeight: dp(600)
    visible: true
    title: qsTr("em-exhale")

    x: appSettings.sceen_x
    y: appSettings.sceen_y
    property bool show_status_bar: false

    flags: show_status_bar ? Qt.FramelessWindowHint | Qt.Window : undefined
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

    property int whichView: 0

    property bool exhaleStarting: false

    property var arr_helxa: [//                "None",
        //                "Feno50Train1",
        //                "Feno50Train2",
        "Feno50Mode1", //                "Feno50Mode2",
        "Feno200Mode1", //                "Feno200Mode2",
        "Sno" //                "NnoMode1",
        //                "NnoMode2",
        //                "Eco",
        //                "Sco",
        //                "Clean",
    ]

    function get_result_prefix() {
        return "record_sno/" + appSettings.mac_code + "-" + _time_name
    }

    function get_result_path() {
        return get_result_prefix() + "/result.csv"
    }

    function get_flow_rt_path() {
        return get_result_prefix() + "/data.csv"
    }

    function save_to_file(diff, f1, f2) {
        var obj = sample_data
        var helxa_type = arr_helxa[appSettings.helxa_type]
        var trace_umd1_temp = obj[Common.UMD1_TEMP] / 100.0
        var ambient_temp = obj[Common.AMBIENT_TEMP] / 100.0
        var ambient_humi = obj[Common.AMBIENT_HUMI]
        var result_data = [appSettings.mac_code, Common.formatDate(
                               ), appSettings.indoor_temp, ambient_temp, ambient_humi, trace_umd1_temp, helxa_type, f1, f2, appSettings.puppet_num, appSettings.puppet_con, diff, appSettings.test_id]
        var res = myFile.saveToCsv(get_result_path(), result_header,
                                   [result_data])

        //        appendLog(res)
        var data_ = arr_flow_rt.map(
                    (element, index) => [appSettings.test_id, element, arr_umd1[index]])

        var res2 = myFile.saveToCsv(get_flow_rt_path(), arr_data_header, data_)
        //        appendLog(res2)
        appSettings.test_id += 1
    }

    function getResultMsg(type) {
        var success = _status === Common.STATUS_END_FINISH
        var msg = ""

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
                var fix_r = fix_umd(
                            sample_data[Common.UMD1_TEMP] / 100.0, r)
                if (type === "FENO50_MODE1") {
                    console.log("result = " + fix_umd2(fix_r))
                    msg = parseFloat(fix_umd2(fix_r)).toFixed(0) + "  ppb"
                } else {
                    msg = "测试成功: 气袋浓度(" + appSettings.puppet_con
                            + ") umd1均值差 = " + fix_r + "/" + fix_umd2(
                                fix_r) + " (ppb)"
                }
                save_to_file(r, fix_r, fix_umd2(fix_r))
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

        if (type !== "FENO50_MODE1") {
            toast.show(msg, 2000)
        }
        return msg
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

        console.log(Screen.desktopAvailableWidth + "," + Screen.desktopAvailableHeight
                    + " real width = " + Screen.width)
    }

    //    DialogResultView {
    //        id: dd
    //        Component.onCompleted: {
    //            dd.open()
    //        }
    //    }
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

    EventBus {
        id: bus
    }

    FileIO {
        id: myFile
        source: "test_file.txt"
        onError: console.log(msg)
    }

    Component.onDestruction: {
        appSettings.sceen_x = window.x
        appSettings.sceen_y = window.y
    }

    Rectangle {
        anchors.fill: parent
        color: '#F3F9FF'
        Item {
            anchors.fill: parent

            StausBarView {
                id: statusBar
                visible: show_status_bar
            }

            StackView {
                id: stack
                initialItem: mainView
                anchors {
                    top: show_status_bar ? statusBar.bottom : parent.top
                    bottom: parent.bottom
                }

                width: parent.width
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

            Component {
                id: newFnoView
                NewFenoMode {}
            }

            Component {
                id: analysisView
                AnalysisView {}
            }
        }
    }

    function pushSnoView() {
        whichView = 2
        stack.push(snoview)
    }

    function pushNewFenoView() {
        whichView = 3
        stack.push(newFnoView)
    }
    function pushAnalysisView() {
        whichView = 4
        stack.replace(analysisView)
    }

    function pop() {
        whichView = 0
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
