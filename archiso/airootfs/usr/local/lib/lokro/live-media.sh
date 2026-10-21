#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Read-only discovery of the embedded Arch root. Ventoy and some firmware paths
# do not expose the ISO at Archiso's traditional /run/archiso/bootmnt path.

lokro_find_airootfs() {
    local run_root="${LOKRO_RUN_ROOT:-/run}"
    local candidate

    for candidate in \
        "$run_root/archiso/bootmnt/arch/x86_64/airootfs.sfs" \
        "$run_root/miso/bootmnt/arch/x86_64/airootfs.sfs" \
        "$run_root/ventoy/arch/x86_64/airootfs.sfs"; do
        if [[ -r "$candidate" ]]; then
            readlink -f -- "$candidate"
            return 0
        fi
    done

    # Search only existing runtime mounts. This never mounts, formats or writes
    # a block device and therefore also works with a Ventoy loop mount.
    candidate="$({
        find -L "$run_root" -maxdepth 9 -type f \
            -path '*/arch/x86_64/airootfs.sfs' -print -quit 2>/dev/null || true
    } | head -n 1)"
    if [[ -n "$candidate" && -r "$candidate" ]]; then
        readlink -f -- "$candidate"
        return 0
    fi

    return 1
}
