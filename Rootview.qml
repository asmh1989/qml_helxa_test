import QtQuick
import QtQuick.Controls

import QtWebSockets

import "common.js" as Common

Item {
    id: root

    readonly property int margin: 10
    readonly property string _sample_value: JSON.stringify(
                                                Common.get_sample_req(0))

    property bool connected: false
    property var sample_data
    property int read_times: 0
    property int update_count: 0

    /// 呼吸检测进行状态
    property bool in_helxa: false
    property string _status: ""

    WebSocket {
        id: socket
        url: appSettings.url
        onTextMessageReceived: function (message) {
            var obj = JSON.parse(message)
            if (obj.ok) {
                if (obj.method === "get_sample") {
                    if (sample_data
                            && sample_data["update_time"] !== obj.ok["update_time"]) {
                        update_count += 1
                    }
                    sample_data = obj.ok

                    _status = sample_data[Common.FUNC_STATUS]

                    if (in_helxa && update_count > 10 && Common.is_helxa_finish(
                                _status)) {
                        in_helxa = false
                    }
                    if (typeof my_satatus !== "undefined") {
                        my_satatus.dataChanged(obj.ok)
                    }
                }
            } else {
                showToast("error msg =  " + message)
            }
        }

        onStatusChanged: {
            connected = false
            appSettings.url = socket.url
            if (socket.status == WebSocket.Error) {
                appendLog("Error: " + socket.errorString)
            } else if (socket.status == WebSocket.Open) {
                appendLog("Socket connected = " + appSettings.url)
                connected = true
                if (!sample_data) {
                    refresh()
                }
            } else if (socket.status == WebSocket.Closed) {
                connected = false
                appendLog("Socket closed = " + appSettings.url)
            } else if (socket.status == WebSocket.Connecting) {
                appendLog("Socket Connecting = " + appSettings.url)
            }
            if (!connected) {
                helxa_reset()
            }
        }

        active: true
    }

    Header {
        id: header
        is_open: connected
        url: appSettings.url
    }

    Status {
        id: my_satatus
        anchors.top: header.bottom
        anchors.topMargin: margin
    }

    Item {
        width: parent.width
        anchors.top: my_satatus.bottom
        anchors.bottom: footer.top
        anchors.margins: margin / 2

        Sno {
            id: my_chart
            anchors.fill: parent
            visible: header.is_sno()
        }

        Fenomode {
            id: feno_chart
            anchors.fill: parent
            visible: !header.is_sno()
        }
    }

    Rectangle {
        id: footer
        color: Qt.rgba(100, 100, 100, 100)
        anchors.bottom: parent.bottom
        height: 128
        width: parent.width

        ScrollView {
            anchors.fill: parent
            TextArea {
                id: area
                wrapMode: Text.Wrap
                font.pointSize: 8
                font.family: "Consolas"
                selectByMouse: true
            }
        }
    }

    function start_websocket(open) {
        socket.url = header.url
        socket.active = open
    }

    function send_json(msg) {
        if (connected) {
            _send_(JSON.stringify(msg))
        } else {
            toast.show("websockets 已断开", 3000)
            helxa_reset()
        }
    }

    function _send_(msg) {
        socket.sendTextMessage(msg)
    }

    function chart_start() {
        if (header.is_sno()) {
            my_chart.start()
        } else {
            feno_chart.start()
        }
    }

    function chart_stop() {
        if (header.is_sno()) {
            my_chart.finish()
        } else {
            feno_chart.finish()
        }
    }

    /// 呼吸检测重置
    function helxa_reset() {
        if (read_times > 100) {
            appendLog("helxa_stop: read_times = " + read_times + " update_count = " + update_count)
        }

        read_times = 0
        update_count = 0
        timer.stop()
        chart_stop()
        in_helxa = false
    }

    function start_helxa_test(command) {
        if (!timer.running) {
            if (header.is_sno()) {
                if (appSettings.mac_code.length === 0) {
                    showToast("请填入仪器码!")
                    return
                } else if (appSettings.puppet_num.length === 0) {
                    showToast("请填入气袋编码!")
                    return
                } else if (appSettings.puppet_con.length === 0) {
                    showToast("请填入气袋浓度!")
                    return
                } else if (appSettings.indoor_temp.length === 0) {
                    showToast("请填入室内/箱内温度!")
                    return
                }
            }

            var msg = Common.get_start_helxa_req(command)
            appendLog("send: " + JSON.stringify(msg))
            send_json(msg)
            helxa_reset()
            timer.restart()
            chart_start()
            console.log("start_helxa_test ...")
            in_helxa = true
        } else {
            showToast("已在呼吸测试中, 请稍后")
        }
    }

    function stop_helxa_test() {
        var msg = Common.get_stop_helxa_req()
        appendLog("send: " + JSON.stringify(msg))
        send_json(msg)
        helxa_reset()
        refresh_timer.start()
    }

    function refresh() {
        let msg = Common.get_sample_req(30)
        send_json(msg)
    }

    function showToastAndLog(msg) {
        appendLog(msg)
        toast.show(msg, 2000)
    }

    function appendLog(msg) {
        if (msg.length === 0) {
            // clear
            area.text = ""
        } else {
            var d = new Date().toISOString()
            area.text += d + " => "
            area.text += msg
            area.text += "\n"
            area.cursorPosition = area.length - 1
        }
    }

    /// 定时获取sample数据
    Timer {
        id: timer
        repeat: true
        interval: 100
        onTriggered: () => {
                         if (!in_helxa) {
                             helxa_reset()
                             return
                         }

                         read_times += 1
                         _send_(_sample_value)
                     }
    }

    Timer {
        id: refresh_timer
        repeat: true
        interval: 1000
        onTriggered: () => {
                         if (!Common.is_helxa_finish(_status)) {
                             console.log("refresh_timer refresh")
                             refresh()
                         } else {
                             refresh_timer.stop()
                         }
                     }
    }
}
