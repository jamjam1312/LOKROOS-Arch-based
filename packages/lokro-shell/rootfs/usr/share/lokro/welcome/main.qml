import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ApplicationWindow {
    id: root
    width: 1060
    height: 700
    minimumWidth: 860
    minimumHeight: 580
    visible: true
    title: qsTr("Willkommen bei LOKRO OS")
    color: "#070708"

    property string networkState: qsTr("Internet wird geprüft …")
    property string speedState: qsTr("Optionaler Kurztest noch nicht gestartet")
    property double speedStarted: 0

    function openAction(name) {
        Qt.openUrlExternally("lokro-action:" + name)
    }

    function checkNetwork() {
        networkState = qsTr("Internet wird geprüft …")
        var request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState !== XMLHttpRequest.DONE)
                return
            networkState = request.status >= 200 && request.status < 400
                ? qsTr("Online – Arch-Paketquellen sind erreichbar")
                : qsTr("Offline – die große ISO installiert trotzdem vollständig")
        }
        request.open("HEAD", "https://archlinux.org/?lokro-check=" + Date.now())
        request.send()
    }

    function runSpeedTest() {
        speedState = qsTr("Kurzer Downloadtest läuft …")
        speedStarted = Date.now()
        var request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState !== XMLHttpRequest.DONE)
                return
            if (request.status < 200 || request.status >= 400 || !request.response) {
                speedState = qsTr("Test nicht möglich – Installation bleibt nutzbar")
                return
            }
            var seconds = Math.max(0.05, (Date.now() - speedStarted) / 1000)
            var megabits = request.response.byteLength * 8 / 1000000
            speedState = qsTr("Ungefähr %1 Mbit/s zum Arch-Spiegel").arg((megabits / seconds).toFixed(1))
        }
        request.open("GET", "https://geo.mirror.pkgbuild.com/core/os/x86_64/core.db?lokro-speed=" + Date.now())
        request.responseType = "arraybuffer"
        request.send()
    }

    Canvas {
        anchors.fill: parent
        opacity: 0.38
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = "#a1a1aa"
            for (var y = 20; y < height; y += 34) {
                for (var x = 20; x < width; x += 34) {
                    var wave = 0.4 + 0.6 * Math.abs(Math.sin((x + y) * 0.012))
                    ctx.globalAlpha = 0.08 + wave * 0.13
                    ctx.beginPath()
                    ctx.arc(x, y, 1.2 + wave, 0, Math.PI * 2)
                    ctx.fill()
                }
            }
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#dd070708" }
            GradientStop { position: 0.58; color: "#e80d0d10" }
            GradientStop { position: 1.0; color: "#f5050506" }
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.gridUnit * 2
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: Kirigami.Units.largeSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.largeSpacing

                Rectangle {
                    width: 62
                    height: 62
                    radius: 18
                    color: "#f4f4f5"
                    Text {
                        anchors.centerIn: parent
                        text: "L"
                        color: "#09090b"
                        font.pixelSize: 34
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        text: qsTr("LOKRO OS")
                        color: "#fafafa"
                        font.pixelSize: 32
                        font.bold: true
                    }
                    Label {
                        text: qsTr("0.1.0 Alpha · Demo für Testgeräte")
                        color: "#a1a1aa"
                        font.pixelSize: 15
                    }
                }

                Button {
                    text: qsTr("Dunkel")
                    onClicked: root.openAction("theme-dark")
                }
                Button {
                    text: qsTr("Hell")
                    onClicked: root.openAction("theme-light")
                }
                Button {
                    text: qsTr("System installieren")
                    highlighted: true
                    onClicked: root.openAction("installer")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: warningContent.implicitHeight + 28
                radius: 14
                color: "#18181b"
                border.color: "#3f3f46"
                ColumnLayout {
                    id: warningContent
                    anchors.fill: parent
                    anchors.margins: 14
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Diese Version ist eine nicht veröffentlichte Alpha. Sichere wichtige Daten, bevor du Partitionen änderst. Secure Boot und garantiertes Dual-Boot sind noch nicht freigegeben.")
                        wrapMode: Text.WordWrap
                        color: "#e4e4e7"
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Schnellzugriff")
                    color: "#a1a1aa"
                }
                Button { text: qsTr("Tastatur"); onClicked: root.openAction("input") }
                Button { text: qsTr("Zeigergröße"); onClicked: root.openAction("cursor") }
                Button { text: qsTr("Shortcuts"); onClicked: root.openAction("shortcuts") }
                Button { text: qsTr("Energie"); onClicked: root.openAction("power") }
                Button { text: qsTr("Updates"); onClicked: root.openAction("updates") }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width > 900 ? 3 : 2
                columnSpacing: Kirigami.Units.largeSpacing
                rowSpacing: Kirigami.Units.largeSpacing

                WelcomeCard {
                    title: qsTr("Verbindung")
                    iconName: "network-wireless"
                    detail: root.networkState
                    primaryText: qsTr("Erneut prüfen")
                    secondaryText: qsTr("Kurztest")
                    onPrimary: root.checkNetwork()
                    onSecondary: root.runSpeedTest()
                    footer: root.speedState
                }
                WelcomeCard {
                    title: qsTr("Personalisieren")
                    iconName: "preferences-desktop-theme"
                    detail: qsTr("Dark/Light, Startmenü, Hintergrund, Panels und Widgets über Plasma anpassen.")
                    primaryText: qsTr("Erscheinungsbild")
                    secondaryText: qsTr("Design-Packs")
                    onPrimary: root.openAction("appearance")
                    onSecondary: root.openAction("design-packs")
                    footer: qsTr("LOKRO Dark ist der Standard · Widgets per Desktop-Rechtsklick")
                }
                WelcomeCard {
                    title: qsTr("Benutzer")
                    iconName: "user-identity"
                    detail: qsTr("Der Installer erstellt den ersten Benutzer. Weitere lokale Benutzer lassen sich danach hier hinzufügen.")
                    primaryText: qsTr("Benutzer verwalten")
                    secondaryText: qsTr("Einstellungen")
                    onPrimary: root.openAction("users")
                    onSecondary: root.openAction("settings")
                    footer: qsTr("Kein Online-Konto erforderlich")
                }
                WelcomeCard {
                    title: qsTr("Geräte & Netzwerk")
                    iconName: "preferences-system-bluetooth"
                    detail: qsTr("WLAN, LAN, Bluetooth, Maus, Tastatur, Displays und Energie werden mit KDE-Systemmodulen verwaltet.")
                    primaryText: qsTr("Netzwerk")
                    secondaryText: qsTr("Bluetooth")
                    onPrimary: root.openAction("network")
                    onSecondary: root.openAction("bluetooth")
                    footer: qsTr("Arch-Kernel, Firmware, NetworkManager und BlueZ")
                }
                WelcomeCard {
                    title: qsTr("Apps")
                    iconName: "lokro-store"
                    detail: qsTr("LOKRO Store zeigt einen geprüften Offline-Katalog freier Apps und installiert sie benutzerbezogen über Flathub.")
                    primaryText: qsTr("LOKRO Store")
                    secondaryText: qsTr("Discover")
                    onPrimary: root.openAction("app-store")
                    onSecondary: root.openAction("discover")
                    footer: qsTr("Keine Download-Skripte · Pacman verwaltet das Basissystem")
                }
                WelcomeCard {
                    title: qsTr("System & Boot")
                    iconName: "system-run"
                    detail: qsTr("GRUB zeigt LOKRO OS und bestmöglich erkannte weitere Systeme. Partitionen werden ausschließlich mit ausdrücklicher Bestätigung geändert.")
                    primaryText: qsTr("Bootmanager")
                    secondaryText: qsTr("Partitionen")
                    onPrimary: root.openAction("boot")
                    onSecondary: root.openAction("partitions")
                    footer: qsTr("Windows-Erkennung über os-prober · Backup erforderlich")
                }
                WelcomeCard {
                    title: qsTr("Taskmanager & Suche")
                    iconName: "utilities-system-monitor"
                    detail: qsTr("Prozesse, CPU, RAM, Speicher und Netzwerk überwachen. Die globale Suche findet Apps, indizierte Dateien, Einstellungen und Systemaktionen.")
                    primaryText: qsTr("Taskmanager")
                    secondaryText: qsTr("Alles durchsuchen")
                    onPrimary: root.openAction("taskmanager")
                    onSecondary: root.openAction("search")
                    footer: qsTr("Ctrl+Esc für Prozesse · Alt+Leertaste für KRunner")
                }
                WelcomeCard {
                    title: qsTr("Fensteraufteilung")
                    iconName: "view-split-left-right"
                    detail: qsTr("Plasma besitzt einen eingebauten Kachel-Editor. Optional kann zusätzlich die tastaturorientierte Hyprland-Sitzung installiert werden.")
                    primaryText: qsTr("Tiling-Hilfe")
                    secondaryText: qsTr("Shortcuts")
                    onPrimary: root.openAction("tiling")
                    onSecondary: root.openAction("shortcuts")
                    footer: qsTr("Plasma: Meta+T · Hyprland: Meta+Pfeiltasten")
                }
                WelcomeCard {
                    title: qsTr("Medien & Archive")
                    iconName: "lokro-media"
                    detail: qsTr("LOKRO Media nutzt die VLC-Engine für MP3, MP4 und viele weitere Formate. Ark öffnet ZIP-, 7z- und andere Archive.")
                    primaryText: qsTr("Media öffnen")
                    secondaryText: qsTr("Dateien")
                    onPrimary: root.openAction("media")
                    onSecondary: root.openAction("files")
                    footer: qsTr("VLC-Engine · Ark · 7-Zip")
                }
                WelcomeCard {
                    title: qsTr("Gaming")
                    iconName: "applications-games"
                    detail: qsTr("Das optionale Installationspaket enthält Steam, Prism Launcher, Java, GameMode, Gamescope und MangoHud.")
                    primaryText: qsTr("Steam")
                    secondaryText: qsTr("Minecraft")
                    onPrimary: root.openAction("steam")
                    onSecondary: root.openAction("minecraft")
                    footer: qsTr("Spiele, Konten und Minecraft-Assets benötigen später Internet")
                }
                WelcomeCard {
                    title: qsTr("Credits")
                    iconName: "help-about"
                    detail: qsTr("Jamie Milo Cürten hat LOKRO OS mitinitiiert und mitentwickelt und mit Hilfe von ChatGPT / OpenAI Codex die technische Grundlage erstellt.")
                    primaryText: qsTr("Über LOKRO OS")
                    secondaryText: qsTr("Open Source")
                    onPrimary: root.openAction("credits")
                    onSecondary: Qt.openUrlExternally("https://github.com/jamjam1312/LOKROOS-Arch-based")
                    footer: qsTr("LOKROGAMER · Jamie Milo Cürten · OpenAI Codex · Upstream-Projekte")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Der LOKRO Hub enthält bestätigte öffentliche Community-Links. Website, Login und API folgen erst nach Verifizierung.")
                    color: "#71717a"
                    wrapMode: Text.WordWrap
                }
                Button {
                    text: qsTr("Schließen")
                    onClicked: root.close()
                }
            }
        }
    }

    Component.onCompleted: checkNetwork()
}
