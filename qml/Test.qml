import QtQuick
import KmcUI
import KmcUI.Controls
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import "./components"
import QtQuick.Effects

Window {
    id: window
    width: 600
    height: 600
    visible: true
    color: "#181818"

    TextField {
        id: control
        wrapMode: TextEdit.Wrap
        verticalAlignment: TextEdit.AlignVCenter
        color: "#cccccc"
        placeholderTextColor: "#8E8E8E"
        font.pointSize: 8
        selectionColor: "white"

        property string fullText
        required property var widget
        validator: widget?.validator
        placeholderText: widget?.placeholder
        maximumLength: widget?.maximumLength

        selectByMouse: true
        background: Rectangle {
            implicitWidth: 180
            implicitHeight: 28
            color: "#2A2A2A"
            radius: 3
            border.color: control.activeFocus ? "#0078D4" : "#444444"
        }

        text: activeFocus ? fullText : metrics.elidedText

        Connections {
            function onTextChanged() {
                if (text !== metrics.elidedText)
                    fullText = text
            }
        }

        TextMetrics {
            id: metrics
            font: control.font
            text: control.fullText
            elide: Qt.ElideRight
            elideWidth: 180
        }
    }
}
