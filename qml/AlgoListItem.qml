import QtQuick
import QtQuick.Controls
import CvTools
import "./components"
import "./algo_components"

Flickable {
    id: control
    property alias model: list.model
    required property var imageMouseArea
    HoverHandler {
        id: hoverHandler
    }

    property alias hovered: hoverHandler.hovered
    ScrollBar.vertical: MyScrollBar {}
    ScrollBar.horizontal: MyScrollBar {}
    contentHeight: Math.min(500, list.height)
    contentWidth: list.width
    boundsBehavior: Flickable.StopAtBounds

    height: Math.min(500, list.height)

    AlgoList {
        id: list
        imageMouseArea: control.imageMouseArea
        width: control.width
    }
}
