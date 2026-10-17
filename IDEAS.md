# IDEAS.md — Technische Roadmap LokroOS (prüfbares Projektmanagement)

> Stand: 2026-10-16, Version `0.1.0-alpha.16`. Statuswerte sind verbindlich:
> `IDEA / PLANNED / IN_PROGRESS / PARTIAL / BLOCKED / IMPLEMENTED / TESTED / COMPLETED / DEPRECATED / CANCELLED`.
> Code vorhanden ≠ fertig. Statuswechsel nur mit Nachweis (Log, Test, Hardware-Protokoll).
> Quelle dieser Struktur: Master-Prompt vom 2026-10-15 (Volltext im Anhang).

## Statusübersicht (ehrlich, Stand heute)

| # | Feature | Status | Nachweis / Bemerkung |
|---|---|---|---|
| F01 | Arch-Basis x86_64 (Kernel, Firmware) | IMPLEMENTED | Quelle vorhanden; HW-Matrix offen |
| F02 | Build-System + ISO offline/online | IMPLEMENTED | alpha.9 beide ISOs gebaut (3,67/2,65 GiB) |
| F03 | BIOS-Plasma-Smoke | TESTED | alpha.10: Plasma nach 32 s (BIOS) |
| F04 | UEFI-Plasma-Smoke | TESTED | Run 38801087314 (2026-10-15): `LOKRO_PLASMA_READY` via UEFI |
| F05 | Calamares-Installation (unpackfs, cleanup) | IMPLEMENTED | Config vorhanden; VM-Installationsnachweis offen |
| F06 | GRUB BIOS+UEFI + os-prober | IMPLEMENTED | Dual-Boot bleibt best-effort/alpha |
| F07 | Plymouth-Theme lokro | IMPLEMENTED | minimal (Logo+Puls), kein Fortschritt |
| F08 | SDDM Live-Autologin | IMPLEMENTED | Teil von BIOS-Smoke |
| F09 | Plasma 6 Wayland + XWayland | IMPLEMENTED | BIOS-Smoke ok; kein Plasma-X11-Login (gewollt) |
| F10 | Hyprland-Sitzung (optional) | IMPLEMENTED | Pakete+Chooser vorhanden; Sitzungstest offen |
| F11 | Netzwerk/Bluetooth/USB | IMPLEMENTED | Pakete+Dienste vorhanden; HW-Tests offen |
| F12 | PipeWire-Audio | IMPLEMENTED | HW-Test offen |
| F13 | ZRAM/oomd/power-profiles/fstrim | IMPLEMENTED | Config vorhanden; Lasttest offen |
| F14 | Firefox + Deutsch | IMPLEMENTED | im ISO; Browser-Abwahl via contextualprocess |
| F15 | LibreOffice offline | IMPLEMENTED | nur offline-Variante |
| F16 | Flatpak/Flathub/Discover | PARTIAL | Deskriptor-Download beim Build fragil → KI-002 |
| F17 | Link-Installer (HTTPS-only) | IMPLEMENTED | validate.mjs-Safety-Invariants bestehen |
| F18 | LOKRO Media (VLC) | IMPLEMENTED | Assoc. audio/mpeg, video/mp4|matroska geprüft |
| F19 | Update-System (5h-Timer, Backup, Kernel-Retention) | IMPLEMENTED | Unit-Tests ok; E2E-Update-Test offen |
| F20 | Task-Manager/Suche/Hub/Welcome (QML) | IMPLEMENTED | qmllint nur in Arch-CI |
| F21 | Gaming-Bundle (Steam/PrismLauncher/Java/GameMode/…) | PARTIAL | Offline-Dedup vorhanden; kein HW-Test |
| F22 | NVIDIA-open (Turing+) | PARTIAL | Paketpfad vorhanden; kein HW-Test; Alt-HW → Nouveau |
| F23 | Update-Kanal-Pinning | IMPLEMENTED | byte-identisch, unattended=false, Unit-Tests ok |
| F24 | Manifeste/Lizenzen/Provenienz/Split | IMPLEMENTED | `checksums.sh`; dbpath-Verdacht → KI-003 |
| F25 | Lokaler KI-Assistent (Chat) | IDEA | **nur Konzept** (Kap. 9); nicht implementieren |
| F25b | OpenClaw-artige Systemsteuerung (Benchmark, Claw-Hook, Permissions, BYOK) | IDEA | **nur Konzept** (Kap. 9.9); kein Code; Modelle nie im ISO |
| F26 | Ollama-Setup (Downloader, gepinnt) | IMPLEMENTED | nur Downloader; kein Modell im ISO |
| F27 | Server-Edition | CANCELLED | `server/` Platzhalter, nicht Teil v0.1 |
| F28 | ARM-Port | IDEA | separates Zukunftsprojekt; Voraussetzung für F30 |
| F29 | Secure Boot | IDEA | nicht unterstützt |
| F30 | Mobile-Version (Smartphone/Tablet) | IDEA | nur Planung (Kap. 9.10); braucht ARM-Port + Mobile-Shell |
| F31 | Eigener Appstore (+ Google Play?) | PARTIAL | Desktop-Store `lokro-store` seit alpha.13, auf v0.1.0-alpha.6 (Flathub-Repair, ArtCraft-Bundle, Design-Pack-Download); Play/Mobile weiter IDEA |
| F32 | APK-/Android-App-Unterstützung | IDEA | nur Planung (Kap. 9.10); „fast alle" unrealistisch ohne Nachweis |
| F33 | Design Packs (deklarativ, user-scoped) | IMPLEMENTED | seit alpha.12: `design-packs/`, Schema, Importer+GUI, Tests |
| F34 | Design-System nach lokro.dev-Branding | PLANNED | Beschluss 2026-10-16 (Kap. 10.1); Umsetzung offen |
| F35 | Custom Taskbar/Dock (iOS-Dock × Glass) | IN_PROGRESS | Grundstein 2026-10-17: ADR 0003 + Prototyp in `lokro-shell/experimental/` (ungetestet, nicht gepackt) |

## Feature-Steckbriefe (kompakt, alle Pflichtfelder)

