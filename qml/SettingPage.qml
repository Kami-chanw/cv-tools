import QtQuick
import QtQuick.Controls
import QtCore
import "./controls"
import KmcUI.Controls
import KmcUI

Item {
    id: root

    enum SettingType {
        Title,
        LineEdit
    }

    Component {
        id: titleComponent
        Text {
            text: _title
            color: "white"
            font {
                bold: true
                pointSize: 19
            }
        }
    }

    Component {
        id: lineEditComponent
        Column {
            spacing: 5
            Text {
                text: _title
                font.bold: true
                color: "white"
            }
            Text {
                text: _informativeText
                color: "#bbbbbb"
            }
            MyLineEdit {
                fullText: _data
                onActiveFocusChanged: {
                    if (activeFocus) {
                        switchToCurrent()
                        forceActiveFocus()
                    }
                }
                onTextChanged: setEditedIndicatorVisible(text !== _data)
                onEditingFinished: _dataSetter(fullText)
            }
        }
    }

    ListModel {
        id: listModel
        ListElement {
            type: SettingPage.Title
            title: qsTr("Basic Settings")
        }
        ListElement {
            type: SettingPage.LineEdit
            title: qsTr("Target Logger Name")
            informativeText: qsTr(
                                 "The logger name specified in client app. VisibleLog will only listen to that logger.")
            dataGetter: () => settings.loggerName
            dataSetter: text => settings.loggerName = text
        }
    }

    KmcTreeModel {
        id: treeModel
        KmcTreeNode {
            data: qsTr("Basic Settings")
        }
    }

    MySplitView {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            bottom: parent.bottom
        }
        width: 800
        MyTreeView {
            SplitView.minimumWidth: 50
            SplitView.maximumWidth: 200

            delegate: MyTreeViewDelegate {

                contentItem: Text {
                    color: selected ? "white" : hovered ? "#ACACAC" : "#BABABA"
                    text: currentData
                    font.bold: selected
                    elide: Text.ElideRight
                }
            }
            model: treeModel
        }

        MyScrollView {
            id: content
            SplitView.fillHeight: true
            SplitView.fillWidth: true
            ListView {
                id: settingList
                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                }
                spacing: 1
                clip: true
                model: listModel
                currentIndex: -1
                delegate: Rectangle {
                    width: settingList.width - settingList.leftMargin - settingList.rightMargin
                    color: ListView.isCurrentItem ? "#252728" : (ma.containsMouse ? "#232424" : "transparent")
                    border.color: ListView.isCurrentItem ? "#0078D4" : "transparent"
                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        onClicked: loader.switchToCurrent()
                    }
                    Rectangle {
                        id: editedIndicator
                        color: "#5E4617"
                        anchors {
                            right: loader.left
                            top: loader.top
                            bottom: loader.bottom
                            rightMargin: 10
                        }
                        width: 2
                        visible: false
                    }

                    Loader {
                        id: loader
                        property string _title: model.title
                        property string _informativeText: model?.informativeText
                        property var _data: model?.dataGetter()
                        property var _dataSetter: model?.dataSetter
                        function switchToCurrent() {
                            settingList.currentIndex = index
                        }
                        function setEditedIndicatorVisible(value) {
                            editedIndicator.visible = value
                        }

                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 20
                        }

                        sourceComponent: {
                            switch (model.type) {
                            case SettingPage.Title:
                                return titleComponent
                            case SettingPage.LineEdit:
                                return lineEditComponent
                            }
                        }
                        onLoaded: {
                            switch (model.type) {
                            case SettingPage.Title:
                                parent.height = item.height + 12
                                break
                            default:
                                parent.height = item.height + 30
                            }
                        }
                    }
                }
            }
        }
    }
}
