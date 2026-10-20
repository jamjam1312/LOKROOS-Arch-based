# LOKRO OS release status

This file separates implemented source from tested release claims. An item being configured does not prove that it works on every physical computer.

## Alpha.24 source candidate (unreleased)

- `LOKRO Black` is now the system Plasma style and the automatic default for
  fresh users. It combines a true-black grayscale color scheme, black Plasma
  surfaces, Breeze Dark application icons and the compiled `LokroMono` cursor.
- Fresh installations receive a deterministic 48-pixel bottom panel with the
  LOKRO launcher icon, LOKRO search, task switcher, workspaces, system tray,
  clock and show-desktop control. The first-login v5 migration deliberately
  keeps an existing user's customized panel while applying the new colors.
- Plymouth uses a new monochrome LOKRO startup mark on a black background, and
  installed GRUB receives a generated 1920x1080 LOKRO background. These are
  implemented and source-validated only until the Alpha.24 Arch CI build and
  BIOS/UEFI smoke boots complete.

- The LOKRO landing page is implemented as an isolated, buildless GitHub Pages
  site for `os.lokro.dev`. Its pointer-reactive background is a fixed terminal
  glyph grid; interaction continues underneath the centered hero content and
  clicks create a short text-only signal. The site is not part of either ISO.
- The Plasma first-login migration now explicitly applies `org.lokro.dark`,
  `LokroDark`, the Breeze Dark application icons and the `LokroMono` cursor.
  This closes the gap where the files existed in Alpha.23 but Plasma could keep
  parts of an older/default appearance. This correction is source-validated
  only and is not retroactively present in the published Alpha.23 images.

## Alpha.23 source and CI release

- The exact hardware-reported installer failure—`lokro-live-installer` missing
  executable permissions—is fixed both in Git's file mode and by an explicit
  `chmod 0755` during profile preparation. The full branch workflow built both
  Alpha.23 images and reached Plasma with Calamares running in BIOS and UEFI;
  this verifies the fix in the live image, not a completed disk installation.
- `LOKRO Chamfer` adds native QML 10/18/28-pixel corner geometry based on the
  measurements supplied by Erik / LOKROGAMER. The style is switchable and
  persistent in LOKRO Settings and selectable through the safe declarative
  design-pack format. No website code or artwork is copied.

- The pinned LOKRO Store source is updated to checksum-verified
  `v0.1.0-alpha.8`, retaining its repaired user-scoped Flathub setup and adding
  the expanded catalog/update controls from the separately tested Store tag.
- Design-pack color schemes are now installed under the basename Plasma is
  asked to apply. This fixes the `LOKRO Glass` install-success/apply-failure
  mismatch. Black-box tests assert the corrected filename.
- Original dark `Eclipse` and light `Lunar` halftone wallpaper packs, the
  trusted compiled `LokroMono` cursor theme, an animated poster-inspired
  settings screen and a more discoverable low-idle-cost animated wallpaper are
  implemented in source.
- The live installer now performs a read-only preflight for the embedded Arch
  root, `unsquashfs`, `rsync`, Calamares and image readability, and writes a
  runtime diagnostics file before Calamares starts. It still selects no disk
  automatically.
- Credit spelling is corrected from `LOKKROGAMER` to `LOKROGAMER`; Jamie Milo
  Cürten's protected co-initiator/co-developer attribution remains unchanged.

The Alpha.23 workflow run `39293180171` built a
3,693,772,800-byte offline ISO and a 2,667,675,648-byte online ISO, enforced the
4 GiB limit and passed both BIOS and UEFI live-Plasma-plus-Calamares smoke
boots. The tag workflow reproduced those results and published the checksummed
multipart prerelease, manifests, provenance and build metadata on 19 October
2026. This still does not prove a completed Calamares installation, a booted
installed disk or operation on physical hardware.

## Alpha.22 source and CI release

The previous downloadable CI release was `0.1.0-alpha.22`.

- LOKRO Store `v0.1.0-alpha.7` adds all 13 ArtCraft Crafting Apps as separate
  experimental choices. Every x86_64 Flatpak uses the exact upstream
  application ID, immutable versioned URL and published SHA-256; the launcher
  remains an optional separate entry.
- The Store receives a restrained translucent glass treatment while preserving
  the existing shell-free installer boundary.
