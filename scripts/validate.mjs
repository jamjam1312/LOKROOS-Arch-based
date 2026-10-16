#!/usr/bin/env node
// SPDX-License-Identifier: GPL-3.0-or-later
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname.replace(/^\/(.:)/, "$1")), "..");
const failures = [];
const required = [
  "VERSION", "Makefile", "CONTRIBUTORS.md", "AI_INFO.md", "AGENTS.md", "desktop/README.md", "server/README.md",
  "design-packs/README.md", "design-packs/design-pack.schema.json",
  "design-packs/org.lokro.monochrome/design.json", "docs/DESIGN_PACKS.md",
  "LOKRO_UPDATE_CHANNEL.json", "schemas/update-channel.schema.json", "docs/UPDATES.md",
  "docs/RELEASE_STATUS.md", "docs/STANDALONE_INSTALL.md", "archiso/packages/common.x86_64",
  "archiso/packages/offline.x86_64", "archiso/packages/online.x86_64",
  "archiso/airootfs/etc/plymouth/plymouthd.conf",
  "vendor/ckbcomp/PKGBUILD",
  "packages/lokro-branding/PKGBUILD", "packages/lokro-shell/PKGBUILD",
  "packages/lokro-installer-config/PKGBUILD", "packages/lokro-ai-setup/PKGBUILD",
  "packages/lokro-store/PKGBUILD",
  "packages/lokro-shell/rootfs/usr/share/plasma/wallpapers/org.lokro.slashes/metadata.json",
  "packages/lokro-shell/rootfs/usr/share/plasma/plasmoids/org.lokro.hub/metadata.json",
  "packages/lokro-shell/rootfs/usr/share/plasma/plasmoids/org.lokro.search/metadata.json",
  "packages/lokro-shell/rootfs/usr/share/lokro/services.json",
  "packages/lokro-shell/rootfs/usr/share/lokro/services.schema.json",
  "packages/lokro-shell/rootfs/usr/share/lokro/welcome/main.qml",
  "packages/lokro-shell/rootfs/usr/share/lokro/welcome/WelcomeCard.qml",
  "packages/lokro-shell/rootfs/usr/bin/lokro-welcome",
  "packages/lokro-shell/rootfs/usr/bin/lokro-action",
  "packages/lokro-shell/rootfs/usr/bin/lokro-search",
  "packages/lokro-shell/rootfs/usr/bin/lokro-update",
  "packages/lokro-shell/rootfs/usr/bin/lokro-update-gui",
  "packages/lokro-shell/rootfs/usr/bin/lokro-link-installer",
  "packages/lokro-shell/rootfs/usr/bin/lokro-link-installer-gui",
  "packages/lokro-shell/rootfs/usr/bin/lokro-media",
  "packages/lokro-shell/rootfs/usr/bin/lokro-boot-manager",
  "packages/lokro-shell/rootfs/usr/bin/lokro-design-pack",
  "packages/lokro-shell/rootfs/usr/bin/lokro-design-pack-gui",
  "packages/lokro-shell/rootfs/usr/share/applications/lokro-control-center.desktop",
  "packages/lokro-shell/rootfs/usr/share/applications/lokro-desktop-sessions.desktop",
  "packages/lokro-shell/rootfs/usr/share/applications/lokro-link-installer.desktop",
  "packages/lokro-shell/rootfs/usr/share/applications/lokro-media.desktop",
  "packages/lokro-shell/rootfs/usr/share/applications/lokro-boot-manager.desktop",
  "packages/lokro-shell/rootfs/usr/share/applications/lokro-design-packs.desktop",
  "packages/lokro-shell/rootfs/usr/lib/systemd/system/lokro-update.timer",
  "packages/lokro-shell/rootfs/usr/lib/lokro-update/keep-running-kernel",
  "packages/lokro-installer-config/rootfs/etc/calamares/modules/packagechooser-gaming.conf",
  "packages/lokro-installer-config/rootfs/etc/calamares/modules/packagechooser-desktop.conf",
  "packages/lokro-installer-config/rootfs/etc/calamares/modules/packagechooser-browser.conf",
  "packages/lokro-installer-config/rootfs/etc/calamares/modules/contextualprocess-browser.conf",
  "packages/lokro-installer-config/rootfs/etc/calamares/modules/packagechooser-apps-offline.conf",
  "packages/lokro-installer-config/rootfs/etc/calamares/modules/packagechooser-apps-online.conf",
  "archiso/airootfs/usr/local/sbin/lokro-smoke-ready",
  "archiso/airootfs/etc/systemd/system/lokro-smoke-ready.service",
  "scripts/smoke-boot.sh",
  "scripts/test-design-packs.py",
  "scripts/validate-pkgbuilds.sh",
  "third_party/sources.json", "docs/AI_DISCLOSURE.md"
];
for (const rel of required) if (!fs.existsSync(path.join(root, rel))) failures.push(`missing: ${rel}`);

