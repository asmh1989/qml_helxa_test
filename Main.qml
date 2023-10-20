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

    /// 呼吸检测进行状态
    property bool in_helxa: false
    property string _status: ""

    readonly property int aver_num: 3


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

                    _status = sample_data[Common.FUNC_STATUS];

                    if(in_helxa && update_count > 10 && Common.is_helxa_finish(_status)) {
                        in_helxa = false
                    }

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
                helxa_reset();
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

            Item {
                width: parent.width
                anchors.top: my_satatus.bottom
                anchors.bottom: footer.top
                anchors.margins: margin  / 2

                Mychart {
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

    function start_websocket(open) {
        socket.url = header.url;
        socket.active = open;
    }

    function send_json(msg) {
        if(connected) {
            _send_(JSON.stringify(msg))
        } else {
            toast.show("websockets 已断开", 3000);
            stop();
        }
    }

    function _send_(msg) {
        //        console.log("发送数据 "+ (new Date().getTime()))
        socket.sendTextMessage(msg)
    }

    function chart_start(){
        if(header.is_sno()){
            my_chart.start();
        } else {
            feno_chart.start();
        }
    }

    function chart_stop(){
        if(header.is_sno()) {
            my_chart.finish();
        } else {
            feno_chart.finish();
        }
    }

    /// 呼吸检测重置
    function helxa_reset() {
        if(read_times > 100){
            appendLog("helxa_stop: read_times = "+ read_times+" update_count = "+ update_count)
        }

        read_times = 0;
        update_count = 0;
        timer.stop();
        chart_stop();
        in_helxa = false
    }

    function start_helxa_test(command) {
        if(!timer.running){
            var msg = Common.get_start_helxa_req(command);
            appendLog("send: "+JSON.stringify(msg))
            send_json(msg)
            helxa_reset();
            timer.restart()
            chart_start();
            console.log("start_helxa_test ...")
            in_helxa = true;
        } else {
            showToast("已在呼吸测试中, 请稍后")
        }

    }

    function stop_helxa_test() {
        var msg = Common.get_stop_helxa_req();
        appendLog("send: "+JSON.stringify(msg))
        send_json(msg)
        helxa_reset();
        refresh_timer.start();
    }

    function refresh() {
        let msg = Common.get_sample_req(30);
        send_json(msg);
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

    /// 定时获取sample数据
    Timer {
        id: timer
        repeat: true
        interval: 100
        onTriggered: ()=>{
                         if(!in_helxa) {
                             helxa_reset();
                             return;
                         }

                         read_times += 1;
                         _send_(_sample_value);

                     }
    }


    Timer {
        id: refresh_timer
        repeat: true
        interval: 1000
        onTriggered: ()=>{
                         if(!Common.is_helxa_finish(_status)){
                             console.log("refresh_timer refresh")
                            refresh();
                         } else {
                             refresh_timer.stop();
                         }
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

        property int helxa_type: 0

    }

}
