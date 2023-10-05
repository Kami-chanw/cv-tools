import QtQuick
import CvTools
import QtQuick.Controls
import "../controls"
import "../scripts/Icon.js" as MdiFont

Column {
    id: control
    required property var model
    required property var imageMouseArea
    Repeater {
        id: repeater
        model: control.model
        delegate: Rectangle {
            id: content
            implicitHeight: contentColumn.height
            width: control.width
            height: contentColumn.height + 18
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
                if (!currentWidget)
                    return
                switch (currentWidget.type) {
                case Enums.WidgetType.ComboBox:
                    loader.setSource("./AlgoComboBox.qml", {
                                         "widget": currentWidget,
                                         "model": currentWidget.labelModel,
                                         "currentIndex": currentWidget.defaultIndex
                                     })
                    return
                case Enums.WidgetType.Slider:
                    loader.setSource("./AlgoSlider.qml", {
                                         "widget": currentWidget,
                                         "value": currentWidget.defaultValue
                                                  ?? (currentWidget.minimum + currentWidget.maximum) / 2
                                     })
                    return
                case Enums.WidgetType.LineEdit:
                    loader.setSource("./AlgoLineEdit.qml", {
                                         "widget": currentWidget,
                                         "fullText": currentWidget.currentValue
                                     })
                    return
                case Enums.WidgetType.CheckBox:
                    loader.setSource("./AlgoCheckBox.qml", {
                                         "widget": currentWidget,
                                         "checked": !!currentWidget.defaultValue
                                     })
                    break
                case Enums.WidgetType.StackLayout:
                    loader.setSource("./AlgoStackLayout.qml", {
                                         "layout": currentWidget,
                                         "imageMouseArea": control.imageMouseArea,
                                         "width": Qt.binding(() => control.width),
                                         "currentIndex": currentWidget.currentIndex
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
                        verticalAlignment: Text.AlignVCenter
                    }

                    MyIconButton {
                        display: Button.TextOnly
                        contentItem: MyTextIcon {
                            anchors.centerIn: parent
                            text: MdiFont.Icon.helpCircleOutline
                            font.pointSize: 11
                        }
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
