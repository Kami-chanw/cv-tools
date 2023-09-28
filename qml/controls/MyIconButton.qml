import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control
    property var toolTip
    property alias toolTipEnabled: toolTip.enabled
    display: AbstractButton.IconOnly
    palette.button: "#12ffffff"
    palette.light: "#21ffffff"
    icon.width: height
    icon.height: height
    icon.color: "#cccccc"
    padding: 2
    background: Rectangle {
        radius: 4
        color: control.checked ? control.palette.light : (mouseArea.containsMouse ? control.palette.button : "transparent")
    }
    MyToolTip {
        id: toolTip
        text: control.toolTip ?? ""

        offsetX: 8
        visible: mouseArea.containsMouse && !!control.toolTip && enabled
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        propagateComposedEvents: true
        onClicked: e => {
                       control.onClicked()
                       e.accepted = false
                   }
    }
}
