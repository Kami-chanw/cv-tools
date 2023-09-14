import QtQuick
import QtQuick.Controls

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
        anchors.topMargin: -1
        height: errorText.contentHeight + errorText.topPadding + errorText.bottomPadding
        border.color: "#BE1100"
        visible: false
        color: "#5A1D1D"
        Text {
            id: errorText
            width: errorRect.width
            topPadding: 6
            bottomPadding: topPadding
            leftPadding: control.leftPadding
            rightPadding: control.rightPadding
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            font: control.font
            color: "#c7c7c7"
            text: widget?.validator.errorString ?? ""
            wrapMode: Text.Wrap
        }
    }

    Connections {
        function onTextChanged() {
            if (control.text !== metrics.elidedText)
                control.fullText = control.text
            errorRect.visible = Number(widget.validator.validate(
                                           control.fullText,
                                           control.cursorPosition)) === Enums.State.Invalid
        }
        function onEditingFinished() {
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
