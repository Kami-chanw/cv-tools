import QtQuick
import QtQuick.Controls

SplitView {
    id: control
    handle: MySplitHandle {
        id: handleRect
        SplitHandle.onHoveredChanged: {
            if (SplitHandle.hovered)
                handleRect.state = SplitHandle.pressed ? "press" : "hover"
            else
                handleRect.state = ""
        }
        SplitHandle.onPressedChanged: {
            if (SplitHandle.pressed)
                handleRect.state = "press"
        }
    }
}
