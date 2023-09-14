import QtQuick
import QtQuick.Controls.Basic

Row {
    id: control
    spacing: 5
    required property var widget
    required property var imageMouseArea

    Component.onCompleted: {
        imageMouseArea.selectorType = widget.selectorType
    }

    Button {
        id: confirm
        topPadding: 0
        bottomPadding: topPadding
        leftPadding: 12
        rightPadding: leftPadding
        contentItem: Text {
            text: confirm.text
            font: confirm.font
            color: confirm.enabled ? "white" : "#7C7D7E"
            topPadding: 0
            bottomPadding: topPadding
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: confirm.enabled ? (confirm.down
                                      || confirm.hovered ? "#026EC1" : "#0078D4") : "#16476D"
            border.color: confirm.down || confirm.hovered ? "#1478C5" : "#1282D7"
            implicitHeight: 24
            implicitWidth: 80
            radius: 3
        }

        onClicked: {
            if (control.state === "ready") {
                control.state = "selecting"
                control.imageMouseArea.startSelection()
            } else {
                control.state = "ready"
                widget.currentValue = control.imageMouseArea.finishSelection()
            }
        }
    }
    Button {
        id: cancel
        text: "Cancel"
        topPadding: confirm.topPadding
        bottomPadding: confirm.topPadding
        leftPadding: confirm.leftPadding
        rightPadding: confirm.leftPadding
        contentItem: Text {
            text: cancel.text
            font: cancel.font
            color: "#cccccc"
            topPadding: 0
            bottomPadding: topPadding
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: cancel.down || cancel.hovered ? "#3C3C3C" : "#313131"
            border.color: cancel.down || cancel.hovered ? "#232425" : "#1F1F1F"
            implicitHeight: 25 // due to unknown reason, cancel button is a bit shorter than confirm button if they actually have the same height
            implicitWidth: 80
            radius: 3
        }

        onClicked: {
            control.state = "ready"
            control.imageMouseArea.finishSelection()
        }
    }

    state: "ready"

    states: [
        State {
            name: "ready"
            PropertyChanges {
                confirm.text: "Start Selection"
                confirm.enabled: true
                cancel {
                    visible: false
                }
            }
        },
        State {
            name: "selecting"
            PropertyChanges {
                confirm.text: "Confirm"
                confirm.enabled: !control.imageMouseArea.isSelecting
                cancel.visible: true
            }
        }
    ]
}
