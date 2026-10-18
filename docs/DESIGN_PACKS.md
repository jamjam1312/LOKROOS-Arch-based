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
color scheme and keeps the interactive Slashes wallpaper. Plasma's trusted
widget style still controls button geometry; the pack deliberately contains no
QML or executable theme code.

## Repository packs

Reviewed built-in packs are stored under `design-packs/` in the source tree.
The package build stages that directory into `/usr/share/lokro/design-packs`.
The JSON Schema and contribution rules are shipped alongside the examples, so a
future app-store repository can reuse the same versioned format without giving
it package-manager or script execution privileges.
