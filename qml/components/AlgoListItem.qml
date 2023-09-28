import QtQuick
import QtQuick.Controls
import CvTools
import "../controls"
import "../algo_controls"

Flickable {
    id: root
    required property var model
    required property var imageMouseArea
    HoverHandler {
        id: hoverHandler
    }
    property alias hovered: hoverHandler.hovered
    ScrollBar.vertical: MyScrollBar {}
    ScrollBar.horizontal: MyScrollBar {}
    contentHeight: Math.max(240, list.height)
    contentWidth: list.width
    boundsBehavior: Flickable.StopAtBounds

    height: Math.max(240, list.height)

    AlgoList {
        id: list
        model: root.model
        imageMouseArea: root.imageMouseArea
        width: root.width
    }
}
