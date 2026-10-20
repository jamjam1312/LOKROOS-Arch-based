// SPDX-License-Identifier: GPL-3.0-or-later

const SHA256_INITIAL = new Uint32Array([
  0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
  0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
]);

const SHA256_K = new Uint32Array([
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
]);

const rotateRight = (value, count) => (value >>> count) | (value << (32 - count));

function asBytes(input) {
  if (typeof input === 'string') return new TextEncoder().encode(input);
  if (input instanceof Uint8Array) return input;
  if (input instanceof ArrayBuffer) return new Uint8Array(input);
  if (ArrayBuffer.isView(input)) return new Uint8Array(input.buffer, input.byteOffset, input.byteLength);
  throw new TypeError('SHA-256 input must be a string, ArrayBuffer or typed array');
}

export class Sha256 {
  constructor() {
    this.state = new Uint32Array(SHA256_INITIAL);
    this.buffer = new Uint8Array(64);
    this.words = new Uint32Array(64);
    this.bufferLength = 0;
    this.bytesHashed = 0;
    this.finished = false;
  }

  update(input) {
    if (this.finished) throw new Error('SHA-256 digest is already finalized');
    const bytes = asBytes(input);
    this.bytesHashed += bytes.byteLength;
    let offset = 0;

    if (this.bufferLength) {
      const available = 64 - this.bufferLength;
      const count = Math.min(available, bytes.byteLength);
      this.buffer.set(bytes.subarray(0, count), this.bufferLength);
      this.bufferLength += count;
      offset += count;
      if (this.bufferLength === 64) {
        this.processBlock(this.buffer, 0);
        this.bufferLength = 0;
      }
    }

    while (offset + 64 <= bytes.byteLength) {
      this.processBlock(bytes, offset);
      offset += 64;
    }

    if (offset < bytes.byteLength) {
      this.buffer.set(bytes.subarray(offset), 0);
      this.bufferLength = bytes.byteLength - offset;
    }
    return this;
  }

  processBlock(bytes, offset) {
    const words = this.words;
    for (let index = 0; index < 16; index += 1) {
      const start = offset + index * 4;
      words[index] = (
        (bytes[start] << 24) |
        (bytes[start + 1] << 16) |
        (bytes[start + 2] << 8) |
        bytes[start + 3]
      ) >>> 0;
    }
    for (let index = 16; index < 64; index += 1) {
      const previous = words[index - 15];
      const recent = words[index - 2];
      const sigma0 = rotateRight(previous, 7) ^ rotateRight(previous, 18) ^ (previous >>> 3);
      const sigma1 = rotateRight(recent, 17) ^ rotateRight(recent, 19) ^ (recent >>> 10);
      words[index] = (words[index - 16] + sigma0 + words[index - 7] + sigma1) >>> 0;
    }

    let [a, b, c, d, e, f, g, h] = this.state;
    for (let index = 0; index < 64; index += 1) {
      const sum1 = rotateRight(e, 6) ^ rotateRight(e, 11) ^ rotateRight(e, 25);
      const choice = (e & f) ^ (~e & g);
      const temp1 = (h + sum1 + choice + SHA256_K[index] + words[index]) >>> 0;
      const sum0 = rotateRight(a, 2) ^ rotateRight(a, 13) ^ rotateRight(a, 22);
      const majority = (a & b) ^ (a & c) ^ (b & c);
      const temp2 = (sum0 + majority) >>> 0;
      h = g;
      g = f;
      f = e;
      e = (d + temp1) >>> 0;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) >>> 0;
    }

    this.state[0] = (this.state[0] + a) >>> 0;
    this.state[1] = (this.state[1] + b) >>> 0;
    this.state[2] = (this.state[2] + c) >>> 0;
    this.state[3] = (this.state[3] + d) >>> 0;
    this.state[4] = (this.state[4] + e) >>> 0;
    this.state[5] = (this.state[5] + f) >>> 0;
    this.state[6] = (this.state[6] + g) >>> 0;
    this.state[7] = (this.state[7] + h) >>> 0;
  }

  digestHex() {
    if (this.finished) throw new Error('SHA-256 digest is already finalized');
    const totalBytes = this.bytesHashed;
    let position = this.bufferLength;
    this.buffer[position] = 0x80;
    position += 1;

    if (position > 56) {
      this.buffer.fill(0, position, 64);
      this.processBlock(this.buffer, 0);
      position = 0;
    }
    this.buffer.fill(0, position, 56);

    const high = Math.floor(totalBytes / 0x20000000) >>> 0;
    const low = (totalBytes * 8) >>> 0;
    this.buffer[56] = high >>> 24;
    this.buffer[57] = high >>> 16;
    this.buffer[58] = high >>> 8;
    this.buffer[59] = high;
    this.buffer[60] = low >>> 24;
    this.buffer[61] = low >>> 16;
    this.buffer[62] = low >>> 8;
    this.buffer[63] = low;
    this.processBlock(this.buffer, 0);
    this.finished = true;

    return [...this.state].map((word) => word.toString(16).padStart(8, '0')).join('');
  }
}

