import QtQuick
import KmcUI.Controls
import QtQuick.Effects
import KmcUI

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
    toolTip: MyBubbleToolTip{
        location:KmcUI.Right
    }
}
