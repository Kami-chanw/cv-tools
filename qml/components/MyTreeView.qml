import QtQuick
import KmcUI.Controls 1.0
import QtQuick.Controls

TreeView {
    ScrollBar.vertical: MyScrollBar {}
    ScrollBar.horizontal: MyScrollBar {}
    property alias hovered: hoverHandler.hovered // for my scroll bar
    HoverHandler {
        id: hoverHandler
    }
}
