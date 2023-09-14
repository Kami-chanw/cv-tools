import QtQuick
import KmcUI
import KmcUI.Controls
import QtQuick.Controls.Basic
import QtQuick.Shapes
import "./components"
import "./algo_widgets"
import QtQuick.Effects
import CvTools

Window {
    id: window
    width: 400
    height: 400
    visible: true
    color: "#181818"
    MyToolBox {
        anchors.fill: parent
        model: fakeModel
    }
    //    Loader {
    //        anchors.centerIn: parent
    //        sourceComponent: ItemDelegate {
    //            contentItem: Rectangle {
    //                color: "white"
    //            }
    //            width: 200
    //            height: 200
    //            onHoveredChanged: console.log(hovered)
    //            MouseArea {
    //                anchors.fill: parent
    //                propagateComposedEvents: true
    //                onClicked: e => {
    //                               console.log("source")
    //                               e.accepted = false
    //                           }
    //            }
    //        }
    //        MouseArea {
    //            anchors.fill: parent
    //            onClicked: console.log("loader")
    //        }
    //    }
}
