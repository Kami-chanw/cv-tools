import QtQuick
import QtQuick.Layouts
import KmcUI.Controls

Item {
    ListModel {
        id: listModel
        ListElement {
            text: qsTr("Open an image or video")
            sequence: "Ctrl+O"
        }
        ListElement {
            text: qsTr("Go to settings page")
            sequence: "Ctrl+3"
        }
    }

    ColumnLayout {
        spacing: 20
        anchors.centerIn: parent
        Text {
            id: welcomeText
            color: "#cdcdcd"
            text: "No Image or Video Loaded"
            font.pointSize: 25
            font.weight: 300
            Layout.alignment: Qt.AlignCenter
            horizontalAlignment: Qt.AlignRight
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            spacing: 10
            Repeater {
                model: listModel
                delegate: RowLayout {
                    spacing: 10
                    Text {
                        horizontalAlignment: Qt.AlignRight
                        verticalAlignment: Qt.AlignVCenter
                        Layout.preferredWidth: 300
                        text: model.text
                        color: keySequenceText.palette.text
                        font.pointSize: 11
                    }
                    KeySequenceText {
                        id: keySequenceText
                        Layout.preferredWidth: 300
                        sequence: model.sequence
                        palette {
                            text: "#A9A9A9"
                        }
                    }
                }
            }
        }
    }
}
