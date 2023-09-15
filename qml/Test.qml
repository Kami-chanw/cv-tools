import QtQuick
import KmcUI
import KmcUI.Controls
import QtQuick.Controls.Basic
import QtQuick.Shapes
import "./components"
import "./algo_widgets"
import QtQuick.Effects
import CvTools

Window {
    id: window
    width: 400
    height: 400
    visible: true
    color: "#181818"
    CheckBox {
        anchors.centerIn: parent
        id: control
        //        required property var widget
        text: "Example text"
        //        Component.onCompleted: checked = Boolean(widget?.defaultValue)
        //        onCheckedChanged: widget.currentValue = checked
        contentItem: Text {
            text: control.text
            font: control.font
            color: "#bbbbbb"
            verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.spacing
        }

        indicator: Rectangle {
            radius: 3
            x: control.leftPadding
            y: parent.height / 2 - height / 2
            implicitHeight: 20
            implicitWidth: implicitHeight
            border.color: control.pressed ? "#3c3c3c" : (control.activeFocus ? "#0078D4" : "#3c3c3c")
            color: "#313131"
            ColorIcon {
                anchors.centerIn: parent
                visible: control.checked
                width: 15
                height: 15
                color: "#cccccc"
                source: "qrc:/assets/icons/check.svg"
            }
        }
    }
    //    Component {
    //        id: dele
    //        ItemDelegate {
    //            background: Rectangle {
    //                color: "#1f1f1f"
    //            }

    //            contentItem: Text {
    //                text: "hello"
    //                color: "#cccccc"
    //                verticalAlignment: Text.AlignVCenter
    //                horizontalAlignment: Text.AlignHCenter
    //            }

    //            onHoveredChanged: console.log(123)
    //        }
    //    }

    //    Loader {
    //        id: boxLoader
    //        anchors.centerIn: parent
    //        width: 200
    //        height: 200
    //        sourceComponent: dele
    //    }

    //    Loader {
    //        id: dragTarget
    //        width: boxLoader.width
    //        height: boxLoader.height
    //        anchors {
    //            top: boxLoader.top
    //            left: boxLoader.left
    //        }

    //        sourceComponent: dele
    //        opacity: mouseArea.drag.active ? 0.7 : 0
    //        Drag.active: mouseArea.drag.active
    //        MouseArea {
    //            id: mouseArea
    //            anchors.fill: parent
    //            hoverEnabled: true
    //            drag.target: dragTarget
    //            onContainsMouseChanged: {
    //                console.log(1234)
    //            }
    //        }
    //        states: [
    //            State {
    //                when: mouseArea.drag.active
    //                AnchorChanges {
    //                    target: dragTarget
    //                    anchors {
    //                        left: undefined
    //                        top: undefined
    //                    }
    //                }
    //            }
    //        ]
    //    }
}