function walk(dir) {
  return fs.readdirSync(dir, {withFileTypes: true}).flatMap(e => {
    const p = path.join(dir, e.name);
    return e.isDirectory() ? walk(p) : [p];
  });
}

for (const file of walk(root)) {
  const skippedDirectories = [".git", "build", "out", "outputs", "work"];
  if (skippedDirectories.some(directory => file.includes(`${path.sep}${directory}${path.sep}`))) continue;
  const rel = path.relative(root, file).replaceAll("\\", "/");
  if (file.endsWith(".json")) {
    try { JSON.parse(fs.readFileSync(file, "utf8")); } catch (e) { failures.push(`${rel}: invalid JSON (${e.message})`); }
  }
  if (/\.(sh|py)$/.test(file) || rel.includes("/usr/bin/") || rel.includes("/usr/local/sbin/")) {
    const text = fs.readFileSync(file, "utf8");
    if (!text.startsWith("#!")) failures.push(`${rel}: missing shebang`);
  }
  const text = fs.readFileSync(file, "utf8");
  if (/curl[^\n|]*\|\s*(sh|bash)/.test(text)) failures.push(`${rel}: forbidden curl-pipe-shell pattern`);
}

const packageFiles = ["common", "offline", "online"].map(variant => `archiso/packages/${variant}.x86_64`);
const packageSets = Object.fromEntries(packageFiles.map(file => [file, fs.readFileSync(path.join(root, file), "utf8")
  .split(/\r?\n/).map(x => x.trim()).filter(x => x && !x.startsWith("#"))]));
const packageLines = Object.values(packageSets).flat();
for (const forbidden of ["yay", "paru", "pamac-aur"]) if (packageLines.includes(forbidden)) failures.push(`forbidden runtime AUR helper: ${forbidden}`);
for (const [file, packages] of Object.entries(packageSets)) {
  const dupes = packages.filter((x, i) => packages.indexOf(x) !== i);
  if (dupes.length) failures.push(`${file}: duplicate package names: ${[...new Set(dupes)].join(", ")}`);
}
for (const localPackage of ["ckbcomp", "calamares-lokro", "lokro-branding", "lokro-shell", "lokro-installer-config", "lokro-ai-setup", "lokro-store"]) {
  if (!packageSets["archiso/packages/common.x86_64"].includes(localPackage)) failures.push(`common ISO package list is missing ${localPackage}`);
}
for (const requiredOffline of ["libreoffice-fresh", "libreoffice-fresh-de"]) {
  if (!packageSets["archiso/packages/offline.x86_64"].includes(requiredOffline)) failures.push(`offline ISO package list is missing ${requiredOffline}`);
}
for (const requiredCommon of [
  "base", "linux", "firefox", "firefox-i18n-de", "networkmanager", "iwd", "wireless-regdb",
  "bluez", "bluez-utils", "usbutils", "linux-firmware", "sof-firmware",
  "mesa", "vulkan-radeon", "vulkan-intel", "vulkan-nouveau",
  "lib32-mesa", "lib32-vulkan-radeon", "lib32-vulkan-intel", "lib32-vulkan-nouveau",
  "pipewire", "wireplumber", "grub", "efibootmgr", "cryptsetup", "sddm",
  "pacman-contrib", "partitionmanager", "flatpak", "discover", "systemsettings", "powerdevil",
  "plasma-systemmonitor", "kinfocenter", "os-prober", "fuse3",
  "ark", "7zip", "unzip", "zip", "vlc", "lokro-store"
]) {
  if (!packageSets["archiso/packages/common.x86_64"].includes(requiredCommon)) failures.push(`common ISO package list is missing ${requiredCommon}`);
}

