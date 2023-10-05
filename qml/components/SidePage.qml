import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../controls"

Rectangle {
    id: root
    property alias title: title.text
    property alias stackLayout: stackLayout
    property alias imageMouseArea: algoList.imageMouseArea
    required property var algoModel
    clip: true
    Item {
        id: sidePageTitle
        height: 32
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        Text {
            id: title
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 16
            color: "#cccccc"
        }
        MyIconButton {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 12
            }
            icon.source: "qrc:/assets/icons/ellipsis.svg"
            palette.button: "#19ffffff"
            toolTip: "More operations..."
            checkable: true
            checked: moreOpMenu.visible
            height: 22
            width: 22
            toolTipEnabled: !moreOpMenu.visible
            onClicked: if (moreOpMenu.visible)
                           moreOpMenu.close()
                       else
                           moreOpMenu.open()

            MyMenu {
                id: moreOpMenu
                y: parent.y + parent.height - 4
                width: 180
                Action {
                    id: clearAll
                    text: "Clear All Effects"
                    onTriggered: algoModel.clear()
                    enabled: algoModel?.count > 0
                }
                Action {
                    text: "Expand All Effects"
                    enabled: clearAll.enabled
                    onTriggered: {
                        for (var i = 0; i < algoList.items.count; ++i) {
                            var item = algoList.items.itemAt(i)
                            if (item.enabled)
                                item.expanded = true
                        }
                    }
                }
                Action {
                    text: "Fold All Effects"
                    enabled: clearAll.enabled
                    onTriggered: {
                        for (var i = 0; i < algoList.items.count; ++i) {
                            var item = algoList.items.itemAt(i)
                            if (item.enabled)
                                item.expanded = false
                        }
                    }
                }
            }
        }
    }

    StackLayout {
        id: stackLayout
        anchors {
            left: parent.left
            right: parent.right
            top: sidePageTitle.bottom
            bottom: parent.bottom
        }

        MyToolBox {
            id: algoList
            model: algoModel
        }
    }
}
