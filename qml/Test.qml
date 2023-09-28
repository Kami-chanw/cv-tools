import QtQuick
import KmcUI
import KmcUI.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "./controls"
import "./algo_controls"
import QtQuick.Effects
import CvTools

Window {
    id: window
    width: 400
    height: 400
    visible: true
    color: "#fff"

    Button {
        height: 20
        width: 40
        anchors.centerIn: parent
        text: "example"
        background: Rectangle {
            color: "#cdcdcd"
        }
        BubbleToolTip {
            id: tooltip
            text: "example toolip"
            shadowBlur: 3
            arrow.position: 10
            border.color: "#454545"
            palette {
                toolTipBase: "#202020"
                toolTipText: "#c2c2c2"
                shadow:"#000"
            }
        }

        HoverHandler {
            onHoveredChanged: {
                if (hovered)
                    tooltip.open()
            }
        }
    }
}
