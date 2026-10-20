#!/usr/bin/env node
// SPDX-License-Identifier: GPL-3.0-or-later
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { Sha256, buildVariant, commandFor, formatBytes, matchFilesForVariant, parseChecksums } from '../website/download-core.mjs';

function hashChunks(chunks) {
  const hash = new Sha256();
  for (const chunk of chunks) hash.update(chunk);
  return hash.digestHex();
}

assert.equal(hashChunks(['']), 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
assert.equal(hashChunks(['a', 'b', 'c']), 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
assert.equal(
  hashChunks([new Uint8Array(63).fill(0x61), new Uint8Array(1).fill(0x61)]),
  'ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb'
);

for (const length of [1, 55, 56, 63, 64, 65, 127, 128, 129, 1024, 65537]) {
  const bytes = Uint8Array.from({ length }, (_, index) => (index * 37 + 11) & 0xff);
  const expected = createHash('sha256').update(bytes).digest('hex');
  const actual = new Sha256()
    .update(bytes.subarray(0, Math.floor(length / 3)))
    .update(bytes.subarray(Math.floor(length / 3), Math.floor(length * 2 / 3)))
    .update(bytes.subarray(Math.floor(length * 2 / 3)))
    .digestHex();
  assert.equal(actual, expected, `incremental SHA-256 differs at ${length} bytes`);
}

const release = {
  tag_name: 'v0.1.0-alpha.test',
  assets: [
    { name: 'lokro-os-offline-test-x86_64.iso.002', size: 20, browser_download_url: 'https://example.test/002' },
    { name: 'lokro-os-offline-test-x86_64.iso.001', size: 10, browser_download_url: 'https://example.test/001' }
  ]
};
const partChecksums = parseChecksums(`${'b'.repeat(64)}  /workspace/out/lokro-os-offline-test-x86_64.iso.002\n${'a'.repeat(64)}  lokro-os-offline-test-x86_64.iso.001\n`);
const isoChecksums = parseChecksums(`${'c'.repeat(64)}  lokro-os-offline-test-x86_64.iso\n`);
const variant = buildVariant(release, 'offline', partChecksums, isoChecksums);

assert.equal(variant.isoName, 'lokro-os-offline-test-x86_64.iso');
assert.equal(variant.parts[0].name, 'lokro-os-offline-test-x86_64.iso.001');
assert.equal(variant.parts[1].sha256, 'b'.repeat(64));
assert.equal(variant.totalSize, 30);
assert.equal(variant.sha256, 'c'.repeat(64));
assert.equal(formatBytes(3693772800), '3.44 GiB');
const selected = matchFilesForVariant(variant, [
  { name: variant.parts[1].name, size: 20 },
  { name: variant.parts[0].name, size: 10 }
]);
assert.equal(selected[0].file.name, variant.parts[0].name);
assert.equal(selected[1].file.name, variant.parts[1].name);
assert.throws(() => matchFilesForVariant(variant, [selected[0].file]), /genau 2 ISO-Teile/);
assert.throws(() => matchFilesForVariant(variant, [selected[0].file, { name: 'wrong.002', size: 20 }]), /fehlt/);
assert.throws(() => matchFilesForVariant(variant, [selected[0].file, { name: variant.parts[1].name, size: 19 }]), /falsche Größe/);
for (const os of ['windows', 'linux', 'macos']) {
  const command = commandFor(variant, os);
  assert.match(command, /https:\/\/example\.test\/001/);
  assert.match(command, new RegExp(variant.sha256));
  assert.doesNotMatch(command, /curl[^\n|]*\|\s*(sh|bash)/);
}
assert.match(commandFor(variant, 'windows'), /Get-FileHash/);
assert.match(commandFor(variant, 'linux'), /sha256sum -c/);
assert.match(commandFor(variant, 'macos'), /shasum -a 256/);
assert.throws(() => buildVariant({ tag_name: 'bad', assets: [] }, 'offline', new Map(), new Map()), /No offline ISO parts/);

console.log('Website download core: SHA-256 vectors, checksum parsing and release assembly passed.');
