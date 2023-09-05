import QtQuick
import QtQuick.Controls
import CvTools

Item {
    id: root
    property SessionData sessionData

    Connections {
        target: imageProvider
        function onSourceChanged(source) {
            image.source = source
        }
    }

    Connections {
        function onSessionDataChanged() {}
    }

    Image {
        id: image
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => {
                     if (wheel.modifiers & Qt.ControlModifier) {

                         //                         adjustZoom(wheel.angleDelta.y / 120)
                     }
                 }
    }
}
