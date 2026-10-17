# ISO-Build-Analyse — LokroOS v0.1.0-alpha.11 (2026-10-15)

> Anlass: Auftrag „komplettes Repo auf ISO-Build-Fehler prüfen“.
> Methode: statische Code-Lesung (Build-Graph, Skripte, Manifeste, Calamares-Flow, Workflows) + nicht-destruktive Checks.
> Kein `mkarchiso` möglich (kein Arch, kein root-Build) — Laufzeitverhalten auf Arch muss die Vermutungen bestätigen.
> Verlinkt aus [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md) (IDs KI-001 ff.) und `TODO.md`.

## Durchgeführte Prüfungen (Ergebnis)

| Prüfung | Ergebnis |
|---|---|
| `node scripts/validate.mjs` | ✅ bestanden (55 Dateien, 102 Paketeinträge) |
| `python3 -m unittest discover -s tests -v` | ✅ 6/6 bestanden |
| `bash -n` (alle Skripte + Tools + Cleaner) | ✅ bestanden |
| `python3 scripts/validate_yaml.py` | ⚠️ Exit 2 — PyYAML fehlt (Umgebung, s. KI-004a) |
| `bash scripts/validate-pkgbuilds.sh` | ⚠️ Exit 1 — `nobody:nobody` fehlt (Umgebung, s. KI-004b) |
| ShellCheck / qmllint / desktop-file-validate | ❌ hier nicht installiert — Arch-CI-Pflicht |
| `make check-repos / packages / iso / smoke` | ❌ nur Arch — offen |
| Paketname `opencode` in offiziellen Repos | ✅ existiert in Arch-`extra` (Web-Check 2026-10-15) — kein Blocker |

## Befunde (Macke → Dringlichkeit → Fix)

### B-01 Flathub-Download + hartcodierter SHA (P0 — Build-Breaker)
`scripts/prepare-profile.sh:38-43`: `curl --fail …/flathub.flatpakrepo` + `sha256sum --check` gegen fest verdrahteten Hash.
Jede Flathub-Rotation oder jeder Netzwerk-Aussetzer bricht mit `set -e` den gesamten Profil-Build ab.
**Fix:** Datei versioniert im Repo cachen (mit dokumentiertem Update-Prozess); Retry (`--retry 3`); Hash aus
`third_party/sources.json` lesen statt duplizieren; als ADR festlegen (Fail-open mit Warnung ist wegen Trust-Modell abzulehnen).

### B-02 Manifest-DB-Pfad (P0 — falsche Release-Daten möglich)
`scripts/checksums.sh:66`: `pacman --root "$installed_root" --dbpath /var/lib/pacman -Q`.
Absoluter `--dbpath` wird je nach Pacman-Version als Host-Pfad gewertet → Manifest/Lizenz-TSV enthält Host- statt ISO-Pakete.
**Fix:** auf Arch beide Formen vergleichen (`--dbpath "$installed_root/var/lib/pacman"` vs. nur `--root`) und festnageln + Regressionstest.

### B-03 `profiledef.sh` ohne Verifikation (P0 — stiller Drift)
`prepare-profile.sh:53-59` sediert `iso_name/version/label/publisher/application` ohne Trefferprüfung.
Benennt Arch releng um, heißt das ISO weiter `archlinux-*` → `smoke-boot.sh` findet `lokro-os-*.iso` nicht.
**Fix:** nach sed `grep -q` auf jeden gesetzten Wert, sonst `die` (3 Zeilen).

### B-04 Größenpuffer (P0 — Release-Gate)
Offline-alpha.9: 3,67 GiB bei 4-GiB-Limit (≈300 MB Luft); alpha.7 war +39 MB drüber (Dedup-Duplikate).
**Fix:** Warnschwelle 3,8 GiB im Workflow, Größen-Trend loggen, Streichkandidatenliste pflegen, Dedup-Test ausbauen.

