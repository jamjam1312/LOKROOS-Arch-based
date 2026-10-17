# AGENTS.md — Verbindliche Wissensgrundlage für alle Coding-Agenten (LokroOS)

> Zentrale Einstiegsdatei. Jeder Agent liest diese Datei zuerst, bevor er Code ändert.
> Detailwissen liegt in den verlinkten Dateien. Diese Datei bleibt die verbindliche Regel- und Orientierungsquelle.
> Stand: 2026-10-16, Version `0.1.0-alpha.16` (Quelle; letztes verifiziertes Release: `0.1.0-alpha.14`), Branch `main`. Alle Statusangaben sind nur so gut wie ihre Nachweise —
> erfundene Build-Erfolge oder Testergebnisse sind verboten.

## A. Projektidentität

- **Name:** LokroOS (im Repo auch „Lokro OS“ / „LOKRO OS“).
- **Ziel:** Eigenständiges, experimentelles x86_64-Desktop-Betriebssystem auf Arch-Basis mit eigener Identität
  (eigenes Branding, eigener Look-and-Feel, eigene Systemwerkzeuge, konsistente Architektur) — kein Ubuntu-/Kubuntu-Reskin.
- **Langfristige Vision:** Unabhängig wartbares System mit Plasma-Standarddesktop, optionaler Hyprland-Sitzung,
  Calamares-Installation, sicherem Update-Modell und öffentlich nachvollziehbarer Build-Pipeline.
  Später evtl. optionale, vollständig lokale KI-Assistenz (derzeit **nur Konzept**, keine Implementierung).
- **Zielgruppe (Alpha):** Test-VMs und Test-Hardware. Kein Produktiv-, kein Daily-Driver-, kein garantierter Dual-Boot-Release.
- **Designprinzipien:**
  1. Arch-offizielle, signierte Pakete für das Basissystem; keine AUR-Helper im Image; keine curl-pipe-shell-Muster.
  2. Pacman gehört das Basissystem, Flatpak/Discover gehören sandboxed Apps.
  3. Live-Image = generische Archiso-Hooks; installiertes Ziel = normale Disk-root-initramfs (wird erst vom Installer erzeugt).
  4. Jede Automatik braucht lokale Bestätigung (kein unattended Install von LOKRO-Artefakten).
  5. Alles, was als „fertig“ gilt, braucht einen reproduzierbaren Nachweis (Build-Log, Smoke-Log, Hardware-Protokoll).
  6. Chamfer mit Maß: Chamfer-Ecken nur dort, wo sie gestalterisch Sinn ergeben; Standard bleibt
     Rundung × Glass-Look. Desktop-Widgets werden per Customize-Dialog umschaltbar
     (rund / Chamfer / weitere Stile); KI-seitige Theming-Hooks dafür sind geplant (F34).
