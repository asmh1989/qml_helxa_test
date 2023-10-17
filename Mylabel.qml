import QtQuick
import QtQuick.Controls

Row {

    property string name: ""
    property string value: ""
    property string unit: ""


    Text {
        text: name+":"
    }

    Text {
        text: " "+ value+" "
        color: 'red'
    }


    Text {
//        text: "°C"
        text: unit
    }

}
