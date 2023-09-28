import QtQuick
import KmcUI.Controls
import QtQuick.Controls
import KmcUI

ToolBox {
    id: control
    ScrollBar.vertical: MyScrollBar {}
    ScrollBar.horizontal: MyScrollBar {}
    toggle: Transition {
        NumberAnimation {
            id: collapseAnim
            property: "height"
            easing.type: Easing.InOutQuad
            duration: 100
        }
    }

    property var imageMouseArea
    property alias hovered: hoverHandler.hovered
    HoverHandler {
        id: hoverHandler
    }

    sourceSelector: index => {
                        return {
                            "source": Qt.resolvedUrl(".") + "../components/AlgoListItem.qml",
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
        expanded: true
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
                anchors.rightMargin: 3
                spacing: 3
                visible: boxDelegate.hovered
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

        background: Rectangle {
            anchors.fill: parent
            color: "#1F1F1F"
            border.color: boxDelegate.highlighted ? "#0078D4" : "transparent"
        }

        indicator: Item {
            implicitHeight: 22
            implicitWidth: 22

            Canvas {
                anchors.centerIn: parent
                width: 19
                height: width
                rotation: boxDelegate.expanded ? 90 : 0
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.strokeStyle = "#dedfdf"
                    const startX = 0.375 * width
                    const startY = 0.25 * height
                    ctx.moveTo(startX, startY)
                    ctx.lineTo(width * 0.625, height / 2)
                    ctx.lineTo(startX, height - startY)
                    ctx.stroke()
                }
                Behavior on rotation {
                    NumberAnimation {
                        easing.type: Easing.InOutQuad
                        duration: collapseAnim.duration
                    }
                }
            }
        }
    }
}
