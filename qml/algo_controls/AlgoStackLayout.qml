import QtQuick
import QtQuick.Layouts

StackLayout {
    id: control
    required property var layout
    required property var imageMouseArea

    onCurrentIndexChanged: {
        if (layout && control.currentIndex !== layout.currentIndex)
            layout.currentIndex = currentIndex
        control.height = currentIndex === -1 ? 0 : undefined
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
        model: control.layout?.layouts
        delegate: Loader {
            id: loader
            Layout.fillWidth: true
            property var model: control.layout?.layouts[index]
            onModelChanged: {
                if (loader.model) {
                    loader.setSource("./AlgoList.qml", {
                                         "model": loader.model,
                                         "imageMouseArea": control.imageMouseArea
                                     })
                }
            }
        }
    }
}
