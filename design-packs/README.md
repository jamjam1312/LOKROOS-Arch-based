# LOKRO design packs

Each subdirectory is one reviewable, declarative LOKRO design pack. A pack can
select installed Plasma components and can ship color-scheme (`.colors`) and
wallpaper image assets. It cannot contain scripts, executables, QML, shared
libraries or package-manager instructions.

To contribute a pack:

1. Copy `org.lokro.monochrome` to a new reverse-DNS identifier directory.
2. Edit `design.json` and keep `schemaVersion` at `1`.
3. Add optional assets below `payload/color-schemes/` or
   `payload/wallpapers/` only.
4. Validate it with `lokro-design-pack validate design-packs/YOUR_ID` on LOKRO
   OS, or let `make validate` check every repository pack.
5. Submit the folder for review with the asset license and author recorded in
   `design.json`.

Users can install a reviewed folder or a ZIP-compatible `.lokrodesign` archive
through **LOKRO Design Packs**. Installation is user-scoped under
`~/.local/share`; it never invokes Pacman, Flatpak, `sudo`, or `pkexec`.

The normative manifest shape is in `design-pack.schema.json`. The runtime
installer also enforces path, file-count, size, symlink and executable-file
limits instead of trusting the extension.
