// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls

Button {
    id: control

    property bool chamfered: true
    property real chamferSize: 10
    property real densityScale: 1.0

    implicitWidth: Math.max(92 * densityScale, contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: 38 * densityScale
    leftPadding: 16 * densityScale
    rightPadding: 16 * densityScale
    topPadding: 8 * densityScale
    bottomPadding: 8 * densityScale

    contentItem: Label {
        text: control.text
        color: control.enabled ? "#ffffff" : "#777777"
        font.pixelSize: 12 * control.densityScale
        font.bold: control.highlighted
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: ChamferSurface {
        chamfered: control.chamfered
        cutSize: control.chamferSize * control.densityScale
        normalRadius: 7
        fillColor: control.down ? "#ff3a3a3a"
                                : control.highlighted ? "#f02c2c2c"
                                : control.hovered ? "#e6242424" : "#d20d0d0d"
        strokeColor: control.activeFocus || control.hovered ? "#ffffff" : "#66777777"
        strokeWidth: control.activeFocus ? 2 : 1
    }
}
