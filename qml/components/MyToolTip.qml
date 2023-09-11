import QtQuick
import KmcUI.Controls
import QtQuick.Effects

MouseToolTip {
    id: control
    palette {
        toolTipText: "#878787"
        toolTipBase: "white"
        shadow: "#8e8e8e"
    }

    delay: 1000
    timeout: 9000
    padding: 4
    horizontalPadding: 6
    margins: 2
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
