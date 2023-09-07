import QtQuick
import KmcUI.Effects
import QtQuick.Controls
import CvTools
import "./components"

Item {
    id: root
    property SessionData sessionData

    signal clonedViewParamChanged(int algoIndex, var params)

    Connections {
        target: imageProvider
        function onSourceChanged() {
            const source = imageProvider.source
            const tokens = source.split("/")
            if (tokens[tokens.length - 2] === "0")
                image.source = source
            else
                clonedImage.source = source
        }
    }

    Connections {
        target: sessionData
        function onIsClonedViewChanged() {
            if (sessionData.isClonedView) {
                splitView.addItem(clonedViewToolBox)
            } else
                splitView.removeItem(clonedViewToolBox)
        }
    }
    MySplitView {
        id: splitView
        anchors.fill: parent
        Item {
            SplitView.fillHeight: true
            SplitView.fillWidth: true
            Image {
                id: image
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
            }
            Image {
                id: clonedImage
                visible: root.sessionData?.isClonedView ?? false
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
            }

            MySplitHandle {
                id: splitHandle
                height: parent.height
                width: 2
                visible: root.sessionData?.isClonedView ?? false
                onVisibleChanged: x = (root.width - width) / 2
                activeColor: "grey"
                MouseArea {
                    id: splitHandleMouseArea
                    drag.target: parent
                    drag.axis: Drag.XAxis
                    drag.smoothed: false
                    height: parent.height
                    width: parent.width
                    hoverEnabled: true
                    cursorShape: Qt.SplitHCursor
                    onContainsMouseChanged: {
                        if (containsMouse)
                            splitHandle.state = pressed ? "press" : "hover"
                        else
                            splitHandle.state = ""
                    }
                    drag.onActiveChanged: {
                        if (drag.active)
                            splitHandle.state = "press"
                    }
                    containmentMask: parent.containmentMask
                }
            }
        }
    }

    MyToolBox {
        id: clonedViewToolBox
        SplitView.preferredWidth: 200
    }
}
