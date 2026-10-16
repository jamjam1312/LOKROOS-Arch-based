#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Black-box safety tests for the LOKRO design-pack importer."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOOL = ROOT / "packages/lokro-shell/rootfs/usr/bin/lokro-design-pack"
EXAMPLE = ROOT / "design-packs/org.lokro.monochrome"


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
        environment["LOKRO_SYSTEM_DESIGN_PACKS"] = str(ROOT / "design-packs")

        run(["validate", str(EXAMPLE)], environment)
        run(["install", str(EXAMPLE)], environment)
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
