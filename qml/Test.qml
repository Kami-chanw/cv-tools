import QtQuick
import KmcUI
import KmcUI.Controls
import QtQuick.Controls
import "./components"

Window {
    id: window
    width: 600
    height: 600
    visible: true
    color: "#181818"
    Flickable {
        ScrollBar.vertical: MyScrollBar {}
        ScrollBar.horizontal: MyScrollBar {}
        property alias hovered: hd1.hovered
        HoverHandler {
            id: hd1
        }

        anchors.fill: parent
        contentHeight: 600
        contentWidth: 600
        Column {
            Flickable {
                width: 600
                height: 300
                contentHeight: text2.contentHeight
                contentWidth: text2.contentWidth
                ScrollBar.vertical: MyScrollBar {
                    policy: ScrollBar.AlwaysOn
                }
                ScrollBar.horizontal: MyScrollBar {}
                property alias hovered: hd2.hovered
                HoverHandler {
                    id: hd2
                }
                Text {
                    id: text2
                    anchors.top: parent.top
                    anchors.left: parent.left
                    font.pointSize: 300
                    text: "BCD"
                }
            }

            Text {
                width: 600
                height: 300
                font.pointSize: 100
                text: "ABC"
            }
        }
    }
}
