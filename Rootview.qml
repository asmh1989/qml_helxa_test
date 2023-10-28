import QtQuick
import QtQuick.Controls

//import QtWebSockets
import EmSockets

import "common.js" as Common

Item {
    id: root

    readonly property int margin: 10
    readonly property string _sample_value: JSON.stringify(
                                                Common.get_sample_req(0))

    property var sample_data
    property int read_times: 0
    property int update_count: 0

    /// 呼吸检测进行状态
    property bool in_helxa: false
    property string _status: ""

    property var send_time

    function change_type() {
        socket.type = appSettings.use_serialport ? EmSocket.SerialPort : EmSocket.WebSocket
    }

    EmSocket {
        id: socket
        url: appSettings.url
        type: (appSettings.use_serialport ? EmSocket.SerialPort : EmSocket.WebSocket)
        onTextMessageReceived: function (message) {
            //            console.log("耗时: " + (new Date().getTime() - send_time))
            var obj = JSON.parse(message)
            if (obj.method === "test") {
                socket.notifyTestOk()
                return
            } else if (obj.method === Common.METHOD_HELXA_STARTED) {
                if (in_helxa) {
                    appendLog("recv server command to start")
                    //                    setTimeout(() => {
                    timer.restart()
                    chart_start()
                    //                               }, 50)
                }
                return
            } else if (obj.method === Common.METHOD_HELXA_STARTING) {
                appendLog("设备正在启动中")
                return
            } else if (obj.method === Common.METHOD_DEVICE_HELXA_FAILED) {
                appendLog("设备启动异常 : " + obj.method)
                return
            }

            if (obj.ok) {
                if (obj.method === Common.METHOD_GET_SAMPLE) {
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
                } else if (obj.method === Common.METHOD_START_HELXA
                           && socket.type === EmSocket.WebSocket) {
                    if (!in_helxa) {
                        start_helxa_test("")
                    }
                }
            } else {
                showToast("error msg =  " + message)
            }
        }

        onStatusChanged: {
            appSettings.url = socket.url
            if (socket.status == EmSocket.Error) {
                if (socket.errorString.length > 0) {
                    appendLog("Error: " + socket.errorString)
                }
                is_open = false
            } else if (socket.status == EmSocket.Open) {
                appendLog("Socket connected = "
                          + (appSettings.use_serialport ? "串口打开" : appSettings.url))
                is_open = true
                if (!sample_data) {
                    refresh()
                }
            } else if (socket.status == EmSocket.Closed) {
                appendLog("Socket closed")
                is_open = false
            } else if (socket.status == EmSocket.Connecting) {
                appendLog("Socket Connecting = "
                          + (appSettings.use_serialport ? "连接串口" : appSettings.url))
            }
            if (!is_open) {
                helxa_reset()
            }
        }

        active: true
    }

    Header {
        id: header
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
        //        console.log("start_websocket active=" + socket.active + " open =" + open
        //                    + " is_open = " + is_open)
        if (open) {
            socket.open()
        } else {
            socket.close()
        }
    }

    function send_json(msg) {
        if (is_open) {
            _send_(JSON.stringify(msg))
        } else {
            toast.show("websockets 已断开", 3000)
            helxa_reset()
        }
    }

    function _send_(msg) {
        send_time = new Date().getTime()
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
        if (read_times > 50) {
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
            if (command.length !== 0) {
                var msg = Common.get_start_helxa_req(command)
                appendLog("send: " + JSON.stringify(msg))
                send_json(msg)
            }
            helxa_reset()
            in_helxa = true
            console.log("start_helxa_test ...")
        } else {
            console.log("已在呼吸测试中, 请稍后")
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
