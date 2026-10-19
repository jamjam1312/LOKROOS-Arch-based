# LOKRO OS website

This directory is the static GitHub Pages source for the LOKRO OS landing page.
It is intentionally separate from `archiso/`, `packages/` and every ISO build
input. The ISO workflows do not copy this directory.

The site is buildless HTML, CSS and JavaScript. It uses no third-party runtime
dependency, font CDN, tracking script or cookie. Release buttons resolve the
newest non-draft GitHub release in the browser and retain Alpha 23 as an offline
fallback.

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
