import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.taskmanager as TaskManager

PlasmoidItem {
    id: root

    // F35 "LOKRO Dock" — PROTOTYP, UNGETESTET (qmllint + Plasma-VM stehen aus).
    // Nicht ins ISO gepackt: liegt unter experimental/, nicht unter rootfs/.

    readonly property int iconSize: 48
    readonly property int cellSize: 60
    readonly property int dockRadius: 24
    readonly property int dockPadding: 10
    readonly property int dockGap: 8

    property var pinned: [
        "applications:org.kde.dolphin.desktop",
        "applications:firefox.desktop",
        "applications:org.kde.konsole.desktop",
        "applications:org.kde.kate.desktop",
        "applications:systemsettings.desktop"
    ]

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    TaskManager.TasksModel {
        id: tasksModel
        launchers: root.pinned
        filterByVirtualDesktop: true
        groupMode: TaskManager.TasksModel.GroupDisabled
    }

    fullRepresentation: Item {
        id: glassRoot
        implicitWidth: dockRow.implicitWidth + 2 * root.dockPadding
        implicitHeight: dockRow.implicitHeight + 2 * root.dockPadding

        opacity: 0.0
        Component.onCompleted: entranceAnim.start()

        ParallelAnimation {
            id: entranceAnim
            NumberAnimation {
                target: glassRoot; property: "opacity"; to: 1.0
                duration: 150; easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: glassRoot; property: "y"; from: 4; to: 0
                duration: 150; easing.type: Easing.OutQuad
            }
        }

        Rectangle {
            id: glass
            anchors.fill: parent
            radius: root.dockRadius
            color: Qt.rgba(0.067, 0.067, 0.075, 0.72)
            border.width: 1
            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.09)
            // TODO(F35): echten Frosted-Effekt prüfen (KWin-Blur-Region von plasmashell).

            RowLayout {
                id: dockRow
                anchors.centerIn: parent
                spacing: root.dockGap

                Repeater {
                    model: tasksModel

                    delegate: Item {
                        id: delegateRoot
                        required property int index
                        required property var model

                        width: root.cellSize
                        height: root.cellSize

                        readonly property bool hovered: tipArea.containsMouse

                        Rectangle {
                            id: hoverHalo
                            anchors.fill: parent
                            radius: 14
                            color: Kirigami.Theme.highlightColor
                            opacity: delegateRoot.hovered ? 0.16 : 0.0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120; easing.type: Easing.OutQuad
                                }
                            }
                        }

                        Kirigami.Icon {
                            id: appIcon
                            anchors.centerIn: parent
                            width: root.iconSize
                            height: root.iconSize
                            source: delegateRoot.model.icon
                            active: delegateRoot.hovered
                            scale: delegateRoot.hovered ? 1.12 : 1.0
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 140; easing.type: Easing.OutBack
                                }
                            }
                        }

                        Rectangle {
                            id: runningDot
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 2
                            width: 4
                            height: 4
                            radius: 2
                            color: "#7fe3b4"
                            opacity: delegateRoot.model.isActive ? 1.0 : 0.0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 160; easing.type: Easing.OutQuad
                                }
                            }
                        }

                        PlasmaCore.ToolTipArea {
                            id: tipArea
                            anchors.fill: parent
                            mainText: delegateRoot.model.display
                            subText: delegateRoot.model.isWindow ? qsTr("Fenster öffnen") : qsTr("App starten")
                            active: true

                            onClicked: {
                                var idx = tasksModel.makeModelIndex(delegateRoot.index);
                                // TODO(F35): Launcher-vs-Fenster sauber trennen
                                // (requestActivate nur für Fenster, sonst requestNewInstance).
                                tasksModel.requestActivate(idx);
                            }
                        }
                    }
                }
            }
        }
    }
}
