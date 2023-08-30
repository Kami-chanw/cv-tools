import QtQuick
import QtQuick.Controls

Menu {
    id: control

    palette {
        text: "#ffffff"
        base: "#15ffffff"
        inactive {
            base: "#1F1F1F"
            text: "#BFBFBF"
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
        implicitWidth: 200
        implicitHeight: 34

        arrow: Canvas {
            x: parent.width - width - 6
            implicitWidth: menuItem.height
            implicitHeight: menuItem.height
            visible: menuItem.subMenu
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = menuItem.highlighted ? control.palette.text : control.palette.inactive.text
                const leftTop = width * 0.35
                const right = width * 0.5
                ctx.moveTo(leftTop, leftTop)
                ctx.lineTo(right, height / 2)
                ctx.lineTo(leftTop, height - leftTop)
                ctx.stroke()
            }
        }

        contentItem: Text {
            leftPadding: menuItem.indicator.width
            rightPadding: menuItem.arrow.width
            text: menuItem.text
            font: menuItem.font
            color: menuItem.highlighted ? control.palette.text : control.palette.inactive.text
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
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

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 34
        color: control.palette.inactive.base
        border {
            width: 1
            color: "#454545"
        }
        radius: 6
    }
}
