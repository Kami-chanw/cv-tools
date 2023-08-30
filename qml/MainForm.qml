import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts
import KmcUI.Window
import KmcUI.Controls
import KmcUI
import Qt.labs.folderlistmodel
import QtCore
import "./components"

ShadowWindow {
    id: root
    visible: true
    resizable: true
    titleButton: TitleBar.Full
    minimumWidth: 850
    title {
        color: "#181818"
        titleText {
            text: "CV Tools"
            color: "white"
            anchors.centerIn: title
            font.pointSize: 9
            anchors.leftMargin: 0
        }
        buttons {
            icons.color: "#cccccc"
            buttonWidth: 42
        }
    }
    background: Rectangle {
        id: backgroundRect
        radius: 10
        color: "#1F1F1F"
        border.color: "#434343"
        Binding {
            when: root.visibility === Window.Maximized
            backgroundRect.border.width: 0
            backgroundRect.radius: 0
        }
    }
    width: 1024
    height: 600

    enum PageType {
        Welcome = 0,
        Setting = 1,
        Testbed = 2
    }

    enum AppBarType {
        None = -1,
        Testbed = 0,
        FileSystem = 1,
        Setting = 2
    }

    menuBar: MenuBar {
        id: menuBar

        menus: [
            MyMenu {
                id: fileMenu
                title: "&File"
            },
            MyMenu {
                id: viewMenu
                title: "&View"
            },

            MyMenu {
                id: helpMenu
                title: "&Help"

                Action {
                    text: qsTr("About")
                    onTriggered: {
                        aboutDialog.open()
                    }
                }
                MessageDialog {
                    id: aboutDialog

                    title: "CV Tools"
                    text: qsTr("你关于你妈呢")
                    informativeText: qsTr("你关于你妈呢")
                    buttons: MessageDialog.Ok
                }
            }
        ]

        background: Rectangle {
            color: "#181818"
        }

        delegate: MenuBarItem {
            id: menuBarItem
            contentItem: Text {
                id: menuItemText
                text: menuBarItem.text
                color: "#cccccc"
                textFormat: Text.RichText
                padding: 1
            }
            background: Item {
                Rectangle {
                    anchors {
                        fill: parent
                        topMargin: 4
                        bottomMargin: 4
                    }
                    radius: 5
                    color: menuBarItem.highlighted ? "#20ffffff" : "transparent"
                }
            }
        }
    }

    ListModel {
        id: topAppItems
        ListElement {
            name: "Testbed"
            icon: "qrc:/assets/icons/logger.svg"
            tooltip: qsTr("Testbed info(Ctrl+1)")
            shortcut: "Ctrl+1"
            activate: () => {
                          appBarContent.shouldCollapse = false
                          if (appBarContent.SplitView.preferredWidth < 150) {
                              appBarContent.SplitView.preferredWidth = 200
                          }
                          appBarContent.switchTo(MainForm.AppBarType.Testbed)
                          stackLayout.switchTo(MainForm.PageType.Testbed)
                      }
        }
        ListElement {
            name: "FileManager"
            icon: "qrc:/assets/icons/file_manager.svg"
            tooltip: qsTr("File manager(Ctrl+2)")
            shortcut: "Ctrl+2"
            activate: () => {
                          appBarContent.shouldCollapse = false
                          if (appBarContent.SplitView.preferredWidth < 150) {
                              appBarContent.SplitView.preferredWidth = 200
                          }
                          appBarContent.switchTo(MainForm.AppBarType.FileSystem)
                          stackLayout.switchTo(MainForm.PageType.Testbed)
                      }
        }
        ListElement {
            name: "Setting"
            icon: "qrc:/assets/icons/settings.svg"
            tooltip: qsTr("Settings(Ctrl+3)")
            shortcut: "Ctrl+3"
            activate: () => {
                          appBarContent.shouldCollapse = true
                          stackLayout.switchTo(MainForm.PageType.Setting)
                      }
            deactivate: () => {
                            appBarContent.shouldCollapse = false
                        }
        }
    }

    ListModel {
        id: bottomAppItems
        ListElement {
            name: "Link"
            icon: "qrc:/assets/icons/connect.svg"
            tooltip: qsTr("Connect(F5)")
            shortcut: "F5"
            activate: () => {
                          terminal.setLoggerName(settingPageLoader.settings.loggerName)
                      }
        }
    }

    contentItem: Item {
        Rectangle {
            id: appBarRect
            width: 50
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }
            color: root.title.color
            MyAppBar {
                id: topAppBar
                anchors.topMargin: 10
                currentIndex: 0
                model: topAppItems
                behavior: MyAppBar.Toggle
                width: parent.width
                onAboutToSwitch: (currentIndex, nextIndex) => {
                                     if (nextIndex === MainForm.AppBarType.None
                                         && currentIndex !== MainForm.AppBarType.Setting)
                                     appBarContent.lastIndex = currentIndex
                                 }

                onCurrentIndexChanged: {
                    if (currentIndex < 0 && !splitView.resizing) {
                        appBarContent.shouldCollapse = true
                    }
                }
            }

            MyAppBar {
                anchors.bottomMargin: 10
                model: bottomAppItems
                width: parent.width
                behavior: MyAppBar.Click
                layoutDirection: Qt.RightToLeft
            }
        }

        MySplitView {
            id: splitView
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: appBarRect.right
                right: parent.right
            }

            StackLayout {
                id: appBarContent
                SplitView.preferredWidth: 200
                property int lastIndex: MainForm.AppBarType.None
                property bool shouldCollapse: false
                function switchTo(item) {
                    appBarContent.currentIndex = item
                }
                SplitView.onPreferredWidthChanged: {
                    if (splitView.resizing && !shouldCollapse) {
                        if (SplitView.preferredWidth < 150
                                && lastIndex === MainForm.AppBarType.None) {
                            lastIndex = topAppBar.currentIndex
                            topAppBar.currentIndex = MainForm.AppBarType.None
                            SplitView.maximumWidth = 0
                        }
                    }
                    if (SplitView.preferredWidth >= 150 && lastIndex !== MainForm.AppBarType.None) {
                        topAppBar.currentIndex = lastIndex
                        lastIndex = MainForm.AppBarType.None
                        SplitView.maximumWidth = undefined
                    }
                }

                Binding {
                    when: appBarContent.shouldCollapse
                    appBarContent.SplitView.maximumWidth: 0
                }
            }

            StackLayout {
                id: stackLayout
                SplitView.fillHeight: true
                SplitView.fillWidth: true
                clip: true

                function switchTo(page) {
                    if (page === MainForm.PageType.Testbed && !root.isConnected)
                        stackLayout.currentIndex = MainForm.PageType.Welcome
                    else
                        stackLayout.currentIndex = page
                }

                Loader {
                    source: "WelcomePage.qml"
                }

                Loader {
                    id: settingPageLoader
                    source: "SettingPage.qml"
                    property Settings settings: Settings {
                        objectName: "settings"
                    }
                }

                Loader {
                    id: loggerPageLoader
                    source: "TestbedPage.qml"
                }
            }
        }
    }
}
