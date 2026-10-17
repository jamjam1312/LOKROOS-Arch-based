#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
source "$(dirname "$0")/common.sh"

firmware="${1:-bios}"
variant="${2:-offline}"
[[ "$firmware" == bios || "$firmware" == uefi ]] || die 'firmware must be bios or uefi'
[[ "$variant" == offline || "$variant" == online ]] || die 'variant must be offline or online'
need qemu-system-x86_64
need timeout

iso="$(find "$OUT_DIR" -maxdepth 1 -type f -name "lokro-os-${variant}-*.iso" -printf '%T@ %p\n' | sort -nr | sed -n '1s/^[^ ]* //p')"
[[ -n "$iso" && -f "$iso" ]] || die "no ${variant} ISO found in out/"

tmp_dir="$(mktemp -d "${BUILD_DIR}/smoke-${firmware}-XXXXXX")"
serial_log="$tmp_dir/serial.log"
acceleration='tcg,thread=multi'
if [[ -c /dev/kvm && -r /dev/kvm && -w /dev/kvm ]]; then
    acceleration='kvm'
fi
qemu_args=(
    -machine q35
    -accel "$acceleration"
    -m 4096
    -smp 2
    -device virtio-vga
    -display none
    -serial "file:${serial_log}"
    -boot d
    -cdrom "$iso"
    -no-reboot
)

if [[ "$firmware" == uefi ]]; then
    code=''
    vars=''
    for candidate in /usr/share/edk2/x64/OVMF_CODE.4m.fd /usr/share/edk2-ovmf/x64/OVMF_CODE.fd /usr/share/OVMF/OVMF_CODE.fd; do
        [[ -f "$candidate" ]] && code="$candidate" && break
    done
    for candidate in /usr/share/edk2/x64/OVMF_VARS.4m.fd /usr/share/edk2-ovmf/x64/OVMF_VARS.fd /usr/share/OVMF/OVMF_VARS.fd; do
        [[ -f "$candidate" ]] && vars="$candidate" && break
    done
    [[ -n "$code" && -n "$vars" ]] || die 'OVMF firmware files were not found'
    cp "$vars" "$tmp_dir/OVMF_VARS.fd"
    qemu_args+=(
        -drive "if=pflash,format=raw,readonly=on,file=${code}"
        -drive "if=pflash,format=raw,file=${tmp_dir}/OVMF_VARS.fd"
    )
fi

log "waiting for Plasma and installer startup marker (${firmware}, ${variant}, acceleration=${acceleration})"
timeout 900s qemu-system-x86_64 "${qemu_args[@]}" &
qemu_pid=$!
trap 'kill "$qemu_pid" 2>/dev/null || true; wait "$qemu_pid" 2>/dev/null || true' EXIT

for ((attempt = 0; attempt < 900; attempt++)); do
    if [[ -f "$serial_log" ]] && grep -q 'LOKRO_LIVE_READY' "$serial_log"; then
        log "Plasma live session and Calamares installer reached for ${firmware}"
        exit 0
    fi
    if [[ -f "$serial_log" ]] && grep -q 'LOKRO_SMOKE_FAILED' "$serial_log"; then
        tail -n 120 "$serial_log" 2>/dev/null || true
        die "live-session smoke watcher reported failure for ${firmware}"
    fi
    kill -0 "$qemu_pid" 2>/dev/null || break
    sleep 1
done

tail -n 120 "$serial_log" 2>/dev/null || true
die "Plasma/installer readiness marker was not observed for ${firmware}"
