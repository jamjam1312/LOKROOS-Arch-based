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
  list)
    [[ "${LOKRO_TEST_INSTALLED_FROM_FLATHUB:-0}" == 1 ]] && printf '%s\n' flathub
    ;;
  info)
    [[ "${LOKRO_TEST_APP_INSTALLED:-0}" == 1 ]]
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
    bash "$wrapper" install org.example.App
}

: > "$log"
run_wrapper 0
grep -Fq "flatpak remote-add --user --if-not-exists --from flathub $descriptor" "$log"
grep -Fq 'flatpak remote-ls --user --app flathub' "$log"
grep -Fq 'flatpak install --user --noninteractive flathub org.example.App' "$log"
if grep -Fq 'internal install' "$log"; then
    printf '%s\n' 'normal Flathub install unexpectedly delegated to the bundle helper' >&2
    exit 1
fi

: > "$log"
run_wrapper 1
grep -Fq 'flatpak remote-modify --user --enable --url=https://dl.flathub.org/repo/ flathub' "$log"
grep -Fq 'flatpak install --user --noninteractive flathub org.example.App' "$log"

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
if grep -Fq 'flatpak update --user --noninteractive org.example.App' "$log"; then
    printf '%s\n' 'Flatpak update ran after failed Flathub verification' >&2
    exit 1
fi

: > "$log"
LOKRO_TEST_LOG="$log" \
LOKRO_FLATPAK_BIN="$fake_flatpak" \
LOKRO_STORE_FLATPAK_INTERNAL="$fake_internal" \
LOKRO_FLATHUB_DESCRIPTOR="$descriptor" \
LOKRO_TEST_EXISTING_REMOTE=1 \
bash "$wrapper" install-bundle org.example.App https://example.invalid/app.flatpak \
    0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
grep -Fq 'internal install-bundle org.example.App' "$log"

printf '%s\n' 'LOKRO Store Flatpak repair/delegation tests passed.'
