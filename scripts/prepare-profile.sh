#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
source "$(dirname "$0")/common.sh"
require_arch
(( EUID == 0 )) || die 'profile preparation must run as root'
need rsync
need pacman
need repo-add
need curl
need sha256sum

variant="${1:-offline}"
[[ "$variant" == offline || "$variant" == online ]] || die 'variant must be offline or online'

[[ -d /usr/share/archiso/configs/releng ]] || die 'archiso releng profile is missing'
[[ -f "${LOCAL_REPO_DIR}/lokro.db.tar.zst" ]] || die 'run make packages first'
[[ -f /etc/pacman.d/mirrorlist ]] || die 'Arch mirrorlist is missing'

PROFILE_DIR="${BUILD_DIR}/profile-${variant}"
rm -rf "$PROFILE_DIR"
mkdir -p "$PROFILE_DIR"
cp -a /usr/share/archiso/configs/releng/. "$PROFILE_DIR/"
rsync -a "${PROJECT_ROOT}/archiso/airootfs/" "$PROFILE_DIR/airootfs/"

# Preserve the normal local console while exposing kernel/systemd progress to
# QEMU's serial log. This also makes real-hardware boot failures diagnosable.
boot_config_count=0
while IFS= read -r -d '' boot_config; do
    sed -i -E \
        '/^[[:space:]]*(APPEND|options)[[:space:]]/ { /console=ttyS0/! s|$| console=tty0 console=ttyS0,115200n8 systemd.show_status=yes systemd.log_target=console|; }' \
        "$boot_config"
    boot_config_count=$((boot_config_count + 1))
done < <(find "$PROFILE_DIR/syslinux" "$PROFILE_DIR/efiboot" "$PROFILE_DIR/grub" \
    -type f \( -name '*.cfg' -o -name '*.conf' \) -print0 2>/dev/null)
(( boot_config_count > 0 )) || die 'no Archiso bootloader configurations were found'
mkdir -p "$PROFILE_DIR/airootfs/usr/share/lokro"
curl --fail --location --silent --show-error \
    --output "$PROFILE_DIR/airootfs/usr/share/lokro/flathub.flatpakrepo" \
    'https://dl.flathub.org/repo/flathub.flatpakrepo'
printf '%s  %s\n' \
    '3371dd250e61d9e1633630073fefda153cd4426f72f4afa0c3373ae2e8fea03a' \
    "$PROFILE_DIR/airootfs/usr/share/lokro/flathub.flatpakrepo" | sha256sum --check --status
chmod 0755 "$PROFILE_DIR/airootfs/usr/local/sbin/lokro-create-live-user"
chmod 0755 "$PROFILE_DIR/airootfs/usr/local/sbin/lokro-smoke-ready"
chmod 0755 "$PROFILE_DIR/airootfs/usr/local/sbin/lokro-live-installer-supervisor"
chmod 0755 "$PROFILE_DIR/airootfs/usr/local/bin/lokro-live-installer"
chmod 0440 "$PROFILE_DIR/airootfs/etc/sudoers.d/10-liveuser"
chmod 0644 "$PROFILE_DIR/airootfs/etc/systemd/system/lokro-live-installer-supervisor.service"
mkdir -p "$PROFILE_DIR/airootfs/etc/lokro" "$PROFILE_DIR/airootfs/etc/calamares/modules"
printf '%s\n' "$variant" > "$PROFILE_DIR/airootfs/etc/lokro/build-variant"
cp "${PROJECT_ROOT}/packages/lokro-installer-config/rootfs/etc/calamares/modules/packages-${variant}.conf" \
    "$PROFILE_DIR/airootfs/etc/calamares/modules/packages.conf"
cp "${PROJECT_ROOT}/packages/lokro-installer-config/rootfs/etc/calamares/modules/packagechooser-apps-${variant}.conf" \
    "$PROFILE_DIR/airootfs/etc/calamares/modules/packagechooser-apps.conf"
sed -i \
    -e "s/^iso_name=.*/iso_name=\"lokro-os-${variant}\"/" \
    -e "s/^iso_version=.*/iso_version=\"${VERSION}\"/" \
    -e "s/^iso_label=.*/iso_label=\"LOKRO_${variant^^}\"/" \
    -e 's/^iso_publisher=.*/iso_publisher="LOKRO Network <https:\/\/www.twitch.tv\/lokrogamer>"/' \
    -e "s/^iso_application=.*/iso_application=\"Lokro OS ${variant^} Live\\/Install Media\"/" \
    "$PROFILE_DIR/profiledef.sh"
if grep -q '^airootfs_image_tool_options=' "$PROFILE_DIR/profiledef.sh"; then
    sed -i "s/^airootfs_image_tool_options=.*/airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')/" \
        "$PROFILE_DIR/profiledef.sh"
else
    printf '%s\n' "airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')" \
        >> "$PROFILE_DIR/profiledef.sh"
fi

cat "${PROJECT_ROOT}/archiso/packages/common.x86_64" \
    "${PROJECT_ROOT}/archiso/packages/${variant}.x86_64" >> "$PROFILE_DIR/packages.x86_64"
sort -u -o "$PROFILE_DIR/packages.x86_64" "$PROFILE_DIR/packages.x86_64"

cp /etc/pacman.conf "$PROFILE_DIR/pacman.conf"
enable_multilib "$PROFILE_DIR/pacman.conf"
cat >> "$PROFILE_DIR/pacman.conf" <<EOF

