import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Controls.Fusion
import QtQuick.Controls.Fusion.impl

ScrollBar {
    id: control
    padding: 2
    visible: control.policy !== ScrollBar.AlwaysOff

    contentItem: Rectangle {
        implicitWidth: 14
        implicitHeight: 14

        color: "white"
        opacity: 0.0

        states: [
            State {
                name: "active"
                when: control.policy === ScrollBar.AlwaysOn || (parent.hovered && !control.hovered
                                                                && control.size < 1.0)
                PropertyChanges {
                    control.contentItem.opacity: 0.08
                }
            },
            State {
                name: "hover"
                when: control.hovered && !control.pressed && (control.policy === ScrollBar.AlwaysOn
                                                              || control.size < 1.0)
                PropertyChanges {
                    control.contentItem.opacity: 0.1
                }
            },
            State {
                name: "press"
                when: control.pressed && (control.policy === ScrollBar.AlwaysOn
                                          || control.size < 1.0)
                PropertyChanges {
                    control.contentItem.opacity: 0.22
                }
            }
        ]

        transitions: [
            Transition {
                to: ""
                NumberAnimation {
                    target: control.contentItem
                    duration: 1500
                    property: "opacity"
                }
            },
            Transition {
                to: "active"
                NumberAnimation {
                    target: control.contentItem
                    duration: 50
                    property: "opacity"
                }
            }
        ]
    }
}