const gamingChooser = fs.readFileSync(path.join(root, "packages/lokro-installer-config/rootfs/etc/calamares/modules/packagechooser-gaming.conf"), "utf8");
for (const gamingPackage of ["steam", "prismlauncher", "jre8-openjdk", "jre17-openjdk", "jre21-openjdk", "gamemode", "gamescope", "mangohud"]) {
  if (!new RegExp(`(^|\\s)-?\\s*${gamingPackage.replace(/[.*+?^${}()|[\\]\\]/g, "\\$&")}($|\\s)`, "m").test(gamingChooser)) failures.push(`gaming chooser is missing ${gamingPackage}`);
}

const desktopChooser = fs.readFileSync(path.join(root, "packages/lokro-installer-config/rootfs/etc/calamares/modules/packagechooser-desktop.conf"), "utf8");
for (const desktopPackage of ["hyprland", "hyprlock", "waybar", "wofi", "xdg-desktop-portal-hyprland"]) {
  if (!desktopChooser.includes(`- ${desktopPackage}`)) failures.push(`desktop chooser is missing ${desktopPackage}`);
}

const calamaresSettings = fs.readFileSync(path.join(root, "packages/lokro-installer-config/rootfs/etc/calamares/settings.conf"), "utf8");
for (const installerStep of ["packagechooser@desktop", "packagechooser@browser", "contextualprocess@browserCleanup"]) {
  if (!calamaresSettings.includes(installerStep)) failures.push(`Calamares flow is missing ${installerStep}`);
}

const browserProcess = fs.readFileSync(path.join(root, "packages/lokro-installer-config/rootfs/etc/calamares/modules/contextualprocess-browser.conf"), "utf8");
if (!browserProcess.includes("pacman -R --noconfirm firefox firefox-i18n-de")) failures.push("browser chooser cannot remove Firefox from the target");

const unpackfs = fs.readFileSync(path.join(root, "packages/lokro-installer-config/rootfs/etc/calamares/modules/unpackfs.conf"), "utf8");
if (!unpackfs.includes("/run/archiso/bootmnt/arch/x86_64/airootfs.sfs")) failures.push("installer does not unpack the embedded x86_64 Arch root");

const usersConfig = fs.readFileSync(path.join(root, "packages/lokro-installer-config/rootfs/etc/calamares/modules/users.conf"), "utf8");
for (const adminInvariant of ["sudoersGroup: wheel", "sudoersConfigureWithGroup: true", "setRootPassword: false", "location: EtcFile"]) {
  if (!usersConfig.includes(adminInvariant)) failures.push(`users config is missing administrator invariant: ${adminInvariant}`);
}

const grubConfig = fs.readFileSync(path.join(root, "packages/lokro-installer-config/rootfs/etc/calamares/modules/grubcfg.conf"), "utf8");
if (!grubConfig.includes("GRUB_DISABLE_OS_PROBER: false")) failures.push("GRUB is not configured to discover other operating systems");

const installerCleanup = fs.readFileSync(path.join(root, "packages/lokro-installer-config/rootfs/usr/lib/lokro/installer-cleanup"), "utf8");
for (const liveArtifact of ["lokro-live-user.service", "10-lokro-live.conf", "getty@tty1.service.d/autologin.conf", "userdel --remove liveuser", "/opt/lokro/repo", "mkinitcpio.conf.d/archiso.conf"]) {
  if (!installerCleanup.includes(liveArtifact)) failures.push(`installer cleanup does not remove live artifact: ${liveArtifact}`);
}
if (!installerCleanup.includes("HOOKS=(base systemd plymouth autodetect")) failures.push("installed target does not receive a disk-root initramfs configuration");
if (fs.existsSync(path.join(root, "packages/lokro-branding/rootfs/etc/mkinitcpio.conf.d/lokro.conf"))) failures.push("disk-root initramfs config must not be present while building the live Archiso root");

