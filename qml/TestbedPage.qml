import QtQuick
import KmcUI.Effects
import QtQuick.Controls
import CvTools
import "./components"

Item {
    id: root
    property SessionData sessionData
    property alias imageMouseArea: imageMouseArea

    onWidthChanged: {
        mask.children = []
        canvas.repaint()
        imageMouseArea.isSelecting = true
    }
    onHeightChanged: {
        mask.children = []
        canvas.repaint()
        imageMouseArea.isSelecting = true
    }

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
            Rectangle {
                id: mask
                color: Qt.rgba(20 / 255, 20 / 255, 20 / 255, 0.6)
                anchors.fill: image
                visible: false
            }

            Component {
                id: dot
                Rectangle {
                    id: path
                    radius: 3
                    width: radius * 2
                    height: width
                    required property int centerX
                    required property int centerY
                    property alias dragEnabled: dragHandler.enabled
                    x: centerX - radius
                    y: centerY - radius
                    onXChanged: {
                        centerX = x + radius
                        dragHandler.enabled = imageMouseArea.containsInPaintedImage(x, y)
                    }
                    onYChanged: {
                        centerY = y + radius
                        dragHandler.enabled = imageMouseArea.containsInPaintedImage(x, y)
                    }

                    color: "#0078D4"
                    Drag.source: path
                    Drag.active: dragHandler.active
                    DragHandler {
                        id: dragHandler
                        cursorShape: Qt.OpenHandCursor
                    }
                }
            }

            Canvas {
                id: canvas
                anchors.fill: parent
                visible: false
                contextType: "2d"
                onPaint: {
                    if (mask.children.length === 0)
                        return
                    let ctx = context
                    ctx.strokeStyle = "#0078D4"
                    ctx.fillStyle = "#449CDCFE"
                    ctx.beginPath()
                    ctx.moveTo(mask.children[0].centerX, mask.children[0].centerY)
                    for (var i = 1; i < mask.children.length; ++i)
                        ctx.lineTo(mask.children[i].centerX, mask.children[i].centerY)
                    ctx.closePath()
                    ctx.stroke()
                    ctx.fill()
                }

                function repaint() {
                    context.clearRect(0, 0, canvas.width, canvas.height)
                    requestPaint()
                }
            }
            MouseArea {
                id: imageMouseArea
                anchors.fill: image
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton

                // the following properties is prepared for AlgoWidgets
                property int selectorType: 0
                property int pointCount: 4
                property bool isSelecting: false
                function startSelection() {
                    isSelecting = true
                    mask.visible = true
                    canvas.visible = true
                }

                function finishSelection() {
                    isSelecting = false
                    let result = []
                    const originalSize = sessionData.imageSize
                    for (var child of mask.children) {
                        let projectedX = (child.centerX - (image.width - image.paintedWidth) / 2)
                            * originalSize.width / image.paintedWidth
                        let projectedY = (child.centerY - (image.height - image.paintedHeight) / 2)
                            * originalSize.height / image.paintedHeight
                        result.push(Qt.point(Math.min(Math.max(0, projectedX), image.paintedWidth),
                                             Math.min(Math.max(0, projectedY),
                                                      image.paintedHeight)))
                    }
                    mask.children = []
                    canvas.repaint()
                    mask.visible = false
                    canvas.visible = false
                    return result
                }

                function containsInPaintedImage(px, py) {
                    // left-top of painted image
                    const x = (image.width - image.paintedWidth) / 2
                    const y = (image.height - image.paintedHeight) / 2
                    return x <= px && px <= x + image.paintedWidth && y <= py
                            && py <= y + image.paintedHeight
                }

                onClicked: {
                    if (!isSelecting || !containsInPaintedImage(mouseX, mouseY))
                        return
                    switch (selectorType) {
                    case Enums.SelectorType.Polygen:
                        let length = mask.data.length
                        let d = dot.createObject(mask, {
                                                     "centerX": mouseX,
                                                     "centerY": mouseY,
                                                     "dragEnabled": Qt.binding(() => !isSelecting)
                                                 })
                        d.xChanged.connect(canvas.repaint)
                        d.yChanged.connect(canvas.repaint)
                        mask.data.push(d)
                        if (mask.data.length === pointCount)
                            isSelecting = false

                        break
                    case Enums.SelectorType.Rectangular:
                    }

                    canvas.repaint()
                }

                onPressed: {
                    if (!isSelecting || !containsInPaintedImage(mouseX, mouseY))
                        return
                    switch (selectorType) {
                    case Enums.SelectorType.Polygen:
                        break
                    case Enums.SelectorType.Rectangular:

                        for (var i = 0; i < 4; ++i) {
                            let d = dot.createObject(mask, {
                                                         "centerX": mouseX,
                                                         "centerY": mouseY,
                                                         "dragEnabled": Qt.binding(
                                                                            () => !isSelecting)
                                                     })
                            mask.children.push(d)
                        }
                        function connectXChanged(from, to) {
                            mask.children[from].xChanged.connect(() => {
                                                                     if (mask.children[to].x
                                                                         !== mask.children[from].x) {
                                                                         mask.children[to].x = mask.children[from].x
                                                                         canvas.repaint()
                                                                     }
                                                                 })
                        }
                        function connectYChanged(from, to) {
                            mask.children[from].yChanged.connect(() => {
                                                                     if (mask.children[to].y
                                                                         !== mask.children[from].y) {
                                                                         mask.children[to].y = mask.children[from].y
                                                                         canvas.repaint()
                                                                     }
                                                                 })
                        }
                        connectXChanged(0, 3)
                        connectYChanged(0, 1)
                        connectXChanged(1, 2)
                        connectYChanged(1, 0)
                        connectXChanged(2, 1)
                        connectYChanged(2, 3)
                        connectXChanged(3, 0)
                        connectYChanged(3, 2)
                    }

                    canvas.repaint()
                }

                onPositionChanged: {
                    if (!isSelecting || !containsInPaintedImage(mouseX, mouseY))
                        return
                    switch (selectorType) {
                    case Enums.SelectorType.Polygen:
                        break
                    case Enums.SelectorType.Rectangular:
                        if (mask.children.length === 0)
                            return
                        else if (!pressed) {
                            isSelecting = false
                            return
                        }

                        mask.children[2].centerX = mouseX
                        mask.children[2].centerY = mouseY
                    }
                    canvas.repaint()
                }

                onReleased: {
                    if (!isSelecting || !containsInPaintedImage(mouseX, mouseY))
                        return
                    switch (selectorType) {
                    case Enums.SelectorType.Polygen:
                        break
                    case Enums.SelectorType.Rectangular:
                        isSelecting = false
                    }
                }
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
