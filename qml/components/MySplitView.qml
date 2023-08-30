import QtQuick
import QtQuick.Controls

SplitView {
    id: control
    handle: Rectangle {
        id: handleRect
        implicitWidth: 1

        color: "#313131"

        states: [
            State {
                name: "hover"
                PropertyChanges {
                    handleRect.width: 4
                    handleRect.color: "#0078D4"
                }
            },
            State {
                name: "press"
                PropertyChanges {
                    handleRect.width: 4
                    handleRect.color: "#0078D4"
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
                            target: handleRect
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
                    target: handleRect
                    property: "width"
                    duration: 130
                }
            }
        ]

        containmentMask: Item {
            height: handleRect.height
            width: 10
            x: (handleRect.width - width) / 2
        }
        SplitHandle.onHoveredChanged: {
            if (SplitHandle.hovered)
                handleRect.state = SplitHandle.pressed ? "press" : "hover"
            else
                handleRect.state = ""
        }
        SplitHandle.onPressedChanged: {
            if (SplitHandle.pressed)
                handleRect.state = "press"
        }
    }
}
