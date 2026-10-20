# LOKRO OS website

This directory is the static GitHub Pages source for the LOKRO OS landing page.
It is intentionally separate from `archiso/`, `packages/` and every ISO build
input. The ISO workflows do not copy this directory.

The site is buildless HTML, CSS and JavaScript. It uses no third-party runtime
dependency, font CDN, tracking script or cookie. Release buttons resolve the
newest non-draft GitHub release in the browser and retain Alpha 24 as a pinned
fallback.

The workbench exposes the numbered release assets as direct links on the site.
On Chromium-based browsers in a secure context, users can select both downloaded
parts and stream them locally into a user-selected ISO file. It computes
incremental SHA-256 for every part and the complete image without buffering the
multi-gigabyte ISO in memory or uploading it. This two-step flow avoids relying
on CORS support from GitHub's release-asset host. Firefox, Safari and
command-line users receive the same direct links plus generated Windows, Linux
and macOS scripts. Failed or aborted writes are never presented as completed.

## Local preview

Serve this directory with any static web server and open `/index.html`. Do not
open the file directly when testing the GitHub Releases API because browser
security behavior differs for `file:` URLs.

The interactive signal field honors `prefers-reduced-motion` and pauses when
the document is hidden.

## GitHub Pages

`.github/workflows/pages.yml` deploys this directory independently from the ISO
build. The intended custom domain is `os.lokro.dev`; `website/CNAME` declares
it for GitHub Pages. DNS must point `os.lokro.dev` to `jamjam1312.github.io`.

`impressum.html` and `datenschutz.html` are linked from every website footer.
The imprint intentionally refuses to publish a school address and visibly marks
the still-missing legal name and service address of the responsible provider.
Those two placeholders must be replaced with verified details before anyone
claims that the imprint is legally complete.
