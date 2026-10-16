#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
source "$(dirname "$0")/common.sh"
require_arch
need pacman

local_packages=(ckbcomp calamares-lokro lokro-branding lokro-shell lokro-installer-config lokro-ai-setup lokro-store)
mapfile -t candidates < <(
    cat "${PROJECT_ROOT}/archiso/packages/common.x86_64" \
        "${PROJECT_ROOT}/archiso/packages/offline.x86_64"
    printf '%s\n' \
        nvidia-open nvidia-utils lib32-nvidia-utils opencode \
        steam prismlauncher jre8-openjdk jre17-openjdk jre21-openjdk \
        gamemode lib32-gamemode gamescope mangohud lib32-mangohud \
        hyprland hyprlock waybar wofi kitty wl-clipboard grim slurp \
        xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
)

official=()
for package in "${candidates[@]}"; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    is_local=false
    for local_package in "${local_packages[@]}"; do
        [[ "$package" == "$local_package" ]] && is_local=true
    done
    $is_local || official+=("$package")
done

mapfile -t official < <(printf '%s\n' "${official[@]}" | sort -u)
mkdir -p "${BUILD_DIR}/repo-check-db/sync"
cp /etc/pacman.conf "${BUILD_DIR}/pacman-check.conf"
enable_multilib "${BUILD_DIR}/pacman-check.conf"
pacman --config "${BUILD_DIR}/pacman-check.conf" \
    --dbpath "${BUILD_DIR}/repo-check-db" --logfile /dev/null -Sy --noconfirm
pacman --config "${BUILD_DIR}/pacman-check.conf" \
    --dbpath "${BUILD_DIR}/repo-check-db" --logfile /dev/null \
    -Sp --print-format '%n %v' "${official[@]}" > /dev/null
log "resolved ${#official[@]} official Arch packages and their dependencies"
