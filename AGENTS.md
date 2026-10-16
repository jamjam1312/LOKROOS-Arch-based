# Repository instructions

Read `AI_INFO.md` before changing build, installer, boot, update or packaging
code. Keep `docs/RELEASE_STATUS.md` factual: distinguish source implementation,
CI/VM verification and real-hardware testing.

Use `make validate` before proposing a change. Package and ISO builds run only
on Arch Linux or in the privileged GitHub Actions Arch container. Never run
partitioning, firmware, bootloader or destructive disk tests on a contributor's
workstation.

Pin every non-Arch source by immutable version and SHA-256 in its PKGBUILD and
record it in `third_party/sources.json`. Do not add AUR helpers, shell-piped
downloads, unattended release installation or unknown catalog commands.

The root `LOKRO_UPDATE_CHANNEL.json` and the packaged copy under
`packages/lokro-shell/rootfs/usr/share/lokro/` must remain byte-identical.
Generated ISOs and build output belong in `out/` and GitHub Releases, never in
Git history.
