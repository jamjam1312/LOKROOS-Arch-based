#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Black-box safety tests for the LOKRO design-pack importer."""

from __future__ import annotations

import json
import os
import runpy
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOOL = ROOT / "packages/lokro-shell/rootfs/usr/bin/lokro-design-pack"
EXAMPLE = ROOT / "design-packs/org.lokro.monochrome"
GLASS = ROOT / "design-packs/org.lokro.glass"
ECLIPSE = ROOT / "design-packs/org.lokro.eclipse"
LUNAR = ROOT / "design-packs/org.lokro.lunar"
CHAMFER = ROOT / "design-packs/org.lokro.chamfer"
BLOOD = ROOT / "design-packs/org.lokro.blood"


def run(arguments: list[str], environment: dict[str, str], expected: int = 0) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        [sys.executable, str(TOOL), *arguments],
        cwd=ROOT,
        env=environment,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != expected:
        raise RuntimeError(
            f"command returned {result.returncode}, expected {expected}: {arguments}\n"
            f"stdout: {result.stdout}\nstderr: {result.stderr}"
        )
    return result


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="lokro-design-pack-test-") as temporary_name:
        temporary = Path(temporary_name)
        environment = os.environ.copy()
        environment["HOME"] = str(temporary / "home")
        environment["XDG_DATA_HOME"] = str(temporary / "data")
        environment["XDG_CONFIG_HOME"] = str(temporary / "config")
        environment["LOKRO_SYSTEM_DESIGN_PACKS"] = str(ROOT / "design-packs")

        run(["validate", str(EXAMPLE)], environment)
        run(["install", str(EXAMPLE)], environment)
        run(["validate", str(GLASS)], environment)
        run(["install", str(GLASS)], environment)
        run(["validate", str(ECLIPSE)], environment)
        run(["validate", str(LUNAR)], environment)
        run(["validate", str(CHAMFER)], environment)
        run(["validate", str(BLOOD)], environment)
        run(["install", str(BLOOD)], environment)
        previous_config_home = os.environ.get("XDG_CONFIG_HOME")
        os.environ["XDG_CONFIG_HOME"] = environment["XDG_CONFIG_HOME"]
        try:
            tool_namespace = runpy.run_path(str(TOOL))
            chamfer_manifest = json.loads((CHAMFER / "design.json").read_text(encoding="utf-8"))
            tool_namespace["apply_lokro_style"](chamfer_manifest)
        finally:
            if previous_config_home is None:
                os.environ.pop("XDG_CONFIG_HOME", None)
            else:
                os.environ["XDG_CONFIG_HOME"] = previous_config_home
        style_settings = temporary / "config" / "lokro" / "settings.ini"
        if "chamferEnabled=true" not in style_settings.read_text(encoding="utf-8"):
            raise RuntimeError("chamfer pack did not persist the trusted LOKRO style switch")
        installed_glass = temporary / "data" / "color-schemes" / "LokroGlass.colors"
        if not installed_glass.is_file():
            raise RuntimeError("glass pack did not stage its KDE color scheme under the declared basename")
        installed_blood_wallpaper = temporary / "data" / "wallpapers" / "org.lokro.blood" / "lokro-blood.png"
        installed_blood_colors = temporary / "data" / "color-schemes" / "LokroBlood.colors"
        if not installed_blood_wallpaper.is_file() or not installed_blood_colors.is_file():
            raise RuntimeError("blood pack did not stage its wallpaper and KDE color scheme")
        listed = json.loads(run(["list", "--json"], environment).stdout)
        matching = [pack for pack in listed if pack["id"] == "org.lokro.monochrome"]
        if len(matching) != 1 or matching[0]["origin"] != "user":
            raise RuntimeError(f"user-installed pack did not override the system copy: {listed}")

        invalid = temporary / "org.example.invalid"
        shutil.copytree(EXAMPLE, invalid)
        manifest = json.loads((invalid / "design.json").read_text(encoding="utf-8"))
        manifest["id"] = "org.example.invalid"
        (invalid / "design.json").write_text(json.dumps(manifest), encoding="utf-8")
        (invalid / "payload").mkdir()
        (invalid / "payload" / "run.sh").write_text("#!/bin/sh\n", encoding="utf-8")
        rejected = run(["validate", str(invalid)], environment, expected=2)
        if "unsupported file location" not in rejected.stderr:
            raise RuntimeError("an unknown executable payload was not rejected for the expected reason")

        traversal = temporary / "traversal.lokrodesign"
        with zipfile.ZipFile(traversal, "w") as archive:
            archive.writestr("../outside.txt", "not allowed")
            archive.writestr("design.json", "{}")
        rejected = run(["validate", str(traversal)], environment, expected=2)
        if "unsafe path" not in rejected.stderr:
            raise RuntimeError("archive path traversal was not rejected")
        if (temporary / "outside.txt").exists():
            raise RuntimeError("archive path traversal wrote outside its extraction directory")

    print("LOKRO design-pack validation, install, override and traversal tests passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
