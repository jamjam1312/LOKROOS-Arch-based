import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    property string manifestUrl: "file:///var/lib/lokro/services.json"
    property string fallbackManifestUrl: "file:///usr/share/lokro/services.json"
    property bool triedFallback: false
    property string loadError: ""
    toolTipMainText: "Lokro Hub"
    toolTipSubText: "Lokro-Netzwerkdienste öffnen"

    ListModel { id: servicesModel }

    function loadServices() {
        var request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState !== XMLHttpRequest.DONE) return
            if (request.status !== 0 && request.status !== 200) {
                if (!triedFallback) {
                    triedFallback = true
                    manifestUrl = fallbackManifestUrl
                    loadServices()
                    return
                }
                loadError = "Diensteliste ist noch nicht verfügbar."
                return
            }
            try {
                var parsed = JSON.parse(request.responseText)
                var entries = Array.isArray(parsed) ? parsed : parsed.services
                servicesModel.clear()
                for (var i = 0; i < entries.length; ++i) {
                    var item = entries[i]
                    if (item.id && item.name && item.url && item.icon) {
                        servicesModel.append({
                            serviceId: item.id,
                            serviceName: item.name,
                            serviceUrl: item.url,
                            serviceIcon: item.icon
                        })
                    }
                }
                loadError = ""
            } catch (error) {
                if (!triedFallback) {
                    triedFallback = true
                    manifestUrl = fallbackManifestUrl
                    loadServices()
                    return
                }
                loadError = "Die Dienstekonfiguration ist ungültig."
            }
        }
        request.open("GET", manifestUrl + "?t=" + Date.now())
        request.send()
    }

    preferredRepresentation: compactRepresentation
    compactRepresentation: Kirigami.Icon {
        source: "lokro-hub"
        active: compactMouse.containsMouse
        MouseArea {
            id: compactMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 18
        Layout.minimumHeight: Kirigami.Units.gridUnit * 16
        Layout.preferredWidth: Kirigami.Units.gridUnit * 22
        Layout.preferredHeight: Kirigami.Units.gridUnit * 20

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                text: "Lokro Hub"
                level: 2
                Layout.fillWidth: true
            }
            PlasmaComponents.Label {
                text: servicesModel.count === 0 && loadError === ""
                    ? "Noch keine Lokro-Dienste konfiguriert."
                    : loadError
                visible: servicesModel.count === 0 || loadError !== ""
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: servicesModel
                spacing: Kirigami.Units.smallSpacing
                delegate: PlasmaComponents.Button {
                    required property string serviceName
                    required property string serviceUrl
                    required property string serviceIcon
                    width: ListView.view.width
                    text: serviceName
                    icon.name: serviceIcon
                    onClicked: Qt.openUrlExternally(serviceUrl)
                }
            }
            PlasmaComponents.Label {
                text: "LOKRO Network"
                opacity: 0.65
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                Layout.fillWidth: true
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: root.visible
        onTriggered: root.loadServices()
    }
    Component.onCompleted: loadServices()
}