const version = fs.readFileSync(path.join(root, "VERSION"), "utf8").trim();
if (!/^\d+\.\d+\.\d+-alpha\.\d+$/.test(version)) failures.push(`VERSION is not an alpha SemVer: ${version}`);

const designSchema = JSON.parse(fs.readFileSync(path.join(root, "design-packs/design-pack.schema.json"), "utf8"));
const designExample = JSON.parse(fs.readFileSync(path.join(root, "design-packs/org.lokro.monochrome/design.json"), "utf8"));
for (const key of designSchema.required ?? []) {
  if (!(key in designExample)) failures.push(`example design pack is missing schema-required key: ${key}`);
}
if (designExample.schemaVersion !== 1) failures.push("example design pack must use schemaVersion 1");
if (designExample.id !== "org.lokro.monochrome") failures.push("example design-pack directory and id must match");
const designTool = fs.readFileSync(path.join(root, "packages/lokro-shell/rootfs/usr/bin/lokro-design-pack"), "utf8");
for (const safetyInvariant of ["MAX_FILES", "MAX_FILE_SIZE", "MAX_TOTAL_SIZE", "path.is_symlink()", "stat.S_ISLNK", "executable files are not allowed", "only schemaVersion 1 is supported"]) {
  if (!designTool.includes(safetyInvariant)) failures.push(`design-pack importer is missing safety invariant: ${safetyInvariant}`);
}
const packageBuilder = fs.readFileSync(path.join(root, "scripts/build-packages.sh"), "utf8");
if (!packageBuilder.includes('PROJECT_ROOT}/design-packs/.')) failures.push("lokro-shell package build does not stage repository design packs");
const lokroAction = fs.readFileSync(path.join(root, "packages/lokro-shell/rootfs/usr/bin/lokro-action"), "utf8");
const welcomeQml = fs.readFileSync(path.join(root, "packages/lokro-shell/rootfs/usr/share/lokro/welcome/main.qml"), "utf8");
if (!lokroAction.includes("design-packs) launch lokro-design-pack-gui")) failures.push("LOKRO action router cannot open design packs");
if (!welcomeQml.includes('openAction("design-packs")')) failures.push("welcome center does not expose design packs");
if (!lokroAction.includes("app-store) launch lokro-store")) failures.push("LOKRO action router cannot open the app store");
if (!welcomeQml.includes('openAction("app-store")')) failures.push("welcome center does not expose the app store");
const storePackage = fs.readFileSync(path.join(root, "packages/lokro-store/PKGBUILD"), "utf8");
for (const storeInvariant of ["_upstream_version=0.1.0-alpha.3", "1472848d780e4f38c1a74e783a607ae1bf02b4458a414f4d6641523655554177", "python-setuptools", "assets/icons/*.svg"]) {
  if (!storePackage.includes(storeInvariant)) failures.push(`LOKRO Store package is missing pinned alpha-3 invariant: ${storeInvariant}`);
}

