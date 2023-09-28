import QtQuick
import QtQuick.Controls
import KmcUI

TreeViewDelegate {
    background: Item {
        implicitHeight: 22
        Rectangle {
            anchors.fill: parent
            anchors.rightMargin: border.width
            anchors.leftMargin: border.width
            color: selected ? Qt.rgba(1, 1, 1, 0.12) : hovered ? Qt.rgba(1, 1, 1,
                                                                         0.07) : "transparent"
            border.color: current ? "#0078D4" : "transparent"
        }
    }

    indicator: Item {
        implicitHeight: 22
        implicitWidth: 22
        ColorIcon {
            anchors.centerIn: parent
            source: "qrc:/assets/icons/arrow.svg"
            visible: hasChildren
            rotation: expanded ? 90 : 0
            height: 13
            width: 13
            color: current ? "white" : hovered ? "#ACACAC" : "#BABABA"
        }
    }
}