### F02 Build-System und ISO-Erstellung — IMPLEMENTED (UEFI-Teil BLOCKED)
- **Ziel:** Reproduzierbare offline-/online-ISOs aus releng + lokro-Overlay.
- **Stand:** vorhanden (`build-packages.sh`, `prepare-profile.sh`, `build-iso.sh`, `checksums.sh`); alpha.9 beide ISOs gebaut.
- **Plan:** 1) Flathub-Pin härten 2) profiledef-Verifikation 3) Größen-Warnschwelle 4) BIOS+UEFI-Smoke bestehen.
- **Anforderungen:** Arch-Container, root, 20 GiB, archiso, edk2-ovmf, qemu.
- **Ressourcen:** mehrere GiB Cache, lange Build-Zeit (zstd-15).
- **Abhängigkeiten:** F01, F23. **Sicherheit:** keine AUR-Helper/curl-pipe; `[lokro]` TrustAll nur lokal (offen: Signatur).
- **Akzeptanz:** beide ISOs ≤4 GiB, BIOS+UEFI `LOKRO_PLASMA_READY`, Manifeste vollständig.
- **Offen:** UEFI-Smoke nach alpha.11-Fix; GRUB-`linux`-Zeile ohne Serial-Logs.
- **Priorität:** kritisch. **Nächster Schritt:** `make iso-offline && make smoke-bios smoke-uefi` auf Arch, Logs sichern.
- **Links:** `scripts/*`, `.github/workflows/build-iso.yml`, `docs/ISO_BUILD_ANALYSE_2026-10-15.md`, KI-001–KI-006.

### F04/F05 Installation und Recovery — IMPLEMENTED
- **Ziel:** Calamares kopiert eingebettetes SquashFS, richtet User/GRUB/initramfs ein, entfernt Live-Artefakte.
- **Stand:** `settings.conf`-Flow, Chooser (desktop/apps/browser/graphics/gaming), `installer-cleanup` vorhanden.
- **Plan:** Calamares-Schema-Validierung einführen; `welcome-online.conf` tatsächlich verkabeln; VM-Install testen (leer, verschlüsselt, alongside mit Backup).
- **Anforderungen:** calamares-lokro 3.3.14/Qt6, grub, efibootmgr, os-prober.
- **Akzeptanz:** Leere-VM-Install bootet ohne ISO; `installer-cleanup`-Artefakte weg; disk-root-HOOKS gesetzt.
- **Offen:** `packagechooser-browser.conf` nutzt `method: legacy` (Kompatibilität mit 3.3.14 verifizieren).
- **Priorität:** hoch. **Nächster Schritt:** Calamares-Modul-Schema gegen installierte 3.3.14 prüfen.

### F06 Bootprozess (GRUB/systemd-boot/syslinux, Plymouth) — IMPLEMENTED
- **Ziel:** BIOS+UEFI booten, Diagnose über seriell, schlichte Animation.
- **Stand:** GRUB für Zielsystem; Live-Serial nur auf `APPEND`/`options` (alpha.11); Plymouth minimal.
- **Akzeptanz:** Beide Firmwares erreichen SDDM; serielle Logs enthalten Kernel-/systemd-Fortschritt.
- **Offen:** GRUB-`linux`-Zeile ohne Serial (Diagnose-Lücke). **Priorität:** hoch.

### F09/F10 Desktop und System-Shell — IMPLEMENTED
- **Ziel:** Plasma-Standard + optionale Hyprland-Sitzung, konsistentes LOKRO-Gefühl.
- **Stand:** Pakete, Chooser, SDDM-Session-Auswahl vorhanden.
- **Akzeptanz (TESTING.md):** KRunner/Wofi, Task-Manager, Cursor-Persistenz, Meta+T, Waybar/portals/screenshots.
- **Priorität:** mittel. **Nächster Schritt:** interaktive VM-Checks protokollieren.

### F11/F12 Netzwerk, Audio, Bluetooth, Hardware — IMPLEMENTED (Tests offen)
- Pakete/Dienste (NetworkManager, iwd, bluez, PipeWire) vorhanden; Dienste-Enables in `prepare-profile.sh` + `services-systemd.conf`.
- **Akzeptanz:** HW-Matrix aus TESTING.md (AMD, NVIDIA-open, Nouveau, Dual-Monitor, Suspend, BT-Audio, USB FAT/exFAT/NTFS, Steam, PrismLauncher+Java). **Priorität:** hoch (Menschenarbeit).

### F16 Flatpak/Flathub — PARTIAL
- **Risiko:** Build lädt `flathub.flatpakrepo` per curl + hartem SHA → Netzwerk-/Rotations-Bruch. **Fix:** cachen/Retry/SHA aus `sources.json`, versionierte Kopie.
- **Priorität:** hoch (P0 als Build-Blocker).

### F19 Updates und Wartung — IMPLEMENTED
- Timer 3 min nach Boot + alle 5 h, low-prio, `checkupdates` (kein Partial-Upgrade), Backup `/var/lib/lokro-update/backups/`, Kernel-Modul-Retention via Hooks.
- **Akzeptanz:** Unit-Tests bestehen; E2E (Download→Bestätigung→`-Syu`→Backup→Reboot-Empfehlung) offen. **Priorität:** mittel.

### F21/F22 Gaming und NVIDIA — PARTIAL
- Offline-Repo unter `/opt/lokro/repo` mit Dedup (bereits installierte Pakete entfernt); Chooser für Gaming/NVIDIA vorhanden.
- **Offen:** Dedup-Parsing (`pacman -Qp`+awk) ohne Fehlerbehandlung; Kernel/NVIDIA-Versionsdrift bei Offline-Install; keine HW-Tests. **Priorität:** mittel.

### F25 Lokale KI — IDEA (Konzept, keine Implementierung)
Siehe Kap. 9 unten. Derzeit real: nur `lokro-ai-setup` (gepinnter Ollama-Downloader + `opencode`-Opt-Dependency, kein Modell im ISO).
**Anordnung: kein Code dafür in dieser Aufgabe.**

## Roadmap (abhängigkeitsgetrieben)

- **Phase 0 – Doku-Fundament (diese Sitzung):** AGENTS/IDEAS/TODO/ARCHITECTURE/DEVELOPMENT_LOG/KNOWN_ISSUES + ISO-Analyse. Fertig, wenn Links + Checks bestehen.
- **Phase 1 – Build-Stabilisierung (P0):** KI-001–KI-006 fixen (Flathub-Pin, dbpath, profiledef-Check, Größenpuffer, validate-Robustheit, sudoers-Trap). Gate: `make validate packages iso-offline iso-online checksums` grün.
- **Phase 2 – Boot-Nachweis:** BIOS+UEFI-Smoke grün, serielle Diagnose für GRUB klären. Gate: beide Smoke-Logs.
- **Phase 3 – Installations-QA:** Calamares-Schema-Check, VM-Installs (leer/verschlüsselt), Installer-E2E, Target-Boot ohne ISO.
- **Phase 4 – Hardware-Matrix:** AMD/NVIDIA-open/Nouveau, Monitore, Audio/BT, Suspend, Steam/Minecraft, alongside mit Backup.
- **Phase 5 – Härtung:** Signaturschlüssel-Design (ADR), Größenbudget-Verteidigung, QML/Desktop-Lint überall, Beta-Kriterien.
- **Phase 6 – KI-Konzept:** erst wenn Phasen 1–4 stehen: Machbarkeit, Backend-/Modell-Evaluation, Benchmark-Konzept (nur Doku, dann Beschluss).