- LOKRO Settings becomes a dedicated glass-styled landing page for appearance,
  cursor, network, Bluetooth, users, shortcuts, power and the complete Plasma
  settings application.
- The original `org.lokro.glass` design pack adds a black glass color scheme,
  bright focus lines and the existing Slashes wallpaper. The reviewed LOKRO
  website declares no repository license, so no website asset or source code
  is copied.

The alpha.22 GitHub workflow built the Arch packages, a 3,687,088,128-byte
offline ISO and a 2,660,270,080-byte online ISO, enforced the 4 GiB limit, and
passed both BIOS and UEFI live-Plasma smoke boots with Calamares observed
running. It published both images as checksummed multipart prerelease assets
on 18 October 2026. This verifies the live boot and installer launch in QEMU;
it does not verify a completed installation to disk or physical hardware.

## Alpha.21 CI release

Alpha.21 was the latest downloadable CI release at that stage. It keeps the
hardware-test and credit changes and replaces
the unobserved desktop autostart path reported by alpha.17's automated BIOS
test:

- The guarded live-user launcher starts Calamares through the live image's
  existing passwordless `sudo` policy while preserving the Plasma display
  environment. The launcher and sudo policy are deleted from the installed
  system by Calamares.
- A root-owned, live-image-only supervisor waits for the actual Plasma process
  and live-user D-Bus, then runs the guarded launcher through Bash as
  `liveuser` with the real Plasma environment. Global and
  user-scoped XDG autostart remain as fallbacks. All paths use one non-blocking
  lock, so Calamares starts at most once. No disk is selected automatically.
- The launcher writes a runtime status marker. The VM watcher reports a failed
  installer exit immediately instead of waiting for the full timeout, while
  still requiring both Plasma and a running Calamares process for success.
- The project credits name **Jamie Milo Cürten** as co-initiator and co-developer
  who created the technical foundation with help from ChatGPT / OpenAI Codex.
  Identical root and installed copies, a welcome-screen entry, an application
  launcher, validation invariants and CODEOWNERS coverage keep this attribution
  visible and require explicit project-owner review for changes.
- The LOKRO Hub no longer declares `icon` on a Plasma button delegate, which
  previously attempted to override a final QML property and prevented the
  widget from loading.
- LOKRO Store `v0.1.0-alpha.6` creates or repairs a user-scoped Flathub remote
  before installing exact application IDs.
- ArtCraft Launcher 0.3.2 is installable from its official versioned x86_64
  Flatpak bundle after a fixed SHA-256 check. It remains clearly experimental.
- The Design Pack dialog now opens the Store catalog as well as local folders
  and `.lokrodesign` files. The Store includes one reviewed first-party pack
  that is downloaded from an immutable tag, SHA-256 verified and passed to the
  existing no-script importer.
- The BIOS/UEFI smoke gate requires both Plasma and the automatically opened
  Calamares process instead of accepting the desktop alone.

The alpha.21 GitHub workflow built the Arch packages, a 3,687,088,128-byte
offline ISO and a 2,660,270,080-byte online ISO, enforced the 4 GiB limit, and
passed both BIOS and UEFI live-Plasma smoke boots with Calamares observed
running. It then published both images as checksummed multipart prerelease
assets on 18 October 2026. This verifies the live boot and installer launch in
QEMU; it does not verify a completed installation to disk or physical hardware.

## Implemented in the source tree

- x86_64-only Archiso desktop images, based on the official releng profile.
- KDE Plasma 6 Wayland desktop with XWayland compatibility and SDDM login.
- Calamares installation flow for locale, keyboard, partitioning, user accounts, package choices and GRUB.
- Installer choices for Plasma/optional Hyprland, Firefox/no browser, application bundle, graphics path and gaming bundle.
- Fully embedded Arch base, kernel and firmware; no pre-installed operating system is required.
- UEFI and legacy BIOS boot configuration; GPT/ext4 default, manual partitioning and optional LUKS encryption.
- Pacman base-system management plus Flatpak, Flathub setup and KDE Discover.
- Pinned LOKRO Store `v0.1.0-alpha.8` in the current source tree (`v0.1.0-alpha.7` in the tested Alpha.22 ISO), with an offline catalog, search, categories, repaired user-scoped Flathub installation, checksum-pinned ArtCraft bundles and checksum-pinned declarative LOKRO design packs. Catalog data still cannot provide shell commands.
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
- Project credits available from the welcome center and application menu, with a byte-identical installed copy and validation of the attribution to Jamie Milo Cürten, LOKROGAMER, ChatGPT / OpenAI Codex and upstream authors.

