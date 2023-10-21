import QtQuick
import QtQuick.Controls

Item {
    id: parent_view
    property double x_: 0
    property double scale_: 1
    property double y_: 0
    property double max_scale: 2.5

    Image {
        source: "/img/bg_none.png" // 图片文件的相对或绝对路径
        fillMode: Image.Stretch // 图片填充模式，可以根据需要调整
        anchors.fill: parent // 让图片填充整个Item
    }

    Image {
        id: ball1
        source:"/img/balloon.png"
        fillMode: Image.Stretch
        //        anchors {
        //            left: parent.left
        //            bottom: parent.bottom
        //            margins: 10
        //        }
        x: 10
        y: parent.height * 0.8 - 10
        width: height* 772/1009 / max_scale
        height: parent.height / 5

        // 定义动画效果
//        Behavior on width {
//            NumberAnimation { duration: 200 }
//        }

//                Behavior on x {
//                    NumberAnimation { duration: 100 }
//                }

//                Behavior on y {
//                    NumberAnimation { duration: 100 }
//                }

    }

    onWidthChanged:  {
        refresh()
    }

    function append_scale(scale) {
        scale_ += scale;

        if(scale_ > max_scale) {
            scale_ = max_scale
        }

        console.log("append_scale  = "+ scale)
        refresh()
    }

    function refresh(){
        var height = parent_view.height / 5;

        ball1.width = height * 772/1009 / max_scale * scale_
        var x_step = (parent_view.width - 20 ) / 80
        var y_step = parent_view.height / 100

        ball1.x = x_ * x_step + 10
        ball1.y = parent_view.height*0.8 -  y_step * map_value(y_) - 10
        console.log("scale = "+ scale_ +  ", ("+x_ +","+ y_+")"+ " = "+ "("+ball1.x +","+ ball1.y+")")

    }

    function reset() {
        scale_ = 1
        x_ = 0
        y_ = 0
        refresh()
    }

    function append(loc_y){
        if(loc_y === 0 || scale_ <= 1) {
            return;
        }
//        scale_ = max_scale
        x_ += 1
        y_ = loc_y
        refresh()
    }

    function map_value(input) {
        if(appSettings.use_real_red_line){
            if(input < 45) {
                return  input * 30 / 45;
            } else if ( input <= 55) {       // 45, 55 => 30, 70
                return 30 + (input -45) * 5;
            } else if (input <= 84) {       // 55, 84 => 70, 89
                return 70 + (input - 55) * 13 / 29;
            }  else  {
                return 84
            }
        } else {
            if(input < 40) {
                return  input * 30 / 40;
            } else if ( input <= 60) {       // 40, 60 => 30, 70
                return 30 + (input -40) * 5;
            } else if (input <= 84) {       // 60, 84 => 70, 83
                return 70 + (input - 60) * 13 / 24;
            }  else  {
                return 84
            }
        }
    }
}
