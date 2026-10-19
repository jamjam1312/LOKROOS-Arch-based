// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick

Item {
    id: surface

    property bool chamfered: true
    property real cutSize: 18
    property real normalRadius: 16
    property color fillColor: "#d20b0b0b"
    property color strokeColor: "#526f6f6f"
    property real strokeWidth: 1

    onCutSizeChanged: shape.requestPaint()
    onChamferedChanged: shape.requestPaint()
    onFillColorChanged: shape.requestPaint()
    onStrokeColorChanged: shape.requestPaint()
    onStrokeWidthChanged: shape.requestPaint()

    Rectangle {
        anchors.fill: parent
        visible: !surface.chamfered
        radius: surface.normalRadius
        color: surface.fillColor
        border.color: surface.strokeColor
        border.width: surface.strokeWidth
    }

    Canvas {
        id: shape
        anchors.fill: parent
        visible: surface.chamfered

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            const inset = surface.strokeWidth / 2
            const cut = Math.max(0, Math.min(surface.cutSize, width / 2, height / 2))
            ctx.reset()
            ctx.beginPath()
            ctx.moveTo(cut + inset, inset)
            ctx.lineTo(width - inset, inset)
            ctx.lineTo(width - inset, height - cut - inset)
            ctx.lineTo(width - cut - inset, height - inset)
            ctx.lineTo(inset, height - inset)
            ctx.lineTo(inset, cut + inset)
            ctx.closePath()
            ctx.fillStyle = surface.fillColor
            ctx.fill()
            if (surface.strokeWidth > 0) {
                ctx.lineWidth = surface.strokeWidth
                ctx.lineJoin = "miter"
                ctx.strokeStyle = surface.strokeColor
                ctx.stroke()
            }
        }
    }
}
