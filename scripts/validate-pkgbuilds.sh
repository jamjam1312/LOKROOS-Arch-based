#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

recipes=(
    vendor/ckbcomp
    vendor/calamares
    packages/lokro-branding
    packages/lokro-shell
    packages/lokro-installer-config
    packages/lokro-ai-setup
    packages/lokro-store
)

validation_root=''
if (( EUID == 0 )); then
    validation_root="$(mktemp -d /tmp/lokro-pkgbuild-validation.XXXXXX)"
    chmod 0755 "$validation_root"
    trap 'rm -rf -- "${validation_root:?}"' EXIT
fi

for recipe in "${recipes[@]}"; do
    if (( EUID == 0 )); then
        copy="${validation_root}/$(basename "$recipe")"
        cp -a "$recipe" "$copy"
        chown -R nobody:nobody "$copy"
        (
            cd "$copy"
            runuser -u nobody -- env HOME=/tmp makepkg --printsrcinfo >/dev/null
        )
    else
        (cd "$recipe" && makepkg --printsrcinfo >/dev/null)
    fi
done