### F33 Design Packs — IMPLEMENTED (seit alpha.12)
- **Ziel:** Sichere, deklarative Themes (Farben + Wallpaper) ohne Code-Ausführung, als Vorstufe eines künftigen App-Stores.
- **Stand:** `design-packs/` (Format + Schema `design-pack.schema.json`), Importer `lokro-design-pack` + GUI, Black-Box-Security-Tests, Doku `docs/DESIGN_PACKS.md`. User-scoped (`~/.local/share`), kein Pacman/Flatpak/sudo.
- **Akzeptanz:** `make validate` prüft alle Repo-Packs; Importer lehnt Pfade/`..`/Links/ausführbare Bits/Übergrößen ab.
- **Offen:** Store-Anbindung (siehe F31). **Priorität:** niedrig (stabil). **Links:** `design-packs/`, `docs/DESIGN_PACKS.md`.

### F30 Mobile-Version — IDEA (nur Planung, Wunsch aus TODO-Rework 2026-10-16)
- **Ziel:** LokroOS auf Smartphones/Tablets (neue + ältere Chips) nutzbar machen.
- **Verbindliche Vorgabe (2026-10-16):** Die Mobile-Version enthält **keine integrierte lokale KI**.
  Begründung: Prozessor, RAM und Storage mobiler Geräte reichen nicht für ein fähiges lokales Modell.
  KI gibt es mobil ausschließlich per **BYOK** (nutzereigene Schlüssel, z. B. ChatGPT/Claude/Anthropic);
  ohne Schlüssel läuft das System vollständig ohne KI. Der Benchmark-/Download-Pfad (9.9.2) gilt nur für Desktop.
- **Stand:** Nichts vorhanden. x86_64-ISO ist nicht wiederverwendbar; `docs/ARM_PORT.md` erklärt ARM als separates Zukunftsprojekt.
- **Plan:** 1) ARM-Port beschließen (F28: Arch Linux ARM-Basis, Kernel/Bootloader je SoC). 2) Mobile-Shell evaluieren (z. B. Plasma Mobile vs. Phosh — unfestgelegt). 3) Telefonie-/SMS-/Modem-Stack (ModemManager vorhanden, Rest offen). 4) Strom-/Touch-/Sensor-Tests auf Referenzgeräten.
- **Anforderungen:** ARM-Build-Infra, SoC-Kernel, mobile Shell, angepasster Calamares- oder OEM-Flow.
- **Ressourcen:** Sehr hoch (eigene Images je Geräteklasse, Hardware-Labor). **Abhängigkeiten:** F28 zuerst.
- **Sicherheit:** Baseband-/Bootloader-Risiken je Gerät;Verified-Boot-Konzepte separat prüfen.
- **Akzeptanz:** Referenzgerät bootet, Touch/Telefonie/SMS/Browser gehen, Update-Pfad existiert.
- **Vertiefung 2026-10-16 (Brainstorm, alles IDEA):**
  - *Input-Hooks:* Shell-Entscheidung zuerst (Leitkandidat Plasma Mobile wegen KDE/Kirigami-Kontinuität, Phosh nur bei
    Showstopper — siehe `docs/adr/0001-mobile-shell-plasma-mobile.md`).
    Maliit-Tastatur + LOKRO-Layout, Gesten-Ebene (Edge-Swipe, Runterziehen, Wisch-Halten, Pinch, Long-Press) via QML/KWin-Touch,
    `feedbackd`-Haptik, libinput-Kalibrierung + kinetisches Scrollen, Lockscreen mit PIN und Notruf-Durchreiche.
  - *Eigene Mobile-OS-Abgrenzung:* eigenes Build-Profil `mobile` — kein Steam/Proton/Gaming, kein nvidia-open, kein LibreOffice;
    dafür Waydroid-Stack, Store-Clients, Dialer/SMS/Kontakte, Mobile-Settings. Kein Calamares: Flash-Images pro Gerät +
    Ersteinrichtungs-Assistent (Sprache, WLAN, SIM-PIN, Stores, BYOK).
  - *Konnektivität:* vorhanden (NetworkManager, ModemManager, provider-info); fehlend: SIM-PIN/PUK-Flow, APN-UI, Anruf-/SMS-App,
    mobiler Hotspot (AP-Modus + Datenwarnung), Flugmodus, Dual-SIM (später). VoLTE/WLAN-Calls offen/geräteabhängig — nichts versprechen.
  - *APK + Stores:* Waydroid (Binder-Kernel-Module nötig, Android-Image gepinnt, Download nur nach Zustimmung — Prinzip wie KI-Modelle);
    Integration (Fenster, Dateien, Mitteilungen). Stores: eigener (F31) + Aurora Store (pragmatischer Play-Zugang) + F-Droid;
    MicroG nur mit dokumentierter Sicherheitsabwägung.
  - *Hardware:* 1–2 Referenzgeräteklassen (alt + neu) mit Mainline-Support; Mainline-vs-Halium als ADR.
  - *Reihenfolge:* ARM-ADR → Referenzgeräte → Shell+Input → Konnektivität → Waydroid/Stores → Assistent → Härtung.
    Der Einrichtungs-Assistent ist als gemeinsame Komponente mit dem Desktop-Welcome gedacht
    (siehe `docs/adr/0002-shared-first-boot-wizard.md`).
- **Offen:** Alles — Geräteauswahl, Shell, Ressourcen. **Priorität:** niedrig (Fernziel). **Nächster Schritt:** Kein Code; erst F28-ADR (ARM-Strategie).

### F31 Eigener Appstore (+ Google Play?) — PARTIAL (Desktop-Store da, Rest Planung)
- **Ziel:** Grafischer Laden für Apps neben Pacman/Discover.
- **Stand:** Seit alpha.13 Paket `lokro-store` (Upstream-Tarball `LOKROOS-Appstore-githubconnection`,
  aktuell v0.1.0-alpha.6, gepinnt mit SHA-256): Katalog `catalog/v1/catalog.json` + Schema, PySide6-GUI,
  Desktop-Datei, Icons. Alpha.6 repariert den user-scoped Flathub-Remote, installiert das verifizierte
  ArtCraft-0.3.2-Flatpak-Bundle (SHA-256-gepinnt) und lädt geprüfte `.lokrodesign`-Design-Packs nur von
  immutablen Tags mit Checksummen-Verifikation in den vorhandenen no-script-Importer. Design-Packs-Format
  (F33) bleibt das privilegienlose Format.
