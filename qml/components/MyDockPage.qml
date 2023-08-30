import QtQuick

Item {
    property alias title: title.children
    property alias contentItem: loader.sourceComponent
    Rectangle {
        id: title
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 15
        color: "#1f1f1f"
    }
    Loader {
        id: loader
        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }
}
