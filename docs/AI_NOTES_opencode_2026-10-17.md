# AI_NOTES_opencode — Custom Taskbar / LOKRO Dock

- **Datum:** 2026-10-17
- **Status:** IDEA → Grundstein gelegt (Prototyp existiert, ungetestet)
- **Feature:** F35 (verlinkt aus `IDEAS.md`), Architektur-Entscheidung: `docs/adr/0003-lokro-dock.md`
- **Autor:in:** opencode (big-pickle), auf Wunsch des Projektverantwortlichen

## 1. Auftrag

Bestehende Taskbar (Stock-Plasma-Default mit komischem Kickoff-Logo links, eckig) ersetzen durch eine
eigene Taskbar. Vorgabe: **Apple-Navbar (iOS-Dock) × LOKRO-Glass** — abgerundete Ecken, zentriert,
Glassdesign, große Icons mit App-Namen bei Hover, cleane Animationen.

## 2. Bestandsaufnahme (Recherche-Ergebnis, Fakten)

- **Keine eigene Panel-Config im Repo.** Keine `plasma-org.kde.plasma.desktop-appletsrc`, kein `layout.js`,
  keine `[Panel]`-Sektion in der Look-and-Feel `org.lokro.dark` (`.../contents/defaults` setzt nur
  Farben/Icons/Deko).
- Das „Logo links" ist der **Stock-Kickoff** des Plasma-Default-Panels — Repo liefert kein
  `lokro-os`-Icon (nur `lokro-link-installer.svg`, `lokro-media.svg`), daher Fallback-Icon.
- Einziges Panel-Eingreifen: `lokro-first-login:19-22` hängt `org.lokro.search` an `panels()[0]`
  (per `qdbus6 ...evaluateScript`, einmalig, Stamp `first-login-v3`).
- Plasmoid-Blaupause vorhanden: `org.lokro.search` / `org.lokro.hub`
  (`metadata.json` mit `KPackageStructure: Plasma/Applet` + `contents/ui/main.qml`,
  Plasma-6-Imports, Install unter `/usr/share/plasma/plasmoids/`).
- **Glass ist bisher nur Planung:** `kwinrc` hat keinen `[Effect-blur]`, Hyprland-Blur `enabled = false`,
  `LokroDark.colors` opak. F34 (Glass-Standard) Status PLANNED.
- Design-Packs dürfen laut Schema **keine** QML/Panel-Elemente → Dock gehört in `lokro-shell`/`lokro-branding`,
  nicht in Design-Packs.

## 3. Design-Spezifikation (Entwurf, visuell zu verifizieren)

Tokens aus F34 (`IDEAS.md` Kap. 10.1). Chamfer-Regel: **Dock bleibt gerundet × Glass**
(Chamfer wäre hier nicht sinnvoll — iOS-Dock lebt von der durchgehenden Rundung).

| Element | Maß (Vorschlag) | Quelle/Begründung |
|---|---|---|
| Position | unten, **zentriert**, schwebend (~8–10 px Abstand zum Bildschirmrand) | iOS-Dock |
| Hintergrund | `#111113` @ **72 %** + KWin-Blur dahinter (Frosted) | F34-Glass |
| Rahmen | 1 px `rgba(255,255,255,0.09)` | F34-Token „Rahmen" |
| Eckenradius | 24 px (F34-Std. 18 px; Dock ist die Ausnahme nach außen) | Rundung × Glass |
| Icon-Größe | 48 px (`Kirigami.Units.iconSizes.huge`), Zelle 60 px | „große Icons" |
| Abstand | 8 px Gap, 10 px Padding | kompakt wie iOS |
| Hover | Scale **1,12**, `Easing.OutBack`, **140 ms** + Halo (`highlightColor` @ ~16 %, Fade **120 ms**) | cleane Animation |
| App-Name | Tooltip über dem Icon, Fade + 6 px Slide-up, 120 ms (`PlasmaCore.ToolTipArea`) | Vorgabe „Name bei Hover" |
| Laufpunkt | 4 px Punkt unter aktivem App, Mint `#7fe3b4` (F34-Akzent), Fade 160 ms | iOS-Running-Dot |
| Start-Animation | Dock fährt 150 ms mit Opacity+4 px Y ein (einmalig) | „cleane Animationen" |

Offen/zu verifizieren (Bildschirm-Check auf Arch nötig): Blur tatsächlich hinter Panel/Applet-Hintergrund
(KWin-Blur-Region von plasmashell), Schatten unter Dock, Verhalten bei vielen Icons (Overflow →
Ein-/Ausklappen oder Scrollen), Mehrmonitore (pro Screen ein Dock?).

## 4. Architektur (Kurzfassung, Details im ADR)

**Empfohlen: Plasma-Containment-Weg** — Applet `org.lokro.dock` in `lokro-shell`, Panel-Default über
Look-and-Feel `org.lokro.dark` (`contents/layouts/.../layout.js`), Blur über `kwinrc`.
Alternativen (layer-shell-Dock, reines Theme) verworfen — siehe `docs/adr/0003-lokro-dock.md`.

## 5. Grundstein (diese Sitzung)

1. `docs/adr/0003-lokro-dock.md` — Architekturentscheidung als **Vorschlag**.
2. `packages/lokro-shell/experimental/org.lokro.dock/` — Applet-Prototyp
   (`metadata.json` + `contents/ui/main.qml`), **bewusst nicht in `rootfs/`** → wird noch nicht gepackt.
3. `IDEAS.md` F35 (Steckbrief + Status), `TODO.md` P2-Nachfolge, `AGENTS.md`-Strukturzeile ergänzt.

## 6. Offene Fragen

1. Kickoff ganz raus (Dock ist Launcher+Tasks) vs. LOKRO-Icon-Button links behalten? Vorschlag: raus,
   Suche bleibt als `org.lokro.search`-Widget rechts oder im Dock.
2. Pinned-Apps-Liste: feste Default-Liste vs. `Plasmoid.configuration` (config main.xml) vs.
   XDG-Default-Apps auslesen? Vorschlag: erst Default-Liste, dann Konfig-UI.
3. Standard-Panel-Layout: LnF-`layout.js` vs. Ausweitung von `lokro-first-login`? Vorschlag: LnF (deklarativer),
   `lokro-first-login` nur noch als Fallback.
4. Braucht das Dock eine Customize-Option (Rundung/Stil, siehe F34) direkt oder erst über den F34-Dialog?
5. Hyprland-Session: Dock ist Plasma-Widget — Waybar bleibt dort unberührt. Ist das so ok? (Vorschlag: ja.)