const prepareProfile = fs.readFileSync(path.join(root, "scripts/prepare-profile.sh"), "utf8");
if (!prepareProfile.includes("ln -sfn /etc/systemd/system/lokro-live-user.service")) {
  failures.push("live-user enablement must point to the unit stored under /etc/systemd/system");
}
if (!prepareProfile.includes("ln -sfn /etc/systemd/system/lokro-smoke-ready.service")) {
  failures.push("smoke-watcher enablement must point to the unit stored under /etc/systemd/system");
}
if (!prepareProfile.includes('cp -L /etc/pacman.d/mirrorlist')) failures.push("embedded Arch root does not receive a pacman mirrorlist");
if (/airootfs\/etc\/calamares\/modules\/welcome\.conf/.test(prepareProfile)) {
  failures.push("profile preparation must not overlay package-owned Calamares welcome.conf before pacstrap");
}
for (const offlineExtra of ["hyprland", "hyprlock", "waybar", "wofi", "xdg-desktop-portal-hyprland"]) {
  if (!prepareProfile.includes(offlineExtra)) failures.push(`offline repository preparation is missing ${offlineExtra}`);
}
const smokeService = fs.readFileSync(path.join(root, "archiso/airootfs/etc/systemd/system/lokro-smoke-ready.service"), "utf8");
if (!/ExecStart=\/usr\/bin\/bash \/usr\/local\/sbin\/lokro-smoke-ready/.test(smokeService) || !/WantedBy=multi-user\.target/.test(smokeService)) {
  failures.push("root-owned smoke watcher must start from multi-user.target before the graphical result is known");
}
const liveUserService = fs.readFileSync(path.join(root, "archiso/airootfs/etc/systemd/system/lokro-live-user.service"), "utf8");
if (!/ExecStart=\/usr\/bin\/bash \/usr\/local\/sbin\/lokro-create-live-user/.test(liveUserService) || !/Before=sddm\.service/.test(liveUserService)) {
  failures.push("live-user creation must run through Bash before SDDM starts");
}
const liveSddm = fs.readFileSync(path.join(root, "archiso/airootfs/etc/sddm.conf.d/10-lokro-live.conf"), "utf8");
for (const displayInvariant of ["Session=plasma", "DisplayServer=x11"]) {
  if (!liveSddm.includes(displayInvariant)) failures.push(`live SDDM configuration is missing: ${displayInvariant}`);
}
const smokeScript = fs.readFileSync(path.join(root, "archiso/airootfs/usr/local/sbin/lokro-smoke-ready"), "utf8");
for (const invariant of ["pgrep -u liveuser -x plasmashell", "LOKRO_SMOKE_WATCHER_STARTED", "LOKRO_PLASMA_READY", "LOKRO_SMOKE_FAILED"]) {
  if (!smokeScript.includes(invariant)) failures.push(`smoke watcher is missing invariant: ${invariant}`);
}
const smokeBoot = fs.readFileSync(path.join(root, "scripts/smoke-boot.sh"), "utf8");
for (const bootInvariant of ["-c /dev/kvm", "acceleration='kvm'", "tcg,thread=multi", "timeout 900s", "attempt < 900"]) {
  if (!smokeBoot.includes(bootInvariant)) failures.push(`VM smoke boot is missing acceleration/timeout invariant: ${bootInvariant}`);
}
for (const smokeArtifact of ["lokro-smoke-ready.service", "/usr/local/sbin/lokro-smoke-ready"]) {
  if (!installerCleanup.includes(smokeArtifact)) failures.push(`installer cleanup does not remove smoke artifact: ${smokeArtifact}`);
}
for (const serialInvariant of ["console=tty0", "console=ttyS0,115200n8", "systemd.log_target=console", "boot_config_count > 0"]) {
  if (!prepareProfile.includes(serialInvariant)) failures.push(`prepared Archiso boot entries are missing serial diagnostic invariant: ${serialInvariant}`);
}
if (prepareProfile.includes("(APPEND|options|linux)")) {
  failures.push("serial diagnostics must never be appended to the systemd-boot linux kernel-path directive");
}
if (!prepareProfile.includes("(APPEND|options)")) {
  failures.push("serial diagnostics must be limited to bootloader kernel-parameter directives");
}

const workflow = fs.readFileSync(path.join(root, ".github/workflows/build-iso.yml"), "utf8");
for (const releaseInvariant of ["Smoke boot BIOS and UEFI", "out/*.iso.[0-9][0-9][0-9]", "--notes-file out/REASSEMBLE.md"]) {
  if (!workflow.includes(releaseInvariant)) failures.push(`release workflow is missing multipart/smoke invariant: ${releaseInvariant}`);
}
const checksumScript = fs.readFileSync(path.join(root, "scripts/checksums.sh"), "utf8");
for (const partInvariant of ["--bytes=1900M", "ISO-PARTS-SHA256SUMS", "REASSEMBLE.md"]) {
  if (!checksumScript.includes(partInvariant)) failures.push(`release metadata is missing multipart invariant: ${partInvariant}`);
}

