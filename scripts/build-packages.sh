#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
source "$(dirname "$0")/common.sh"
require_arch
need makepkg
need repo-add

mkdir -p "${BUILD_DIR}/pkg" "${LOCAL_REPO_DIR}"

build_one() {
    local source_dir="$1"
    local work_dir
    work_dir="${BUILD_DIR}/pkg/$(basename "$source_dir")"
    rm -rf "$work_dir"
    cp -a "$source_dir" "$work_dir"
    if [[ "$(basename "$source_dir")" == lokro-shell ]]; then
        mkdir -p "$work_dir/rootfs/usr/share/lokro/design-packs"
        cp -a "${PROJECT_ROOT}/design-packs/." "$work_dir/rootfs/usr/share/lokro/design-packs/"
    fi
    if (( EUID == 0 )); then
        local build_user=lokro-builder
        id "$build_user" >/dev/null 2>&1 || useradd --system --create-home "$build_user"
        chown -R "$build_user":"$build_user" "$work_dir"
        local sudoers_file=/etc/sudoers.d/lokro-builder-makepkg
        printf '%s ALL=(root) NOPASSWD: /usr/bin/pacman\n' "$build_user" > "$sudoers_file"
        chmod 0440 "$sudoers_file"
        trap 'rm -f /etc/sudoers.d/lokro-builder-makepkg' RETURN
        if ! runuser -u "$build_user" -- bash -lc "cd '$work_dir' && makepkg --syncdeps --noconfirm --cleanbuild --clean"; then
            return 1
        fi
        rm -f "$sudoers_file"
        trap - RETURN
    else
        (cd "$work_dir" && makepkg --syncdeps --noconfirm --cleanbuild --clean)
    fi
    find "$work_dir" -maxdepth 1 -type f -name '*.pkg.tar.zst' -exec cp -f {} "${LOCAL_REPO_DIR}/" \;
}

install_local_build_dependency() {
    local package_glob="$1"
    local packages=()
    mapfile -t packages < <(find "${LOCAL_REPO_DIR}" -maxdepth 1 -type f -name "$package_glob" -print)
    if (( ${#packages[@]} != 1 )); then
        printf 'Expected exactly one local package matching %s, found %s\n' "$package_glob" "${#packages[@]}" >&2
        return 1
    fi
    if (( EUID == 0 )); then
        pacman -U --needed --noconfirm "${packages[0]}"
    else
        need sudo
        sudo pacman -U --needed --noconfirm "${packages[0]}"
    fi
}

log 'building pinned ckbcomp dependency'
build_one "${PROJECT_ROOT}/vendor/ckbcomp"
install_local_build_dependency 'ckbcomp-*.pkg.tar.zst'

log 'building pinned Calamares package'
build_one "${PROJECT_ROOT}/vendor/calamares"
install_local_build_dependency 'calamares-lokro-[0-9]*-x86_64.pkg.tar.zst'

for package in lokro-branding lokro-shell lokro-installer-config lokro-ai-setup lokro-store; do
    log "building ${package}"
    build_one "${PROJECT_ROOT}/packages/${package}"
done

rm -f "${LOCAL_REPO_DIR}/lokro.db" "${LOCAL_REPO_DIR}/lokro.db.tar.zst" \
      "${LOCAL_REPO_DIR}/lokro.files" "${LOCAL_REPO_DIR}/lokro.files.tar.zst"
repo-add "${LOCAL_REPO_DIR}/lokro.db.tar.zst" "${LOCAL_REPO_DIR}"/*.pkg.tar.zst
log "local repository ready at ${LOCAL_REPO_DIR}"
