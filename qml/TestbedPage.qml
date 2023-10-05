import QtQuick
import KmcUI.Effects
import QtQuick.Controls
import CvTools
import "./controls"
import "./components"

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
                contrastImage.source = source
        }
    }

    Connections {
        target: sessionData
        function onIsContrastViewChanged() {
            if (sessionData.isContrastView) {
                splitView.addItem(contrastViewToolBox)
            } else
                splitView.removeItem(contrastViewToolBox)
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

            property point origin: root.sessionData?.isFixedView ? Qt.point(
                                                                       (image.width - image.paintedWidth)
                                                                       / 2, (image.height
                                                                             - image.paintedHeight) / 2) : Qt.point(
                                                                       image.x + (1 - image.scale) * image.width
                                                                       / 2, image.y + (1 - image.scale)
                                                                       * image.height / 2)

            property int validWidth: image.scale * image.paintedWidth
            property int validHeight: image.scale * image.paintedHeight
            property int imageWidth: root.sessionData?.imageSize.width ?? 0
            property int imageHeight: root.sessionData?.imageSize.height ?? 0

            function isInValidRegion(px, py) {
                return origin.x <= px && px <= origin.x + validWidth && origin.y <= py
                        && py <= origin.y + validHeight
            }

            MouseArea {
                id: imageMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: dragHandler.enabled ? Qt.SizeAllCursor : Qt.ArrowCursor

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
                    for (var child of mask.children) {
                        let projectedX = (child.centerX(
                                              ) - container.origin.x) * container.imageWidth / container.validWidth
                        let projectedY = (child.centerY(
                                              ) - container.origin.y) * container.imageHeight / container.validHeight
                        result.push(Qt.point(Math.min(Math.max(0, projectedX),
                                                      container.imageWidth),
                                             Math.min(Math.max(0, projectedY),
                                                      container.imageHeight)))
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
                                       if (!isSelecting || !container.isInValidRegion(mouseX,
                                                                                      mouseY)) {

                                           return
                                       }
                                       let d = dot.createObject(mask, {
                                                                    "x": mouseX - mask.dotRadius,
                                                                    "y": mouseY - mask.dotRadius,
                                                                    "dragEnabled": true
                                                                })
                                       d.xChanged.connect(canvas.repaint)
                                       d.yChanged.connect(canvas.repaint)
                                       mask.children.push(d)
                                       if (mask.children.length === pointCount) {
                                           isSelecting = false
                                       }
                                   }

                                   canvas.repaint()
                                   break
                                   case Enums.SelectorType.Rectangular:
                               }
                           }

                onPressed: mouse => {
                               if (mouse.button !== Qt.LeftButton)
                               return
                               if (!isSelecting || !container.isInValidRegion(mouseX, mouseY))
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
                    if (!isSelecting || !container.isInValidRegion(mouseX, mouseY))
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
                    if (!isSelecting || !container.isInValidRegion(mouseX, mouseY))
                        return
                    switch (selectorType) {
                    case Enums.SelectorType.Polygon:
                        break
                    case Enums.SelectorType.Rectangular:
                        isSelecting = false
                    }
                }
            }

            Image {
                id: image
                WheelHandler {
                    id: imgWheelHandler
                    property: "scale"
                    acceptedModifiers: Qt.ControlModifier
                    enabled: !mask.visible
                }

                DragHandler {
                    acceptedModifiers: Qt.ControlModifier
                    enabled: imgWheelHandler.enabled
                }

                states: [
                    State {
                        when: !root.sessionData?.isFixedView ?? true
                        PropertyChanges {
                            image {
                                width: root.sessionData?.imageSize.width
                                height: root.sessionData?.imageSize.widt
                            }
                        }
                    },
                    State {
                        when: root.sessionData?.isFixedView ?? false
                        PropertyChanges {
                            image {
                                anchors.fill: container
                                fillMode: Image.PreserveAspectFit
                                scale: 1
                            }
                            imgWheelHandler.enabled: false
                        }
                    }
                ]

                onStateChanged: {
                    if (state === "") {
                        width = root.sessionData?.imageSize.width
                        height = root.sessionData?.imageSize.height
                    }
                }
            }

            Rectangle {
                color: "#66cdcdcd"
                x: container.origin.x
                y: container.origin.y

                width: image.width
                height: image.height
            }

            Image {
                id: contrastImage
                visible: root.sessionData?.isContrastView ?? false
                fillMode: image.fillMode
                anchors.fill: image
            }
            Rectangle {
                id: mask
                color: Qt.rgba(20 / 255, 20 / 255, 20 / 255, 0.6)
                anchors.fill: parent
                visible: false

                property int dotRadius: 3
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

                    // for drag
                    property int cacheX: 0
                    property int cacheY: 0

                    property alias dragEnabled: dotDragHandler.enabled
                    color: "#0078D4"
                    Drag.source: path
                    Drag.active: dotDragHandler.active

                    TapHandler {
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onTapped: (_, button) => {
                                      if (button & Qt.LeftButton) {
                                          if (mask.children.length > 2
                                              && imageMouseArea.selectorType === Enums.SelectorType.Auto
                                              && path === mask.children[0]) {
                                              imageMouseArea.isSelecting = false
                                              canvas.repaint()
                                          }
                                      } else {
                                          if (imageMouseArea.selectorType !== Enums.SelectorType.Rectangular) {
                                              mask.children = mask.children.filter(d => d !== path)
                                              imageMouseArea.isSelecting = true
                                              canvas.repaint()
                                          }
                                      }
                                  }
                    }

                    HoverHandler {
                        cursorShape: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    DragHandler {
                        id: dotDragHandler
                        onActiveChanged: {
                            if (!active) {
                                path.x = Math.max(container.origin.x,
                                                  Math.min(container.origin.x + image.paintedWidth,
                                                           path.centerX())) - path.radius
                                path.y = Math.max(container.origin.y, Math.min(
                                                      container.origin.y + image.paintedHeight,
                                                      path.centerY())) - path.radius
                            }
                        }
                    }
                }
            }

            Canvas {
                id: canvas
                width: imageMouseArea.width
                height: imageMouseArea.height
                Drag.active: dragHandler.active
                Drag.source: canvas

                DragHandler {
                    id: dragHandler
                    enabled: active || (!imageMouseArea.isSelecting && canvas.isInShape(
                                            imageMouseArea.mouseX, imageMouseArea.mouseY))
                    onActiveTranslationChanged: {
                        for (var d of mask.children) {
                            d.x = activeTranslation.x + d.cacheX
                            d.y = activeTranslation.y + d.cacheY
                        }
                    }

                    onActiveChanged: {
                        if (active) {
                            for (var d of mask.children) {
                                d.cacheX = d.x
                                d.cacheY = d.y
                            }
                        } else {
                            for (d of mask.children) {
                                if (d.centerX() < container.origin.x) {
                                    var deltaX = container.origin.x - d.centerX()
                                    for (var p of mask.children)
                                        p.x += deltaX
                                } else if (d.centerX(
                                               ) > container.origin.x + container.validWidth) {
                                    deltaX = container.origin.x + container.validWidth - d.centerX()
                                    for (p of mask.children)
                                        p.x += deltaX
                                }

                                if (d.centerY() < container.origin.y) {
                                    var deltaY = container.origin.y - d.centerY()
                                    for (p of mask.children) {
                                        p.y += deltaY
                                    }
                                } else if (d.centerY(
                                               ) > container.origin.y + container.validHeight) {
                                    deltaY = container.origin.y + container.validHeight - d.centerY(
                                                )
                                    for (p of mask.children)
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
                    if (!imageMouseArea.isSelecting
                            || imageMouseArea.selectorType === Enums.SelectorType.Rectangular)
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
                    // canvas.isInShape will crash the app if 4 points at the same place
                    if (imageMouseArea.selectorType === Enums.SelectorType.Rectangular)
                        for (var i = 1; i < mask.children.length; ++i) {
                            if (mask.children[i].x - mask.children[0].x < 1
                                    && mask.children[i].y - mask.children[0].y < 1)
                                return false
                        }
                    return mask.children.length > 2 && (context?.isPointInPath(x, y) ?? false)
                }
            }

            MySplitHandle {
                id: splitHandle
                height: parent.height
                width: 2
                visible: root.sessionData?.isContrastView ?? false
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

    SidePage {
        id: contrastViewToolBox
        SplitView.preferredWidth: 200
        color: "#181818"
        title: "Contrast"
        algoModel: root.sessionData?.algoModel[1]
        imageMouseArea: imageMouseArea
    }
}
