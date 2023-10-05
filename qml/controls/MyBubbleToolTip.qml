import QtQuick
import KmcUI
import KmcUI.Controls

BubbleToolTip {
    shadowBlur: 5
    radius: 3
    arrow.height: location === KmcUI.Left || location === KmcUI.Right ? 8 : 4
    arrow.width: location === KmcUI.Left || location === KmcUI.Right ? 4 : 8
    verticalPadding: 6
    horizontalPadding: 8
    delay: 500
    border.color: "#494949"
    palette {
        toolTipBase: "#202020"
        toolTipText: "#c2c2c2"
        shadow: "#000"
    }
}
