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
    radius: 18
    color: pointer.containsMouse ? "#e6292d35" : "#b81a1d23"
    border.width: 1
    border.color: pointer.containsMouse ? "#e6ffffff" : "#55777f8b"

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 1
        height: 1
        color: "#80ffffff"
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
                color: pointer.containsMouse ? "#ffffff" : "#8f98a6"
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
            color: "#aeb6c2"
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
