// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore

ApplicationWindow {
    id: root
    width: 1160
    height: 780
    minimumWidth: 780
    minimumHeight: 580
    visible: true
    title: qsTr("LOKRO Settings")
    color: "#050505"

    function openAction(name) { Qt.openUrlExternally("lokro-action:" + name) }

    Settings {
        id: styleSettings
        location: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/lokro/settings.ini"
        category: "Style"
        property bool chamferEnabled: true
    }

    background: Rectangle {
        color: "#050505"

        Canvas {
            anchors.fill: parent
            opacity: 0.42
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const cx = width * 0.92
                const cy = height * 0.86
                for (let ring = 0; ring < 8; ++ring) {
                    ctx.beginPath()
                    ctx.arc(cx, cy, 120 + ring * 34, Math.PI * 1.02, Math.PI * 1.72)
                    ctx.strokeStyle = "rgba(255,255,255," + (0.20 - ring * 0.018) + ")"
                    ctx.lineWidth = ring === 0 ? 2 : 1
                    ctx.stroke()
                }
            }
        }

        Repeater {
            model: 120
            Rectangle {
                required property int index
                width: index % 17 === 0 ? 4 : 2
                height: width
                radius: width / 2
                x: 18 + (index % 20) * Math.max(38, (root.width - 36) / 20)
                y: 24 + Math.floor(index / 20) * 112
                color: "#ffffff"
                opacity: index % 11 === 0 ? 0.52 : 0.12
                SequentialAnimation on opacity {
                    running: true
                    loops: Animation.Infinite
                    PauseAnimation { duration: 350 + (index % 9) * 110 }
                    NumberAnimation { to: 0.52; duration: 420; easing.type: Easing.InOutSine }
                    NumberAnimation { to: index % 11 === 0 ? 0.52 : 0.12; duration: 680; easing.type: Easing.InOutSine }
                    PauseAnimation { duration: 1100 }
                }
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 18

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 172

                ChamferSurface {
                    anchors.fill: parent
                    chamfered: styleSettings.chamferEnabled
                    cutSize: 28
                    normalRadius: 0
                    fillColor: "#e3090909"
                    strokeColor: "#70ffffff"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 28

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        Label { text: "LOKRO / SYSTEM 01"; color: "#8e8e8e"; font.pixelSize: 11; font.letterSpacing: 2 }
                        Label { text: qsTr("EINSTELLUNGEN"); color: "#ffffff"; font.pixelSize: 32; font.bold: true; font.letterSpacing: 1 }
                        Label { text: qsTr("ENTWICKELN.  GESTALTEN.  VERBINDEN."); color: "#d8d8d8"; font.pixelSize: 13; font.letterSpacing: 1 }
                        Rectangle { Layout.topMargin: 9; width: 58; height: 3; color: "#ffffff" }
                    }

                    ColumnLayout {
                        Label { text: qsTr("DESIGN DIREKT ANWENDEN"); color: "#9d9d9d"; font.pixelSize: 10; font.letterSpacing: 1 }
                        RowLayout {
                            ChamferButton { chamfered: styleSettings.chamferEnabled; text: qsTr("Animiert"); onClicked: root.openAction("design-animated") }
                            ChamferButton { chamfered: styleSettings.chamferEnabled; text: qsTr("Eclipse"); onClicked: root.openAction("design-eclipse") }
                            ChamferButton { chamfered: styleSettings.chamferEnabled; text: qsTr("Lunar"); onClicked: root.openAction("design-lunar") }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            ChamferButton {
                                Layout.fillWidth: true
                                chamfered: styleSettings.chamferEnabled
                                text: styleSettings.chamferEnabled ? qsTr("Chamfer: An") : qsTr("Chamfer: Aus")
                                onClicked: {
                                    styleSettings.chamferEnabled = !styleSettings.chamferEnabled
                                    styleSettings.sync()
                                }
                            }
                            ChamferButton {
                                Layout.fillWidth: true
                                chamfered: styleSettings.chamferEnabled
                                text: qsTr("Alle Packs …")
                                highlighted: true
                                onClicked: root.openAction("design-packs")
                            }
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 30
                Layout.rightMargin: 30
                columns: root.width >= 1000 ? 3 : root.width >= 720 ? 2 : 1
                columnSpacing: 16
                rowSpacing: 16

                SettingsCard { chamfered: styleSettings.chamferEnabled; Layout.fillWidth: true; title: qsTr("Aussehen"); detail: qsTr("Farben, Fensterstil und globale Designs"); glyph: "◩"; actionName: "appearance"; onActivated: name => root.openAction(name) }
                SettingsCard { chamfered: styleSettings.chamferEnabled; Layout.fillWidth: true; title: qsTr("Hintergrund & Widgets"); detail: qsTr("Desktop, Animation und Plasma-Widgets anpassen"); glyph: "✦"; actionName: "wallpaper"; onActivated: name => root.openAction(name) }
                SettingsCard { chamfered: styleSettings.chamferEnabled; Layout.fillWidth: true; title: qsTr("Mauszeiger"); detail: qsTr("LOKRO Mono, weitere Cursor und Zeigergröße"); glyph: "↖"; actionName: "cursor"; onActivated: name => root.openAction(name) }
                SettingsCard { chamfered: styleSettings.chamferEnabled; Layout.fillWidth: true; title: qsTr("Netzwerk"); detail: qsTr("WLAN, LAN, VPN und Verbindungen verwalten"); glyph: "⌁"; actionName: "network"; onActivated: name => root.openAction(name) }
                SettingsCard { chamfered: styleSettings.chamferEnabled; Layout.fillWidth: true; title: qsTr("Bluetooth"); detail: qsTr("Mäuse, Tastaturen, Audio und Geräte koppeln"); glyph: "ᛒ"; actionName: "bluetooth"; onActivated: name => root.openAction(name) }
                SettingsCard { chamfered: styleSettings.chamferEnabled; Layout.fillWidth: true; title: qsTr("Benutzer"); detail: qsTr("Lokale Konten und Administratoren verwalten"); glyph: "◎"; actionName: "users"; onActivated: name => root.openAction(name) }
                SettingsCard { chamfered: styleSettings.chamferEnabled; Layout.fillWidth: true; title: qsTr("Tastenkürzel"); detail: qsTr("Globale und anwendungsspezifische Shortcuts"); glyph: "⌘"; actionName: "shortcuts"; onActivated: name => root.openAction(name) }
                SettingsCard { chamfered: styleSettings.chamferEnabled; Layout.fillWidth: true; title: qsTr("Energie"); detail: qsTr("Energiesparen, Bildschirm und Ruhezustand"); glyph: "◒"; actionName: "power"; onActivated: name => root.openAction(name) }
                SettingsCard { chamfered: styleSettings.chamferEnabled; Layout.fillWidth: true; title: qsTr("Alle Plasma-Module"); detail: qsTr("Vollständige KDE-Systemeinstellungen öffnen"); glyph: "+"; actionName: "system-settings"; onActivated: name => root.openAction(name) }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: 32
                Layout.rightMargin: 32
                Layout.bottomMargin: 24
                text: qsTr("LOKRO Settings öffnet die geprüften KDE-Plasma-Module. Designs werden benutzerbezogen angewendet und führen keinen Pack-Code aus.")
                color: "#888888"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }
    }
}
