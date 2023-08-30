import QtQuick
import QtQuick.Controls.Basic

TextField {
    id: control
    wrapMode: TextEdit.Wrap
    verticalAlignment: TextEdit.AlignVCenter
    color: "#cccccc"
    font.pointSize: 8

    property string fullText

    selectByMouse: true
    background: Rectangle {
        implicitWidth: 200
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