- **Ehrlicher Hinweis:** **Google Play kann nicht einfach mitgeliefert werden** — Play Store/Play-Dienste (GMS)
  erfordern Googles Lizenzierung und Gerätezertifizierung; ohne das gibt es kein legales Play auf eigenem OS.
  Realistische Pfade: eigener Store für Flatpaks/Packs, optional F-Droid-Repos, Play nur per Nutzer-eigener
  Installation (deren Legalität/Funktion der Nutzer verantwortet).
- **Plan:** 1) Store-Umfang/QA (Katalog-Kommandos nur aus Allowlist — Upstream-Regel). 2) Signatur-Modell
  (baut auf Update-Kanal F23 + Signatur-ADR auf). 3) Mobile Stores (Aurora/F-Droid, siehe F30-Vertiefung).
- **Abhängigkeiten:** F16, F23, Signatur-ADR. **Akzeptanz:** Installieren/Deinstallieren/Updates aus kuratierter Quelle
  mit Signaturprüfung; `make validate` prüft Katalog-Schema.
- **Priorität:** mittel (Desktop), niedrig (Mobile-Stores). **Nächster Schritt:** Store-E2E (Katalog installieren,
  GUI-Start, Update-Pfad) protokollieren.

### F32 APK-/Android-App-Unterstützung — IDEA (nur Planung)
- **Ziel:** Android-Apps (APK) unter LokroOS nutzen.
- **Stand:** Nichts vorhanden.
- **Ehrlicher Hinweis:** „Fast alle Android-Apps" ist ohne Nachweis unrealistisch: Als einziger gangbarer Weg gilt ein Container-Ansatz (z. B. Waydroid: Wayland + Binder-Kernel-Module + Android-Image), der nur einen Teil der Apps (v. a. ohne GMS-Abhängigkeit und ohne exotische NDK-/Hardware-Bindung) abdeckt und eigenen Pflegeaufwand (Images, Updates, Integration) bedeutet.
- **Plan:** 1) Machbarkeit prüfen (Kernel-Module, Wayland-Sitzungen, Image-Quelle/Lizenz). 2) Prototyp mit 5 definierten Referenz-APKs. 3) Integration (Fenster, Dateien, Berechtigungen) + Update-Modell.
- **Abhängigkeiten:** Wayland-Sitzungen (F09/F10 ok), Kernel-Config (Binder!), Image-Trust-Modell.
- **Akzeptanz:** Referenz-APKs starten, laufen stabil, deinstallieren rückstandsfrei; kein Root-Bruch des Hosts.
- **Priorität:** niedrig. **Nächster Schritt:** Machbarkeitsnotiz (1 Seite), kein Code.

### F35 Custom Taskbar / LOKRO Dock — IN_PROGRESS (Grundstein gelegt, Prototyp ungetestet)
- **Ziel:** Eigene Taskbar im Stil der Apple-iOS-Navbar, verbunden mit LOKRO-Glass: zentriertes,
  schwebendes Dock unten, **gerundete Ecken** (Rundung × Glass — Chamfer bewusst nicht, s. Designprinzip 6),
  Glass-Hintergrund (KWin-Blur + `#111113` @ 72 %), große Icons (48 px) mit App-Namen bei Hover,
  cleane Animationen (Hover-Scale 1,12/140 ms, Halo-Fade, Tooltip-Slide, Mint-Laufpunkt `#7fe3b4`).
  Anstoß: beobachtetes Stock-Panel mit „komischem Logo" links und eckiger Leiste (Videofeedback 2026-10-17).
- **Stand (2026-10-17):** Recherche + Architektur-Vergleich abgeschlossen; **ADR 0003** (Vorschlag:
  Plasma-Applet statt Standalone-Dock); Prototyp `packages/lokro-shell/experimental/org.lokro.dock/`
  (`metadata.json` + `main.qml`, TasksModel-basiert). **Bewusst noch nicht in `rootfs/`** → wird nicht
  gepackt, nicht getestet, kein Nachweis. Panel-Config existiert im Repo bisher nicht (Stock-Plasma-Default).
- **Plan:** 1) qmllint + Plasma-VM-Check des Prototyps (Rollen, Klick, Blur) 2) KWin-Blur in `kwinrc`
  verifizieren 3) Panel-Default über LnF `org.lokro.dark` (`contents/layouts/.../layout.js`) setzen,
  Kickoff-Entscheidung (AI-Notizen §6) 4) nach `rootfs/` heben, `make validate`, visuellen Abgleich
  gegen die Spezifikation (AI-Notizen §3) 5) F34-Theming-Hooks/Stil-Option (rund/Chamfer) später anbinden.
- **Abhängigkeiten:** F34 (Glass-Tokens), F09/F10 (Plasma-Default), ADR 0003.
- **Akzeptanz:** Dock zentriert/gerundet/glassig sichtbar; Hover zeigt App-Namen; Animationen flüssig;
  beide ISOs bauen, Rauch-Test weiter grün; Hyprland/Waybar unberührt; `make validate` grün.
- **Priorität:** mittel (User-Wunsch). **Nächster Schritt:** Prototyp auf Arch mit `qmllint` prüfen,
  dann manuell ins Panel hängen und visuell bewerten.
- **Links:** `docs/adr/0003-lokro-dock.md`, `docs/AI_NOTES_opencode_2026-10-17.md`,
  `packages/lokro-shell/experimental/org.lokro.dock/`.

## 9. Zukünftiges Feature: Lokal integrierte KI (nur Konzept)

### 9.1 Zielsetzung
Lokal betriebener KI-Assistent mit grafischer Chat-Oberfläche für Fragen, Systembedienung, Fehlerdiagnose, später evtl. Entwickleraufgaben.
Inferenz lokal, keine Pflicht-Cloud. Datenschutzfreundlich, frei konfigurierbar, ohne unnötige Modell-Zensur-Versprechen.
„Unzensiert“ ≠ Garantie: Modellgrenzen, Lizenzen, Sicherheit und Einsatzgrenzen separat prüfen. Status: IDEA.

### 9.2 Keine Modellgewichte im ISO
Ablauf: Erkennung → transparente Info → Hardware-/Ressourcenanalyse → begründete Modell-/Backend-Empfehlung →
ausdrückliche Zustimmung oder Ablehnung → bei Ja: Download+Setup+Integritäts-/Funktionstests → Freischaltung.
Bei Nein: keine Downloads, System voll nutzbar. Bootstrap ohne Gewichte prüfen. Status: IDEA.

