# Architecture

## Build flow

1. `scripts/build-packages.sh` builds a checksum-pinned Calamares source release and the five Lokro packages with `makepkg`.
2. `repo-add` creates an ephemeral local repository under `out/repo`.
3. `scripts/prepare-profile.sh` builds either the `offline` or `online` profile from shared and variant-specific manifests.
4. The offline profile stores zstd-compressed, signed NVIDIA, gaming and optional Hyprland-session packages under `/opt/lokro/repo`. The online profile resolves them from Arch mirrors only when selected.
5. `mkarchiso` constructs a complete custom Arch root containing `base`, the Arch kernel, firmware and Plasma, then produces distinct hybrid BIOS/UEFI images.
6. Calamares copies that custom SquashFS root, optionally installs selected packages, creates the local administrator, and removes live-only state before generating initramfs and GRUB configuration.

The profile copy is deliberate: Archiso's boot files evolve with Arch. Lokro owns only its overlay and package list while inheriting the boot implementation matching the installed Archiso version.

## Runtime components

- `lokro-branding`: color scheme, static background, Plymouth theme, KDE defaults and one-time Plasma setup.
- `lokro-shell`: interactive wallpaper, Lokro Hub and search widgets, graphical settings/boot launchers, safe user-scoped design-pack importer, safe HTTPS link installer, VLC-backed media launcher, update client, service-manifest merger and Flathub setup.
- `lokro-installer-config`: Calamares flow, branding, administrator and hostname setup, optional LUKS1 encryption, ext4/GPT defaults, desktop-session and NVIDIA choices.
- `lokro-ai-setup`: optional Ollama downloader with pinned checksums plus official-Arch OpenCode installation.

System packages are updated only with Pacman. Discover is intended for Flatpaks. No AUR helper is part of the image.

The link installer deliberately accepts only HTTPS `.flatpakref`, `.flatpak`, detached-signature-verified Arch package and user-scoped AppImage links. It never executes downloaded shell scripts and rejects DEB, RPM and arbitrary archives. Its update button checks only AppImages previously installed by the same tool; OS updates remain handled by the separate Pacman-based LOKRO updater.

Plasma is the supported default environment. The optional Hyprland packages add a second selectable SDDM Wayland session and keyboard-first dynamic tiling without forking either desktop. Plasma System Settings remains the graphical configuration surface for appearance, pointer, users, networking, Bluetooth, shortcuts and power.

Repository design packs live under `design-packs/` and are staged into the `lokro-shell` package during the isolated package build. The runtime importer accepts a reviewed directory or ZIP-compatible `.lokrodesign` file, validates every path and file, then installs only to the current user's XDG data directory. It never invokes a package manager or executes pack content.

## Performance policy

Lokro deliberately does not import the CachyOS kernel, repositories or Ananicy stack. Those are useful projects but would add another trust root and a larger maintenance surface. Lokro independently applies a small reviewed subset of ideas suitable for the stock Arch kernel: zram, high swappiness toward compressed RAM, page-cluster zero, systemd-oomd, periodic fstrim and power-profiles-daemon.

## Lokro service manifest

The base manifest is `/usr/share/lokro/services.json`. Administrators add sorted fragments at `/etc/lokro/services.d/*.json`. A fragment may contain either an array or `{ "services": [...] }`; later entries replace earlier entries with the same `id`. The merged, read-only result is `/var/lib/lokro/services.json`.

Every service contains exactly these public fields:

```json
{"id":"status","name":"Status","url":"https://status.example.org","icon":"network-server"}
```

No authentication or SSO semantics are implied in v0.1.

## Component interaction and interfaces

- **Build-time:** `build-packages.sh` produces `out/repo/lokro.db` (`[lokro]`). `prepare-profile.sh` copies the
  installed Archiso `releng` profile, overlays `archiso/airootfs/`, appends `archiso/packages/{common,variant}.x86_64`
  to `packages.x86_64` (`sort -u`), injects `[lokro]` into `pacman.conf`, resolves the full set with
  `pacman -Sp --print-format '%n %v'` into `out/resolved-packages-<variant>.txt`, and — for `offline` only —
  pre-downloads the NVIDIA/gaming/Hyprland bundle into `airootfs/opt/lokro/repo` (deduped against the base
  transaction, then indexed with `repo-add` as `[lokro-media]`). `mkarchiso` pacstraps the live root and bakes
  the SquashFS; `checksums.sh` splits, hashes, and records manifests/licenses/provenance.
- **Live vs. installed:** the live image keeps Archiso's generic initramfs hooks and live-only state
  (`lokro-live-user.service`, `10-lokro-live.conf`, sudoers drop-in, smoke watcher, `/opt/lokro/repo`,
  `archiso.conf`). Calamares `unpackfs` copies the embedded SquashFS, `packages`/`contextualprocess@browserCleanup`
  adjust the target selection, and `shellprocess@cleanup` (`installer-cleanup`) removes live artifacts and writes a
  normal disk-root `HOOKS=(base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block
  sd-encrypt filesystems fsck)` config before `initcpiocfg`/`initcpio`/`grubcfg`/`bootloader` run.
- **Boot interfaces:** syslinux (`APPEND`), systemd-boot loader entries (`options`), and GRUB (`linux`) carry kernel
  parameters; since alpha.11 only `APPEND`/`options` receive serial diagnostics (see `docs/KNOWN_ISSUES.md` KI-007
  for the GRUB gap). SDDM greets on X11 while the Plasma session itself is Wayland.
- **Update interface:** `LOKRO_UPDATE_CHANNEL.json` (root) must stay byte-identical with the packaged copy;
  `lokro-update.timer` + `lokro-update` implement download-strict-validate-cache-confirm-apply with backups and
  running-kernel module retention hooks.

## Open decisions (ADRs, `docs/adr/`, since 2026-10-16)

First records exist as proposals (none decided yet): `0001-mobile-shell-plasma-mobile.md` and
`0002-shared-first-boot-wizard.md`. Still open candidates: Flathub pinning strategy, offline dedup
method, serial-diagnostic scope for the GRUB `linux` directive, manifest generation (`pacman --root/--dbpath`
semantics), and the 4 GiB size budget. Each ADR records problem, requirements, alternatives, decision, rationale,
drawbacks, and impact, marked binding vs. proposal.
