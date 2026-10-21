#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
resolver="$project_root/archiso/airootfs/usr/local/lib/lokro/live-media.sh"
temporary="$(mktemp -d -t lokro-live-media-test.XXXXXX)"
trap 'rm -rf "$temporary"' EXIT

# shellcheck source=../archiso/airootfs/usr/local/lib/lokro/live-media.sh
source "$resolver"

mkdir -p "$temporary/archiso/bootmnt/arch/x86_64"
: > "$temporary/archiso/bootmnt/arch/x86_64/airootfs.sfs"
result="$(LOKRO_RUN_ROOT="$temporary" lokro_find_airootfs)"
[[ "$result" == "$(readlink -f "$temporary/archiso/bootmnt/arch/x86_64/airootfs.sfs")" ]]

rm -rf "$temporary/archiso"
mkdir -p "$temporary/media/ventoy-loop/random/arch/x86_64"
: > "$temporary/media/ventoy-loop/random/arch/x86_64/airootfs.sfs"
result="$(LOKRO_RUN_ROOT="$temporary" lokro_find_airootfs)"
[[ "$result" == "$(readlink -f "$temporary/media/ventoy-loop/random/arch/x86_64/airootfs.sfs")" ]]

rm -rf "${temporary:?}/media"
if LOKRO_RUN_ROOT="$temporary" lokro_find_airootfs >/dev/null 2>&1; then
    printf '%s\n' 'resolver accepted a runtime tree without airootfs.sfs' >&2
    exit 1
fi

printf '%s\n' 'LOKRO live-media resolver tests passed.'
