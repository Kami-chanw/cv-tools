import QtQuick
import CvTools
import "../components"

Column {
    id: control
    property alias model: repeater.model
    required property var imageMouseArea
    Repeater {
        id: repeater
        delegate: Rectangle {
            id: content
            implicitHeight: contentColumn.height
            width: control.width
            height: contentColumn.height + 15
            color: loader.item?.activeFocus ? "#252728" : (hh.hovered ? "#232424" : "transparent")

            property var currentWidget: repeater.model.data(repeater.model.index(index, 0),
                                                            Qt.UserRole)

            states: [
                State {
                    when: !!content.currentWidget
                          && content.currentWidget.type === Enums.WidgetType.StackLayout
                    PropertyChanges {
                        content.color: "transparent"
                        content.height: contentColumn.height
                        contentColumn.leftPadding: 0
                    }
                }
            ]
            onCurrentWidgetChanged: {
                if (!content.currentWidget)
                    return
                let source
                switch (content.currentWidget.type) {
                case Enums.WidgetType.ComboBox:
                    source = "./AlgoComboBox.qml"
                    break
                case Enums.WidgetType.Slider:
                    source = "./AlgoSlider.qml"
                    break
                case Enums.WidgetType.LineEdit:
                    source = "./AlgoLineEdit.qml"
                    break
                case Enums.WidgetType.CheckBox:
                    source = "./AlgoCheckBox.qml"
                    break
                case Enums.WidgetType.StackLayout:
                    loader.setSource("./AlgoStackLayout.qml", {
                                         "layout": currentWidget,
                                         "imageMouseArea": control.imageMouseArea,
                                         "width": Qt.binding(() => control.width)
                                     })
                    return
                case Enums.WidgetType.Selector:
                    loader.setSource("./AlgoSelector.qml", {
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
            z: hh.hovered ? 1 : 0
            HoverHandler {
                id: hh
            }

            Column {
                id: contentColumn
                leftPadding: 16
                spacing: 7
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
                        background: Item {}
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
