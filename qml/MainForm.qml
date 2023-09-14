import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts
import KmcUI.Window
import KmcUI.Controls
import KmcUI
import KmcUI.Effects
import Qt.labs.folderlistmodel
import Qt.labs.settings
import QtCore
import "./components"
import CvTools

ShadowWindow {
    id: root
    visible: true
    resizable: true
    titleButton: TitleBar.Full
    minimumWidth: 850
    minimumHeight: 400
    objectName: "MainForm"

    readonly property string appName: "CV Tools"

    Image {
        parent: root.title
        source: "qrc:/assets/logo.svg"
        width: 18
        height: 18
        anchors.leftMargin: 7
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: titleText
        parent: root.title
        width: 300
        anchors.centerIn: parent
        text: root.appName
        color: "white"
        font.pointSize: 9
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    title {
        color: "#181818"
        buttons {
            icons.color: "#cccccc"
            buttonWidth: 42
        }
        bottomBorder.color: "#2A2A2A"
    }
    background: KmcRectangle {
        id: backgroundRect
        radius: 10
        color: "#1F1F1F"
        border.color: "#404040"
        Binding {
            when: root.visibility === Window.Maximized
            backgroundRect.border.width: 0
            backgroundRect.radius: 0
        }
    }
    width: mainFormSettings.windowSize.width
    height: mainFormSettings.windowSize.height

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

    property SessionData sessionData

    onSessionDataChanged: {
        if (sessionData) {
            testbedPageLoader.item.sessionData = root.sessionData
            titleText.text = root.sessionData.fileName + " - " + root.sessionData.name + " - " + root.appName
            stackLayout.switchTo(MainForm.PageType.Testbed)
        } else {
            titleText.text = root.appName
            stackLayout.switchTo(MainForm.PageType.Welcome)
        }
    }

    Connections {
        target: root.sessionData
        enabled: !!root.sessionData
        function onErrorStringChanged() {
            messageDialog.text = root.sessionData.errorString
            messageDialog.open()
        }
    }

    Component {
        id: algoGroup
        MyMenu {}
    }
    Component {
        id: algoAction
        Action {
            required property var index
            onTriggered: {
                var algorithm = algorithmTreeModel.data(index, Qt.UserRole)
                sessionData.algoModel[Number(sessionData.isClonedView
                                             && !algoList.activeFocus)].append(algorithm)
            }
        }
    }

    function createAlgoMenu(parent, parentIndex) {
        for (var i = 0; i < algorithmTreeModel.rowCount(parentIndex); ++i) {
            const currentIndex = algorithmTreeModel.index(i, 0, parentIndex)
            const node = algorithmTreeModel.data(currentIndex, Qt.UserRole)
            if (node.algorithms !== undefined) {
                var group = algoGroup.createObject(parent, {
                                                       "title": algorithmTreeModel.data(
                                                                    currentIndex, Qt.DisplayRole)
                                                   })
                parent.addMenu(group)
                createAlgoMenu(group, currentIndex)
            } else {

                var algo = algoAction.createObject(parent, {
                                                       "text": algorithmTreeModel.data(
                                                                   currentIndex, Qt.DisplayRole),
                                                       "enabled": Qt.binding(
                                                                      () => !!root.sessionData),
                                                       "index": currentIndex
                                                   })
                parent.addAction(algo)
            }
        }
    }

    Component.onCompleted: {
        createAlgoMenu(editMenu, algorithmTreeModel.index(-1, -1))
    }

    Settings {
        id: mainFormSettings
        property string recentOpenFolder: Qt.resolvedUrl(".")
        property string recentSaveFolder: Qt.resolvedUrl(".")
        property string recentSession
        property size windowSize: Qt.size(1024, 600)
    }

    Bridge {
        id: bridge
    }

    MessageDialog {
        id: messageDialog

        title: "CV Tools"
        buttons: MessageDialog.Ok
    }

    function readSessionData(path) {
        root.sessionData = bridge.parseFile(path, imageProvider)
        if (!root.sessionData) {
            messageDialog.text = bridge.errorString
            messageDialog.open()
        }
    }

    Popup {
        id: commandPane
        width: 350
        height: 300
        x: (content.width - commandPane.width) / 2
        y: content.y + commandPaneBackground.radius + padding
        padding: 7
        background: Item {
            RectangularGlow {
                anchors.fill: commandPaneBackground
                color: "#000000"
                glowRadius: 3
                cornerRadius: commandPaneBackground.radius + glowRadius
            }

            Rectangle {
                id: commandPaneBackground
                anchors.fill: parent
                color: "#1F1F1F"
                border {
                    width: 1
                    color: "#454545"
                }
                radius: 6
            }
        }
        contentItem: Column {
            MyLineEdit {
                implicitHeight: 30
                implicitWidth: commandPane.width - commandPane.padding * 2
                placeholderText: qsTr("Command/Effect Name...")
            }
            MyScrollView {
                implicitWidth: commandPane.width - commandPane.padding * 2
                Column {
                    anchors.fill: parent
                    Repeater {}
                }
            }
        }
    }

    FileDialog {
        id: openFileDialog
        currentFolder: mainFormSettings.recentOpenFolder
        nameFilters: ["JPEG files (*.jpg *,jpeg *jpe)", "Portable network graphics (*.png)", "Cv Tools Session File (*.cvsession)"]
        onAccepted: {
            mainFormSettings.recentOpenFolder = currentFolder
            readSessionData(selectedFile)
        }
    }

    FileDialog {
        id: saveFileDialog
        fileMode: FileDialog.SaveFile
        currentFolder: mainFormSettings.recentSaveFolder
        defaultSuffix: "cvsession"
        nameFilters: ["Cv Tools Session File (*.cvsession)"]
        onAccepted: {
            mainFormSettings.recentSaveFolder = currentFolder
            bridge.save(root.sessionData, currentFile)
            mainFormSettings.recentSession = currentFile
        }
    }

    FileDialog {
        id: exportFileDialog
        fileMode: FileDialog.SaveFile
        nameFilters: ["Joint Photographic Experts Group (*.jpg, *.jpeg)", "Portable Network Graphics (*.png)", "Windows Bitmap (*.bmp)"]
        defaultSuffix: {
            switch (selectedNameFilter.index) {
            case 0:
                return "jpg"
            case 1:
                return "png"
            case 2:
                return "bmp"
            }
        }

        onAccepted: {
            if (!bridge.export(currentFile, sessionData, 100)) {
                messageDialog.text = bridge.errorString
                messageDialog.open()
            }
        }
    }

    MenuBar {
        id: menuBar
        parent: root.title
        anchors {
            left: parent.left
            leftMargin: 34
            top: parent.top
            bottom: parent.bottom
        }

        menus: [
            MyMenu {
                id: fileMenu
                title: "&File"

                Action {
                    text: qsTr("Open File...")
                    shortcut: "Ctrl+O"
                    onTriggered: {
                        openFileDialog.open()
                    }
                }

                Action {
                    text: qsTr("Save Session")
                    shortcut: "Ctrl+S"
                    enabled: !!root.sessionData
                    onTriggered: {
                        if (sessionData.sessionPath)
                            sessionData.save()
                        else
                            saveFileDialog.open()
                    }
                }

                Action {
                    text: qsTr("Save As...")
                    onTriggered: saveFileDialog.open()
                    enabled: !!root.sessionData
                }

                Action {
                    text: qsTr("Recover Last Session")
                    enabled: !!mainFormSettings.recentSession
                    onTriggered: {
                        readSessionData(mainFormSettings.recentSession)
                    }
                }

                MyMenuSeparator {}

                Action {
                    text: qsTr("Export...")
                    shortcut: "Ctrl+E"
                    onTriggered: exportFileDialog.open()
                    enabled: !!root.sessionData
                }
            },
            MyMenu {
                id: viewMenu
                title: "&View"
                Action {
                    text: root.sessionData?.isClonedView ? qsTr("Close Cloned View") : qsTr(
                                                               "Clone Current Image/Video")
                    enabled: !!root.sessionData
                    onTriggered: {
                        root.sessionData.isClonedView = !root.sessionData.isClonedView
                    }
                }
            },
            MyMenu {
                id: editMenu
                title: "&Edit"
                implicitWidth: 250
                Action {
                    text: qsTr("Command Pane...")
                    shortcut: "Ctrl+P"
                    onTriggered: commandPane.open()
                }
                MyMenuSeparator {}

                Action {
                    text: qsTr("Open Camera")
                }
                MyMenuSeparator {}
            },
            MyMenu {
                id: helpMenu
                title: "&Help"

                Action {
                    text: qsTr("About")
                    onTriggered: {
                        messageDialog.text = qsTr("你关于你妈呢")
                        messageDialog.open()
                    }
                }
            }
        ]

        background: Rectangle {
            color: "#181818"
        }

        delegate: MenuBarItem {
            id: menuBarItem
            implicitWidth: 18 + menuItemText.contentWidth
            contentItem: Text {
                id: menuItemText
                text: menuBarItem.text
                color: "#cccccc"
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
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
            icon: "qrc:/assets/icons/testbed.svg"
            tooltip: qsTr("Testbed (Ctrl+1)")
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
            tooltip: qsTr("File manager (Ctrl+2)")
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
            tooltip: qsTr("Settings (Ctrl+3)")
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
            tooltip: qsTr("Connect (F5)")
            shortcut: "F5"
            activate: () => {}
        }
    }

    contentItem: Item {
        id: content
        KmcRectangle {
            id: appBarRect
            width: 50
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }
            color: root.title.color
            rightBorder.color: "#2A2A2A"
            leftBottomRadius: backgroundRect.radius
            MyAppBar {
                id: topAppBar
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

            Rectangle {
                id: appBarContent
                SplitView.preferredWidth: 200
                property int lastIndex: MainForm.AppBarType.None
                property bool shouldCollapse: false
                color: "#181818"
                clip: true

                function switchTo(appBarContentType) {
                    appBarContentStack.currentIndex = appBarContentType
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

                Item {
                    id: appBarContentTitle
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    height: 30
                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 16
                        color: "#cccccc"
                        text: topAppItems.get(appBarContentStack.currentIndex).name
                    }
                }

                StackLayout {
                    id: appBarContentStack
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: appBarContentTitle.bottom
                        bottom: parent.bottom
                    }

                    MyToolBox {
                        id: algoList
                        model: sessionData?.algoModel[0]
                        imageMouseArea: testbedPageLoader.item?.imageMouseArea
                    }
                }
            }

            StackLayout {
                id: stackLayout
                SplitView.fillHeight: true
                SplitView.fillWidth: true
                clip: true

                function switchTo(page) {
                    if (!root.sessionData && page === MainForm.PageType.Testbed)
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
                    id: testbedPageLoader
                    source: "TestbedPage.qml"
                }
            }
        }
    }
}
