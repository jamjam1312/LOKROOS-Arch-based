# LOKRO OS 0.1.0-alpha.12 release status

This file separates implemented source from tested release claims. An item being configured does not prove that it works on every physical computer.

## Implemented in the source tree

- x86_64-only Archiso desktop images, based on the official releng profile.
- KDE Plasma 6 Wayland desktop with XWayland compatibility and SDDM login.
- Calamares installation flow for locale, keyboard, partitioning, user accounts, package choices and GRUB.
- Installer choices for Plasma/optional Hyprland, Firefox/no browser, application bundle, graphics path and gaming bundle.
- Fully embedded Arch base, kernel and firmware; no pre-installed operating system is required.
- UEFI and legacy BIOS boot configuration; GPT/ext4 default, manual partitioning and optional LUKS encryption.
- Pacman base-system management plus Flatpak, Flathub setup and KDE Discover.
- NetworkManager, Wi-Fi database and iwd tooling, LAN support through the Linux kernel, Bluetooth, USB utilities, Thunderbolt tooling and current Arch firmware packages.
- Mesa/OpenGL, AMD/Intel/Nouveau Vulkan and video acceleration. The offline installer can optionally install `nvidia-open`, `nvidia-utils` and `lib32-nvidia-utils` for supported Turing-or-newer NVIDIA hardware.
- PipeWire audio, power management, ZRAM, KDE settings, theming and desktop widgets.
- Plasma System Monitor exposed as the LOKRO Task Manager, KRunner/Baloo global search, searchable system actions, cursor/style settings and an optional Hyprland tiling session.
- LOKRO Settings shortcuts for users, appearance, wallpaper, cursor, network, Bluetooth, keyboard shortcuts, power, widgets and desktop-session guidance.
- User-scoped LOKRO Design Packs with a versioned JSON format, repository upload folder, graphical installer and path/link/executable/size validation. Packs may contain color files and wallpaper images but cannot execute code.
- A graphical LOKRO Boot Manager that displays generated GRUB entries and performs a backed-up, atomic `grub-mkconfig` refresh through administrator authorization.
- A safe HTTPS Link Installer for Flatpak refs/bundles, signed Arch packages and user-scoped AppImages. Scripts and foreign package formats are rejected.
- VLC-based LOKRO Media file associations for common MP3, MP4 and other audio/video formats, plus Ark, 7zip, unzip and zip archive support in both images.
- Firefox, LibreOffice, Dolphin, Kate, Konsole, Okular, Gwenview, Spectacle, KDE Connect and Flatseal in the offline payload.
- Optional Steam, Prism Launcher, Java 8/17/21, GameMode, Gamescope and MangoHud installation from the offline media.
- Separate offline and smaller online profiles, release checksums, manifests, provenance and license reports.
- Boot-time and five-hour update checks with low resource priority, safe pre-download, local confirmation, recovery metadata backups and running-kernel module retention.

## Static checks completed on the Windows development workspace

- Repository/configuration invariants and package-presence checks.
- JSON parsing and LOKRO service merge unit tests.
- YAML parsing, including Calamares and GitHub Actions files.
- Shell syntax parsing.
- Git whitespace checks.

QML linting and PKGBUILD parsing are enforced in the Arch build workflow, where the required Arch/KDE tools are available.

The alpha.5 CI attempt successfully produced both hybrid ISO files, including a roughly 2.5 GiB online image, but its six-minute BIOS check ended without userspace diagnostics. Alpha.6 confirmed the runner exposes KVM and reproduced the missing marker after 15 minutes; its serial log still showed only the bootloader because the kernel command line did not route boot output to serial. Alpha.7 added kernel/systemd serial diagnostics and successfully built both images, but the offline image exceeded the 4 GiB acceptance limit by about 39 MB because the optional offline repository duplicated package archives already installed in the live root. Alpha.8 introduced duplicate removal but stopped before ISO creation because the current Pacman rejects `--print-format` for file queries. Alpha.9 produced a 3,670,376,448-byte offline ISO and a 2,646,310,912-byte online ISO; BIOS reached userspace in 13.2 seconds but the live-user helper received `203/EXEC` before Plasma. Alpha.10 fixed that helper startup and reached the Plasma live session in the BIOS VM after 32 seconds. Its UEFI firmware reached systemd-boot, but no Linux entry was shown because the serial-debug rewrite had appended kernel parameters to systemd-boot's `linux` kernel-path directive. Alpha.11 fixed that rewrite, passed both BIOS and UEFI Plasma smoke boots, and was published as a checksummed multipart GitHub prerelease. Alpha.12 added the design-pack format and importer, built a 3,673,702,400-byte offline ISO and a 2,648,637,440-byte online ISO, passed the 4 GiB limit plus both BIOS and UEFI Plasma smoke boots, and was published on 16 October 2026.

## Required before sharing an ISO as tested

- Build both images on Arch Linux or in the privileged Arch GitHub Actions container.
- Complete automated BIOS and UEFI Plasma smoke boots.
- Install with Calamares into an empty VM and boot the installed disk without the ISO.
- Test manual partitioning and install-alongside behavior using backed-up disposable disks.
- Verify networking, audio, Bluetooth, suspend, multi-monitor, Flatpak installation and a full Pacman update.
- Test at least one AMD GPU machine, one supported NVIDIA Turing-or-newer machine with `nvidia-open`, and the Nouveau fallback.
- Verify Minecraft with Prism Launcher and Steam/Proton on hardware. Compatibility depends on each game, anti-cheat system and GPU driver.

## Not part of this alpha

- A server edition (the `server/` directory is only a placeholder).
- Secure Boot, guaranteed dual boot, guaranteed support for every peripheral, or automatic proprietary legacy NVIDIA drivers.
- A custom package server, custom desktop environment, LibreOffice fork or bundled AI model.
- General-purpose live kernel replacement. The running kernel remains active until reboot; only its matching modules are retained safely.

Alpha.12 is downloadable after successful builds, size checks and BIOS/UEFI live-Plasma smoke boots. It remains an experimental test image: Calamares installed-disk, real-hardware, gaming and install-alongside acceptance still require human testing before any daily-driver claim.
