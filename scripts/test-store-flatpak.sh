#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
wrapper="$project_root/packages/lokro-store/rootfs/usr/bin/lokro-store-flatpak"
temporary="$(mktemp -d -t lokro-store-flatpak-test.XXXXXX)"
trap 'rm -rf "$temporary"' EXIT

fake_flatpak="$temporary/flatpak"
fake_internal="$temporary/internal"
descriptor="$temporary/flathub.flatpakrepo"
log="$temporary/calls.log"

printf '%s\n' '[Flatpak Repo]' 'Title=Flathub' > "$descriptor"

cat > "$fake_flatpak" <<'EOF'
#!/usr/bin/env bash
set -u
printf 'flatpak %s\n' "$*" >> "$LOKRO_TEST_LOG"
case "${1:-}" in
  remotes)
    [[ "${LOKRO_TEST_EXISTING_REMOTE:-0}" == 1 ]] && printf '%s\n' flathub
    ;;
  remote-ls)
    [[ "${LOKRO_TEST_REMOTE_LS_FAIL:-0}" == 0 ]]
    ;;
esac
EOF
cat > "$fake_internal" <<'EOF'
#!/usr/bin/env bash
printf 'internal %s\n' "$*" >> "$LOKRO_TEST_LOG"
EOF
chmod 0755 "$fake_flatpak" "$fake_internal"

run_wrapper() {
    LOKRO_TEST_LOG="$log" \
    LOKRO_FLATPAK_BIN="$fake_flatpak" \
    LOKRO_STORE_FLATPAK_INTERNAL="$fake_internal" \
    LOKRO_FLATHUB_DESCRIPTOR="$descriptor" \
    LOKRO_TEST_EXISTING_REMOTE="${1:-0}" \
    bash "$wrapper" install org.example.App stable
}

: > "$log"
run_wrapper 0
grep -Fq "flatpak remote-add --user --if-not-exists --from flathub $descriptor" "$log"
grep -Fq 'flatpak remote-ls --user --app flathub' "$log"
grep -Fq 'internal install org.example.App stable' "$log"

: > "$log"
run_wrapper 1
grep -Fq 'flatpak remote-modify --user --enable --url=https://dl.flathub.org/repo/ flathub' "$log"
grep -Fq 'internal install org.example.App stable' "$log"

: > "$log"
set +e
failure_output="$(
    LOKRO_TEST_LOG="$log" \
    LOKRO_FLATPAK_BIN="$fake_flatpak" \
    LOKRO_STORE_FLATPAK_INTERNAL="$fake_internal" \
    LOKRO_FLATHUB_DESCRIPTOR="$descriptor" \
    LOKRO_TEST_REMOTE_LS_FAIL=1 \
    bash "$wrapper" update org.example.App 2>&1
)"
failure_code=$?
set -e
[[ "$failure_code" == 2 ]]
grep -Fq 'Prüfe Internet, Datum und Uhrzeit' <<< "$failure_output"
if grep -Fq 'internal update' "$log"; then
    printf '%s\n' 'internal helper ran after failed Flathub verification' >&2
    exit 1
fi

printf '%s\n' 'LOKRO Store Flatpak repair/delegation tests passed.'