[lokro]
SigLevel = Optional TrustAll
Server = file://${LOCAL_REPO_DIR}
EOF

log 'resolving the complete ISO package set'
PACKAGE_DB_DIR="${BUILD_DIR}/package-check-db"
rm -rf "$PACKAGE_DB_DIR"
mkdir -p "$PACKAGE_DB_DIR/sync"
pacman --config "$PROFILE_DIR/pacman.conf" --dbpath "$PACKAGE_DB_DIR" \
    --logfile /dev/null --noconfirm -Sy
mapfile -t iso_packages < <(grep -Ev '^\s*(#|$)' "$PROFILE_DIR/packages.x86_64")
pacman --config "$PROFILE_DIR/pacman.conf" --dbpath "$PACKAGE_DB_DIR" \
    --logfile /dev/null --noconfirm -Sp --print-format '%n %v' "${iso_packages[@]}" \
    > "${OUT_DIR}/resolved-packages-${variant}.txt"

mkdir -p "$PROFILE_DIR/airootfs/etc/pacman.d"
cp /etc/pacman.conf "$PROFILE_DIR/airootfs/etc/pacman.conf"
cp -L /etc/pacman.d/mirrorlist "$PROFILE_DIR/airootfs/etc/pacman.d/mirrorlist"
enable_multilib "$PROFILE_DIR/airootfs/etc/pacman.conf"
if [[ "$variant" == offline ]]; then
    mkdir -p "$PROFILE_DIR/airootfs/opt/lokro/repo"
    cat >> "$PROFILE_DIR/airootfs/etc/pacman.conf" <<'EOF'

# Removed from the installed target by Calamares.
[lokro-media]
SigLevel = Optional TrustAll
Server = file:///opt/lokro/repo
EOF

    log 'downloading offline NVIDIA, gaming and optional tiling-session packages with dependencies'
    pacman --config "$PROFILE_DIR/pacman.conf" --dbpath "$PACKAGE_DB_DIR" \
        --logfile /dev/null -Syw --noconfirm \
        --cachedir "$PROFILE_DIR/airootfs/opt/lokro/repo" \
        nvidia-open nvidia-utils lib32-nvidia-utils \
        steam prismlauncher jre8-openjdk jre17-openjdk jre21-openjdk \
        gamemode lib32-gamemode gamescope mangohud lib32-mangohud \
        hyprland hyprlock waybar wofi kitty wl-clipboard grim slurp \
        xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
        vulkan-radeon lib32-vulkan-radeon vulkan-intel lib32-vulkan-intel \
        vulkan-nouveau lib32-vulkan-nouveau

    # pacman resolves the optional bundle against a clean database, so its
    # cache also contains dependencies that are already installed in the live
    # root. Keeping those archives would duplicate identical package payloads
    # inside the SquashFS. The installed target satisfies these dependencies;
    # retain only packages that are not part of the embedded base transaction.
    declare -A embedded_packages=()
    while read -r embedded_name _; do
        [[ -n "$embedded_name" ]] && embedded_packages["$embedded_name"]=1
    done < "${OUT_DIR}/resolved-packages-${variant}.txt"
    shopt -s nullglob
    for cached_package in "$PROFILE_DIR/airootfs/opt/lokro/repo"/*.pkg.tar.zst; do
        cached_name="$(pacman -Qp "$cached_package" | awk 'NR == 1 { print $1 }')"
        if [[ -n "${embedded_packages[$cached_name]+present}" ]]; then
            rm -f "$cached_package" "${cached_package}.sig"
        fi
    done
    offline_packages=("$PROFILE_DIR/airootfs/opt/lokro/repo"/*.pkg.tar.zst)
    shopt -u nullglob
    (( ${#offline_packages[@]} > 0 )) || die 'offline optional-package repository is empty'
    repo-add "$PROFILE_DIR/airootfs/opt/lokro/repo/lokro-media.db.tar.zst" \
        "${offline_packages[@]}"
    mkdir -p "$PROFILE_DIR/airootfs/var/lib/pacman/sync"
    cp "$PROFILE_DIR/airootfs/opt/lokro/repo/lokro-media.db.tar.zst" \
        "$PROFILE_DIR/airootfs/var/lib/pacman/sync/lokro-media.db"
fi

mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants"
ln -sfn /etc/systemd/system/lokro-live-user.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/lokro-live-user.service"
ln -sfn /usr/lib/systemd/system/NetworkManager.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"
ln -sfn /usr/lib/systemd/system/sddm.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/display-manager.service"
ln -sfn /etc/systemd/system/lokro-smoke-ready.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/lokro-smoke-ready.service"
ln -sfn /etc/systemd/system/lokro-live-installer-supervisor.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/lokro-live-installer-supervisor.service"
ln -sfn /usr/lib/systemd/system/lokro-services-merge.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/lokro-services-merge.service"
ln -sfn /usr/lib/systemd/system/lokro-services-merge.path \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/lokro-services-merge.path"
ln -sfn /usr/lib/systemd/system/lokro-flatpak-setup.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/lokro-flatpak-setup.service"
ln -sfn /usr/lib/systemd/system/systemd-oomd.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/systemd-oomd.service"
ln -sfn /usr/lib/systemd/system/power-profiles-daemon.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/power-profiles-daemon.service"
ln -sfn /usr/lib/systemd/system/bluetooth.service \
    "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/bluetooth.service"

log "prepared ${variant} profile at ${PROFILE_DIR}"
