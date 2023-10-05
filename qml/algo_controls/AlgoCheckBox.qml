import QtQuick
import QtQuick.Controls
import KmcUI
import "../scripts/Icon.js" as MdiFont
import "../controls"

CheckBox {
    id: control
    required property var widget
    text: widget?.text

    onCheckedChanged: widget.currentValue = checked
    contentItem: Text {
        text: control.text
        font: control.font
        color: "#bbbbbb"
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }

    indicator: Rectangle {
        radius: 3
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        implicitHeight: 20
        implicitWidth: implicitHeight
        border.color: control.pressed ? "#3c3c3c" : (control.activeFocus ? "#0078D4" : "#3c3c3c")
        color: "#313131"
        MyTextIcon {
            anchors.centerIn: parent
            visible: control.checked
            text: MdiFont.Icon.check
        }
    }
}
