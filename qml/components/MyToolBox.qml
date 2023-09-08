import QtQuick
import KmcUI.Controls
import QtQuick.Controls
import KmcUI

ToolBox {
    ScrollBar.vertical: MyScrollBar {}
    ScrollBar.horizontal: MyScrollBar {}
    dropAreaItem: Rectangle {
        color: "#cccccc"
        opacity: 0.15
    }

    sourceSelector: index => {
                        return {
                            "source": "../AlgoListItem.qml",
                            "properties": {
                                "title": "test"
                            }
                        }
                    }

    boxDelegate: ToolBoxDelegate {
        implicitHeight: 22
        contentItem: Text {
            text: "123"
            color: "#CCCCCC"
            verticalAlignment: Text.AlignVCenter
            leftPadding: indicator.implicitWidth
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