- **Design-System (verbindlich seit 2026-10-16):** Stil folgt dem LOKRO-Branding-Guide
  ([lokro.dev/branding](https://lokro.dev/branding), Repo `Lokrogaming/lokrogaming.github.io`, `assets/site.css`):
  Dark/Glass, Chamfer-Ecken statt Rundungen (18/10/28 px), Tokens `#0a0a0b`/`#111113`/`#f2f2f0`,
  Mint-Akzent `#7fe3b4`, Space Grotesk/Inter/JetBrains Mono. Details + Migrationsstand: `IDEAS.md` F34/Kap. 10.1.
- **Abgrenzung:** Keine eigene Distribution im Sinne eines eigenen Kernels/Repos. Basis = Arch-Repos + Archiso-`releng`-Profil
  + 5 eigene Pakete + gepinnter Calamares-Build. CachyOS-Kernel/Repos/Ananicy werden bewusst **nicht** übernommen
  (eigener Trust-Root, siehe `docs/ARCHITECTURE.md`).
- **Entwicklungsstand (überprüfbar am 2026-10-16):**
  - Quelle vollständig vorhanden; `scripts/validate.mjs` besteht (68 Pflichtdateien, 103 Paketeinträge);
    Python-Unit-Tests 6/6; `bash -n` ok (2026-10-16 nach alpha.15/16-Merge erneut bestätigt).
    Seit alpha.12: deklarative **Design Packs**; seit alpha.13: **`lokro-store`** (5. eigenes Paket);
    alpha.15/16: **Live-Installer** (Autostart + Desktop-Shortcut in der Live-Session, Polkit-Action statt
    `sudo -E`, Rauch-Test-Gate verlangt jetzt Plasma **und** laufendes Calamares).
  - Laut `docs/RELEASE_STATUS.md`: alpha.11/12/14 bestanden BIOS- **und** UEFI-Plasma-Smoke und wurden
    publiziert (alpha.14 = letztes verifiziertes Release). **Alpha.15: Gate korrekt fehlgeschlagen**
    (`sudo -E`-Launcher hielt Calamares nicht offen → keine Veröffentlichung, KI-009).
    Alpha.16 (Quelle) behebt den Launch-Pfad — **CI-Verifikation für alpha.15/16 steht noch aus**.

## B. Technische Grundlagen

| Bereich | Basis (tatsächlich im Repo) | Status |
|---|---|---|
| Linux-Basis | Arch Linux x86_64, Stock-Kernel `linux`, `linux-firmware`, `sof-firmware` | IMPLEMENTED (HW-Tests offen) |
| Paketverwaltung | Pacman (offizielle Repos + Multilib); lokales `[lokro]`-Repo via `repo-add`; offline `[lokro-media]`-Repo unter `/opt/lokro/repo` | IMPLEMENTED |
| Eigene Pakete | `lokro-branding`, `lokro-shell`, `lokro-installer-config`, `lokro-ai-setup`, `lokro-store` (+ `vendor/ckbcomp`, `vendor/calamares` → `calamares-lokro`) | IMPLEMENTED |
| Build/ISO | `scripts/build-packages.sh` → `scripts/prepare-profile.sh` → `mkarchiso` (offline- + online-Variante), `scripts/checksums.sh` (SHA256, Split <2 GiB) | IMPLEMENTED, BIOS+UEFI-Smoke TESTED |
| Bootloader | GRUB (BIOS+UEFI), systemd-boot/syslinux aus releng-Profil; `os-prober` best-effort | IMPLEMENTED |
| Bootanimation | Plymouth, Theme `lokro` (minimal: Logo + Puls) | IMPLEMENTED |
| Display-Manager | SDDM (Live-Autologin `liveuser`, Greeter X11, Session Plasma-Wayland) | IMPLEMENTED |
| Desktop-Shell | KDE Plasma 6 Wayland (Standard) + optional Hyprland-Sitzung; XWayland für X11-Apps, kein Plasma-X11-Login | IMPLEMENTED |
| Installer/Live | Calamares 3.3.14 (gepinnt, Qt6), kopiert eingebettetes SquashFS, `installer-cleanup` entfernt Live-Artefakte | IMPLEMENTED |
| Sprachen/Tools | Bash, Python (Tests/YAML), Node (validate.mjs), QML, CMake/Ninja (Calamares), makepkg, `mkarchiso` | IMPLEMENTED |
| Dev-Umgebung | Arch-Linux-VM oder privilegierter `archlinux:base-devel`-Container, root, ≥20 GiB frei | verbindlich |
| Externe Quellen | Arch-Mirror, Flathub-Deskriptor (gepinnt, SHA-verifiziert), Ollama-GitHub-Releases (gepinnt, opt-in), Debian-Console-Setup-Quelle (ckbcomp), Codeberg-Calamares, LOKRO-Store-Upstream-Tarball (gepinnt, SHA-verifiziert) | siehe `third_party/sources.json` |

**Explizit nicht enthalten / noch zu entscheiden:** eigener Paketserver mit Signaturschlüssel (offen),
Secure Boot (nicht unterstützt), ARM-Port (separates Zukunftsprojekt), Server-Edition (`server/` = Platzhalter, CANCELLED für v0.1),
KI-Chat-Assistent (nur Konzept in `IDEAS.md`, keine Implementierung in dieser Aufgabe).

## C. Verzeichnisstruktur

| Pfad | Zweck | Abhängigkeiten / Wirkung bei Änderung | Prüfung |
|---|---|---|---|
| `archiso/packages/{common,offline,online}.x86_64` | Paketmanifest je Variante; wird an releng-`packages.x86_64` angehängt + `sort -u` | Jeder Name muss in Arch-Repos oder lokalem `[lokro]`-Repo auflösbar sein, sonst stirbt `prepare-profile.sh` beim `pacman -Sp` | `make check-repos`, `node scripts/validate.mjs` |
| `archiso/airootfs/` | Live-Overlay: liveuser, smoke-watcher, **Live-Installer** (`lokro-live-installer`, Polkit-Regel, Autostart), SDDM, sudoers, plymouthd, zram | Wird per rsync über releng gelegt; **keine** paket-eigenen Pfade vor pacstrap überschreiben (Pacman-Konflikt) | Smoke-Boot-Logs (Gate = Plasma + Calamares-Prozess) |
| `packages/lokro-branding/` | Plasma-Defaults, Farben, Hintergrund, Plymouth, SDDM, First-Login | Wirkt auf Live- **und** Zielsystem | `desktop-file-validate`, qmllint (Arch-CI) |
| `packages/lokro-shell/` | Suche, Hub, Welcome, Updater, Link-Installer, Media-Launcher, Service-Merge, Flatpak-Setup, Design-Pack-Importer; `experimental/` = Prototypen (nur `rootfs/` wird gepackt!) | Viele ausführbare Tools; chmod-Liste in PKGBUILD muss Dateiliste exakt abdecken | Unit-Tests `tests/`, ShellCheck |
| `packages/lokro-installer-config/` | Calamares-Flow (`settings.conf`), Chooser, `installer-cleanup` | Falsche Chooser-Pakete → Installation schlägt erst zur Laufzeit fehl (kein Build-Fehler!) | `python3 scripts/validate_yaml.py`, Calamares-Schema-Check (offen, siehe TODO) |
| `packages/lokro-ai-setup/` | Nur Downloader/Setup für Ollama (gepinnt) + `opencode`-Opt-Dependency; **kein Modell im ISO** | Downloads nur nach expliziter Zustimmung | SHA-Prüfung in `releases.json` |
| `packages/lokro-store/` | Gepinnter App-/Design-Katalog (eigene Upstream-Quelle, PySide6-GUI, validiertes Katalog-JSON) | Nur bekannte Katalog-Kommandos; keine unbekannten Katalogbefehle | `make validate`, Schema-Check |
| `vendor/ckbcomp`, `vendor/calamares/` | Gepinnte Quellen mit SHA256; ckbcomp muss **vor** calamares-lokro gebaut+installiert werden | Reihenfolge in `build-packages.sh` nicht ändern | `make packages` auf Arch |
| `scripts/` | `common.sh` (Pfade/Version), `build-packages.sh`, `prepare-profile.sh`, `build-iso.sh`, `checksums.sh`, `smoke-boot.sh`, `run-vm.sh`, Validierungen | Herz der Pipeline; ShellCheck-pflichtig | `make validate`, `bash -n`, ShellCheck |
| `LOKRO_UPDATE_CHANNEL.json` ↔ `packages/lokro-shell/.../update-channel.json` | Update-Kanal, byte-identisch, Repo gepinnt, `installWithoutLocalConfirmation: false` | Drift blockiert Release-Vertrauen | `validate.mjs`-Check |
| `docs/` | Architektur, Tests, Hardware, Updates, Release-Wahrheit | `RELEASE_STATUS.md` ehrlich halten (implementiert ≠ verifiziert ≠ hardware-getestet) | Link-Check (Phase 3) |
| `tests/` | `test_update_channel.py`, `test_services.py` (echte Unit-Tests) | Bei Kanal-/Service-Änderungen erweitern | `python3 -m unittest discover -s tests -v` |
| `.github/workflows/` | `validate.yml` (PR), `build-iso.yml` (ISO + Smoke + Size-Gate 4 GiB + Split) | Workflow-Änderungen nur mit Begründung | YAML-Parse |

## D. Entwicklungsregeln

1. Bestehende Implementierung zuerst verstehen (Datei + Abhängigkeiten + Tests lesen).
2. Vor Änderungen relevante Dateien/Abhängigkeiten untersuchen; keine großen Dateien/Skripte blind überschreiben.
3. Bestehende Funktionalität nicht ohne Not entfernen.
4. Kein Feature als fertig markieren ohne reproduzierbaren Nachweis.
5. Keine erfundenen Build-Erfolge/Testergebnisse dokumentieren. Unbekanntes bleibt „unbekannt“.
6. Modular, kleine, nachvollziehbare Commits; sicherheitsrelevante Configs (sudoers, pacman.conf, Bootloader, LUKS, GRUB) besonders vorsichtig behandeln.
7. Abhängigkeiten/Paketquellen nachvollziehbar dokumentieren (`third_party/sources.json` + Doku).
8. Nach relevanten Änderungen passende Tests/Prüfungen laufen lassen.
9. Unlösbare Probleme als Fehler mit Ursache + Lösungswegen festhalten (→ `docs/KNOWN_ISSUES.md`), nicht verschweigen.
10. Architekturentscheidungen mit Alternativen/Pro/Contra dokumentieren (→ `docs/adr/`, siehe Abschnitt G).
11. **Keine Secrets** (Tokens, Schlüssel, Passwörter) in Doku/Logs/Commits.
12. Riskante/irreversible Änderungen (Disk, Firmware, Bootloader am Arbeitsgerät) nur nach Rücksprache; Tests nur in VM/Container.
13. **KI-Gedanken-Regel (verbindlich ab 2026-10-15):** Jede KI (und jeder Entwickler) legt eigene Gedanken, Ideen,
    Lösungsansätze und offene Fragen in einer **eigenen MD-Datei** ab (z. B. `docs/AI_NOTES_<name>_<datum>.md`),
    statt sie nur im Chat zu lassen. Dateiname + Datum + Status (IDEA/PLANNED/…) angeben und in `IDEAS.md` verlinken.
    Der Master-Prompt-Volltext dieser Sitzung ist als Quelle im Anhang von `IDEAS.md` archiviert.
14. **Store-Katalog-Regel (aus Upstream alpha.13 übernommen):** Keine unbekannten Katalog-Kommandos;
    Store-Quellen nur gepinnt mit SHA-256; generierte ISOs/`out/` gehören nie ins Git.

## E. Build- und Testverfahren (nur verifizierte Befehle)

Voraussetzungen: Arch Linux (VM ok), root für ISO-Builds, ≥20 GiB frei, privilegierter Container für CI.

```bash
sudo pacman -Syu --needed base-devel archiso git jq nodejs qemu-desktop edk2-ovmf shellcheck
make validate        # statische Checks (Node immer; YAML/PKGBUILD/QML/ShellCheck/Desktop nur wenn Tool vorhanden)
make check-repos     # löst alle offiziellen Pakete auf (nur Arch)
make packages        # baut ckbcomp -> calamares-lokro -> 4 lokro-Pakete, legt out/repo an
sudo make iso-offline
sudo make iso-online
make checksums       # SHA256, Split in <2-GiB-Teile, Manifeste, Lizenzen, Provenienz
make smoke-bios smoke-uefi   # QEMU ohne Display, wartet auf LOKRO_PLASMA_READY via seriell
make vm-bios / make vm-uefi  # interaktive QEMU-Tests (braucht Display/GL)
```

- Bei Fehlschlag: erst Log lesen (`out/build-<variante>-<version>.log`, serielles QEMU-Log), dann `docs/KNOWN_ISSUES.md`
  prüfen (IDs KI-001 ff.), dann gezielt reproduzieren. Nur klar abgegrenzte, sichere Fixes ohne Architekturänderung
  direkt beheben; alles andere dokumentieren und als TODO einplanen.
- Build-Artefakte (`build/`, `out/`) gehören nicht ins Git; Release nur über **Build alpha ISO**-Workflow mit
  Size-Gate (≤4 GiB), BIOS+UEFI-Smoke und Artifact-Upload.

## F. Dokumentationspflicht (wann welche Datei anfassen)

| Datei | Wann aktualisieren |
|---|---|
| `AGENTS.md` (diese) | Regeln, Verfahren, Struktur ändern sich; neue Pflicht-Checks. Schlank halten, Details auslagern. |
| `IDEAS.md` | Feature-Status ändert sich (nur mit Nachweis); neue Idee mit vollem Steckbrief; Roadmap-Phasen. |
| `TODO.md` | Jede Sitzung: erledigt/blockiert/neu priorisieren (P0–P3, Akzeptanzkriterium). |
| `docs/ARCHITECTURE.md` | Komponenten/Schnittstellen/Build-Fluss ändern sich; ADR bei größeren Entscheidungen unter `docs/adr/`. |
| `docs/DEVELOPMENT_LOG.md` | **Jede** Arbeitseinheit (chronologisch anhängen, nie still überschreiben). |
| `docs/KNOWN_ISSUES.md` | Neuer Fehler / neue Diagnose / verifizierte Lösung. Nur Beobachtetes, Vermutung als solche kennzeichnen. |
| `docs/ISO_BUILD_ANALYSE_*.md` | Gezielte Build-Fehleranalyse (Macke, Dringlichkeit, Fix) — verlinkt aus KNOWN_ISSUES. |
| `docs/RELEASE_STATUS.md` | Ehrliche Release-Wahrheit: implementiert vs. CI-verifiziert vs. hardware-getestet. |
| `AI_INFO.md` | Maschinenlesbare Projektkarte + KI-Regeln synchron halten. |

## G. Architecture Decision Records (neu ab 2026-10-15)

Größere Entscheidungen als ADR unter `docs/adr/NNNN-titel.md` ablegen (Problem, Anforderungen, Alternativen,
Entscheidung, Begründung, Nachteile, Auswirkungen; Status: verbindlich vs. Vorschlag). Vorhanden: `0001-mobile-shell`,
`0002-shared-wizard` (beide Vorschlag). Weitere Kandidaten: Store-Katalog-Modell, Flathub-Pinning-Strategie,
Offline-Dedup-Verfahren, Serial-Diagnose-Umfang (GRUB-`linux`-Zeile), Manifest-Generierung
(`pacman --root/--dbpath`), Größenbudget 4 GiB.

## Regelmäßiger Arbeitsablauf (verbindlich)

**Sitzungsbeginn:** 1. `AGENTS.md` lesen. 2. `TODO.md` prüfen. 3. Relevante `IDEAS.md`-Abschnitte lesen.
4. Letzten `docs/DEVELOPMENT_LOG.md`-Eintrag lesen. 5. `docs/KNOWN_ISSUES.md` beachten.
6. `git status` + `git log --oneline -10` prüfen. 7. Sinnvollste nächste Aufgabe wählen.

**Währenddessen:** Eine abgegrenzte Aufgabe; Abhängigkeiten prüfen; nur nötige Dateien ändern;
passende Tests laufen lassen; neue Fehler/Nebenwirkungen dokumentieren; Roadmap-Status nur bei Nachweis ändern.

**Sitzungsende:** Änderungen zusammenfassen → Development-Log anhängen → `TODO.md` aktualisieren →
`IDEAS.md`-Status bei Nachweis aktualisieren → KNOWN_ISSUES aktualisieren → Fehlschläge/offene Fragen notieren →
nächsten konkreten Schritt benennen. Auch bei unfertigen Aufgaben durchführen.
