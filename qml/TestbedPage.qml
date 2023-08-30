import QtQuick
import QtQuick.Controls

SplitView {
    property alias text: content.text
    Text {
        id: content
        SplitView.fillHeight: true
        SplitView.fillWidth: true
        verticalAlignment: Qt.AlignTop
        horizontalAlignment: Qt.AlignLeft
    }
}
