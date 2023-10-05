import QtQuick
import QtQuick.Controls

MenuItem {
    id: control
    readonly property int textPadding: contentText.leftPadding + backgroundRect.anchors.leftMargin + 6

    readonly property color textColor: {
        if (!control.enabled)
            return control.palette.disabled.text
        return control.highlighted ? control.palette.text : control.palette.inactive.text
    }

    indicator: Canvas {
        x: (control.textPadding - width) / 2
        implicitWidth: control.height - 11
        implicitHeight: control.height - 11
        anchors.verticalCenter: parent.verticalCenter
        visible: control.checked
        contextType: "2d"
        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = control.palette.text
            ctx.moveTo(width * 0.22, height * 0.5)
            ctx.lineTo(width * 0.38, 0.72 * height)
            ctx.lineTo(width * 0.72, height * 0.33)
            ctx.stroke()
        }
    }

    arrow: Canvas {
        x: parent.width - width - 6
        implicitWidth: control.height
        implicitHeight: control.height
        anchors.verticalCenter: parent.verticalCenter
        visible: control.subMenu
        contextType: "2d"
        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = textColor
            const leftTop = width * 0.35
            const right = width * 0.5
            ctx.moveTo(leftTop, leftTop)
            ctx.lineTo(right, height / 2)
            ctx.lineTo(leftTop, height - leftTop)
            ctx.stroke()
        }
    }

    contentItem: Item {
        Text {
            id: contentText
            leftPadding: 23
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            text: control.text
            font: control.font
            color: textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            rightPadding: control.arrow.width
            text: control.action?.shortcut?.toString() ?? ""
            font: control.font
            color: textColor
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    background: Item {
        Rectangle {
            id: backgroundRect
            radius: 4
            anchors {
                fill: parent
                leftMargin: 4
                rightMargin: anchors.leftMargin
                topMargin: 3
                bottomMargin: anchors.topMargin
            }

            opacity: enabled ? 1 : 0.3
            color: control.highlighted ? control.palette.active.base : control.palette.inactive.base
        }
    }
}
