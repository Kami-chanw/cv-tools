import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects

Slider {
    id: control
    required property var widget
    from: widget?.minimum
    to: widget?.maximum
    stepSize: widget?.stepSize
    palette {
        toolTipText: "#878787"
        toolTipBase: "white"
        shadow: "#8e8e8e"
    }

    onValueChanged: {
        widget.currentValue = value
    }

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 180
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: "#cdcecf"

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: "#0078D4"
            radius: 2
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 18
        implicitHeight: implicitWidth
        radius: implicitWidth / 2
        color: control.pressed ? "#bcbebf" : "#f6f6f6"
        ToolTip {
            visible: control.pressed
            text: control.value
            padding: 4
            horizontalPadding: 6

            background: Rectangle {
                color: control.palette.toolTipBase
                border.width: 1
                border.color: "#E5E5E5"
                radius: 2
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowBlur: 0.5
                    shadowEnabled: true
                    shadowHorizontalOffset: 2
                    shadowVerticalOffset: 2
                    shadowColor: control.palette.shadow
                }
            }
        }
    }
}
