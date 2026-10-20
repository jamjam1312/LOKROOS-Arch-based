// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: card
    required property string title
    required property string detail
    required property string glyph
    required property string actionName
    property bool chamfered: true
    property real densityScale: 1.0

    signal activated(string actionName)

    implicitWidth: 280 * densityScale
    implicitHeight: 142 * densityScale
    scale: pointer.containsMouse ? 1.018 : 1.0

    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    ChamferSurface {
        id: surface
        anchors.fill: parent
        chamfered: card.chamfered
        cutSize: 18 * card.densityScale
        normalRadius: 16 * card.densityScale
        fillColor: pointer.containsMouse ? "#f0202020" : "#d20b0b0b"
        strokeColor: pointer.containsMouse ? "#ffffff" : "#526f6f6f"

        Behavior on fillColor { ColorAnimation { duration: 120 } }
        Behavior on strokeColor { ColorAnimation { duration: 120 } }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: card.chamfered ? 20 * card.densityScale : 1
        anchors.rightMargin: card.chamfered ? 1 : 1
        anchors.topMargin: 1
        height: 1
        color: pointer.containsMouse ? "#ffffff" : "#70ffffff"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18 * card.densityScale
        spacing: 9 * card.densityScale

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: card.glyph
                color: "#ffffff"
                font.pixelSize: 20 * card.densityScale
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Label {
                text: "↗"
                color: pointer.containsMouse ? "#ffffff" : "#7a7a7a"
                font.pixelSize: 17 * card.densityScale
            }
        }
        Label {
            Layout.fillWidth: true
            text: card.title
            color: "#ffffff"
            font.pixelSize: 18 * card.densityScale
            font.bold: true
        }
        Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: card.detail
            color: "#b6b6b6"
            font.pixelSize: 12 * card.densityScale
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
