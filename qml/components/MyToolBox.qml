import QtQuick
import KmcUI.Controls
import QtQuick.Controls
import KmcUI

ToolBox {
    id: control
    ScrollBar.vertical: MyScrollBar {}
    ScrollBar.horizontal: MyScrollBar {}
    dropAreaItem: Rectangle {
        color: "#cccccc"
        opacity: 0.15
    }
    property var imageMouseArea
    property alias hovered: hoverHandler.hovered
    HoverHandler {
        id: hoverHandler
    }

    sourceSelector: index => {
                        return {
                            "source": Qt.resolvedUrl(".") + "../AlgoListItem.qml",
                            "properties": {
                                "model": control.model.get(index).widgets,
                                "imageMouseArea": control.imageMouseArea
                            }
                        }
                    }
    boxDelegate: ToolBoxDelegate {
        id: boxDelegate
        implicitHeight: 22
        rightPadding: 4
        contentItem: Item {
            Text {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                font.strikeout: !boxDelegate.model?.enabled
                width: row.visible ? parent.width - row.width - leftPadding - row.anchors.rightMargin : parent.width
                text: boxDelegate.model?.title.toUpperCase() ?? ""
                color: "#CCCCCC"
                leftPadding: 13
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.bold: true
            }
            Row {
                id: row
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3
                //                visible: boxDelegate.hovered
                MyIconButton {
                    height: boxDelegate.height - 2
                    width: height
                    icon.source: "qrc:/assets/icons/apply.svg"
                    toolTip: "Enable/Disable effect"
                    checkable: true
                    checked: true
                    onClicked: {
                        boxDelegate.model.enabled = !boxDelegate.model.enabled
                        checked = !checked
                    }
                }
                MyIconButton {
                    height: boxDelegate.height - 2
                    width: height
                    icon.source: "qrc:/assets/icons/close_tab.svg"
                    toolTip: "Remove effect"
                    onClicked: {
                        control.model.remove(boxDelegate.index, 1)
                    }
                }
            }
        }
        background: Item {
            Rectangle {
                anchors.fill: parent
                anchors.rightMargin: border.width
                anchors.leftMargin: border.width
                color: "#1F1F1F"
                border.color: boxDelegate.highlighted ? "#0078D4" : "transparent"
            }
        }

        indicator: Item {
            implicitHeight: 22
            implicitWidth: 22

            ColorIcon {
                anchors.centerIn: parent
                source: "qrc:/assets/icons/arrow.svg"
                rotation: boxDelegate.expanded ? 90 : 0
                height: 13
                width: 13
                color: "#CCCCCC"
            }
        }
    }
}
