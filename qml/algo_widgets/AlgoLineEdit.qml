import QtQuick
import QtQuick.Controls.Basic
import CvTools

TextField {
    id: control
    wrapMode: TextEdit.Wrap
    verticalAlignment: TextEdit.AlignVCenter
    color: "#cccccc"
    placeholderTextColor: "#8E8E8E"
    selectionColor: "#0A67D6"
    selectedTextColor: "white"
    font.pointSize: 8
    property string fullText
    required property var widget
    placeholderText: widget?.placeholderText ?? ""
    maximumLength: widget?.maximumLength ?? -1
    Component.onCompleted: {
        if (widget.defaultValue !== undefined)
            fullText = widget.defaultValue
    }

    selectByMouse: true
    background: Rectangle {
        implicitWidth: 180
        implicitHeight: 27
        color: "#2A2A2A"
        radius: 3
        border.color: control.activeFocus ? "#0078D4" : "#444444"
    }

    text: activeFocus ? fullText : metrics.elidedText
    Popup {
        id: errorRect
        x: control.x
        y: control.y + control.height - 1
        padding: 0
        margins: 0
        visible: false
        width: control.width
        height: errorText.contentHeight + errorText.topPadding + errorText.bottomPadding
        background: Rectangle {
            border.color: "#BE1100"
            color: "#5A1D1D"
        }
        contentItem: Text {
            id: errorText
            topPadding: 6
            bottomPadding: topPadding
            leftPadding: control.leftPadding
            rightPadding: control.rightPadding
            font: control.font
            color: "#c7c7c7"
            text: widget?.validator.errorString ?? ""
            wrapMode: Text.WordWrap
        }
    }

    Connections {
        function onTextChanged() {
            if (control.text !== metrics.elidedText)
                control.fullText = control.text
            errorRect.visible = Number(widget.validator.validate(
                                           control.fullText,
                                           control.cursorPosition)) !== Enums.State.Acceptable
        }
        function onEditingFinished() {
            if (Number(widget.validator.validate(
                           control.fullText, control.cursorPosition)) !== Enums.State.Acceptable)
                control.fullText = widget.validator.fixup(control.fullText)
            widget.currentValue = control.fullText
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
