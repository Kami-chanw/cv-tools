import QtQuick
import QtQuick.Controls
import CvTools
import "./components"

Flickable {
    id: control
    property alias model: repeater.model
    required property var imageMouseArea
    HoverHandler {
        id: hoverHandler
    }

    property alias hovered: hoverHandler.hovered
    ScrollBar.vertical: MyScrollBar {}
    ScrollBar.horizontal: MyScrollBar {}
    contentHeight: Math.min(500, column.height)
    contentWidth: column.width
    boundsBehavior: Flickable.StopAtBounds

    height: Math.min(500, column.height)

    Column {
        id: column
        property int currentIndex: -1
        Repeater {
            id: repeater
            delegate: Rectangle {
                id: content
                implicitHeight: contentColumn.height
                width: control.width
                height: contentColumn.height + 20
                color: column.currentIndex === index ? "#252728" : (hh.hovered ? "#232424" : "transparent")
                property var currentWidget: repeater.model.data(repeater.model.index(index, 0),
                                                                Qt.UserRole)

                onCurrentWidgetChanged: {
                    let source
                    switch (content.currentWidget?.type) {
                    case Enums.WidgetType.ComboBox:
                        source = "./algo_widgets/AlgoComboBox.qml"
                        break
                    case Enums.WidgetType.Slider:
                        source = "./algo_widgets/AlgoSlider.qml"
                        break
                    case Enums.WidgetType.LineEdit:
                        source = "./algo_widgets/AlgoLineEdit.qml"
                        break
                    case Enums.WidgetType.CheckBox:
                        source = "./algo_widgets/AlgoCheckBox.qml"
                        break
                    case Enums.WidgetType.Selector:
                        loader.setSource("./algo_widgets/AlgoSelector.qml", {
                                             "widget": currentWidget,
                                             "imageMouseArea": control.imageMouseArea
                                         })
                        return
                    default:
                        return
                    }
                    loader.setSource(source, {
                                         "widget": currentWidget
                                     })
                }

                HoverHandler {
                    id: hh
                }
                TapHandler {
                    id: th
                    onTapped: column.currentIndex = index
                }

                Column {
                    id: contentColumn
                    leftPadding: 16
                    spacing: 10
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    Row {
                        Text {
                            color: "white"
                            text: content.currentWidget?.title ?? ""
                            font.pointSize: 9
                        }

                        MyIconButton {
                            icon.source: "qrc:/assets/icons/question.svg"
                            icon.width: 15
                            icon.height: 15
                            icon.color: "#cccccc"
                            visible: !!content.currentWidget?.informativeText
                            //                            background: Item {}
                            toolTip: content.currentWidget?.informativeText
                        }
                    }

                    Loader {
                        id: loader
                    }
                }
            }
        }
    }
}
