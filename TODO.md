# TODO.md — Zentrale Aufgabenliste (Stand 2026-10-16, v0.1.0-alpha.16)

> Pflege: jede Sitzung. Abhaken nur mit Nachweis. Blocker mit Grund + Fortsetzungsbedingung.
> Details zu Ursachen/Fixes: `docs/KNOWN_ISSUES.md`, `docs/ISO_BUILD_ANALYSE_2026-10-15.md`.

## Kritische Fehler (P0 — blockieren Build/Release)

- [x] `[P0]` UEFI-Smoke nach alpha.11-Fix bestehen (KI-001). ✅ Verifiziert in Run 38801087314 (2026-10-15, `Plasma live session reached for uefi`); Prerelease v0.1.0-alpha.11 publiziert.
- [ ] `[P0]` Flathub-Deskriptor-Pinning härten (KI-002). Akzeptanz: Build überlebt Flathub-Rotation/Netzwerk-Aussetzer (Cache+Retry, SHA aus `sources.json`).
- [ ] `[P0]` `profiledef.sh`-Rewrite verifizieren (KI-006). Akzeptanz: Build bricht ab, wenn `iso_name/iso_version/iso_label` nicht gesetzt wurden.
- [ ] `[P0]` Manifest-Generierung (`pacman --root/--dbpath`) auf Arch verifizieren (KI-003). Akzeptanz: `package-manifest-*.txt` enthält ISO- (nicht Host-) Pakete.
- [ ] `[P0]` ISO-Größenpuffer verteidigen (KI-005, offline ~3,67 GiB / Limit 4 GiB). Akzeptanz: Warnschwelle bei 3,8 GiB + Doku, welche Pakete fliegen dürften.

## Blockierende Probleme (P1)

- [ ] `[P1]` `make validate`-Robustheit: PyYAML fehlt → harter Exit 2 statt Skip (KI-004a). Akzeptanz: Warnung+Skip wie bei qmllint/shellcheck.
- [ ] `[P1]` `validate-pkgbuilds.sh` (`nobody:nobody`) portabel machen (KI-004b). Akzeptanz: läuft auch, wo Gruppe `nobody` fehlt.
- [ ] `[P1]` Calamares-Schema-Check einführen (`method: legacy` in packagechooser-browser, Pflichtfelder). Akzeptanz: CI validiert alle `*.conf` gegen installierte Calamares-3.3.14-Module.
- [ ] `[P1]` `welcome-online.conf` tatsächlich verkabeln (wird nie kopiert). Akzeptanz: online-Profil nutzt Online-Welcome oder Doku warum nicht.
- [ ] `[P1]` `installer-cleanup` + `build-packages.sh`-Trap gegen Abbruch härten. Akzeptanz: kein sudoers-Rest, kein halb entfernter Live-State (VM-Test).
- [ ] `[P1]` GRUB-`linux`-Zeile: Serial-Diagnose-Lücke schließen oder bewusst dokumentieren. Akzeptanz: Entscheidung als ADR + Smoke-Log-Bewertung.

## Aktuelle Entwicklungsaufgaben (P1–P2)

- [ ] `[P1]` VM-Installationsmatrix leer/verschlüsselt + Target-Boot ohne ISO (TESTING.md-Akzeptanz).
- [ ] `[P2]` `branding.desc`/os-release-Versionen an `VERSION` koppeln (Drift-Check wie Update-Kanal).
- [ ] `[P2]` Offline-Dedup (`pacman -Qp`-Parsing) mit Fehlerbehandlung + Log.
- [ ] `[P2]` `docs/adr/` anlegen + erste ADRs (Flathub-Pin, Dedup, Serial-Umfang, Manifest, 4-GiB-Budget).

## Kurzfristig (P2)

- [ ] `[P2]` LOKRO Dock (F35): Prototyp `packages/lokro-shell/experimental/org.lokro.dock/` auf Arch prüfen
  (`qmllint`, manueller Panel-Test, TaskManager-Rollen, KWin-Blur). Akzeptanz: QML lintet, Dock sichtbar
  zentriert/gerundet/glassig mit Hover-Label; erst danach nach `rootfs/` heben + Panel-Default (LnF layout.js)
  + Kickoff-Entscheidung → dann F35 `IMPLEMENTED`.