const linkInstaller = fs.readFileSync(path.join(root, "packages/lokro-shell/rootfs/usr/bin/lokro-link-installer"), "utf8");
for (const safetyInvariant of ["only HTTPS download links are accepted", "pacman-key --verify", ".flatpakref", ".AppImage", ".deb", ".rpm"]) {
  if (!linkInstaller.includes(safetyInvariant)) failures.push(`link installer is missing safety invariant: ${safetyInvariant}`);
}
if (/\beval\b|curl[^\n|]*\|\s*(sh|bash)/.test(linkInstaller)) failures.push("link installer may not evaluate or pipe downloaded content into a shell");

const mediaDesktop = fs.readFileSync(path.join(root, "packages/lokro-shell/rootfs/usr/share/applications/lokro-media.desktop"), "utf8");
for (const mediaInvariant of ["Exec=lokro-media %U", "audio/mpeg", "video/mp4", "video/x-matroska"]) {
  if (!mediaDesktop.includes(mediaInvariant)) failures.push(`LOKRO Media association is missing: ${mediaInvariant}`);
}
const mergeService = fs.readFileSync(path.join(root, "packages/lokro-shell/rootfs/usr/lib/systemd/system/lokro-services-merge.service"), "utf8");
if (!/\[Install\][\s\S]*WantedBy=multi-user\.target/.test(mergeService)) {
  failures.push("lokro-services-merge.service must be enableable by Calamares");
}

const rootUpdateChannelText = fs.readFileSync(path.join(root, "LOKRO_UPDATE_CHANNEL.json"), "utf8");
const packagedUpdateChannelText = fs.readFileSync(path.join(root, "packages/lokro-shell/rootfs/usr/share/lokro/update-channel.json"), "utf8");
if (rootUpdateChannelText !== packagedUpdateChannelText) failures.push("packaged update channel differs from root LOKRO_UPDATE_CHANNEL.json");
const updateChannel = JSON.parse(rootUpdateChannelText);
if (updateChannel.version !== version) failures.push("update channel version differs from VERSION");
if (updateChannel.repository !== "jamjam1312/LOKROOS-Arch-based") failures.push("update channel repository is not pinned");
if (updateChannel.architecture !== "x86_64") failures.push("update channel architecture must be x86_64");
if (updateChannel.automaticPolicy?.installWithoutLocalConfirmation !== false) failures.push("remote policy must not permit unattended installation");

const services = JSON.parse(fs.readFileSync(path.join(root, "packages/lokro-shell/rootfs/usr/share/lokro/services.json"), "utf8"));
if (!Array.isArray(services.services)) failures.push("services.json must contain a services array");
for (const svc of services.services ?? []) for (const key of ["id", "name", "url", "icon"]) if (typeof svc[key] !== "string") failures.push(`service entry missing string ${key}`);

const aiReleases = JSON.parse(fs.readFileSync(path.join(root, "packages/lokro-ai-setup/rootfs/usr/share/lokro-ai/releases.json"), "utf8"));
for (const artifact of [aiReleases.ollama?.base, aiReleases.ollama?.rocm]) {
  if (!artifact?.url?.startsWith("https://")) failures.push("AI artifact URL must use HTTPS");
  if (!/^[a-f0-9]{64}$/.test(artifact?.sha256 ?? "")) failures.push("AI artifact must have a lowercase SHA-256 digest");
}

if (failures.length) {
  console.error(failures.map(x => `FAIL ${x}`).join("\n"));
  process.exit(1);
}
console.log(`Validated ${required.length} required files, ${packageLines.length} package entries across three profiles, and JSON/config invariants.`);
