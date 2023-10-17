import QtQuick
import QtQuick.Window
import QtQuick.Controls

import QtWebSockets

import "common.js" as Common


Window  {
    id: root
    width: 960
    height: 640
    visible: true
    title: qsTr("Hello World")

    readonly property int margin: 10
    readonly property string _sample_value: JSON.stringify(Common.get_sample_req(0))

    property bool connected: false

    property var sample_data;

    ToastManager {
        id: toast
    }


    WebSocket {
        id: socket
        url: "ws://192.168.2.184:8080"
        onTextMessageReceived: function(message) {
            var obj = JSON.parse(message);
            if(obj.ok) {
                if (obj.method === "get_sample") {
                    sample_data = obj.ok;
                    my_satatus.dataChanged(obj.ok);
                }
            } else {
                showToast("error msg =  "+ message)
            }
        }
        onStatusChanged:{
            if (socket.status == WebSocket.Error) {
                appendLog("Error: " + socket.errorString)
                connected = false
            } else if (socket.status == WebSocket.Open) {
                appendLog("Socket connected")
                connected = true
                if(!sample_data){
                    refresh();
                }

            } else if (socket.status == WebSocket.Closed) {
                connected = false
                appendLog("Socket closed")
            } else if (socket.status == WebSocket.Connecting) {
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
            }

            Status {
                id: my_satatus
                anchors.top: header.bottom
                anchors.topMargin: margin
            }


            Rectangle{
                color:Qt.rgba(100,100,100, 100)
                anchors.bottom: parent.bottom
                height: 128
                width: parent.width

                ScrollView {
                    anchors.fill: parent
                    //                    ScrollBar.vertical.policy: ScrollBar.AlwaysOn

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
        //        triggeredOnStart: true
        repeat: true
        interval: 100
        onTriggered: ()=>{
                         socket.sendTextMessage(_sample_value);
                         if(!timer2.running) {
                             timer2.start();
                         }
                     }

    }

    Timer {
        id: timer2
        //        triggeredOnStart: true
        repeat: true
        interval: 1000
        onTriggered: ()=>{
                         if(sample_data && !Common.is_helxa_starting(sample_data[Common.FUNC_STATUS])){
                             timer2.stop();
                             timer.stop();
                             refresh();
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
        socket.active = open;
    }

    function send_data(msg) {
        if(connected) {
            socket.sendTextMessage(JSON.stringify(msg))
        } else {
            toast.show("websockets 已断开", 3000);
        }
    }

    function start_helxa_test(command) {
        var msg = Common.get_start_helxa_req(command);
        appendLog("send: "+JSON.stringify(msg))
        send_data(msg)
        if (timer.running) {
            timer.stop();
        }
        timer.start()
    }

    function stop_helxa_test() {
        var msg = Common.get_stop_helxa_req();
        appendLog("send: "+JSON.stringify(msg))
        send_data(msg)
        timer.stop()
        timer2.stop();
        refresh_timer.start();
    }

    function refresh() {
        let msg = Common.get_sample_req(100);
        send_data(msg);

    }

    function showToast(msg) {
        toast.show(msg, 3000);
    }


    function appendLog(msg) {
        if (msg.length === 0) {  // clear
            area.text = ""
        } else {
            area.text += msg
            area.text += "\n"
            area.cursorPosition = area.length-1
        }

    }



}