## Static checks completed on the Windows development workspace

- Repository/configuration invariants and package-presence checks.
- JSON parsing and LOKRO service merge unit tests.
- YAML parsing, including Calamares and GitHub Actions files.
- Shell syntax parsing.
- Git whitespace checks.

QML linting and PKGBUILD parsing are enforced in the Arch build workflow, where the required Arch/KDE tools are available.

The alpha.5 CI attempt successfully produced both hybrid ISO files, including a roughly 2.5 GiB online image, but its six-minute BIOS check ended without userspace diagnostics. Alpha.6 confirmed the runner exposes KVM and reproduced the missing marker after 15 minutes; its serial log still showed only the bootloader because the kernel command line did not route boot output to serial. Alpha.7 added kernel/systemd serial diagnostics and successfully built both images, but the offline image exceeded the 4 GiB acceptance limit by about 39 MB because the optional offline repository duplicated package archives already installed in the live root. Alpha.8 introduced duplicate removal but stopped before ISO creation because the current Pacman rejects `--print-format` for file queries. Alpha.9 produced a 3,670,376,448-byte offline ISO and a 2,646,310,912-byte online ISO; BIOS reached userspace in 13.2 seconds but the live-user helper received `203/EXEC` before Plasma. Alpha.10 fixed that helper startup and reached the Plasma live session in the BIOS VM after 32 seconds. Its UEFI firmware reached systemd-boot, but no Linux entry was shown because the serial-debug rewrite had appended kernel parameters to systemd-boot's `linux` kernel-path directive. Alpha.11 fixed that rewrite, passed both BIOS and UEFI Plasma smoke boots, and was published as a checksummed multipart GitHub prerelease. Alpha.12 added the design-pack format and importer, built a 3,673,702,400-byte offline ISO and a 2,648,637,440-byte online ISO, passed the 4 GiB limit plus both BIOS and UEFI Plasma smoke boots, and was published on 16 October 2026. Alpha.13 stopped safely during the new Store package build because `python-setuptools` was missing; it produced and published no ISO. Alpha.14 corrected that dependency, built a 3,687,088,128-byte offline ISO and a 2,660,270,080-byte online ISO, passed the size limit plus both BIOS and UEFI Plasma smoke boots, and was published on 16 October 2026. Alpha.15 built the same-size offline and online ISOs and passed the size gate. Its BIOS VM reached Plasma, but the `sudo -E` GUI launcher did not leave Calamares running; the smoke gate correctly failed and no alpha.15 release was published. Alpha.16 again built a 3,687,088,128-byte offline ISO and a 2,660,270,080-byte online ISO and passed the size gate. Its BIOS VM reached Plasma, but no launcher status file appeared, proving the XDG autostart itself had not run; the smoke gate failed and no alpha.16 release was published. Alpha.17 embedded the protected credits, built both images and passed the size gate, but its BIOS VM again reached Plasma without a launcher status file. The Plasma target-based user-service enablement was therefore not observed; the gate failed and no alpha.17 release was published. Alpha.18 built both images and passed the size gate. Its supervisor found Plasma and the user D-Bus and successfully requested the user service, but systemd never executed the launcher, so the BIOS installer gate failed and no alpha.18 release was published. Alpha.19 built both images and passed the size gate. Its supervisor directly invoked the launcher, but execution returned code 126 before the launcher could write a status file; the BIOS gate failed after 55 seconds and no alpha.19 release was published. Alpha.20 built both images and passed the size gate. Changing the launcher from `pkexec` to `sudo -E` did not change that pre-launch code 126, confirming the executable file mode—not the elevation backend—was the remaining blocker; no alpha.20 release was published.

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

Alpha.23 is the latest downloadable build after successful package/ISO builds,
size checks and BIOS/UEFI live-Plasma-plus-Calamares smoke boots. Every alpha
remains experimental: Calamares installed-disk, real-hardware, gaming and
install-alongside acceptance still require human testing before any
daily-driver claim.
