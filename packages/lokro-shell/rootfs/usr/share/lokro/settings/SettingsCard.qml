// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: card
    required property string title
    required property string detail
    required property string glyph
    required property string actionName

    signal activated(string actionName)

    implicitWidth: 280
    implicitHeight: 142
    radius: 16
    color: pointer.containsMouse ? "#f0202020" : "#d20b0b0b"
    border.width: 1
    border.color: pointer.containsMouse ? "#ffffff" : "#526f6f6f"
    scale: pointer.containsMouse ? 1.018 : 1.0

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 1
        height: 1
        color: pointer.containsMouse ? "#ffffff" : "#70ffffff"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: card.glyph
                color: "#ffffff"
                font.pixelSize: 20
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Label {
                text: "↗"
                color: pointer.containsMouse ? "#ffffff" : "#7a7a7a"
                font.pixelSize: 17
            }
        }
        Label {
            Layout.fillWidth: true
            text: card.title
            color: "#ffffff"
            font.pixelSize: 18
            font.bold: true
        }
        Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: card.detail
            color: "#b6b6b6"
            font.pixelSize: 12
            wrapMode: Text.WordWrap
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: card.activated(card.actionName)
    }
}
