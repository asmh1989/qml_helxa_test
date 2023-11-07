import QtQuick
import QtQuick.Controls

import "common.js" as Common

Rectangle {
    color: Qt.rgba(100, 100, 100, 100)
    height: is_sno() ? 64 : row1.height
    width: parent.width

    property alias url: tf.text

    property int times: 0

    function is_sno() {
        return cb.currentText.toUpperCase() === "SNO"
    }

    Column {
        anchors.fill: parent
        Row {
            id: row1
            spacing: 6
            height: 28
            anchors.horizontalCenter: parent.horizontalCenter

            ComboBox {
                height: parent.height
                width: 100
                currentIndex: (appSettings.use_serialport ? 0 : 1)
                model: ["串口", "Socket"]
                onCurrentTextChanged: {
                    console.log("onCurrentTextChanged " + currentIndex + " "
                                + appSettings.use_serialport)
                    appSettings.use_serialport = (currentIndex == 0)
                    root.change_type()
                }
            }

            TextField {
                id: tf
                height: parent.height
                width: 188
                font.pixelSize: 14
                placeholderText: qsTr("URL")
                visible: !appSettings.use_serialport
            }

            Button {
                height: parent.height
                text: is_open ? "断开" : "连接"
                onClicked: {
                    root.start_websocket(!is_open)
                }
            }

            Button {
                height: parent.height
                text: "刷新"
                onClicked: {
                    root.refresh()
                }
            }
            ComboBox {
                id: cb
                height: parent.height
                width: 168
                currentIndex: appSettings.helxa_type
                onCurrentTextChanged: {
                    appSettings.helxa_type = cb.currentIndex
                }
                model: root.arr_helxa
            }

            Button {
                height: parent.height
                text: "开始测试"
                enabled: (is_open && !root.in_helxa)
                onClicked: {
                    save_cache()
                    root.start_helxa_test(cb.currentText)
                }
            }

            Button {
                height: parent.height
                text: "手动停止"
                enabled: is_open
                onClicked: {
                    save_cache()
                    root.stop_helxa_test()
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
        Item {
            width: 1
            height: 6
        }

        Row {
            id: row2
            spacing: 6
            height: row1.height
            visible: is_sno()
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "次数:"
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: t_times
                height: parent.height
                text: appSettings.offline_times
                validator: IntValidator {
                    bottom: 2
                    top: 999
                }
            }

            Text {
                text: "间隔(S):"
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: t_interval
                text: appSettings.offline_interval
                height: parent.height
                validator: IntValidator {
                    bottom: 0
                    top: 99
                }
            }

            Button {
                text: "离线循环"
                height: parent.height
                enabled: times === 0
                onClicked: {
                    save_cache()
                    start_timer()
                }
            }

            Button {
                text: "结束循环"
                height: parent.height

                onClicked: {
                    save_cache()
                    stop_test()
                    root.stop_helxa_test()
                }
            }

            Text {
                text: "UMD帧间隔:"
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: t1
                text: appSettings.umd_state1
                height: parent.height

                validator: IntValidator {
                    bottom: 0
                    top: 300
                }
            }
            TextField {
                id: t2
                height: parent.height
                text: appSettings.umd_state2
                validator: IntValidator {
                    bottom: 50
                    top: 400
                }
            }
            TextField {
                id: t3
                height: parent.height
                text: appSettings.umd_state3
                validator: IntValidator {
                    bottom: 350
                    top: 500
                }
            }
            TextField {
                id: t4
                height: parent.height
                text: appSettings.umd_state4
                validator: IntValidator {
                    bottom: 450
                    top: 650
                }
            }
        }
    }

    function start_timer() {
        if (!timer.running) {
            times = 0
            timer.start()
        } else {
            root.showToast("已在进行离线循环测试中!")
        }
    }
    function stop_test() {
        timer.stop()
        timer2.stop()
        times = 0
    }
    function _start_test() {
        times += 1
        var msg = "开始循环离线测试 times = " + times
        root.showToastAndLog(msg)
        root.start_helxa_test("SNO")
    }

    Timer {
        id: timer
        triggeredOnStart: true
        interval: 1000
        repeat: true
        onTriggered: {
            if (times === 0) {
                // 开始第一次
                _start_test()
                return
            }

            if (times < appSettings.offline_times + 1) {
                if (!root.in_helxa) {
                    // 结束后
                    timer.stop()
                    if (times === appSettings.offline_times) {
                        // 次数用完, 结束任务
                        root.showToastAndLog(
                                    appSettings.offline_times + "次循环离线测试完成!")
                        stop_test()
                    } else {
                        // 还有次数开启延时间隔执行
                        timer2.interval = Math.max(
                                    appSettings.offline_interval, 1) * 1000
                        console.log("延时离线循环定时器启动 .. " + timer2.interval)
                        timer2.start()
                    }
                }
            }
        }
    }

    Timer {
        id: timer2
        triggeredOnStart: false
        repeat: false
        interval: 1000
        onTriggered: {
            _start_test()
            timer.start()
        }
    }

    function save_cache() {
        appSettings.offline_times = parseInt(t_times.text)
        appSettings.offline_interval = parseInt(t_interval.text)
        appSettings.umd_state1 = parseInt(t1.text)
        appSettings.umd_state2 = parseInt(t2.text)
        appSettings.umd_state3 = parseInt(t3.text)
        appSettings.umd_state4 = parseInt(t4.text)
    }
}
