import QtQuick
import QtQuick.Layouts

StackLayout {
    id: control
    required property var layout
    required property var imageMouseArea
    Component.onCompleted: currentIndex = layout.currentIndex
    onCurrentIndexChanged: {
        if (control.currentIndex !== layout.currentIndex)
            layout.currentIndex = currentIndex
    }
    Connections {
        target: control.layout
        function onCurrentIndexChanged() {
            if (control.currentIndex !== layout.currentIndex)
                control.currentIndex = layout.currentIndex
        }
    }

    Repeater {
        id: repeater
        model: control.layout.layouts.length
        delegate: Loader {
            id: loader
            Layout.fillWidth: true
            property var model: control.layout.layouts[index]
            onModelChanged: {
                loader.setSource("./AlgoList.qml", {
                                     "model": loader.model,
                                     "imageMouseArea": control.imageMouseArea
                                 })
            }
        }
    }
}
