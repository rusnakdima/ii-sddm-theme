// Config created by Keyitdev https://github.com/Keyitdev/sddm-astronaut-theme
// Copyright (C) 2022-2025 Keyitdev
// Distributed under the GPLv3+ License https://www.gnu.org/licenses/gpl-3.0.html
// Modified by 3d3f for the "ii-sddm-theme" project (2025)
// Licensed under the GNU General Public License v3.0
// See: https://www.gnu.org/licenses/gpl-3.0.txt
// Fork change: always-visible dropdown with an extra "Other user" entry.

import "Commons"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: userIsland
    // The appended "Other user" row sits one past the real SDDM users.
    readonly property int otherUserIndex: userModel.count
    readonly property string otherUserLabel: qsTr("Other user")

    property int currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : otherUserIndex
    property bool isOpen: false

    readonly property bool isOtherUser: currentIndex === otherUserIndex
    readonly property string currentText: isOtherUser
        ? otherUserLabel
        : (currentIndex >= 0 && currentIndex < userModel.count ? nameAt(currentIndex) : "")

    readonly property int baseHeight: 42
    readonly property int popupHeight: Math.min(400, (userModel.count + 1) * 48 + 12)
    readonly property int baseWidth: Math.ceil(Math.max(150, selectedTextMetrics.advanceWidth + 70))
    readonly property int expandedWidth: Math.ceil(Math.max(150, longestTextMetrics.advanceWidth + 100))

    signal selectionChanged()
    signal accepted()

    function nameAt(i) {
        return userModel.data(userModel.index(i, 0), 257) || "";
    }

    function iconAt(i) {
        return userModel.data(userModel.index(i, 0), 260) || "";
    }

    function avatarAt(i) {
        var name = nameAt(i);
        return name === "dmitriy"
            ? "file:///home/dmitriy/Pictures/ava/ava-violet-2x.png"
            : iconAt(i);
    }

    function labelAt(i) {
        return i === userIsland.otherUserIndex ? userIsland.otherUserLabel : userIsland.nameAt(i);
    }

    focusPolicy: Qt.ClickFocus
    implicitWidth: isOpen ? expandedWidth : baseWidth
    implicitHeight: baseHeight

    onActiveFocusChanged: {
        if (!activeFocus)
            isOpen = false;
    }

    Keys.onPressed: function(event) {
        if (!isOpen) {
            if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_Return) {
                isOpen = true;
                event.accepted = true;
            }
        } else {
            if (event.key === Qt.Key_Return) {
                if (userList.currentIndex >= 0) {
                    userIsland.currentIndex = userList.currentIndex;
                    userIsland.selectionChanged();
                }
                isOpen = false;
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                isOpen = false;
                event.accepted = true;
            }
        }
    }

    TextMetrics {
        id: selectedTextMetrics
        font.family: Appearance.font_family_main
        font.pixelSize: Appearance.font.pixelSize.normal
        text: userIsland.currentText
    }

    TextMetrics {
        id: longestTextMetrics
        font.family: Appearance.font_family_main
        font.pixelSize: Appearance.font.pixelSize.normal
        text: {
            var longest = userIsland.otherUserLabel;
            for (var i = 0; i < userModel.count; i++) {
                var name = userIsland.nameAt(i);
                if (name && name.length > longest.length)
                    longest = name;
            }
            return longest;
        }
    }

    Rectangle {
        id: animatedContainer
        anchors.bottom: parent.bottom
        width: parent.width
        height: isOpen ? userIsland.popupHeight : userIsland.baseHeight
        antialiasing: true
        clip: true
        color: isOpen ? Colors.primary_container : (userButton.hovered ? Colors.surface_container_highest : Colors.surface_container)
        radius: isOpen ? 16 : Appearance.rounding.full

        MouseArea {
            anchors.fill: parent
            enabled: isOpen
            onClicked: (mouse) => { mouse.accepted = true; }
        }

        Button {
            id: userButton
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: userIsland.baseHeight
            hoverEnabled: true
            focusPolicy: Qt.NoFocus
            opacity: isOpen ? 0 : 1
            visible: opacity > 0
            onClicked: {
                userIsland.forceActiveFocus();
                isOpen = true;
            }

            background: Item {
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.NoButton
                }
            }

            contentItem: RowLayout {
                spacing: 8
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                Avatar {
                    size: 24
                    userName: userIsland.currentText
                    source: userIsland.isOtherUser ? "" : userIsland.avatarAt(userIsland.currentIndex)
                    iconColor: Colors.on_surface_variant
                }

                Text {
                    Layout.fillWidth: true
                    text: userIsland.currentText
                    font: selectedTextMetrics.font
                    color: Colors.on_surface_variant
                    elide: Text.ElideRight
                }
            }
        }

        ListView {
            id: userList
            anchors.fill: parent
            anchors.margins: 6
            model: userModel.count + 1
            clip: true
            spacing: 6
            focusPolicy: Qt.NoFocus
            focus: isOpen
            opacity: isOpen ? 1 : 0
            visible: opacity > 0
            currentIndex: userIsland.currentIndex

            delegate: Item {
                id: userEntry
                width: userList.width
                height: 42

                readonly property string rowName: userIsland.labelAt(index)
                readonly property bool rowIsOther: index === userIsland.otherUserIndex

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: userList.currentIndex === index
                           ? Colors.primary
                           : (ma.containsMouse ? Colors.colPrimaryContainerHover : Colors.primary_container)
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Avatar {
                        size: 26
                        userName: rowName
                        source: rowIsOther ? "" : userIsland.avatarAt(index)
                        iconColor: userList.currentIndex === index ? Colors.on_primary : Colors.on_primary_container
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.leftMargin: 10
                    }

                    Text {
                        text: rowName
                        font.family: Appearance.font_family_main
                        font.pixelSize: Appearance.font.pixelSize.normal
                        elide: Text.ElideRight
                        color: userList.currentIndex === index ? Colors.on_primary : Colors.on_primary_container
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.leftMargin: 10
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        userIsland.currentIndex = index;
                        userIsland.isOpen = false;
                        userIsland.selectionChanged();
                        userIsland.accepted();
                    }
                }
            }
        }

        Behavior on height {
            NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
        }

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
    }
}
