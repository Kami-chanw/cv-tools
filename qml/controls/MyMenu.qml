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

    delegate: MyMenuItem {
        implicitWidth: control.implicitWidth
        implicitHeight: 30
        palette: control.palette
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
