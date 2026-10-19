// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls

Button {
    id: control

    property bool chamfered: true
    property real chamferSize: 10

    implicitWidth: Math.max(104, contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: 38
    leftPadding: 16
    rightPadding: 16
    topPadding: 8
    bottomPadding: 8

    contentItem: Label {
        text: control.text
        color: control.enabled ? "#ffffff" : "#777777"
        font.pixelSize: 12
        font.bold: control.highlighted
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: ChamferSurface {
        chamfered: control.chamfered
        cutSize: control.chamferSize
        normalRadius: 7
        fillColor: control.down ? "#ff3a3a3a"
                                : control.highlighted ? "#f02c2c2c"
                                : control.hovered ? "#e6242424" : "#d20d0d0d"
        strokeColor: control.activeFocus || control.hovered ? "#ffffff" : "#66777777"
        strokeWidth: control.activeFocus ? 2 : 1
    }
}
