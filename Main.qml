import QtQuick
import QtQuick.Window
import QtQuick.Controls

import "common.js" as Common
import Qt.labs.settings 1.0

ApplicationWindow {
    id: window
    width: 960
    height: 720
    visible: true
    title: qsTr("em-exhale")
    x: appSettings.sceen_x
    y: appSettings.sceen_y

    property string data_dir_name: ""

    ToastManager {
        id: toast
    }

    Component.onDestruction: {
        appSettings.sceen_x = window.x
        appSettings.sceen_y = window.y
    }

    Component.onCompleted: {

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

        // 室内温度
        property string indoor_temp: ""
        // 气袋编号
        property string puppet_num: ""
        // 气袋浓度
        property string puppet_con: ""
        // 仪器码
        property string mac_code: ""

        // 测试任务id
        property int test_id: 1
    }
}
