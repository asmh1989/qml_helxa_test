import QtQuick

import QtQuick.Controls
import QtQuick.Layouts
import QtCharts

//import "common.js" as Common
Rectangle {
    id: rect
    visible: false
    width: 210 * 4 - 40 // A4纸的宽度（单位：毫米）
    height: 297 * 4 - 40 // A4纸的高度（单位：毫米）
    color: "white"

    property int spacing: 12

    Item {
        anchors.fill: parent
        anchors.margins: 30

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            Label {
                text: "呼气检测结果"
                Layout.preferredHeight: 60
                font {
                    bold: true
                    pixelSize: 32
                }
                Layout.alignment: Qt.AlignCenter
            }

            Item {
                Layout.preferredHeight: 10
                Layout.fillWidth: true
                Rectangle {
                    width: parent.width
                    height: 2
                    color: '#b6d2ec'
                }
            }

            Grid {
                id: grid
                columns: 8
                spacing: 10
                columnSpacing: 6
                Layout.preferredHeight: grid.height
                Layout.maximumWidth: parent.width
                Label {
                    id: label
                    text: "姓名："
                    font.pixelSize: 18
                }

                Label {
                    text: "吴睿"
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "检测卡号："
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    text: "11123210000000"
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    text: "年龄："
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    text: "18"
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    text: "性别："
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "男"
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    text: "检测项目："
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "FeNO"
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    text: "检测时间："
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    id: timeLabel
                    text: "2023/7/2 10:20:36"
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    text: "检测结果："
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    id: resultLabel
                    text: "14ppb"
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    text: "参考范围："
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "10-20"
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    text: "检测科室："
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "呼吸科"
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "检测编号："
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "22"
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "开单医生："
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "张三"
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "操作医生："
                    font.pixelSize: label.font.pixelSize
                }
                Label {
                    text: "李四"
                    font.pixelSize: label.font.pixelSize
                }

                Component.onCompleted: {

                    //                    grid.columnSpacing += (parent.width - grid.width) / 8
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: bzLabel.height
                Label {
                    id: bz
                    text: "备注："
                    font.pixelSize: label.font.pixelSize
                }

                Label {
                    id: bzLabel
                    anchors.left: bz.right
                    anchors.right: parent.right
                    width: parent.width - bz.width - 12
                    font.pixelSize: label.font.pixelSize
                    maximumLineCount: 3
                    wrapMode: Text.Wrap
                    text: "这是一个多行的备注内容，可以随意扩展，会自动换行显示。这是一个多行的备注内容，可以随意扩展，会自动换行显示。这是一个多行的备注内容，可以随意扩展，会自动换行显示。"
                }
            }

            Item {
                Layout.preferredHeight: 10
                Layout.fillWidth: true
                Rectangle {
                    width: parent.width
                    height: 2
                    color: '#b6d2ec'
                }
            }

            Column {
                Layout.fillWidth: true
                Layout.fillHeight: true
                width: grid.width
                spacing: 6

                Label {
                    text: "FeNO呼气测试流量曲线图"
                    width: parent.width
                    font {
                        bold: true
                        pixelSize: label.font.pixelSize
                    }
                }

                ChartView {
                    width: parent.width
                    height: 320
                    id: flow_chart
                    antialiasing: true
                    legend.visible: false
                    dropShadowEnabled: false
                    animationOptions: ChartView.NoAnimation

                    SplineSeries {
                        color: 'red'
                        XYPoint {
                            x: 0
                            y: 30
                        }
                        XYPoint {
                            x: 1200
                            y: 30
                        }
                        axisX: xAxis
                        axisY: yAxis
                    }

                    SplineSeries {
                        color: 'red'
                        XYPoint {
                            x: 0
                            y: 70
                        }
                        XYPoint {
                            x: 1200
                            y: 70
                        }
                        axisX: xAxis
                        axisY: yAxis
                    }

                    LineSeries {
                        id: chart
                        axisX: xAxis
                        axisY: yAxis
                        color: 'blue'
                    }

                    ValueAxis {
                        id: xAxis
                        min: 0
                        max: 120
                        tickCount: 11
                        labelFormat: "%.0f"
                    }

                    CategoryAxis {
                        id: yAxis
                        min: -15 // 最小值，避免出现0值
                        max: 85 // 最大值
                        labelFormat: "%.0f"
                        labelsPosition: CategoryAxis.AxisLabelsPositionOnValue

                        titleText: "FLOW_RT(ml/s)"
                        CategoryRange {
                            label: ""
                            endValue: -15
                        }
                        CategoryRange {
                            label: "0"
                            endValue: 0
                        }
                        CategoryRange {
                            label: "30"
                            endValue: 15
                        }
                        CategoryRange {
                            label: "45"
                            endValue: 30
                        }
                        CategoryRange {
                            label: ""
                            endValue: 40
                        }
                        CategoryRange {
                            label: "50"
                            endValue: 50
                        }
                        CategoryRange {
                            label: ""
                            endValue: 60
                        }

                        CategoryRange {
                            label: "55"
                            endValue: 70
                        }

                        CategoryRange {
                            label: ""
                            endValue: 85
                        }
                    }
                }

                Label {
                    text: "FeNO呼气测试浓度曲线图"
                    font {
                        bold: true
                        pixelSize: label.font.pixelSize
                    }
                }

                ChartView {
                    width: parent.width
                    height: 320
                    id: umd_chart
                    antialiasing: true
                    legend.visible: false
                    dropShadowEnabled: false
                    animationOptions: ChartView.NoAnimation

                    LineSeries {
                        id: chart2
                        axisX: xAxis2
                        axisY: yAxis2
                        color: 'black'
                    }

                    ValueAxis {
                        id: xAxis2
                        min: 0
                        max: 120
                        tickCount: 11
                        labelFormat: "%.0f"
                    }

                    ValueAxis {
                        id: yAxis2
                        min: 0 // 最小值，避免出现0值
                        max: 120 // 最大值
                        labelFormat: "%.0f"
                        titleText: "UMD(ppb)"
                    }
                }
            }

            Item {
                Layout.preferredHeight: 10
                Layout.fillWidth: true
                Rectangle {
                    width: parent.width
                    height: 2
                    color: '#b6d2ec'
                }
            }
            Label {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "声明：本报告只对本次检测负责，如有疑问请及时与检测科室联系。"
                font {
                    bold: true
                    pixelSize: 20
                }
            }
        }
    }

    function addData(data, result) {

        var time = result[1]
        timeLabel.text = time
        var resultValue = result[result.length - 2]
        resultLabel.text = resultValue

        var min_y_u = 10000000
        var max_y_u = 0
        data.forEach((e, i) => {
                         var flow = e[0]
                         var umd = e[1]

                         if (min_y_u > umd) {
                             min_y_u = umd
                         }

                         if (max_y_u < umd) {
                             max_y_u = umd
                         }

                         chart.append(i, flow)
                         chart2.append(i, umd)
                     })

        xAxis2.max = Math.max(xAxis2.max, data.length + 10)
        xAxis.max = Math.max(xAxis.max, data.length + 10)
        //        redSeries1.append(xAxis.max, 30)
        //        redSeries2.append(xAxis.max, 70)
        yAxis2.min = Math.round(min_y_u - Math.abs(min_y_u) / 10 - 1)
        yAxis2.max = Math.ceil(max_y_u + Math.abs(max_y_u) / 10 + 1)
    }

    function saveImage() {
        rect.grabToImage(function (result) {
            result.saveToFile("print_preview.png")
            console.log("save to file ...")
        })
    }

    Component.onCompleted: {

        //        saveImage()
    }

    Component.onDestruction: {
        console.log("onDestruction ...")
    }
}
