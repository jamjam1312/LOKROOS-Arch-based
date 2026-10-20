SHELL := /usr/bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

.PHONY: help validate check-repos packages iso iso-offline iso-online vm-bios vm-uefi vm-online-bios vm-online-uefi smoke-bios smoke-uefi checksums clean

help:
	@printf '%s\n' 'Lokro OS build targets:' '  validate        Static checks' '  check-repos     Resolve official packages on Arch' '  packages        Build local packages' '  iso/offline     Build the complete offline image' '  iso-online      Build the smaller network installer' '  vm-bios/uefi    Boot the offline image' '  vm-online-*     Boot the online image' '  smoke-bios/uefi Verify Plasma startup over QEMU serial' '  checksums       Generate release metadata' '  clean           Remove generated build/out data'

validate:
	@node scripts/validate.mjs
	@node scripts/test-website-download.mjs
	@bash scripts/test-store-flatpak.sh
	@if command -v python3 >/dev/null 2>&1; then python3 scripts/validate_yaml.py; else echo 'python3 not installed; YAML validation skipped'; fi
	@if command -v python3 >/dev/null 2>&1; then python3 scripts/test-design-packs.py; else echo 'python3 not installed; design-pack tests skipped'; fi
	@if command -v makepkg >/dev/null 2>&1; then bash scripts/validate-pkgbuilds.sh; else echo 'makepkg not installed; PKGBUILD parse checks skipped'; fi
	@qml_linter="$$(command -v qmllint || command -v qmllint6 || true)"; if [[ -z "$$qml_linter" && -x /usr/lib/qt6/bin/qmllint ]]; then qml_linter=/usr/lib/qt6/bin/qmllint; fi; if [[ -n "$$qml_linter" ]]; then find packages -type f -name '*.qml' -print0 | xargs -0 -r "$$qml_linter"; else echo 'qmllint not installed; QML validation skipped'; fi
	@if command -v shellcheck >/dev/null 2>&1; then files="$$(grep -Ilr -E '^#!(/usr/bin/env (ba)?sh|/bin/(ba)?sh)' scripts packages archiso || true)"; if [[ -n "$$files" ]]; then shellcheck -x -e SC1091 $$files; fi; else echo 'shellcheck not installed; skipped'; fi
	@if command -v desktop-file-validate >/dev/null 2>&1; then find packages -type f -name '*.desktop' -print0 | xargs -0 -r -n1 desktop-file-validate; else echo 'desktop-file-validate not installed; skipped'; fi

check-repos:
	@bash scripts/check-repository-packages.sh

packages:
	@bash scripts/build-packages.sh

iso: iso-offline

iso-offline:
	@bash scripts/build-iso.sh offline

iso-online:
	@bash scripts/build-iso.sh online

vm-bios:
	@bash scripts/run-vm.sh bios

vm-uefi:
	@bash scripts/run-vm.sh uefi

vm-online-bios:
	@bash scripts/run-vm.sh bios online

vm-online-uefi:
	@bash scripts/run-vm.sh uefi online

smoke-bios:
	@bash scripts/smoke-boot.sh bios offline

smoke-uefi:
	@bash scripts/smoke-boot.sh uefi offline

checksums:
	@bash scripts/checksums.sh

clean:
	@bash scripts/clean.sh
