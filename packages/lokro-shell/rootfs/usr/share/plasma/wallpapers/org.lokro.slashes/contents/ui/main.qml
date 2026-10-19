import QtQuick

Item {
    id: root
    property real pointerX: width * 0.5
    property real pointerY: height * 0.5
    property real phase: 0
    // Start with a short visible motion preview, then reduce work until the
    // pointer moves again. This makes the animation discoverable without
    // keeping the GPU busy on an unattended desktop.
    property double lastInteraction: Date.now()
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    readonly property bool activeMotion: !softwareRendering && Date.now() - lastInteraction < 6500

    Rectangle {
        anchors.fill: parent
        color: "#09090f"

        Rectangle {
            anchors.fill: parent
            opacity: 0.32
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#18181b" }
                GradientStop { position: 0.48; color: "#0f0f10" }
                GradientStop { position: 1.0; color: "#050505" }
            }
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = "rgba(210,210,218,0.16)"
            for (var gy = 24; gy < height; gy += 42) {
                for (var gx = 24; gx < width; gx += 42) {
                    var pdx = gx - pointerX
                    var pdy = gy - pointerY
                    var proximity = Math.max(0, 1 - Math.sqrt(pdx * pdx + pdy * pdy) / 190)
                    var cloud = Math.max(0, Math.sin(gx * 0.008 + gy * 0.011 + phase) * 0.5 + 0.5)
                    ctx.globalAlpha = 0.06 + cloud * 0.13 + proximity * 0.48
                    ctx.beginPath()
                    ctx.arc(gx, gy, 1.0 + cloud * 1.2 + proximity * 2.2, 0, Math.PI * 2)
                    ctx.fill()
                }
            }
            ctx.globalAlpha = 1
            ctx.strokeStyle = "rgba(255,255,255,0.14)"
            ctx.lineWidth = 1.4
            for (var ring = 0; ring < 5; ring++) {
                ctx.beginPath()
                ctx.arc(width * 0.86, height * 0.90, Math.min(width, height) * (0.32 + ring * 0.055), Math.PI * 1.04, Math.PI * 1.72)
                ctx.stroke()
            }
            var spacing = Math.max(110, width / 18)
            var influence = Math.max(220, Math.min(width, height) * 0.28)
            for (var x = -spacing; x < width + spacing; x += spacing) {
                var baseY = height * (0.18 + 0.64 * (0.5 + 0.5 * Math.sin(x * 0.006 + phase)))
                var dx = x - pointerX
                var dy = baseY - pointerY
                var distance = Math.sqrt(dx * dx + dy * dy)
                var hover = Math.max(0, 1 - distance / influence)
                var length = 80 + hover * 150
                var drift = softwareRendering ? 0 : Math.sin(phase + x * 0.01) * 16

                ctx.save()
                ctx.translate(x + drift, baseY)
                ctx.rotate(-0.36 + hover * 0.16)
                ctx.lineCap = "round"
                ctx.lineWidth = 3 + hover * 5
                ctx.strokeStyle = hover > 0.08
                    ? "rgba(250,250,250," + (0.32 + hover * 0.60) + ")"
                    : "rgba(180,180,185,0.23)"
                ctx.beginPath()
                ctx.moveTo(0, -length / 2)
                ctx.lineTo(0, length / 2)
                ctx.stroke()
                ctx.restore()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: function(mouse) {
            root.pointerX = mouse.x
            root.pointerY = mouse.y
            root.lastInteraction = Date.now()
            canvas.requestPaint()
        }
    }

    Timer {
        interval: root.activeMotion ? 40 : 1400
        running: root.visible
        repeat: true
        onTriggered: {
            if (root.activeMotion) root.phase += 0.032
            canvas.requestPaint()
        }
    }

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    Component.onCompleted: {
        root.lastInteraction = Date.now()
        canvas.requestPaint()
    }
}
