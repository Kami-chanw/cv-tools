import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls.Basic
import QtQuick.Layouts
import KmcUI.Window
import KmcUI.Controls
import KmcUI
import KmcUI.Effects
import Qt.labs.folderlistmodel
import Qt.labs.settings
import QtCore
import "./controls"
import "./components"
import "./scripts/Icon.js" as MdiFont
import CvTools

ShadowWindow {
    id: root
    visible: true
    resizable: true
    titleButton: TitleBar.Full
    minimumWidth: 850
    minimumHeight: 400
    objectName: "MainForm"
    dragBehavior: ShadowWindow.DragTitle

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
        MyBubbleToolTip {
            id: titleToolTip
            location: KmcUI.Bottom
        }

        HoverHandler {
            id: hoverHandler
        }

        states: State {
            when: !!root.sessionData
            PropertyChanges {
                titleText.text: root.sessionData.name
                titleToolTip {
                    visible: hoverHandler.hovered
                    text: root.sessionData.fileName + " - " + root.sessionData.name + " - " + root.appName
                }
            }
        }
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
        border.color: "#59595a"
        Binding {
            when: root.visibility === Window.Maximized
            backgroundRect.border.width: 0
            backgroundRect.radius: 0
        }
    }
    statusBar: KmcRectangle {
        id: statusBar
        topBorder.color: "#2b2b2b"
        color: "#181818"
        height: 22
        leftBottomRadius: backgroundRect.radius
        rightBottomRadius: leftBottomRadius

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 9
            Button {
                id: notification
                height: statusBar.height
                width: height
                background: Rectangle {
                    color: notification.pressed ? "#424242" : notification.hovered ? "#343434" : "transparent"
                }

                MyTextIcon {
                    anchors.centerIn: parent
                    text: mainFormSettings.notifiable ? (mainFormSettings.notificationList.length
                                                         > 0 ? MdiFont.Icon.bellBadgeOutline : MdiFont.Icon.bellOutline) : MdiFont.Icon.bellOffOutline
                    color: "#c2c2c2"
                }
                MyBubbleToolTip {
                    location: KmcUI.Top
                    visible: notification.hovered
                    onVisibleChanged: {
                        if (visible) {
                            const parentCoordinate = notification.mapToItem(statusBar,
                                                                            Qt.point(parent.x,
                                                                                     parent.y))
                            arrow.position = parentCoordinate.x + parent.width / 2 - (parentCoordinate.x + x)
                        }
                    }
                    text: mainFormSettings.notifiable ? (mainFormSettings.notificationList.length
                                                         > 0 ? mainFormSettings.notificationList.length
                                                               + " New Notifications" : "No Notifications") : "Hide Notifications"
                }
            }
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
            stackLayout.switchTo(MainForm.PageType.Testbed)
        } else {
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
            required property var algorithm
            onTriggered: {
                sessionData.algoModel[Number(sessionData.isContrastView
                                             && !algoList.activeFocus)].append(
                            algorithm.newInstance())
            }
        }
    }

    function createAlgoMenu(parent, parentIndex) {
        for (var i = 0; i < algorithmTreeModel.rowCount(parentIndex); ++i) {
            const currentIndex = algorithmTreeModel.index(i, 0, parentIndex)
            const node = algorithmTreeModel.data(currentIndex, Qt.UserRole)
            if (node.enabled === undefined) {
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
                                                       "algorithm": algorithmTreeModel.data(
                                                                        currentIndex, Qt.UserRole)
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
        property var notificationList: []
        property bool notifiable: value
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

                Action {
                    text: qsTr("Close Session")
                    enabled: !!root.sessionData
                    onTriggered: {
                        root.sessionData = null
                        stackLayout.switchTo(MainForm.PageType.Welcome)
                    }
                }

                MyMenuSeparator {}

                Action {
                    text: qsTr("Export...")
                    shortcut: "Ctrl+E"
                    onTriggered: exportFileDialog.open()
                    enabled: !!root.sessionData
                }

                MyMenuSeparator {}

                Action {
                    text: qsTr("Exit")
                    onTriggered: Qt.quit()
                }
            },
            MyMenu {
                id: viewMenu
                title: "&View"
                MyMenuItem {
                    text: root.sessionData?.isContrastView ? qsTr("Close Contrast View") : qsTr(
                                                                 "Show Contrast View")
                    enabled: !!root.sessionData
                    onTriggered: {
                        root.sessionData.isContrastView = !root.sessionData.isContrastView
                    }
                    indicator: MyTextIcon {
                        x: (parent.textPadding - contentWidth) / 2
                        anchors.verticalCenter: parent.verticalCenter
                        text: MdiFont.Icon.contrast
                        color: parent.textColor
                    }
                }

                Action {
                    text: qsTr("Fixed View")
                    checkable: true
                    checked: root.sessionData?.isFixedView ?? false
                    enabled: !!root.sessionData
                    onTriggered: {
                        root.sessionData.isFixedView = !root.sessionData.isFixedView
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
                anchors.centerIn: parent
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
                          sidePage.shouldCollapse = false
                          if (sidePage.SplitView.preferredWidth < 150) {
                              sidePage.SplitView.preferredWidth = 200
                          }
                          sidePage.switchTo(MainForm.AppBarType.Testbed)
                          stackLayout.switchTo(MainForm.PageType.Testbed)
                      }
        }
        ListElement {
            name: "FileManager"
            icon: "qrc:/assets/icons/file_manager.svg"
            tooltip: qsTr("File manager (Ctrl+2)")
            shortcut: "Ctrl+2"
            activate: () => {
                          sidePage.shouldCollapse = false
                          if (sidePage.SplitView.preferredWidth < 150) {
                              sidePage.SplitView.preferredWidth = 200
                          }
                          sidePage.switchTo(MainForm.AppBarType.FileSystem)
                          stackLayout.switchTo(MainForm.PageType.Testbed)
                      }
        }
        ListElement {
            name: "Setting"
            icon: "qrc:/assets/icons/settings.svg"
            tooltip: qsTr("Settings (Ctrl+3)")
            shortcut: "Ctrl+3"
            activate: () => {
                          sidePage.shouldCollapse = true
                          stackLayout.switchTo(MainForm.PageType.Setting)
                      }
            deactivate: () => {
                            sidePage.shouldCollapse = false
                        }
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
            MyAppBar {
                id: topAppBar
                currentIndex: 0
                model: topAppItems
                behavior: MyAppBar.Toggle
                width: parent.width
                onAboutToSwitch: (currentIndex, nextIndex) => {
                                     if (nextIndex === MainForm.AppBarType.None
                                         && currentIndex !== MainForm.AppBarType.Setting)
                                     sidePage.lastIndex = currentIndex
                                 }

                onCurrentIndexChanged: {
                    if (currentIndex < 0 && !splitView.resizing) {
                        sidePage.shouldCollapse = true
                    }
                }
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

            SidePage {
                id: sidePage
                SplitView.preferredWidth: 200
                property int lastIndex: MainForm.AppBarType.None
                property bool shouldCollapse: false
                imageMouseArea: testbedPageLoader.item?.imageMouseArea
                algoModel: root.sessionData?.algoModel[0]
                color: "#181818"

                title: topAppItems.get(sidePage.stackLayout.currentIndex).name

                function switchTo(sidePageType) {
                    sidePage.stackLayout.currentIndex = sidePageType
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
                    when: sidePage.shouldCollapse
                    sidePage.SplitView.maximumWidth: 0
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
