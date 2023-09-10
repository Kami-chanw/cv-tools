import QtQuick
import QtQuick.Controls
import "./components"

Flickable {
    id: control
    property var model
    HoverHandler {
        id: hoverHandler
    }

    property alias hovered: hoverHandler.hovered
    ScrollBar.vertical: MyScrollBar {}
    ScrollBar.horizontal: MyScrollBar {}
    Column {
        Repeater {
            id: repeater
            model: control.model
        }
    }
}
