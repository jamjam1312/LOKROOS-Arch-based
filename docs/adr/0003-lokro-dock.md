# ADR 0003: LOKRO Dock — eigene Taskbar als Plasma-Applet statt Standalone-Dock

- **Status:** Vorschlag (nicht entschieden). Datum: 2026-10-17.
- **Betrifft:** F35 (Custom Taskbar/Dock), F34 (Design-System Glass), F09/F10 (Desktop-Shell).
- **Fundstellen:** Recherche 2026-10-17, s. `docs/AI_NOTES_opencode_2026-10-17.md`.

## Problem
Die aktuelle Taskbar ist der Stock-Plasma-Default (Kickoff-Logo links, eckig, keine Glass-Effekte;
im Repo existiert keine Panel-Config, `kwinrc` ohne `[Effect-blur]`). Gesucht wird eine eigene,
iOS-Dock-inspirierte Taskbar: zentriert, gerundet, Glass, große Icons mit App-Name bei Hover,
saubere Animationen. Offen ist der Integrationsweg — er legt fest, wo Code lebt, wie gepackt wird
und ob die Hyprland-Session betroffen ist.

## Anforderungen
- Volle Gestaltungsfreiheit (Layout, Rundung, Glass, Hover-Animationen) — mit Theme/Config allein nicht erreichbar.
- Kein zweiter Desktop-Stack: Plasma 6 Wayland bleibt unterstützter Default (`docs/ARCHITECTURE.md`).
- Keine eigene Wayland-Session-Abhängigkeit; darf die optionale Hyprland-Sitzung nicht brechen.
- Wartbar mit vorhandenen Mitteln: Plasmoid-Pattern aus `org.lokro.search`/`org.lokro.hub` wiederverwendbar,
  Packaging über `lokro-shell` (`cp -a rootfs`), Validierung über `make validate`.
- Regeln: Design-Packs bleiben codefrei (Schema erlaubt kein QML); Chamfer-nur-wo-sinnvoll — Dock gerundet.

## Alternativen
1. **Plasma-Applet/Containment + LnF-Panel-Layout (empfohlen):** Applet `org.lokro.dock` unter
   `/usr/share/plasma/plasmoids/`, Panel-Default deklarativ über die Look-and-Feel
   `org.lokro.dark` (`contents/layouts/<template>/contents/layout.js`), Glass über KWin-Blur (`kwinrc`).
   - Pro: gleicher Stack wie bestehende Widgets, `metadata.json`-Pattern + `lokro-first-login`-Blaupause
     vorhanden, kein neues Packaging, keine Session-Abhängigkeit, Blurr/Zentrierung über Plasma-Konfigurierbarkeit.
   - Contra: Blur hinter Panel ist plasmashell-/Theme-abhängig (zu verifizieren); Panel-Defaults der LnF sind
     ein neuer Mechanismus im Repo (noch nie eingesetzt).
2. **Standalone layer-shell-Dock (verworfen):** eigener Wayland-Client (à la wlr-layer-shell-Docks).
   - Pro: maximale Unabhängigkeit vom Panel.
   - Contra: keine layer-shell-Infrastruktur im Repo; nur Plasma-Wayland (Hyprland-Interoperabilität?);
     eigenes Packaging/Fenstermanagement/HiDPI/Scaling zu pflegen; kollidiert mit der bestehenden
     „Plasma + Waybar-für-Hyprland"-Arbeitsteilung; doppelter Wartungsaufwand für Icons/Fensterzuordnung.
3. **Reines Theme/Look-and-Feel (verworfen):** Farben/Deko änderbar, aber kein zentriertes Icon-Layout,
   keine Tasks, keine Hover-Animationen — die Kernanforderung bleibt unerfüllt.

## Entscheidung (Vorschlag)
Variante 1: **Plasma-Applet `org.lokro.dock`** in `lokro-shell`, Panel-Default über LnF
`org.lokro.dark`, Glass über KWin-Blur + eigenes halbtransparentes Background-Item des Applets.
Hyprland behält Waybar unverändert (Dock ist Plasma-spezifisch, dort bewusst nicht portiert).

## Begründung
Stack-Kontinuität (gleiche Argumente wie ADR 0001): vorhandenes Plasmoid-Pattern, vorhandenes
Packaging, kein neuer Client, keine neue Abhängigkeit. Die Recherche zeigte, dass keinerlei
Panel- oder layer-shell-Konstrukt im Repo existiert — der Plasma-Weg ist der einzige, der auf
dem bestehenden Fundament ohne neue Infrastruktur auskommt.

## Nachteile
- Panel-Layout-Override über LnF ist neu; Fallback (`lokro-first-login`) muss definiert bleiben.
- KWin-Blur muss auf Arch verifiziert werden (Frosted-Effekt hinter dem Applet-Hintergrund ist nicht garantiert).
- Dock-Verhalten bei vielen Icons/HiDPI/Mehrmonitoren ist ungelöst (Offenpunkte F35).
- Eigenes Applet = eigene QML-Oberfläche, die mit Plasma-Updates mitschwingt (API-Prüfung bei jedem Alpha).

## Auswirkungen
- Neue Dateien: `packages/lokro-shell/.../plasmoids/org.lokro.dock/` (später `rootfs/`),
  LnF-`layout.js`, `kwinrc`-Blur-Eintrag; Kickoff-Default wird ersetzt (Entscheidung offen, s. AI-Notizen §6).
- `AGENTS.md`-Strukturzeile für `lokro-shell` ergänzt; F35-Steckbrief in `IDEAS.md`.
- Design-Packs/Store bleiben unberührt; F34-Theming-Hooks (Customize-Dialog) können Dock-Stil später erben.
- Bei Entscheidung für Variante 2/3: dieses ADR aktualisieren, nicht still ersetzen.
