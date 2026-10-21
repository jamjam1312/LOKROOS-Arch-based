# AI project map — LOKRO OS

This file is the machine-readable starting point for coding assistants and human contributors. Read it before changing build, installer, boot or update code.

## Product contract

- Product: experimental x86_64 desktop distribution. The latest downloadable
  CI prerelease and current source release is `0.1.0-alpha.25`.
- Base: official Arch Linux repositories and the current Archiso `releng` profile.
- Primary session: KDE Plasma 6 on Wayland. Optional second session: Hyprland.
- Installer: Calamares copies the complete embedded Arch root. An existing Arch installation is never required.
- Package boundaries: Pacman owns the base OS; Flatpak/Discover own sandboxed desktop apps. No AUR helper is shipped.
- Boot: GRUB supports BIOS and UEFI. `os-prober`, `ntfs-3g` and `fuse3` support best-effort discovery of other operating systems.
- License policy: project code is GPL-3.0-or-later, project artwork is CC BY-SA 4.0, and upstream works retain their licenses.

## Repository map

| Path | Responsibility |
| --- | --- |
| `archiso/` | Shared Archiso overlay and package manifests for common, offline and online images. |
| `packages/lokro-branding/` | Plasma defaults, colors, wallpaper, SDDM and first-login layout. |
| `packages/lokro-shell/` | Search, Hub, welcome screen, graphical tools, safe updater and desktop integration. |
| `packages/lokro-installer-config/` | Calamares flow, package choices, administrator creation, encryption and GRUB. |
| `packages/lokro-ai-setup/` | Optional, checksum-pinned local-AI setup. No model is embedded. |
| `packages/lokro-store/` | Pinned, checksum-verified build of the separate LOKRO Store catalog and Qt UI. |
| `design-packs/` | Reviewed declarative appearance packs, schema and contribution rules. |
| `vendor/` | Pinned source recipes required to build software unavailable as an official Arch binary. |
| `scripts/` | Validation, package/repository construction, Archiso builds, metadata and VM smoke tests. |
| `docs/` | Architecture, hardware, gaming, dual-boot, update, test and release truth. |
| `website/` | Buildless GitHub Pages landing page for `os.lokro.dev`; never copied into an ISO. |

## Build graph

```text
PKGBUILDs -> makepkg -> out/repo/lokro.db
                           |
official releng + archiso overlay + package manifest
                           |
                     mkarchiso
                    /         \
          offline ISO         online ISO
                    \         /
             BIOS + UEFI VM smoke tests
                           |
          checksums + manifests + GitHub prerelease
```

Developer entry points are `make validate`, `make packages`, `make iso-offline`, `make iso-online`, `make smoke-bios`, `make smoke-uefi` and `make checksums`. ISO/package builds require Arch Linux and root inside a disposable build environment. The GitHub workflow uses a privileged Arch container. Never run disk, firmware or bootloader tests against a contributor's workstation.

## Safety invariants

1. Do not add network-fetched shell pipelines, an AUR helper, an unsigned automatic updater, or unattended installation of LOKRO release assets.
2. Do not overwrite a package-owned path in `airootfs` before `pacstrap`; Pacman correctly treats that as a conflict.
3. The live image keeps Archiso's initramfs hooks. Calamares removes them and creates the installed disk-root initramfs only after unpacking.
4. The first Calamares user belongs to `wheel` and is configured through the normal sudoers group; root login stays disabled.
5. The installer must not select an erase target by default. Dual boot remains best-effort and requires a verified backup.
6. URL installation accepts only HTTPS and known package formats. Scripts, `.deb`, `.rpm` and unclassified downloads are rejected.
7. `LOKRO_UPDATE_CHANNEL.json` and its packaged copy must be byte-identical and pinned to `jamjam1312/LOKROOS-Arch-based`.
8. A release is downloadable only after both ISO builds, size checks, BIOS/UEFI smoke boots and artifact upload succeed.

## Desktop behavior

- Plasma System Monitor is exposed as **LOKRO Task Manager** for processes, CPU, RAM, storage and network.
- Dolphin and Baloo provide filename-first indexed search in the home directory. Hidden folders, caches and build trees are excluded.
- The taskbar search opens KRunner on Plasma and Wofi on Hyprland. Its context menu exposes settings, task manager, updates and power actions.
- Plasma provides configurable panels, widgets, themes, cursor size, shortcuts and `Meta+T` tiling. Fresh Alpha.24 users receive the `LOKRO Black` Plasma style, LOKRO launcher and bottom-panel layout by default; upgrades preserve an existing customized panel. Hyprland is selected independently on the SDDM login screen.
- `lokro-design-pack` validates and installs user-scoped color/wallpaper packs without executing pack content; repository packs are staged into `lokro-shell` at build time.
- **LOKRO Link Installer** installs GPG-verifiable Arch package links, Flatpak refs/bundles and user-scoped AppImages. It never executes downloaded scripts.
- **LOKRO Media** is a branded launcher around the official VLC package and owns the common audio/video associations.
- **LOKRO Credits** exposes the protected project attribution in the welcome
  center, application menu and `/usr/share/doc/lokro-os/CREDITS.md`. The root
  and packaged copies must remain byte-identical.
- **LOKRO Store** `v0.1.0-alpha.8` ships a validated offline catalog, repairs
  the user-scoped Flathub remote and installs exact Flatpak IDs without a
  shell. ArtCraft Launcher 0.3.2 uses its official, versioned x86_64 Flatpak
  bundle with an exact SHA-256 check. All 13 ArtCraft Crafting Apps are also
  independently selectable through exact `ai.storyteller.*` IDs, immutable
  upstream bundles and published checksums. Reviewed `.lokrodesign` archives
  are downloaded only from immutable URLs and verified before the safe
  importer is invoked.
- **LOKRO appearance packs** include the interactive Monochrome wallpaper plus
  original Eclipse (dark), Lunar (light) and optional Blood (black/white/red)
  wallpapers. The trusted
  `lokro-branding` package provides the compiled `LokroMono` cursor theme;
  downloaded packs still cannot supply executable cursor or QML code.
- **LOKRO Settings** is a glass-styled visual landing page for the
  existing trusted Plasma settings modules; it does not replace KDE's settings
  backends. Its native chamfer geometry can be toggled and persisted without
  loading HTML, JavaScript or executable design-pack content.

## Status discipline

Keep `docs/RELEASE_STATUS.md` honest. Separate “implemented”, “CI-verified” and “hardware-tested”. A generated ISO is not automatically safe for a real dual-boot machine. Real AMD/NVIDIA, suspend, multi-monitor, audio, Bluetooth, Steam, Minecraft and install-alongside tests remain human hardware acceptance work.
