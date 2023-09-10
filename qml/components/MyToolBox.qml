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
    property alias hovered: hoverHandler.hovered
    HoverHandler {
        id: hoverHandler
    }

    sourceSelector: index => {
                        console.log(control.model.data(control.model.index(index, 0),
                                                       Qt.UserRole).widgets)
                        return {
                            "source": Qt.resolvedUrl(".") + "../AlgoListItem.qml",
                            "properties": {
                                "model": undefined
                            }
                        }
                    }

    boxDelegate: ToolBoxDelegate {
        implicitHeight: 22
        contentItem: Item {
            Text {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

                text: "model.title"
                color: model.enbaled ? "#CCCCCC" : "#181818"
                verticalAlignment: Text.AlignVCenter
                leftPadding: indicator.implicitWidth
                elide: Text.ElideRight
                font.bold: true
            }
        }
        background: Item {
            Rectangle {
                anchors.fill: parent
                anchors.rightMargin: border.width
                anchors.leftMargin: border.width
                color: "#1F1F1F"
                border.color: highlighted ? "#0078D4" : "transparent"
            }
        }

        indicator: Item {
            implicitHeight: 22
            implicitWidth: 22

            ColorIcon {
                anchors.centerIn: parent
                source: "qrc:/assets/icons/arrow.svg"
                rotation: expanded ? 90 : 0
                height: 13
                width: 13
                color: "#CCCCCC"
            }
        }
    }
}
