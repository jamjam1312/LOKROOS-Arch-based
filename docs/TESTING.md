# Testing

## Automated checks

Run `make validate` on every change. On Arch Linux, also run `make packages`, `sudo make iso-offline`, `sudo make iso-online`, and `make checksums`. The GitHub workflow repeats those operations in a privileged Arch container and rejects either ISO when it exceeds 4 GiB.

After building, boot both firmware modes:

```bash
make vm-bios
make vm-uefi
make vm-online-bios
make vm-online-uefi
make smoke-bios
make smoke-uefi
```

The smoke targets run QEMU without a visible display and succeed only when a root-owned systemd watcher observes the live user's `plasmashell` process and writes `LOKRO_PLASMA_READY` to the emulated serial port. Bootloader entries retain the normal local console and also route kernel/systemd diagnostics to serial. The GitHub ISO workflow executes both BIOS and UEFI smoke boots after building the images.

For each mode and image variant, verify the live session reaches Plasma, the welcome center opens, networking works, `lokro-services-merge` produces valid JSON, Dolphin finds a newly-created file after Baloo indexing, and Calamares installs to an empty 32 GiB virtual disk. Test Plasma and optional Hyprland, Firefox and no-browser, minimal/complete and gaming selections, both an unencrypted installation and the optional encrypted layout. Remove the ISO and boot the installed disk to confirm GRUB, SDDM, NetworkManager, PipeWire, Bluetooth and Flatpak initialization.

In Plasma, verify that the panel search button opens KRunner, localized shutdown/restart/update launchers appear as search results, `Ctrl+Esc` and the LOKRO Task Manager show processes and resource sensors, cursor size changes persist, and `Meta+T` opens KWin's tiling editor. For Hyprland, select the session in SDDM and verify Waybar, Wofi, `Meta+Arrow`, `Meta+L`, portals and screenshots.

Open LOKRO Design Packs, install the bundled `org.lokro.monochrome` folder (or an equivalent `.lokrodesign` archive), apply it, and confirm colors plus wallpaper update. Confirm that a pack containing an unknown payload, executable file, symlink or archive `..` path is rejected without writing outside `~/.local/share`.

## Hardware matrix before an alpha release

- AMD GPU with Mesa and Vulkan.
- NVIDIA Turing-or-newer using the explicit `nvidia-open` installer choice.
- NVIDIA using the default Nouveau path.
- Two-monitor Wayland session.
- Suspend/resume, Bluetooth audio and a Flatpak installation.
- USB 2/3 storage on FAT32, exFAT and NTFS; wired and wireless networking.
- Steam starts, `gamemoded -t` passes, and Prism Launcher detects Java 8/17/21.

Record idle RAM after five minutes in a 4 GiB, four-vCPU reference VM. The target is at most 1.5 GiB. Confirm the Slashes wallpaper drops to its one-second idle timer and uses a static phase with software rendering.

Ollama testing is opt-in because the verified runtime download is over 1 GiB. Confirm it listens only on `127.0.0.1:11434` and does not download a model by itself.