### 9.3 Hardware-Benchmark und Modellauswahl
Kriterien: CPU, RAM, GPU/VRAM/Backend, Arch, Platte, Bandbreite, Energie, OS-Kompatibilität.
Kurzer reproduzierbarer Leistungstest statt reiner Theorie; Abwägung Qualität/Latenz/Durchsatz/RAM/Energie;
kein Modell über Ressourcen empfehlen; No-GPU-/Low-RAM-Fälle + Fallbacks, Timeouts, manuelle Nachwahl. Status: IDEA.

### 9.4 Modell-/Backend-Auswahl
Kandidaten (unfestgelegt): llama.cpp/GGUF u. a. Bewertung: Linux-, CPU-/GPU-Support, RAM, Leistung/Stabilität,
Lizenz, Wartung/Updates, Sicherheit, Offline-Fähigkeit. Quantisierungen/Modellfamilien theoretisch, keine erfundenen Benchmarks. Status: IDEA.

### 9.5 Optionalität und Deinstallation
Systemeinstellungen: aktivieren/deaktivieren, Status, Modellinfo, Modellauswahl, Speicher, Updates, Komplett-Deinstallation
(Gewichte, Caches, Backends, Dienste; geteilte Libs nur wenn ungenutzt; Chatdaten nur mit Bestätigung löschen).
Danach keine Reinstall-Nörgelei. Zustandsautomat: installiert/aktiv/deaktiviert/Update/Fehler/entfernt. Status: IDEA.

### 9.6 Datenschutz und Sicherheit
Lokal-first, keine Pflicht-Registrierung, keine Chat-Uploads, keine Telemetrie ohne Zustimmung, nur nachvollziehbare Quellen,
Prüfsummen/Signaturen wo verfügbar, Lizenz-Doku, Ressourcen-Limits, keine unkontrollierte Shell-Ausführung,
keine privilegierten Auto-Änderungen, Trennung Antwort vs. Aktion, Bestätigung vor Sensiblem/Destruktivem.
Admin-Fähigkeiten brauchen eigenes Berechtigungs-/Sandbox-/Audit-Design. Status: IDEA.

### 9.7 Phasen
1 Machbarkeit/ADR, 2 Modell-/Backend-Evaluation, 3 Erkennung/Benchmark, 4 Download/Prüfung/Install,
5 Inferenzdienst, 6 Chat-UI, 7 Einstellungen, 8 Verwaltung/Updates, 9 Deinstallation, 10 Security-/Offline-/Perf-Tests.
Keine Phase begonnen. Status: IDEA.

### 9.8 Akzeptanzkriterien
System läuft voll ohne KI; Ablehnung ⇒ keine Downloads; Auswahl nachvollziehbar; zu wenig Speicher ⇒ kontrollierter Abbruch;
nach Setup ohne externe API nutzbar; Deaktivierung stoppt Dienste; Deinstallation entfernt Komponenten/Gewichte;
kein Reinstall-Drängen; Boot bleibt bei Fehlschlag stabil. Status: IDEA.

### 9.9 OpenClaw-artige Systemsteuerung (Konzept, IDEA — kein Code)
Vorschlag des Projektverantwortlichen vom 2026-10-15: ein lokal gehosteter Agent im Stil von OpenClaw,
der über einen integrierten Claw-Hook das System steuern kann. Alles hier ist Planung, keine Implementierung.

**9.9.1 Ziel und Leitplanken.** Der Agent soll auf Wunsch Aufgaben am System ausführen (Apps öffnen, Dateien lesen/bearbeiten,
Einstellungen bedienen, Diagnose), strikt innerhalb einer vom Nutzer definierten Berechtigungsmatrix. „Unzensiert" bedeutet hier:
Modellauswahl ohne unnötige inhaltliche Filter — es ist **keine** Garantie für Abwesenheit von Modellgrenzen, Fehlern oder
Sicherheitsrisiken. Gerade uncensored Modelle plus Systemzugriff sind die riskanteste Kombination im ganzen Projekt:
Deshalb gilt vom ersten Entwurf an Allowlist statt Denylist, Bestätigungspflicht für alles Sensible/Destruktive und ein
prüfbares Audit-Log. Status: IDEA.

**9.9.2 Benchmark und Modellauswahl (nichts vorinstalliert).** Ablauf: 1) Beim Ersteinrichtungs-Assistenten (nicht bei jedem
Boot — Boot-Zeit soll nicht leiden; Wiederholung manuell oder bei Hardwarewechsel) läuft ein ressourcenschonender Benchmark:
CPU-Leistung, RAM, GPU/VRAM/Backend (CPU/ROCm/CUDA-fähig?), Platte, grob Bandbreite. 2) Anhand dokumentierter Schwellen
(RAM-Bedarf = Modellgröße × Quantisierung + Backend-Overhead + Puffer) wird genau ein passendes Modell empfohlen; passt nichts,
gibt es kontrolliert „kein Modell möglich" statt eines überforderten Setups. 3) Erst nach ausdrücklicher Zustimmung wird
das empfohlene Modell aus einer gepinnten Quelle (URL + SHA-256, analog zu `releases.json`) heruntergeladen, verifiziert und
eingerichtet. 4) Bei Ablehnung: keine Downloads, System läuft normal, keine erneuten Nörgel-Prompts. Status: IDEA.

**9.9.3 Claw-Hook (Werkzeug-Gateway, Ansatz).** Der Agent spricht nie direkt mit System-APIs, sondern nur über ein Gateway mit
festem Werkzeugkatalog (z. B. App-starten, Datei-lesen/schreiben in freigegebenen Pfaden, Einstellung-setzen, Befehl-vorschlagen).
Jeder Werkzeugaufruf wird gegen die Nutzer-Policy geprüft, protokolliert (wer/was/wann/mit welchem Ergebnis) und braucht je nach
Risikoklasse entweder Freigabe (Lesen in erlaubten Bereichen) oder ausdrückliche Bestätigung (Schreiben, Installieren,
Systemdienste, Netzwerk-Aktionen). Privilegierte Aktionen laufen nie direkt als Root aus dem Modell — Ausführung nur über
bestehende Mechanismen (Polkit/pkexec) mit sichtbarem Prompt. Unbekannte/unsichere Aufrufe werden abgelehnt statt geraten.
Status: IDEA.

