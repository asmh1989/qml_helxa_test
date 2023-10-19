import QtQuick
import QtQuick.Window
import QtQuick.Controls

import QtWebSockets

import "common.js" as Common
import QtCore

Window  {
    id: root
    width: 960
    height: 720
    visible: true
    title: qsTr("em-exhale")

    readonly property int margin: 10
    readonly property string _sample_value: JSON.stringify(Common.get_sample_req(0))

    property bool connected: false


    property var sample_data;

    property int read_times: 0
    property int update_count: 0

    property bool in_helxa: false

    ToastManager {
        id: toast
    }


    WebSocket {
        id: socket
        url: appSettings.url
        onTextMessageReceived: function(message) {
            var obj = JSON.parse(message);
            if(obj.ok) {
                if (obj.method === "get_sample") {
                    if(sample_data && sample_data["update_time"] !== obj.ok["update_time"]){
                        update_count += 1;
                    }
                    sample_data = obj.ok;
                    my_satatus.dataChanged(obj.ok);
                }
            } else {
                showToast("error msg =  "+ message)
            }
        }
        onStatusChanged:{
            connected = false
            appSettings.url = socket.url
            if (socket.status == WebSocket.Error) {
                appendLog("Error: " + socket.errorString)
            } else if (socket.status == WebSocket.Open) {
                appendLog("Socket connected = "+ header.url)
                connected = true
                if(!sample_data){
                    refresh();
                }
            } else if (socket.status == WebSocket.Closed) {
                connected = false
                appendLog("Socket closed = "+ header.url)
            } else if (socket.status == WebSocket.Connecting) {
                appendLog("Socket Connecting = "+ header.url)
            }
            if(!connected) {
                stop();
            }
        }

        active: true
    }

    Rectangle {
        anchors.fill: parent
        color: '#F3F9FF'
        Item {
            anchors.fill: parent

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

            Mychart {
                id: my_chart
                width: parent.width
                anchors.top: my_satatus.bottom
                anchors.bottom: footer.top
                anchors.margins: margin  / 2
            }


            Rectangle{
                id: footer
                color:Qt.rgba(100,100,100, 100)
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
        }
    }


    Timer {
        id: timer
        repeat: true
        interval: 100
        onTriggered: ()=>{
                         if(!timer2.running) {
                             console.log("呼吸检测停止检测定时器 will start")
                             timer2.start();
                         }
                         read_times += 1;
                         socket.sendTextMessage(_sample_value);

                     }

    }

    Timer {
        id: timer2
        repeat: true
        interval: 500
        onTriggered: ()=>{
                         if(sample_data && Common.is_helxa_finish(sample_data[Common.FUNC_STATUS])){
                             console.log("呼吸检测停止检测定时器 will stop")
                             appendLog("stop: read_times = "+ read_times+" update_count = "+ update_count)
                             timer.stop();
                             timer2.stop();
                         }
                     }
    }

    Timer {
        id: refresh_timer
        repeat: false
        interval: 1200
        onTriggered: ()=>{
                         refresh();
                     }
    }

    function start_websocket(open) {
        socket.url = header.url;
        socket.active = open;
    }

    function send_data(msg) {
        if(connected) {
            socket.sendTextMessage(JSON.stringify(msg))
        } else {
            toast.show("websockets 已断开", 3000);
            stop();
        }
    }

    function stop() {
        read_times = 0;
        update_count = 0;
        timer.stop();
        my_chart.finish();
        in_helxa = false
    }

    function start_helxa_test(command) {
        if(!timer.running){
            var msg = Common.get_start_helxa_req(command);
            appendLog("send: "+JSON.stringify(msg))
            send_data(msg)
            stop();
            timer.restart()
            my_chart.start();
            console.log("start_helxa_test ...")
            in_helxa = true;
        } else {
            showToast("已在呼吸测试中, 请稍后")
        }

    }

    function stop_helxa_test() {
        var msg = Common.get_stop_helxa_req();
        appendLog("send: "+JSON.stringify(msg))
        send_data(msg)
        stop();
        my_chart.finish();

        refresh_timer.start();
    }

    function refresh() {
        let msg = Common.get_sample_req(100);
        send_data(msg);
    }

    function showToast(msg) {
        toast.show(msg, 3000);
    }

    function showToastAndLog(msg) {
        appendLog(msg)
        toast.show(msg, 2000);
    }


    function appendLog(msg) {
        if (msg.length === 0) {  // clear
            area.text = ""
        } else {
            var d = new Date().toISOString();
            area.text += d+" => "
            area.text += msg
            area.text += "\n"
            area.cursorPosition = area.length-1
        }
    }

    Settings {
        id: appSettings
        location: "./config.txt"
        property string url: "ws://192.168.2.184:8080"
        property int umd_state1: 201
        property int umd_state2: 250
        property int umd_state3: 451
        property int umd_state4: 500

        property int offline_times: 10
        property int offline_interval: 2

    }

}
