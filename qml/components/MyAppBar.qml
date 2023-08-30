import QtQuick
import KmcUI.Controls
import QtQuick.Effects

AppBar {
    palette {
        text: "#8C8C8C"
    }
    size: 45
    active.iconColor: "#D7D7D7"
    hover.iconColor: "#D7D7D7"
    icons {
        width: 26
        height: 26
        color: "#8c8c8c"
    }
    toolTip: MouseToolTip {
        id: appBarToolTip
        palette {
            toolTipText: "#878787"
            toolTipBase: "white"
            shadow: "#8e8e8e"
        }

        delay: 1000
        timeout: 9000
        margins: 2

        background: Rectangle {
            color: appBarToolTip.palette.toolTipBase
            border.width: 1
            border.color: "#E5E5E5"
            radius: 2
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowBlur: 0.5
                shadowEnabled: true
                shadowHorizontalOffset: 2
                shadowVerticalOffset: 2
                shadowColor: background.palette.shadow
            }
        }
    }
}