**9.9.4 Berechtigungseinstellungen (Ansatz).** Eigene Einstellungsseite: Hauptschalter (Agent an/aus), pro Bereich getrennte
Rechte — Anwendungen (welche darf er öffnen/bedienen), Dateien/Ordner (Lesen/Schreiben je Pfad, Standard: nur explizit
freigegebene), Aktionen (z. B. keine Paketinstallation, keine Systemdienste, kein Netzwerkversand ohne Nachfrage).
Alles standardmäßig aus/restriktiv; Änderungen brauchen Admin-Bestätigung; jederzeit einsehbar, was erlaubt ist und was der
Agent zuletzt getan hat (Audit-Ansicht). Deaktivierung stoppt Agent + Hintergrunddienste sofort. Status: IDEA.

**9.9.5 BYOK (Bring Your Own Key, später).** Optional darf der Nutzer eigene API-Schlüssel externer Anbieter hinterlegen
(z. B. als Fallback, wenn das lokale Modell nicht reicht). **BYOK ist zugleich der einzige KI-Pfad der geplanten
Mobile-Version (F30): Mobil gibt es keine lokale Inferenz, nur Schlüssel-basierte Nutzung.**
Ansatz: Speicherung im Secret Service (KWallet), nie in Logs/Configs
im Klartext, pro Schlüssel einseh-/löschbar, Nutzung nur nach expliziter Auswahl pro Anfrage oder als konfigurierter Fallback.
Ohne Schlüssel bleibt das System vollständig lokal nutzbar. Status: IDEA.

**9.9.6 Abhängigkeiten (was dafür gebraucht wird).** Lokales Inferenz-Backend (Kandidat: llama.cpp/GGUF o. ä., unfestgelegt);
Modell-Registry mit gepinnten URLs + SHA-256 (Erweiterung von `packages/lokro-ai-setup/.../releases.json`);
Hardware-Erkennung (CPU/RAM/GPU/VRAM/Platte) + reproduzierbarer Mini-Benchmark; Download-/Verifizierungs-Pipeline
(nur nach Zustimmung, Checksumme + möglichst Signatur); Gateway-Dienst + Policy-Engine + Audit-Log; Einstellungs-UI
(Systemeinstellungen-Modul); Secret-Service-Anbindung für BYOK; mehrere GiB Plattenplatz je Modell; Test-Hardware mit/ohne GPU.
Keine dieser Abhängigkeiten ist derzeit im Repo vorhanden (außer dem Ollama-Downloader als entferntem Verwandten). Status: IDEA.

**9.9.7 Umsetzungsansatz (Schritte, alle noch IDEA).** 1) ADR: Bedrohungsmodell + Policy-Format festlegen. 2) Benchmark-Prototyp
als reines Messwerkzeug ohne Modell. 3) Modell-Registry-Schema + Verifizierung. 4) Gateway mit 2–3 harmlosen Werkzeugen
(nur Lesen) hinter Policy + Audit. 5) Einstellungs-UI (An/aus, Matrix, Audit-Ansicht). 6) Download-/Install-/Deinstall-Fluss.
7) Schreibende Werkzeuge erst nach Security-Review. 8) BYOK-Schlüsselverwaltung. 9) Uncensored-Modell-Evaluation
(Lizenz, Verhalten, Ressourcen) mit dokumentierten Kriterien. 10) Offline-/Fehler-/Deinstall-Tests.
**Akzeptanz (zusätzlich zu 9.8):** Agent tut ohne Freigabe nichts; verbotene Aktion wird abgelehnt + geloggt; Deinstallation
entfernt Modell, Gateway-Regeln und Caches; BYOK-Schlüssel nie im Log; Boot-Zeit ohne Benchmark unverändert.

**9.9.8 Policy-Format (Entwurf, IDEA).** Eine Policy ist eine versionierte JSON-Datei (`policyVersion: 1`), user-scoped unter
`~/.config/lokro/agent/policy.json`, vom Einstellungs-UI geschrieben und vom Gateway strikt gelesen. Draft-Shape:
`{ "agentEnabled": false, "apps": { "allow": ["org.kde.dolphin"], "deny": [] }, "files": { "read": ["~/Dokumente"], "write": [] },
"actions": { "installPackages": "confirm", "systemServices": "deny", "networkSend": "confirm", "shellExec": "deny" } }`.
Regeln: Default-deny (alles nicht Erlaubte ist verboten); Risikoklassen `allow` (still) / `confirm` (Dialog mit Was/Warum) /
`deny` (Ablehnung + Log); Änderungen nur mit Admin-Bestätigung; jede Ablehnung landet im Audit-Log. Status: IDEA.

**9.9.9 Benchmark-Schwellen (Entwurf, IDEA).** Gemessen: CPU-Kerne/Takt + Kurzlast (z. B. 10 s Multi-Core, Ziel: Tokens/s-Prognose),
RAM-frei, GPU/VRAM + Backend-Verfügbarkeit, Platten-frei. Faustregel: `Modellgröße_GB × 1,35 (KV-Cache + Overhead) + 2 GB Puffer
≤ RAM-frei`, sonst kein Vorschlag. Staffel (Beispiel, zu validieren): ≥16 GB RAM + GPU → mittlere Modelle;
8–16 GB → kleine Modelle (CPU ok, langsam); <8 GB oder <5 GB Platte → „kein Modell möglich" mit Begründung + Hinweis auf BYOK.
Benchmark läuft nur im Setup-Assistenten und auf Knopfdruck (nicht bei jedem Boot), mit Timeout + Abbruch. Status: IDEA.

**9.9.10 Modell-Registry (Entwurf, IDEA).** Erweiterung von `packages/lokro-ai-setup/.../releases.json` um Einträge je Klasse:
`{ "id": "klasse-s", "backend": "llama.cpp", "format": "GGUF", "quant": "Q4_K_M", "ramGB": 8, "diskGB": 5,
"url": "https://…", "sha256": "<64 hex>", "license": "…", "uncensoredNote": "…" }`. Download nur bei exakter
Übereinstimmung mit Benchmark-Empfehlung + Nutzer-Zustimmung; Verifizierung SHA-256 (Pflicht) + Signatur (wo verfügbar);
danach Funktions-Smoke (Modell lädt, antwortet lokal, kein Netz). Kein Eintrag ohne Lizenz- und Herkunftsangabe. Status: IDEA.

