// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1060
    height: 740
    minimumWidth: 760
    minimumHeight: 560
    visible: true
    title: qsTr("LOKRO Settings")
    color: "#07090c"

    function openAction(name) {
        Qt.openUrlExternally("lokro-action:" + name)
    }

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#11151b" }
            GradientStop { position: 0.55; color: "#080a0e" }
            GradientStop { position: 1.0; color: "#030405" }
        }

        Repeater {
            model: 84
            Rectangle {
                required property int index
                width: index % 9 === 0 ? 3 : 2
                height: width
                radius: width / 2
                x: 28 + (index % 14) * 76
                y: 24 + Math.floor(index / 14) * 126
                color: index % 9 === 0 ? "#99ffffff" : "#24ffffff"
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 22

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 126
                color: "#d912151a"
                border.color: "#55777f8b"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 34
                    anchors.rightMargin: 34
                    spacing: 22

                    ColumnLayout {
                        Layout.fillWidth: true
                        Label { text: "// LOKRO SETTINGS"; color: "#ffffff"; font.pixelSize: 27; font.bold: true }
                        Label {
                            text: qsTr("System, Geräte und Oberfläche zentral verwalten")
                            color: "#aeb6c2"
                            font.pixelSize: 14
                        }
                    }
                    Button {
                        text: qsTr("Dunkel")
                        onClicked: root.openAction("theme-dark")
                        background: Rectangle { radius: 10; color: parent.hovered ? "#ffffff" : "#26303b"; border.color: "#80ffffff" }
                        contentItem: Label { text: parent.text; color: parent.hovered ? "#080a0e" : "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Button {
                        text: qsTr("Hell")
                        onClicked: root.openAction("theme-light")
                        background: Rectangle { radius: 10; color: parent.hovered ? "#ffffff" : "#26303b"; border.color: "#80ffffff" }
                        contentItem: Label { text: parent.text; color: parent.hovered ? "#080a0e" : "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Button {
                        text: qsTr("Design-Packs")
                        highlighted: true
                        onClicked: root.openAction("design-packs")
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 32
                Layout.rightMargin: 32
                columns: root.width >= 980 ? 3 : root.width >= 700 ? 2 : 1
                columnSpacing: 16
                rowSpacing: 16

                SettingsCard { Layout.fillWidth: true; title: qsTr("Aussehen"); detail: qsTr("Farben, Fensterstil und globale Designs"); glyph: "◩"; actionName: "appearance"; onActivated: name => root.openAction(name) }
                SettingsCard { Layout.fillWidth: true; title: qsTr("Hintergrund & Widgets"); detail: qsTr("Desktop-Hintergrund und Plasma-Widgets anpassen"); glyph: "✦"; actionName: "wallpaper"; onActivated: name => root.openAction(name) }
                SettingsCard { Layout.fillWidth: true; title: qsTr("Mauszeiger"); detail: qsTr("Cursor-Design und Zeigergröße einstellen"); glyph: "↖"; actionName: "cursor"; onActivated: name => root.openAction(name) }
                SettingsCard { Layout.fillWidth: true; title: qsTr("Netzwerk"); detail: qsTr("WLAN, LAN, VPN und Verbindungen verwalten"); glyph: "⌁"; actionName: "network"; onActivated: name => root.openAction(name) }
                SettingsCard { Layout.fillWidth: true; title: qsTr("Bluetooth"); detail: qsTr("Mäuse, Tastaturen, Audio und weitere Geräte koppeln"); glyph: "ᛒ"; actionName: "bluetooth"; onActivated: name => root.openAction(name) }
                SettingsCard { Layout.fillWidth: true; title: qsTr("Benutzer"); detail: qsTr("Lokale Konten und Administratoren verwalten"); glyph: "◎"; actionName: "users"; onActivated: name => root.openAction(name) }
                SettingsCard { Layout.fillWidth: true; title: qsTr("Tastenkürzel"); detail: qsTr("Globale und anwendungsspezifische Shortcuts ändern"); glyph: "⌘"; actionName: "shortcuts"; onActivated: name => root.openAction(name) }
                SettingsCard { Layout.fillWidth: true; title: qsTr("Energie"); detail: qsTr("Energiesparen, Bildschirm und Ruhezustand konfigurieren"); glyph: "◒"; actionName: "power"; onActivated: name => root.openAction(name) }
                SettingsCard { Layout.fillWidth: true; title: qsTr("Alle Plasma-Module"); detail: qsTr("Vollständige KDE-Systemeinstellungen öffnen"); glyph: "＋"; actionName: "system-settings"; onActivated: name => root.openAction(name) }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: 34
                Layout.rightMargin: 34
                Layout.bottomMargin: 28
                text: qsTr("LOKRO Settings ist eine übersichtliche Startseite. Die eigentlichen Änderungen werden weiterhin von den geprüften KDE-Plasma-Modulen vorgenommen.")
                color: "#7f8997"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
        }
    }
}