export function parseChecksums(text) {
  const checksums = new Map();
  for (const line of text.split(/\r?\n/)) {
    const match = line.trim().match(/^([a-fA-F0-9]{64})\s+\*?(.+)$/);
    if (!match) continue;
    const filename = match[2].replaceAll('\\', '/').split('/').pop();
    checksums.set(filename, match[1].toLowerCase());
  }
  return checksums;
}

export function buildVariant(release, variant, partChecksums, isoChecksums) {
  if (!['offline', 'online'].includes(variant)) throw new Error(`Unknown ISO variant: ${variant}`);
  const expression = new RegExp(`^lokro-os-${variant}-.+-x86_64\\.iso\\.\\d{3}$`);
  const parts = release.assets
    .filter((asset) => expression.test(asset.name))
    .sort((left, right) => left.name.localeCompare(right.name, 'en'));
  if (!parts.length) throw new Error(`No ${variant} ISO parts found in ${release.tag_name}`);

  const isoName = parts[0].name.replace(/\.\d{3}$/, '');
  parts.forEach((part, index) => {
    const expectedSuffix = String(index + 1).padStart(3, '0');
    if (!part.name.endsWith(`.${expectedSuffix}`)) throw new Error(`Missing or unordered ISO part: .${expectedSuffix}`);
    part.sha256 = partChecksums.get(part.name);
    if (!part.sha256) throw new Error(`Missing SHA-256 for ${part.name}`);
  });
  const sha256 = isoChecksums.get(isoName);
  if (!sha256) throw new Error(`Missing final SHA-256 for ${isoName}`);

  return {
    variant,
    isoName,
    sha256,
    totalSize: parts.reduce((sum, part) => sum + Number(part.size || 0), 0),
    parts
  };
}

export function formatBytes(bytes) {
  if (!Number.isFinite(bytes) || bytes < 0) return '—';
  const units = ['B', 'KiB', 'MiB', 'GiB', 'TiB'];
  let value = bytes;
  let unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit += 1;
  }
  return `${value.toFixed(unit >= 3 ? 2 : 1)} ${units[unit]}`;
}

export function matchFilesForVariant(variant, files) {
  const candidates = [...files];
  const byName = new Map(candidates.map((file) => [file.name, file]));
  if (candidates.length !== variant.parts.length || byName.size !== variant.parts.length) {
    throw new Error(`Bitte genau ${variant.parts.length} ISO-Teile auswählen`);
  }
  return variant.parts.map((part) => {
    const file = byName.get(part.name);
    if (!file) throw new Error(`${part.name} fehlt`);
    if (Number(part.size) && file.size !== Number(part.size)) throw new Error(`${part.name} hat die falsche Größe`);
    return { file, part };
  });
}

export function commandFor(variant, os) {
  if (!['windows', 'linux', 'macos'].includes(os)) throw new Error(`Unknown script platform: ${os}`);
  const downloads = variant.parts.map((part) => part.browser_download_url);
  if (os === 'windows') {
    const fetches = downloads.map((url, index) => `Invoke-WebRequest -Uri '${url}' -OutFile \"$base.${String(index + 1).padStart(3, '0')}\"`).join('\n');
    return `$ErrorActionPreference = 'Stop'\n$base = '${variant.isoName}'\n${fetches}\n$output = [IO.File]::Create($base)\nGet-ChildItem \"$base.???\" | Sort-Object Name | ForEach-Object {\n    $partStream = [IO.File]::OpenRead($_.FullName)\n    $partStream.CopyTo($output)\n    $partStream.Dispose()\n}\n$output.Dispose()\n$expected = '${variant.sha256}'\n$actual = (Get-FileHash $base -Algorithm SHA256).Hash.ToLowerInvariant()\nif ($actual -ne $expected) { throw \"SHA-256 stimmt nicht: $actual\" }\nWrite-Host \"Fertig und geprüft: $base\"`;
  }
  const fetches = downloads.map((url) => `curl -fL --retry 3 -O '${url}'`).join('\n');
  if (os === 'macos') {
    return `#!/bin/sh\nset -eu\nbase='${variant.isoName}'\n${fetches}\ncat \"$base\".??? > \"$base\"\nexpected='${variant.sha256}'\nactual=$(shasum -a 256 \"$base\" | awk '{print $1}')\n[ \"$actual\" = \"$expected\" ] || { echo \"SHA-256 stimmt nicht: $actual\" >&2; exit 1; }\necho \"Fertig und geprüft: $base\"`;
  }
  return `#!/usr/bin/env bash\nset -euo pipefail\nbase='${variant.isoName}'\n${fetches}\ncat \"$base\".??? > \"$base\"\nprintf '%s  %s\\n' '${variant.sha256}' \"$base\" | sha256sum -c -`;
}
