import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control
    property var toolTip
    display: AbstractButton.IconOnly
    icon.width: height
    icon.height: height
    icon.color: "#cccccc"
    padding: 2
    background: Rectangle {
        radius: 4
        color: mouseArea.containsMouse || control.checked ? "#12ffffff" : "transparent"
    }
    MyToolTip {
        id: toolTip
        Binding {
            when: !!control.toolTip
            toolTip.text: control.toolTip
        }

        offsetX: 8
        visible: mouseArea.containsMouse && !!control.toolTip
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        propagateComposedEvents: true
        onClicked: e => {
                       control.onClicked()
                   }
    }
}
