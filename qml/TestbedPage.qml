import QtQuick
import KmcUI.Effects
import QtQuick.Controls
import CvTools
import "./controls"

Item {
    id: root
    property SessionData sessionData
    property alias imageMouseArea: imageMouseArea

    onWidthChanged: {
        if (mask.children.length) {
            mask.children = []
            canvas.repaint()
            imageMouseArea.isSelecting = true
        }
    }
    onHeightChanged: {
        if (mask.children.length) {
            mask.children = []
            canvas.repaint()
            imageMouseArea.isSelecting = true
        }
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

    Keys.onEscapePressed: {
        imageMouseArea.finishSelection()
    }

    MySplitView {
        id: splitView
        anchors.fill: parent
        Item {
            id: container
            SplitView.fillHeight: true
            SplitView.fillWidth: true

            property int originX: (image.width - image.paintedWidth) / 2
            property int originY: (image.height - image.paintedHeight) / 2

            function isInPaintedImage(px, py) {
                // left-top of painted image
                return originX <= px && px <= originX + image.paintedWidth && originY <= py
                        && py <= originY + image.paintedHeight
            }
            Image {
                id: image
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
            }
            Image {
                id: clonedImage
                visible: root.sessionData?.isClonedView ?? false
                fillMode: Image.PreserveAspectFit
                anchors.fill: image
            }
            Rectangle {
                id: mask
                color: Qt.rgba(20 / 255, 20 / 255, 20 / 255, 0.6)
                anchors.fill: image
                visible: false

                property int dotRadius: 3

                function isInPaintedImage() {
                    for (var d of mask.data) {
                        if (!container.isInPaintedImage(d.centerX(), d.centerY()))
                            return false
                    }
                    return true
                }
            }

            Component {
                id: dot
                Rectangle {
                    id: path
                    radius: mask.dotRadius
                    width: radius * 2
                    height: width

                    function centerX() {
                        return x + radius
                    }
                    function centerY() {
                        return y + radius
                    }

                    function isInClickRange(x, y) {
                        return Math.abs(centerX() - x) <= 1.5 * radius && Math.abs(
                                    centerY() - y) <= 1.5 * radius
                    }

                    // for drag
                    property int cacheX: 0
                    property int cacheY: 0

                    property bool dragEnabled
                    onXChanged: {
                        if (!(container.originX <= x + radius
                              && x + radius <= container.originX + image.paintedWidth)) {
                            dragHandler.enabled = false
                            dotDragHandler.enabled = false
                        } else
                            dotDragHandler.enabled = dragEnabled
                    }
                    onYChanged: {
                        if (!(container.originY <= y + radius
                              && y + radius <= container.originY + image.paintedHeight)) {
                            dragHandler.enabled = false
                            dotDragHandler.enabled = false
                        } else
                            dotDragHandler.enabled = dragEnabled
                    }

                    color: "#0078D4"
                    Drag.source: path
                    Drag.active: dotDragHandler.active

                    DragHandler {
                        id: dotDragHandler
                        cursorShape: Qt.OpenHandCursor
                        onActiveChanged: {
                            if (!active) {
                                path.x = Math.max(container.originX,
                                                  Math.min(container.originX + image.paintedWidth,
                                                           path.centerX())) - path.radius
                                path.y = Math.max(container.originY,
                                                  Math.min(container.originY + image.paintedHeight,
                                                           path.centerY())) - path.radius
                            }
                        }
                    }
                }
            }

            Canvas {
                id: canvas
                width: image.width
                height: image.height
                Drag.active: dragHandler.active
                Drag.source: canvas
                DragHandler {
                    id: dragHandler
                    cursorShape: Qt.OpenHandCursor
                    enabled: false
                    onActiveTranslationChanged: {
                        for (var d of mask.data) {
                            d.x = activeTranslation.x + d.cacheX
                            d.y = activeTranslation.y + d.cacheY
                        }
                    }

                    onActiveChanged: {
                        if (active) {
                            for (var d of mask.data) {
                                d.cacheX = d.x
                                d.cacheY = d.y
                            }
                        } else {
                            for (d of mask.data) {
                                if (d.centerX() < container.originX) {
                                    var deltaX = container.originX - d.centerX()
                                    for (var p of mask.data)
                                        p.x += deltaX
                                } else if (d.centerX() > container.originX + image.paintedWidth) {
                                    deltaX = container.originX + image.paintedWidth - d.centerX()
                                    for (p of mask.data)
                                        p.x += deltaX
                                }

                                if (d.centerY() < container.originY) {
                                    var deltaY = container.originY - d.centerY()
                                    for (p of mask.data) {
                                        p.y += deltaY
                                    }
                                } else if (d.centerY() > container.originY + image.paintedHeight) {
                                    deltaY = container.originY + image.paintedHeight - d.centerY()
                                    for (p of mask.data)
                                        p.y += deltaY
                                }
                            }
                            canvas.x = canvas.y = 0
                            canvas.repaint()
                        }
                    }
                }

                visible: false
                contextType: "2d"
                onPaint: {
                    if (mask.children.length === 0)
                        return
                    let ctx = context
                    ctx.strokeStyle = "#0078D4"
                    ctx.fillStyle = "#449CDCFE"
                    ctx.beginPath()
                    ctx.moveTo(mask.children[0].centerX(), mask.children[0].centerY())
                    for (var i = 1; i < mask.children.length; ++i)
                        ctx.lineTo(mask.children[i].centerX(), mask.children[i].centerY())
                    if (!imageMouseArea.isSelecting)
                        ctx.closePath()
                    ctx.stroke()
                    ctx.fill()
                }

                function repaint() {
                    if (!dragHandler.active) {
                        context.clearRect(0, 0, canvas.width, canvas.height)
                        requestPaint()
                    }
                }

                function isInShape(x, y) {
                    return context?.isPointInPath(x, y) ?? false
                }
            }
            MouseArea {
                id: imageMouseArea
                anchors.fill: image
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                // the following properties is prepared for AlgoWidgets
                property int selectorType
                property int pointCount
                property bool isSelecting: false
                function startSelection() {
                    isSelecting = true
                    mask.visible = true
                    canvas.visible = true
                    canvas.repaint()
                }

                function finishSelection() {
                    isSelecting = false
                    let result = []
                    const originalSize = sessionData.imageSize
                    for (var child of mask.children) {
                        let projectedX = (child.centerX(
                                              ) - container.originX) * originalSize.width / image.paintedWidth
                        let projectedY = (child.centerY(
                                              ) - container.originY) * originalSize.height / image.paintedHeight
                        result.push(Qt.point(Math.min(Math.max(0, projectedX), originalSize.width),
                                             Math.min(Math.max(0, projectedY),
                                                      originalSize.height)))
                    }
                    mask.children = []
                    canvas.repaint()
                    mask.visible = false
                    canvas.visible = false
                    return result
                }

                onClicked: mouse => {

                               switch (selectorType) {
                                   case Enums.SelectorType.Polygon:
                                   case Enums.SelectorType.Auto:
                                   if (mouse.button === Qt.LeftButton) {
                                       if (!isSelecting || !container.isInPaintedImage(mouseX,
                                                                                       mouseY)) {
                                           return
                                       }
                                       if (mask.data.length > 2
                                           && selectorType === Enums.SelectorType.Auto
                                           && mask.data[0].isInClickRange(mouseX, mouseY)) {
                                           isSelecting = false
                                       } else {
                                           let d = dot.createObject(mask, {
                                                                        "x": mouseX - mask.dotRadius,
                                                                        "y": mouseY - mask.dotRadius,
                                                                        "dragEnabled": true
                                                                    })
                                           d.xChanged.connect(canvas.repaint)
                                           d.yChanged.connect(canvas.repaint)
                                           mask.data.push(d)
                                           if (mask.data.length === pointCount) {
                                               isSelecting = false
                                           }
                                       }
                                   } else if (mouse.button === Qt.RightButton) {
                                       mask.data = mask.data.filter(d => !d.isInClickRange(mouseX,
                                                                                           mouseY))
                                       isSelecting = true
                                   }

                                   canvas.repaint()
                                   break
                                   case Enums.SelectorType.Rectangular:
                               }
                           }

                onPressed: mouse => {
                               if (mouse.button !== Qt.LeftButton)
                               return
                               dragHandler.enabled = !isSelecting && canvas.isInShape(mouseX,
                                                                                      mouseY)
                               if (!isSelecting || !container.isInPaintedImage(mouseX, mouseY))
                               return

                               switch (selectorType) {
                                   case Enums.SelectorType.Polygon:
                                   break
                                   case Enums.SelectorType.Rectangular:

                                   for (var i = 0; i < 4; ++i) {
                                       let d = dot.createObject(mask, {
                                                                    "x": mouseX - mask.dotRadius,
                                                                    "y": mouseY - mask.dotRadius,
                                                                    "dragEnabled": Qt.binding(
                                                                                       () => !isSelecting)
                                                                })
                                       mask.children.push(d)
                                   }
                                   function connectXChanged(from, to) {
                                       mask.children[from].xChanged.connect(() => {
                                                                                if (mask.children[to].x
                                                                                    !== mask.children[from].x) {
                                                                                    mask.children[to].x
                                                                                    = mask.children[from].x
                                                                                    canvas.repaint()
                                                                                }
                                                                            })
                                   }
                                   function connectYChanged(from, to) {
                                       mask.children[from].yChanged.connect(() => {
                                                                                if (mask.children[to].y
                                                                                    !== mask.children[from].y) {
                                                                                    mask.children[to].y
                                                                                    = mask.children[from].y
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
                                   canvas.repaint()
                               }
                           }

                onPositionChanged: {
                    if (!isSelecting || !container.isInPaintedImage(mouseX, mouseY))
                        return
                    switch (selectorType) {
                    case Enums.SelectorType.Polygon:
                        break
                    case Enums.SelectorType.Rectangular:
                        if (mask.children.length === 0)
                            return
                        if (!pressed) {
                            isSelecting = false
                            return
                        }

                        mask.children[2].x = mouseX - mask.dotRadius
                        mask.children[2].y = mouseY - mask.dotRadius
                    }
                }

                onReleased: {
                    if (!isSelecting || !container.isInPaintedImage(mouseX, mouseY))
                        return
                    switch (selectorType) {
                    case Enums.SelectorType.Polygon:
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