- [ ] `[P2]` interaktive Desktop-Checks protokollieren (KRunner/Wofi, Task-Manager, Cursor, Meta+T, Waybar/Portale).
- [ ] `[P2]` `run-vm.sh`-GL-Abhängigkeit dokumentieren (headless-Alternative für Server ohne GL).
- [ ] `[P2]` QML/Desktop-Lint auch außerhalb Arch-CI verfügbar machen oder Skip-Doku verbessern.
- [ ] `[P2]` Alpha.16-CI-Gate beobachten (Codex): erst Veröffentlichung erwarten, wenn Build+BIOS/UEFI-Rauch inkl. Installer-Prozess grün ist; dann RELEASE_STATUS/AGENTS-Fakten nachziehen.
- [ ] `[P2]` Stale Codex-Branches aufräumen (alle 10 PRs merged, keine offenen PRs; Stand 2026-10-15 per `gh` verifiziert) — erst **nach** laufendem Codex-ISO-Build löschen.

## Mittelfristig (P2–P3)

- [ ] `[P2]` Hardware-Matrix (AMD, NVIDIA-open, Nouveau, Dual-Monitor, Suspend, BT-Audio, USB, Steam, PrismLauncher+Java 8/17/21).
- [ ] `[P3]` Signaturschlüssel-Design für `[lokro]`-Repo (ADR; löst TrustAll + unattended-Sperre langfristig).
- [ ] `[P3]` Update-E2E (Download→Bestätigung→`-Syu`→Backup→Reboot-Empfehlung).

## Langfristig (P3, nur Ideen)

- [ ] `[P3]` KI-Konzeptphasen 1–10 (nur Doku, kein Code — siehe `IDEAS.md` Kap. 9).
- [ ] `[P3]` F25b OpenClaw-Konzept ausarbeiten (IDEA): Benchmark-Design, Claw-Hook-Gateway + Policy-Format als ADR, Berechtigungsmatrix-Entwurf, Modell-Registry-Schema, BYOK-Schlüsselablage — alles Doku, kein Code (siehe `IDEAS.md` Kap. 9.9).
- [ ] `[P3]` ARM-Port evaluieren (separat, kein x86_64-Archiso wiederverwendbar).
- [ ] `[P3]` Secure-Boot-Option evaluieren (derzeit nicht unterstützt).

## Versionen (P3, nur Planung erstmal — Details siehe `IDEAS.md` F30–F32)
- [ ] `[P3]` Mobile-Version von LokroOS (soll auf sowohl neuen als auch auf älteren Chips laufen)
- [ ] `[P3]` Google Play + eigener Appstore für Appinstallierung
- [ ] `[P3]` Soll APKs unterstützen für Appinstall und soll fast alle AndroidApps unterstützen

## Tests & QS

- [ ] `node scripts/validate.mjs` — bestanden am 2026-10-16 (68 Dateien, 103 Pakete, nach alpha.15/16-Merge).
- [ ] `python3 -m unittest discover -s tests -v` — 6/6 bestanden am 2026-10-16.
- [ ] `bash -n` über Skripte/Tools — bestanden am 2026-10-16.
- [ ] `python3 scripts/validate_yaml.py` — hier Exit 2 (PyYAML fehlt, Umgebung); auf Arch mit python-yaml nachholen.
- [ ] `bash scripts/validate-pkgbuilds.sh` — hier Exit 1 (`nobody:nobody` fehlt, Umgebung); auf Arch nachholen.
- [ ] ShellCheck/QML/Desktop-Lint — hier nicht installiert; Arch-CI-Pflicht.
- [ ] `make check-repos`, `make packages`, `make iso-*`, `make smoke-*` — nur Arch, noch ausstehend (nächster Schritt).

## Doku-Aufgaben

- [x] `AGENTS.md`, `IDEAS.md` (inkl. Prompt-Anhang), `TODO.md` erstellt (2026-10-15).
- [ ] `docs/ARCHITECTURE.md` erweitert + `docs/adr/` angelegt.
- [ ] `docs/KNOWN_ISSUES.md` + `docs/DEVELOPMENT_LOG.md` + `docs/ISO_BUILD_ANALYSE_2026-10-15.md` erstellt.
- [ ] `AI_INFO.md` um KI-Gedanken-Regel ergänzt.
- [ ] Jede Sitzung: `DEVELOPMENT_LOG` anhängen, `TODO`/`IDEAS`/`KNOWN_ISSUES`/`RELEASE_STATUS` bei Nachweis pflegen.
