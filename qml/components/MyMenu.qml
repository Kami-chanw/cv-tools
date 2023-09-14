import QtQuick
import QtQuick.Controls
import KmcUI.Effects

Menu {
    id: control

    implicitWidth: 200

    palette {
        text: "#ffffff"
        base: "#15ffffff"
        inactive {
            base: "#1F1F1F"
            text: "#BFBFBF"
        }
        disabled {
            text: "#535353"
        }
    }

    onTitleChanged: () => {
                        for (var i = 0; i < title.length; ++i) {
                            if (title[i] === '&') {
                                shortcut.sequence = "Alt+" + title[i + 1]
                                title = title.replace(/&(.)/g, '<u>$1</u>')
                                return
                            }
                        }
                    }

    Shortcut {
        id: shortcut
        onActivated: control.open()
    }

    delegate: MenuItem {
        id: menuItem
        implicitWidth: control.implicitWidth
        implicitHeight: 30

        function textColor() {
            if (menuItem.enabled === false)
                return control.palette.disabled.text
            return menuItem.highlighted ? control.palette.text : control.palette.inactive.text
        }

        arrow: Canvas {
            x: parent.width - width - 6
            implicitWidth: menuItem.height
            implicitHeight: menuItem.height
            visible: menuItem.subMenu
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = menuItem.textColor()
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
                leftPadding: menuItem.indicator.width
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                text: menuItem.text
                font: menuItem.font
                color: menuItem.textColor()
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                rightPadding: menuItem.arrow.width
                text: menuItem.action?.shortcut?.toString() ?? ""
                font: menuItem.font
                color: menuItem.textColor()
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        background: Item {
            implicitWidth: menuItem.implicitWidth
            implicitHeight: menuItem.implicitHeight
            Rectangle {
                radius: 4
                anchors {
                    fill: parent
                    leftMargin: 4
                    rightMargin: anchors.leftMargin
                    topMargin: 3
                    bottomMargin: anchors.topMargin
                }

                opacity: enabled ? 1 : 0.3
                color: menuItem.highlighted ? control.palette.active.base : control.palette.inactive.base
            }
        }
    }

    background: Item {
        implicitHeight: 34
        implicitWidth: control.implicitWidth
        RectangularGlow {
            anchors.fill: menuBackground
            color: "#000000"
            glowRadius: 3
            cornerRadius: menuBackground.radius + glowRadius
        }

        Rectangle {
            id: menuBackground
            anchors.fill: parent
            color: control.palette.inactive.base
            border {
                width: 1
                color: "#454545"
            }
            radius: 6
        }
    }
}
