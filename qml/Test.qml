import QtQuick
import KmcUI
import KmcUI.Controls
import QtQuick.Controls.Basic
import QtQuick.Shapes
import "./components"
import QtQuick.Effects
import CvTools

Window {
    id: window
    width: 400
    height: 400
    visible: true
    color: "#181818"
    Component {
        id: dele
        Rectangle {
            color: "#1f1f1f"

            Text {
                anchors.centerIn: parent
                text: "hello"
                color: "#cccccc"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    ShaderEffectSource {
        id: dragTarget
        sourceItem: loader
        width: 200
        height: 200
        anchors {
            top: parent.top
            left: parent.left
        }
        Drag.active: dragHandler.active
        opacity: dragHandler.active ? 0.7 : 0
        z: dragHandler.active ? 1 : 0

        DragHandler {
            id: dragHandler
            onActiveChanged: {
                if (active) {
                    tapHandler.pressX = tapHandler.point.position.x
                    tapHandler.pressY = tapHandler.point.position.y
                }
            }
        }
        PointHandler {
            id: tapHandler
            property int pressX
            property int pressY
        }

        states: [
            State {
                when: dragHandler.active
                AnchorChanges {
                    target: dragTarget
                    anchors {
                        left: undefined
                        top: undefined
                    }
                }
            }
        ]
    }
    Loader {
        id: loader
        width: 200
        height: 200
        anchors {
            top: parent.top
            left: parent.left
        }

        sourceComponent: dele
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }
}