**9.9.11 Bedrohungsmodell (Kurzfassung, IDEA — vor jedem Code als ADR zu beschließen).** Angreifer-Szenarien: bösartiges Modell
(Prompt-Injection über Webseiten/Dateien → Aktionen erschleichen), kompromittierte Modellquelle (Gewichte mit Schadverhalten),
neugieriger Agent (liest mehr als erlaubt), BYOK-Schlüsselabfluss. Gegenmaßnahmen: Gateway als einzige Ausführungsstelle +
Schema-validierte Werkzeuge; Datei-/App-Allowlist (keine Denylist); Bestätigung mit Originaltext der Aktion (kein Freifahrtschein);
Audit-Log append-only für den Nutzer einsehbar; Netz-Sandbox für Inferenz (localhost only, kein Modell-Phone-home);
Schlüssel nur im Secret Service, niemals in Prompts/Logs; Deinstallation entfernt alles Agent-Eigene. Offene Entscheidung:
Prozess-Sandbox (separater User? Container?) — ADR-pflichtig. Status: IDEA.

## 10. Weitere Langfristziele (nur aus Repo ableitbar, nichts erfunden)

### 10.1 Design-System: lokro.dev-Branding ist verbindlich (Beschluss 2026-10-16, Umsetzung PLANNED)
Stil, Chamfer-Cards usw. werden von **lokro.dev** übernommen. Quellen: [Branding-Guide](https://lokro.dev/branding)
(weitergeleitet nach `/de/branding.html`) und Repo `Lokrogaming/lokrogaming.github.io` (`assets/site.css`).
Festgelegte Tokens: Hintergrund `#0a0a0b`, erhöht `#111113`/`#17171a`, Vordergrund `#f2f2f0`,
gedämpft `#9a9a9e`/`#626266`, Rahmen `rgba(255,255,255,0.09)` (stark `0.16`), Akzent Mint `#7fe3b4`
(gedämpft `rgba(127,227,180,0.14)`), Warnung `#e3b97f`, Gold `#d9b876`.
Formensprache: **Chamfer statt Rundungen** — abgeschnittene Ecken via Clip-Pfad (18 px Standard,
10 px small, 28 px large); Cards mit Hover-Lift (`translateY(-3px)`) + Glow. Schriften: Space Grotesk
(Headlines), Inter (Fließtext), JetBrains Mono (Technik/Labels).
**Chamfer mit Maß (verbindlich seit 2026-10-16):** Chamfer-Ecken kommen nur dort zum Einsatz, wo sie gestalterisch
wirklich Sinn ergeben; Standard bleibt **Rundung × Glass-Look**. Desktop-Widgets sind per Customize-Dialog
umschaltbar (rund / Chamfer / weitere Stile) — keine Festlegung auf einen Stil. Die KI baut dafür
**Theming-Hooks** (Stil-Umschaltung pro Widget/Fläche per Policy/Gateway, siehe F25b), sobald das Widget-System steht.
Ehrlicher Stand: Das OS nutzt heute noch eigene Werte (runde 16-px-Karten, Zink-Töne, kein Mint) —
die Migration (Farben in `lokro-branding`, QML-Karten, SDDM-, Calamares-Branding; QML braucht für Chamfer
eigene Form-Pfade statt CSS-Clip) ist offene Arbeit, kein abgeschlossener Umbau.
- **F34-Steckbrief (kurz):** Abhängigkeiten: `lokro-branding` (Farben), QML-Karten (Welcome/Hub), SDDM-Theme,
  Calamares-Branding, `gh-pages`-Website. Akzeptanz: visueller Abgleich gegen Guide (Tokens, Chamfer-Maße, Fonts)
  mit Screenshots pro Fläche. Priorität: mittel. Nächster Schritt: Migrations-Checkliste pro Fläche anlegen.
- Eigene Systemoberfläche/UX-Konsistenz (Branding, SDDM, Welcome, Hub) — IMPLEMENTED, Feinschliff offen.
- Sicheres Update-Modell mit Signatur (Design offen, ADR-Kandidat).
- Gaming/Windows-Kompatibilität nur via signierte Arch-Pakete (Steam/Proton-Rolle begründen, Lizenzen beachten).
- Entwicklerwerkzeuge (VS Code etc.) nur bei begründeter Rolle + Lizenzprüfung — derzeit keine konkrete Planung.
- Wartbarkeit: kleine eigene Paketoberfläche, kein Fork von Kernel/Desktop.

## KI-Notizen-Verzeichnis (Regel ab 2026-10-15)
Jede KI legt eigene Gedanken/Ideen/Lösungsansätze in `docs/AI_NOTES_<name>_<datum>.md` ab und verlinkt sie hier.
- [`docs/AI_NOTES_opencode_2026-10-17.md`](docs/AI_NOTES_opencode_2026-10-17.md) — Custom Taskbar/Dock (F35):
  Bestandsaufnahme Panel, Design-Spezifikation (Maße/Animationen), Architektur-Vergleich, offene Fragen.
- (weitere Einträge: Vorlage `docs/AI_NOTES_vorlage.md` folgt bei Bedarf)

## Anhang: Master-Prompt (Volltext, Quelle dieser Sitzung, 2026-10-15)

> Der folgende Prompt wurde vom Projektverantwortlichen in den Chat eingefügt und ist hier als Quelle archiviert.
> Er definiert die Doku-Struktur dieser Sitzung. Die lokale KI (Kap. 9) bleibt Konzept — keine Implementierung.

```
LOKROOS – MASTER-PROMPT FÜR PROJEKTANALYSE, DOKUMENTATION UND LANGFRISTIGE ENTWICKLUNG

1. Deine Rolle und dein Auftrag

Du bist der leitende Softwarearchitekt, Linux-Systementwickler, technischer Dokumentar und Projektmanager für LokroOS,
ein eigenständiges Linux-Betriebssystem. Deine Aufgabe besteht darin, das gesamte bestehende Repository gründlich zu
untersuchen, den aktuellen Entwicklungsstand zu verstehen und eine vollständige, langfristig nutzbare Dokumentations- und
Projektmanagementstruktur aufzubauen. Du arbeitest nicht nur als Programmierer, sondern auch als technischer
Verantwortlicher für die langfristige Wartbarkeit, Sicherheit, Stabilität und Weiterentwicklung des gesamten
Betriebssystems. Alle zukünftigen KI-Agenten und Entwickler müssen anhand deiner Dokumentation nachvollziehen können:
Was LokroOS ist und welches Ziel das Projekt verfolgt; wie das Betriebssystem technisch aufgebaut ist; welche
Komponenten bereits implementiert sind; welche teilweise funktionieren oder noch fehlerhaft sind; welche Funktionen noch
fehlen; welche Architekturentscheidungen getroffen wurden und warum; wie geplante Funktionen technisch umgesetzt werden
können; welche Abhängigkeiten, Programme, Pakete, Werkzeuge und Ressourcen benötigt werden; welche Probleme,
technischen Schulden und bekannten Fehler bestehen; welche Aufgaben als Nächstes bearbeitet werden sollten; wie das
Projekt sicher weiterentwickelt, getestet und gebaut werden kann. Arbeite ausschließlich auf Grundlage des tatsächlich
vorhandenen Codes und überprüfbarer Ergebnisse. Erfinde keine Implementierungen, Testergebnisse, abgeschlossenen
Aufgaben oder technischen Eigenschaften. Beginne zunächst mit einer vollständigen Bestandsaufnahme und der
Dokumentation. Größere Architekturänderungen und neue Features sollen nicht eigenmächtig im Rahmen dieser
Dokumentationsaufgabe implementiert werden.

2. Verbindliche Repository-Analyse (alle Verzeichnisse/Dateien, AGENTS.md, IDEAS.md, IMPORTANT.md, Doku, Skripte,
Build-Werkzeuge, Live-Build-Configs, Paketlisten, Hooks, GRUB/Plymouth/SDDM/Calamares, Desktop/Shell, Branding,
Installer/Live, Paketquellen, Tests/CI/Logs, Git-Historie). Unterscheide vorhanden vs. geplant vs. nachgewiesen.
Nicht-destruktive Prüfungen, Ergebnisse dokumentieren, keine riskanten Befehle. Bei Build-Fehlschlag Ursache
dokumentieren; nur klar abgegrenzte sichere Fixes ohne Architekturänderung; jede Änderung dokumentieren.

3. Zentrale Datei AGENTS.md (Abschnitte A–F: Projektidentität; technische Grundlagen inkl. Status umgesetzt/geplant/offen;
Verzeichnisstruktur mit Zweck/Abhängigkeiten/Wirkung/Prüfung; Entwicklungsregeln 1–14; Build-/Testverfahren mit nur
verifizierten Befehlen; Dokumentationspflicht mit Auslagerung von Details).

4. Projektplanung IDEAS.md (keine reine Ideensammlung, sondern überprüfbares Projektmanagement: Kategorien,
Steckbrief je Feature mit Name/Ziel/Status/Aktueller Stand/Umsetzungsplan/Anforderungen/Ressourcen/Abhängigkeiten/
Sicherheit/Tests+Akzeptanz/Offene Fragen/Priorität/Nächster Schritt/Verknüpfungen; Statuswerte IDEA/PLANNED/
IN_PROGRESS/PARTIAL/BLOCKED/IMPLEMENTED/TESTED/COMPLETED/DEPRECATED/CANCELLED; Roadmap nach Abhängigkeiten).

5. Entwicklungstagebuch docs/DEVELOPMENT_LOG.md (Datum/Zeit, Bereich, Ausgangszustand, Änderungen, Dateien, Grund,
Umsetzung, Befehle, Tests, Fehler, Fixes+Ursachen, offene Fehler, Auswirkungen, Schulden, nächste Schritte; chronologisch
anhängen; keine Pauschalen; keine erfundenen Historien; Quellen angeben).

6. Aufgabenverwaltung TODO.md (kritische Fehler; blockierend; aktuell; kurz-/mittel-/langfristig; Tests/QS; Doku;
Checkboxen mit P0–P3 + Akzeptanzkriterium; nur bei Nachweis abhaken; Blocker mit Grund+Bedingung).

7. Architektur docs/ARCHITECTURE.md (Zusammenspiel, Abhängigkeiten, Schnittstellen, Config-Entstehung, Paketfluss,
Hooks, Live-vs-installiert, Ersatzkandidaten) + ADRs unter docs/adr/ (Problem/Anforderungen/Alternativen/Entscheidung/
Begründung/Nachteile/Auswirkungen; verbindlich vs. Vorschlag).

8. Fehlerverwaltung docs/KNOWN_ISSUES.md (ID, Beschreibung/Symptome, Schweregrad, Komponenten, Repro, erwartet vs.
tatsächlich, Logs, Ursache vermutet/nachgewiesen, Lösungsversuche, Status, nächste Diagnose, verifizierte Lösung;
nur Beobachtetes oder aus Logs Ableitbares).

9. Zukünftiges Feature Lokal-KI (nur konzipieren/dokumentieren, NICHT implementieren): Zielsetzung; keine Gewichte im
ISO (Opt-in-Ablauf beim Erststart); Hardware-Benchmark/Modellauswahl; Backend-/Modell-Evaluation (z. B. llama.cpp/GGUF,
theoretisch, keine erfundenen Benchmarks); optionale Installation/Deinstallation mit Zustandsautomat; Datenschutz/
Sicherheit (lokal-first, keine Pflicht-Registrierung/Uploads/Telemetrie, pin + Hash/Signatur, Lizenzen, Limits, keine
unkontrollierten Shell-/Privileg-Aktionen, Trennung Antwort/Aktion, Bestätigung); Phasen 1–10; Akzeptanzkriterien.

10. Weitere Langfristziele (nur aus Unterlagen/Code ableitbar: eigene Oberfläche/UX, Install/Update, Gaming,
Dev-Werkzeuge, Wartbarkeit/Sicherheit; Steam/Proton/VS Code/VPN nur mit Begründung+Lizenzprüfung; Wunsch vs. Konzept
vs. implementiert trennen; nichts erfinden).

11. Regelmäßiger Arbeitsablauf für zukünftige Agenten (Beginn: AGENTS lesen, TODO prüfen, IDEAS lesen, letztes Log,
KNOWN_ISSUES, git status, nächste Aufgabe; Während: eine Aufgabe, Abhängigkeiten, minimale Dateien, Tests, Fehler+Doku,
Roadmap nur bei Nachweis; Ende: Zusammenfassung, Log, TODO, IDEAS-Status, KNOWN_ISSUES, Fehlschläge/Fragen, nächster
Schritt; auch bei Unfertigem).

12. Qualität/Konsistenz (Dateien konsistent halten; Status nur bei Nachweis; überholte ADRs aktualisieren; keine
Duplikate/Widersprüche; relative Links; Tabellen/Checklisten/Beispiele; keine zwecklosen Dateien).

13. Arbeitsauftrag dieser Sitzung (Phase 1 Bestandsaufnahme; Phase 2 Dateien AGENTS/IDEAS/TODO/ARCHITECTURE/
DEVELOPMENT_LOG/KNOWN_ISSUES erstellen-erweitern statt blind ersetzen; Phase 3 Verifizierung Links/Code/Status/
kein Fertig-Schwindel/sichere Prüfungen; Phase 4 Abschlussbericht mit 10 Punkten). Aktuell: Analyse+Doku, KI nur
dokumentiert, keine riskanten Änderungen. Gründlich, nachvollziehbar, faktenbasiert.
```
