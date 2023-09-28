import QtQuick
import KmcUI
import KmcUI.Controls

BubbleToolTip {
    location: KmcUI.Right
    shadowBlur: 5
    radius: 3
    arrow.height: 8
    arrow.width: 4
    verticalPadding: 4
    horizontalPadding: 8
    border.color: "#494949"
    palette {
        toolTipBase: "#202020"
        toolTipText: "#c2c2c2"
        shadow: "#000"
    }
}
