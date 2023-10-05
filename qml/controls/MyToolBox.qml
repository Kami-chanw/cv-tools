import QtQuick
import KmcUI.Controls
import QtQuick.Controls
import KmcUI
import "../scripts/Icon.js" as MdiFont

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
        implicitHeight: 23
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
                spacing: 4
                visible: boxDelegate.hovered
                MyIconButton {
                    height: boxDelegate.height - 2
                    width: height
                    display: Button.TextOnly

                    contentItem: MyTextIcon {
                        anchors.centerIn: parent
                        color: parent.icon.color
                        text: MdiFont.Icon.tune
                    }
                    toolTip: "Enable/Disable effect"
                    checkable: true
                    checked: true
                    onClicked: {
                        boxDelegate.model.enabled = !boxDelegate.model.enabled
                        boxDelegate.expanded = !boxDelegate.expanded
                        boxDelegate.enabled = !boxDelegate.enabled
                        checked = !checked
                    }
                }
                MyIconButton {
                    height: boxDelegate.height - 2
                    width: height
                    display: Button.TextOnly
                    contentItem: MyTextIcon {
                        anchors.centerIn: parent
                        color: parent.icon.color
                        text: MdiFont.Icon.close
                    }

                    toolTip: "Remove effect"
                    onClicked: {
                        control.model.remove(boxDelegate.index, 1)
                    }
                }
            }
        }

        background: Rectangle {
            anchors.fill: parent
            color: "#181818"
            border.color: boxDelegate.highlighted ? "#0078D4" : "transparent"
        }

        indicator: MyTextIcon {
            rotation: boxDelegate.expanded ? 90 : 0
            font.pointSize: 15
            text: MdiFont.Icon.chevronRight
            color: "#dedfdf"
            Behavior on rotation {
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    duration: collapseAnim.duration
                }
            }
        }
    }
}
