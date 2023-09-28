import QtQuick
import QtQuick.Controls.Basic
import KmcUI

ComboBox {
    id: control
    required property var widget
    textRole: "display"
    onCurrentTextChanged: {
        if (currentText)
            widget.currentValue = currentText
    }

    indicator: Canvas {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 7
        rotation: 90
        height: 19
        width: height
        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = "#dedfdf"
            const startX = 0.375 * width
            const startY = 0.25 * height
            ctx.moveTo(startX, startY)
            ctx.lineTo(width * 0.625, height / 2)
            ctx.lineTo(startX, height - startY)
            ctx.stroke()
        }
    }

    delegate: ItemDelegate {
        width: control.width - 2
        implicitHeight: 25
        contentItem: Text {
            text: model.display
            color: highlighted ? "white" : "#cccccc"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: highlighted ? "#1F1F1F" : "#323232"
        }

        Text {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: parent.padding
            }
            visible: model.display === widget.defaultValue
            text: "default"
            color: highlighted ? "white" : "#cccccc"
            font: control.font
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }

        highlighted: control.highlightedIndex === index
    }
    contentItem: Text {
        color: "#cccccc"
        text: control.currentText
        horizontalAlignment: Text.AlignLeft
        leftPadding: 5
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitHeight: 27
        implicitWidth: 180
        color: "#313131"
        radius: 3
        focus: true
        border.color: control.pressed ? "#444444" : (control.down ? "#0078D4" : "#444444")
    }
    popup: Popup {
        width: control.width
        y: control.height
        implicitHeight: contentItem.implicitHeight
        padding: 1
        background: KmcRectangle {
            leftBottomRadius: 3
            rightBottomRadius: 3
            border.color: "#0078D4"
            color: "#1F1F1F"
        }

        contentItem: Column {
            spacing: 2
            readonly property var toolTip: !!control.model ? control.model.data(
                                                                 control.model.index(
                                                                     control.highlightedIndex, 0),
                                                                 Qt.ToolTipRole) : undefined
            ListView {
                implicitHeight: contentHeight + 2
                implicitWidth: parent.width
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex
            }
            Rectangle {
                width: control.width
                visible: !!parent.toolTip
                height: 1
                color: "#3A3A3A"
            }

            Text {
                text: parent.toolTip ?? ""
                width: parent.width
                visible: !!parent.toolTip
                wrapMode: Text.WordWrap
                topPadding: 2
                leftPadding: 7
                rightPadding: 7
                bottomPadding: 6
                color: "#cccccc"
            }
        }
    }
}
