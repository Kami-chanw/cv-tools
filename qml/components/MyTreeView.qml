import QtQuick
import KmcUI.Controls 1.0
import QtQuick.Controls

KmcTreeView {
    ScrollBar.vertical: MyScrollBar {}
    ScrollBar.horizontal: MyScrollBar {}
    property alias hovered: hoverHandler.hovered // for my scrol bar
    HoverHandler {
        id: hoverHandler
    }
}
