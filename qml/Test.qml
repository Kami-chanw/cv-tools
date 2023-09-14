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
    AlgoSelector {
        anchors.fill: parent
        model: fakeModel
    }

}
