import "OrbitalField.js" as Field
import QtQuick

Item {
    id: root

    required property color skyColour
    required property color starColour
    required property color planetColour
    required property color terrainColour
    required property color accentColour
    required property color orbitColour
    required property real dayProgress
    property bool animating: true
    property real phase: 0

    Accessible.name: qsTr("Animated orbital observatory")
    onPhaseChanged: scene.requestPaint()
    onSkyColourChanged: scene.requestPaint()
    onStarColourChanged: scene.requestPaint()
    onPlanetColourChanged: scene.requestPaint()
    onTerrainColourChanged: scene.requestPaint()
    onAccentColourChanged: scene.requestPaint()
    onOrbitColourChanged: scene.requestPaint()
    onDayProgressChanged: scene.requestPaint()

    Canvas {
        id: scene

        objectName: "orbitalCanvas"
        anchors.fill: parent
        onAvailableChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const dot = (x, y, alpha, size, colour) => {
                ctx.globalAlpha = alpha;
                ctx.fillStyle = colour;
                ctx.fillRect(x - size / 2, y - size / 2, size, size);
            };
            for (let i = 0; i < Field.starCount(width, height); i++) {
                const star = Field.star(i, root.phase, width, height);
                if (!star)
                    continue;

                dot(star.x, star.y, star.alpha, star.size, root.starColour);
                if (star.cross) {
                    dot(star.x - 2.5, star.y, star.alpha * 0.45, 0.8, root.starColour);
                    dot(star.x + 2.5, star.y, star.alpha * 0.45, 0.8, root.starColour);
                    dot(star.x, star.y - 2.5, star.alpha * 0.45, 0.8, root.starColour);
                    dot(star.x, star.y + 2.5, star.alpha * 0.45, 0.8, root.starColour);
                }
            }
            const moonX = width * 0.72;
            const moonY = height * 0.18;
            const moonRadius = Math.min(width, height) * 0.052;
            ctx.globalAlpha = 0.72;
            ctx.fillStyle = root.terrainColour;
            ctx.beginPath();
            ctx.arc(moonX, moonY, moonRadius, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalAlpha = 0.58;
            ctx.fillStyle = root.skyColour;
            ctx.beginPath();
            ctx.arc(moonX - moonRadius * 0.42, moonY - moonRadius * 0.08, moonRadius * 0.95, 0, Math.PI * 2);
            ctx.fill();
            const centreX = width * 0.76;
            const centreY = height * 1.07;
            const radius = height * 0.67;
            ctx.globalAlpha = 0.22;
            ctx.strokeStyle = root.orbitColour;
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.ellipse(centreX, centreY, radius * 1.22, radius * 0.68, -0.11, Math.PI * 1.04, Math.PI * 1.96);
            ctx.stroke();
            ctx.globalAlpha = 1;
            ctx.fillStyle = root.planetColour;
            ctx.beginPath();
            ctx.arc(centreX, centreY, radius, 0, Math.PI * 2);
            ctx.fill();
            ctx.save();
            ctx.beginPath();
            ctx.arc(centreX, centreY, radius, 0, Math.PI * 2);
            ctx.clip();
            for (let i = 0; i < 260; i++) {
                const grain = Field.terrainPoint(i, centreX, centreY, radius);
                dot(grain.x, grain.y, grain.alpha, grain.size, root.terrainColour);
            }
            const shadowOffset = Math.cos(root.dayProgress * Math.PI * 2) * radius * 0.32;
            ctx.globalAlpha = 0.48;
            ctx.fillStyle = root.skyColour;
            ctx.beginPath();
            ctx.arc(centreX + shadowOffset - radius * 0.42, centreY - radius * 0.18, radius * 0.98, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
            for (let ring = 0; ring < 3; ring++) {
                ctx.globalAlpha = 0.24 - ring * 0.065;
                ctx.strokeStyle = root.accentColour;
                ctx.lineWidth = 1.4;
                ctx.beginPath();
                ctx.arc(centreX, centreY, radius + 2 + ring * 4, Math.PI * 1.04, Math.PI * 1.96);
                ctx.stroke();
            }
            const ship = Field.craft(root.phase, centreX, centreY, radius * 1.22, radius * 0.68);
            ctx.save();
            ctx.translate(ship.x, ship.y);
            ctx.rotate(ship.rotation);
            ctx.globalAlpha = 0.82;
            ctx.fillStyle = root.accentColour;
            ctx.beginPath();
            ctx.moveTo(8, 0);
            ctx.lineTo(-5, -3.5);
            ctx.lineTo(-2, 0);
            ctx.lineTo(-5, 3.5);
            ctx.closePath();
            ctx.fill();
            for (let trail = 0; trail < 4; trail++) dot(-8 - trail * 4.5, 0, 0.42 - trail * 0.085, 1.2, root.starColour)
            ctx.restore();
            const meteor = Field.meteor(root.phase, width, height);
            if (meteor) {
                const length = Math.hypot(meteor.dx, meteor.dy);
                for (let i = 15; i >= 0; i--) dot(meteor.x + meteor.dx / length * i * 2, meteor.y + meteor.dy / length * i * 2, meteor.alpha * (1 - i / 16), i === 0 ? 1.8 : 0.9, root.starColour)
            }
            ctx.globalAlpha = 1;
        }
    }

    Timer {
        interval: 50
        repeat: true
        running: root.visible && root.animating
        onTriggered: root.phase += 0.025
    }

}
