import QtQuick
import QtQuick.Controls

TextField {
    id: control
    wrapMode: TextEdit.Wrap
    verticalAlignment: TextEdit.AlignVCenter
    color: "#cccccc"
    placeholderTextColor: "#8E8E8E"
    font.pointSize: 8
    selectionColor: "white"
    validator: widget?.validator
    property string fullText
    required property var widget
    placeholderText: widget?.placeholderText
    maximumLength: widget?.maximumLength

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
        anchors.top: parent.top
        implicitHeight: 28
        border.color: "#BE1100"
        color: "#5A1D1D"
        Text {
            font: control.font
            text: widget?.validator.errorString ?? ""
        }
    }

    Connections {
        function onTextChanged() {
            if (text !== metrics.elidedText)
                fullText = text
            errorRect.visible = widget.validator.validate(
                        fullText, cursorPosition) === Enums.Validator.Invalid
        }
        function onEditingFinished() {
            fullText = widget.validator(fullText)
            if (result === Enums.Validator.Acceptable)
                widget.currentValue = fullText
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
