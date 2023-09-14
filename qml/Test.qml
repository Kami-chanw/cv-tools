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
    width: 700
    height: 700
    visible: true

    TextField {
        id: control
        wrapMode: TextEdit.Wrap
        verticalAlignment: TextEdit.AlignVCenter
        color: "#cccccc"
        placeholderTextColor: "#8E8E8E"
        font.pointSize: 8
        selectionColor: "white"
        property string fullText
        //        required property var widget
        placeholderText: widget?.placeholderText ?? ""
        maximumLength: widget?.maximumLength ?? -1

        selectByMouse: true
        background: Rectangle {
            implicitWidth: 180
            implicitHeight: 27
            color: "#2A2A2A"
            radius: 3
            border.color: control.activeFocus ? "#0078D4" : "#444444"
        }

        text: activeFocus ? fullText : metrics.elidedText

        Rectangle {
            id: errorRect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.bottom
            implicitHeight: 28
            radius: 3
            border.color: "#BE1100"
            visible: false
            color: "#5A1D1D"
            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                font: control.font
                color: "white"
                text: widget?.validator.errorString ?? ""
                wrapMode: Text.WordWrap
            }
        }

        Connections {
            function onTextChanged() {
                if (control.text !== metrics.elidedText)
                    control.fullText = control.text
                console.log(Number(widget.validator.validate(control.fullText,
                                                             control.cursorPosition)))
                errorRect.visible = Number(widget.validator.validate(
                                               control.fullText,
                                               control.cursorPosition)) === IntValidator.Invalid
            }
            function onEditingFinished() {
                control.fullText = widget.validator.fixup(control.fullText)
                console.log("here")
                if (Number(widget.validator.validate(
                               control.fullText,
                               control.cursorPosition)) === IntValidator.Acceptable)
                    widget.currentValue = control.fullText
                else {
                    errorRect.visible = true
                }
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
