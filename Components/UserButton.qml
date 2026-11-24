// Config created by Keyitdev https://github.com/Keyitdev/sddm-astronaut-theme
// Copyright (C) 2022-2025 Keyitdev
// Based on https://github.com/MarianArlt/sddm-sugar-dark
// Distributed under the GPLv3+ License https://www.gnu.org/licenses/gpl-3.0.html
// Modified by 3d3f for the "ii-sddm-theme" project (2025)
// See: https://www.gnu.org/licenses/gpl-3.0.txt
// Fork change: always-visible dropdown with an extra "Other user" entry.

import "Commons"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: userIsland

    readonly property int otherUserIndex: userModel.count
    readonly property string otherUserLabel: qsTr("Other user")

    property int currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : otherUserIndex
    property bool isOpen: userPopup.opened

    readonly property bool isOtherUser: currentIndex === otherUserIndex
    readonly property string currentText: isOtherUser
        ? otherUserLabel
        : (currentIndex >= 0 && currentIndex < userModel.count ? nameAt(currentIndex) : "")

    readonly property int baseHeight: 42
    readonly property int baseWidth: Math.ceil(Math.max(150, selectedTextMetrics.advanceWidth + 70))
    readonly property int popupWidth: Math.ceil(Math.max(baseWidth, longestTextMetrics.advanceWidth + 100))
    readonly property int rowHeight: 42
    readonly property int popupHeight: (userModel.count + 1) * (rowHeight + 6) + 12

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

    function selectRow(i) {
        if (i < 0 || i > userModel.count)
            return;
        userIsland.currentIndex = i;
        userPopup.close();
        userIsland.selectionChanged();
        userIsland.accepted();
    }

    focusPolicy: Qt.ClickFocus
    implicitWidth: baseWidth
    implicitHeight: baseHeight

    onActiveFocusChanged: {
        if (!activeFocus)
            userPopup.close();
    }

    Keys.onPressed: function(event) {
        if (!userPopup.opened) {
            if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_Return) {
                userPopup.open();
                event.accepted = true;
            }
        } else {
            if (event.key === Qt.Key_Return) {
                selectRow(userList.currentIndex);
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                userPopup.close();
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
        id: pillBackground
        anchors.fill: parent
        color: userButton.hovered ? Colors.surface_container_highest : Colors.surface_container
        radius: Appearance.rounding.full
    }

    Loader {
        active: config.Shadow == "true"
        anchors.fill: pillBackground
        z: -1
        sourceComponent: StyledRectangularShadow {
            target: pillBackground
            anchors.fill: undefined
        }
    }

    Button {
        id: userButton
        anchors.fill: parent
        hoverEnabled: true
        focusPolicy: Qt.NoFocus
        onClicked: {
            userIsland.forceActiveFocus();
            userPopup.open();
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

            MaterialSymbol {
                text: userPopup.opened ? "keyboard_arrow_up" : "keyboard_arrow_down"
                iconSize: 18
                color: Colors.on_surface_variant
            }
        }
    }

    Popup {
        id: userPopup
        width: userIsland.popupWidth
        height: userIsland.popupHeight
        y: -height - 6
        x: 0
        padding: 6
        modal: false
        focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Colors.primary_container
            radius: 16
        }

        contentItem: ListView {
            id: userList
            model: userModel.count + 1
            clip: true
            interactive: true
            spacing: 6
            currentIndex: userIsland.currentIndex
            delegate: Item {
                width: userList.width
                height: userIsland.rowHeight

                readonly property string rowName: userIsland.labelAt(index)
                readonly property bool rowIsOther: index === userIsland.otherUserIndex
                readonly property bool rowIsCurrent: index === userIsland.currentIndex

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: rowIsCurrent ? Colors.primary : (ma.containsMouse ? Colors.colPrimaryContainerHover : Colors.primary_container)
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Avatar {
                        size: 26
                        userName: rowName
                        source: rowIsOther ? "" : userIsland.avatarAt(index)
                        iconColor: rowIsCurrent ? Colors.on_primary : Colors.on_primary_container
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.leftMargin: 10
                    }

                    Text {
                        text: rowName
                        font.family: Appearance.font_family_main
                        font.pixelSize: Appearance.font.pixelSize.normal
                        elide: Text.ElideRight
                        color: rowIsCurrent ? Colors.on_primary : Colors.on_primary_container
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.leftMargin: 10
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: userIsland.selectRow(index)
                }
            }
        }
    }
}
