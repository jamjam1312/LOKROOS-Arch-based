# org.lokro.dock — LOKRO Dock (Prototyp, WIP)

**Status: PROTOTYP — nicht getestet, nicht gepackt, nicht im ISO.**

Dieses Verzeichnis liegt bewusst außerhalb von `rootfs/`: das `lokro-shell`-PKGBUILD kopiert nur
`rootfs/.`, solange diese Dateien hier liegen, landet **nichts** im Paket/ISO. Das schützt davor,
ungetestetes QML auszuliefern (AGENTS-Regel: kein „fertig" ohne Nachweis).

## Idee (F35)

iOS-Dock × LOKRO-Glass: zentrierte, gerundete, halbtransparente Taskbar unten, große Icons (48 px),
App-Name bei Hover, sanfte Animationen. Design-Spezifikation: `docs/AI_NOTES_opencode_2026-10-17.md`,
Architektur: `docs/adr/0003-lokro-dock.md`.

## Offene Prüfungen (bevor es nach `rootfs/` wandern darf)

1. `qmllint contents/ui/main.qml` (Arch-CI) muss grün sein.
2. TaskManager-Rollen prüfen: `model.display`/`model.icon`/`model.isActive`/`model.isLauncher` auf
   Plasma 6 verifizieren; Klick-Verhalten Launcher-vs-Fenster (`requestActivate` vs `requestNewInstance`).
3. Manuell in einer Plasma-6-VM: Applet ins Panel hängen, Icon-Größe/Hover/Tooltip/Blur prüfen.
4. Glass prüfen: KWin-Blur-Effekt aktivieren (`kwinrc [Effect-blur]`) und ob der Applet-Hintergrund
   tatsächlich Frosted dahinter bekommt.
5. Panel-Default (LnF `org.lokro.dark` layout.js) + Kickoff-Entscheidung (s. AI-Notizen §6).
6. Danach: `rootfs/`-Pfad, `EnabledByDefault` prüfen, `make validate`, Visuell-Check → erst dann
   Status `IMPLEMENTED` in `IDEAS.md` F35.

## Struktur

```
org.lokro.dock/
├── metadata.json            # Plasma-6-Metadaten (Blaupause: org.lokro.search)
└── contents/ui/main.qml     # Prototyp: TasksModel + zentriertes Glass-Dock
```
