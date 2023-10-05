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
    contentHeight: list.height
    contentWidth: list.width
    boundsBehavior: Flickable.StopAtBounds

    height: list.height

    AlgoList {
        id: list
        model: root.model
        imageMouseArea: root.imageMouseArea
        width: root.width
    }
}