### B-05 Validate-Robustheit (P1 — Dev-Reibung, heute reproduziert)
Makefile duldet fehlende Tools (qmllint/shellcheck/…) mit Skip, aber `validate_yaml.py` stirbt hart (Exit 2 ohne PyYAML)
und `validate-pkgbuilds.sh` stirbt an `chown nobody:nobody` außerhalb Arch.
**Fix:** YAML-Check tolerant (Try/Import-Fehlermeldung → Skip-Warnung); Gruppe dynamisch auflösen.

### B-06 Offline-Dedup-Parsing (P1 — leeres Repo möglich)
`prepare-profile.sh:128-133`: `pacman -Qp … | awk 'NR==1{print $1}'` ohne Fehlerbehandlung; Dateinamen mit Leerzeichen,
geändertes Ausgabeformat oder Query-Fehler → falsche Löschung oder `die 'offline optional-package repository is empty'`.
**Fix:** `--print-format '%n'` nutzen, Rückgabewert prüfen, Löschliste loggen.

### B-07 Serial-Diagnose lückenhaft bei GRUB (P1 — Debug-Blindheit)
Alpha.11-Fix deckt nur `APPEND|options` ab (richtig für syslinux/systemd-boot), GRUB-`linux`-Zeile bleibt ohne `console=ttyS0`.
UEFI-GRUB-Pfade liefern keine seriellen Kernel-Logs.
**Fix:** GRUB separat behandeln (eigene `linux`-Regel mit Test) oder per ADR bewusst ausnehmen + Doku, welche Pfade abgedeckt sind.

### B-08 `welcome-online.conf` ungenutzt (P1 — falsche Installer-Anforderungen möglich)
Datei vorhanden (Internet nur Warnung), wird aber nie ins Profil kopiert — Online-ISO zeigt Offline-Welcome.
**Fix:** analog zu `packages.conf` tauschen oder dokumentieren, dass identische Werte Absicht sind.

### B-09 Build-Zeit-/Timeout-Risiko (P2)
`airootfs_image_tool_options` zstd-Level 15 + `-b 1M` ist langsam/RAM-hungrig; CI ohne Cache installiert u. a.
`plasma-workspace+qemu+edk2` neu bei 180-min-Timeout.
**Fix:** Build-Zeiten loggen, Cache prüfen, ggf. Level/Blocksize per ADR begründen.

### B-10 Versions-Drift (P2)
`branding.desc` + `os-release` enthalten hartcodierte `0.1.0-alpha.11`; validiert wird nur Kanal↔`VERSION`.
**Fix:** Generierung aus `VERSION` oder CI-Drift-Check erweitern.

## Was explizit kein Befund ist
- `opencode` ist in Arch-`extra` vorhanden (Web-Check) — `check-repos`-Kandidat ok.
- `vulkan-nouveau`/`lib32-vulkan-nouveau`, `jre8-openjdk`, `steam`, `prismlauncher`, `hyprland`-Familie: keine Auffälligkeit im Code;
  endgültige Auflösung nur via `make check-repos` auf Arch.
- `nobody`-/`PyYAML`-Abbrüche sind Umgebungs-, keine Arch-Defekte.
- Calamares-`method: legacy`, `os-release` ohne `VERSION_ID`, Plymouth-Minimalismus: Laufzeit-/Installationsrisiken, keine ISO-Build-Breaker.

## Empfohlene nächste Schritte (konkret)
1. Auf Arch: `make validate check-repos packages` → Logs sichern (KI-003/004 verifizieren).
2. B-03-Fix (3 Zeilen) + B-05-Fix einbauen, `make validate` erneut.
3. `make iso-offline iso-online checksums` → Größen + Manifeste prüfen (B-02/B-04).
4. `make smoke-bios smoke-uefi` → serielle Logs sichern (KI-001/KI-007).
5. B-01-ADR entscheiden, bevor Flathub rotiert.
