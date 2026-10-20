# Design packs

LOKRO design packs are deliberately smaller and safer than arbitrary Plasma
extensions. They provide one declarative `design.json`, optional KDE color
schemes and ordinary wallpaper images. They may select a Plasma look-and-feel,
cursor theme or wallpaper plugin already installed by a trusted system package.

## Install and apply

Open **LOKRO Design Packs** from the application menu, or use:

```bash
lokro-design-pack validate /path/to/pack-folder
lokro-design-pack install /path/to/pack-folder
lokro-design-pack apply org.example.pack
lokro-design-pack list
```

A `.lokrodesign` file is a ZIP archive containing `design.json` at its root or
inside one top-level directory. The importer rejects absolute paths, `..`,
backslashes, links, executable bits, unknown payload locations, oversized files
and excessive file counts before extracting anything.

Installed packs live in
`~/.local/share/lokro/design-packs/ID`. Color files are copied to the user's
KDE color directory and wallpapers to a pack-specific user wallpaper directory.
No administrator password is requested and no system file is replaced.

Applying a pack updates only the fields present in its `plasma` object. A cursor
change can require a new login before every application sees it. The bundled
`org.lokro.monochrome` pack references the LOKRO components already installed by
`lokro-branding` and `lokro-shell`.

The built-in `org.lokro.glass` pack adds an original high-contrast black glass
color scheme and keeps the interactive Slashes wallpaper. `org.lokro.eclipse`
and `org.lokro.lunar` provide original dark and light halftone wallpapers.
`org.lokro.blood` adds an optional sharp black, white and signal-red color
scheme plus original project-owned PNG wallpaper artwork. It is never selected
automatically; `LOKRO Black` stays the fresh-install default.
All bundled packs can select the compiled `LokroMono` cursor supplied by the
trusted `lokro-branding` package. Plasma's trusted widget style still controls
button geometry; design-pack payloads deliberately contain no QML, cursor
binaries or executable theme code.

The built-in `org.lokro.chamfer` pack uses the optional, strictly enumerated
`lokro.settingsStyle` field to enable native 10/18/28-pixel chamfer surfaces in
LOKRO Settings. The same option can be toggled directly in that app and is
stored in `~/.config/lokro/settings.ini`. This is trusted application code,
not pack-supplied QML: downloaded packs may only choose `rounded` or `chamfer`.
The geometry reimplements the corner measurements supplied by Erik /
LOKROGAMER; no source or artwork from `lokro.dev` is copied.

The importer keeps a declared KDE color-scheme filename intact. This matters
because Plasma resolves schemes by basename; prefixing `LokroGlass.colors`
while requesting `LokroGlass` caused earlier packs to install but not apply.

## Repository packs

Reviewed built-in packs are stored under `design-packs/` in the source tree.
The package build stages that directory into `/usr/share/lokro/design-packs`.
The JSON Schema and contribution rules are shipped alongside the examples, so a
future app-store repository can reuse the same versioned format without giving
it package-manager or script execution privileges.
