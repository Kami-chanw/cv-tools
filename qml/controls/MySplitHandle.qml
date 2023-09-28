import QtQuick

Rectangle {
    id: control
    implicitWidth: 1

    color: "#313131"
    property color activeColor: "#0078D4"

    states: [
        State {
            name: "hover"
            PropertyChanges {
                control.width: 4
                control.color: control.activeColor
            }
        },
        State {
            name: "press"
            PropertyChanges {
                control.width: 4
                control.color: control.activeColor
            }
        }
    ]

    transitions: [
        Transition {
            to: "hover"
            SequentialAnimation {
                PauseAnimation {
                    duration: 300
                }
                ParallelAnimation {
                    ColorAnimation {
                        duration: 130
                    }
                    NumberAnimation {
                        target: control
                        property: "width"
                        duration: 130
                    }
                }
            }
        },
        Transition {
            ColorAnimation {
                duration: 130
            }
            NumberAnimation {
                target: control
                property: "width"
                duration: 130
            }
        }
    ]

    containmentMask: Item {
        height: control.height
        width: 10
        x: (control.width - width) / 2
    }
}
