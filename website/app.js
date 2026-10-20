import { Sha256, buildVariant, commandFor, formatBytes, matchFilesForVariant, parseChecksums } from './download-core.mjs';

(() => {
  'use strict';

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const header = document.querySelector('[data-nav]');
  const preview = document.querySelector('[data-desktop-theme]');
  const themeName = document.querySelector('[data-theme-name]');
  const themeButtons = [...document.querySelectorAll('[data-preview-theme]')];

  const updateHeader = () => header?.classList.toggle('is-scrolled', window.scrollY > 20);
  updateHeader();
  window.addEventListener('scroll', updateHeader, { passive: true });

  const themeNames = { mono: 'MONO', eclipse: 'ECLIPSE', lunar: 'LUNAR' };
  themeButtons.forEach((button) => {
    button.addEventListener('click', () => {
      const next = button.dataset.previewTheme;
      preview.dataset.desktopTheme = next;
      themeName.textContent = themeNames[next] || next.toUpperCase();
      themeButtons.forEach((candidate) => candidate.classList.toggle('is-active', candidate === button));
    });
  });

  function createField(canvas, options = {}) {
    if (!canvas) return;
    const context = canvas.getContext('2d', { alpha: true });
    const pointer = { x: -1000, y: -1000, active: false };
    const cells = [];
    const signals = [];
    let width = 0;
    let height = 0;
    let frame = 0;
    let framePending = false;
    let previousTime = 0;
    const cellWidth = options.cellWidth || 26;
    const cellHeight = options.cellHeight || 30;
    const glyphs = ['-', '\\', '|', '/'];

    function resize() {
      const rect = canvas.getBoundingClientRect();
      const ratio = Math.min(window.devicePixelRatio || 1, 1.75);
      width = rect.width;
      height = rect.height;
      canvas.width = Math.round(width * ratio);
      canvas.height = Math.round(height * ratio);
      context.setTransform(ratio, 0, 0, ratio, 0, 0);
      cells.length = 0;
      const columns = Math.ceil(width / cellWidth);
      const rows = Math.ceil(height / cellHeight);
      for (let row = 0; row < rows; row += 1) {
        for (let column = 0; column < columns; column += 1) {
          cells.push({
            column,
            row,
            x: column * cellWidth + cellWidth * .5,
            y: row * cellHeight + cellHeight * .5
          });
        }
      }
      requestDraw();
    }

    function positionFromEvent(event) {
      const rect = canvas.getBoundingClientRect();
      pointer.x = event.clientX - rect.left;
      pointer.y = event.clientY - rect.top;
      pointer.active = pointer.x >= 0 && pointer.y >= 0 && pointer.x <= width && pointer.y <= height;
    }

    function draw(time) {
      framePending = false;
      const delta = previousTime ? Math.min((time - previousTime) / 1000, .05) : 0;
      previousTime = time;
      context.clearRect(0, 0, width, height);
      context.font = '13px "Cascadia Code", Consolas, monospace';
      context.textAlign = 'center';
      context.textBaseline = 'middle';

      for (const cell of cells) {
        const dx = cell.x - pointer.x;
        const dy = cell.y - pointer.y;
        const distance = Math.hypot(dx, dy);
        const force = pointer.active ? Math.max(0, 1 - distance / 175) : 0;
        let glyph = '|';
        let strength = force;

        if (force > .08) {
          const angle = Math.atan2(dy, dx);
          const sector = ((Math.round(angle / (Math.PI / 4)) % 4) + 4) % 4;
          glyph = glyphs[sector];
        }

        for (const signal of signals) {
          const gridDistance = Math.abs(cell.column - signal.column) + Math.abs(cell.row - signal.row);
          const bandDistance = Math.abs(gridDistance - signal.band);
          if (bandDistance < 1.2) {
            glyph = bandDistance < .45 ? '#' : '+';
            strength = Math.max(strength, signal.life);
          }
        }

        context.fillStyle = `rgba(244,244,240,${.075 + Math.min(strength, 1) * .78})`;
        context.fillText(glyph, cell.x, cell.y);
      }

      for (let index = signals.length - 1; index >= 0; index -= 1) {
        const signal = signals[index];
        signal.band += delta * 22;
        signal.life -= delta * 1.35;
        if (signal.life <= 0) signals.splice(index, 1);
      }

      if (!reducedMotion && signals.length) requestDraw();
    }

    function requestDraw() {
      if (framePending) return;
      framePending = true;
      frame = requestAnimationFrame(draw);
    }

    window.addEventListener('pointermove', (event) => {
      positionFromEvent(event);
      requestDraw();
    }, { passive: true });
    window.addEventListener('pointerdown', (event) => {
      positionFromEvent(event);
      if (!pointer.active) return;
      signals.push({
        column: Math.floor(pointer.x / cellWidth),
        row: Math.floor(pointer.y / cellHeight),
        band: 0,
        life: 1
      });
      requestDraw();
    });
    window.addEventListener('resize', resize, { passive: true });
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        cancelAnimationFrame(frame);
        framePending = false;
      } else {
        requestDraw();
      }
    });
    resize();
  }

  createField(document.querySelector('#signal-field'), { cellWidth: 26, cellHeight: 30 });
  createField(document.querySelector('#footer-field'), { cellWidth: 24, cellHeight: 28 });

  const repository = 'jamjam1312/LOKROOS-Arch-based';
  const fallbackTag = 'v0.1.0-alpha.24';
  const fallbackAssetBase = `https://github.com/${repository}/releases/download/${fallbackTag}`;
  const fallbackRelease = {
    tag_name: fallbackTag,
    html_url: `https://github.com/${repository}/releases/tag/${fallbackTag}`,
    assets: [
      { name: 'lokro-os-offline-0.1.0-alpha.24-x86_64.iso.001', size: 1992294400 },
      { name: 'lokro-os-offline-0.1.0-alpha.24-x86_64.iso.002', size: 1701478400 },
      { name: 'lokro-os-online-0.1.0-alpha.24-x86_64.iso.001', size: 1992294400 },
      { name: 'lokro-os-online-0.1.0-alpha.24-x86_64.iso.002', size: 675381248 }
    ].map((asset) => ({ ...asset, browser_download_url: `${fallbackAssetBase}/${asset.name}` }))
  };
  const fallbackPartChecksums = parseChecksums(`
027cc52a5930fc8cb9efc5cfec9f0ac7ff6baf83461b586f122512fcb7aa8032  lokro-os-offline-0.1.0-alpha.24-x86_64.iso.001
c0a3906e186a774bbdc84005f5b97780bbdc79af0bfac08b203b66acc365b894  lokro-os-offline-0.1.0-alpha.24-x86_64.iso.002
cafc58cc487f5c8ea4e59212f36434fb9f09f1756a68bda9df1a3cde26f81309  lokro-os-online-0.1.0-alpha.24-x86_64.iso.001
11581c45b600f3d7aad1d471477023647d4e890a6e6d32c43e0a5f9d84d3a194  lokro-os-online-0.1.0-alpha.24-x86_64.iso.002
  `);
  const fallbackIsoChecksums = parseChecksums(`
0bf10e85c6132eaa386c7d6c61ce46f0dcd9a9809728ed3720e92404ed32d70d  lokro-os-offline-0.1.0-alpha.24-x86_64.iso
2274332041b447c6e8297e8f78824beb5d755f56e959b31693eec9cf67efb5ed  lokro-os-online-0.1.0-alpha.24-x86_64.iso
  `);

  function createReleaseModel(release, partChecksums, isoChecksums, source) {
    return {
      release,
      source,
      variants: {
        offline: buildVariant(release, 'offline', partChecksums, isoChecksums),
        online: buildVariant(release, 'online', partChecksums, isoChecksums)
      }
    };
  }

  const fallbackModel = () => createReleaseModel(fallbackRelease, fallbackPartChecksums, fallbackIsoChecksums, 'fallback');

  async function fetchTextAsset(release, filename) {
    const asset = release.assets.find((candidate) => candidate.name === filename);
    if (!asset) throw new Error(`${filename} fehlt im Release`);
    const response = await fetch(asset.browser_download_url, { cache: 'no-store' });
    if (!response.ok) throw new Error(`${filename}: HTTP ${response.status}`);
    return response.text();
  }

  async function loadReleaseModel() {
    try {
      const response = await fetch(`https://api.github.com/repos/${repository}/releases?per_page=10`, {
        headers: { Accept: 'application/vnd.github+json' }
      });
      if (!response.ok) throw new Error(`GitHub API: HTTP ${response.status}`);
      const releases = await response.json();
      const release = releases.find((item) => !item.draft) || null;
      if (!release) throw new Error('Kein GitHub Release gefunden');
      const [partText, isoText] = await Promise.all([
        fetchTextAsset(release, 'ISO-PARTS-SHA256SUMS'),
        fetchTextAsset(release, 'SHA256SUMS')
      ]);
      return createReleaseModel(release, parseChecksums(partText), parseChecksums(isoText), 'github');
    } catch (error) {
      console.warn('Latest release metadata unavailable; using pinned Alpha 24 fallback.', error);
      return fallbackModel();
    }
  }

  function updateReleaseLabels(model) {
    document.querySelectorAll('.release-link').forEach((link) => { link.href = model.release.html_url; });
    const clean = model.release.tag_name.replace(/^v/, '').replace('0.1.0-', '').replace('alpha.', 'ALPHA ');
    const label = document.querySelector('[data-release-label]');
    if (label) label.textContent = `${clean.toUpperCase()} · EXPERIMENTELL`;
    for (const [variant, data] of Object.entries(model.variants)) {
      const size = document.querySelector(`[data-variant-size="${variant}"]`);
      if (size) size.textContent = formatBytes(data.totalSize);
    }
  }

  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) return navigator.clipboard.writeText(text);
    const field = document.createElement('textarea');
    field.value = text;
    field.setAttribute('readonly', '');
    field.style.position = 'fixed';
    field.style.opacity = '0';
    document.body.append(field);
    field.select();
    document.execCommand('copy');
    field.remove();
    return Promise.resolve();
  }

  const prepareButtons = [...document.querySelectorAll('[data-browser-prepare]')];
  const supportBadge = document.querySelector('[data-browser-support]');
  const statusText = document.querySelector('[data-assembler-status]');
  const progressWrap = document.querySelector('[data-assembler-progress]');
  const progressBar = progressWrap?.querySelector('progress');
  const progressPercent = document.querySelector('[data-assembler-percent]');
  const cancelButton = document.querySelector('[data-assembler-cancel]');
  const fileInput = document.querySelector('[data-assembler-files]');
  const assembleButton = document.querySelector('[data-assemble-selected]');
  const filePickerLabel = document.querySelector('[data-file-picker-label]');
  const copyScriptButton = document.querySelector('[data-copy-script]');
  const saveScriptButton = document.querySelector('[data-save-script]');
  const partLinks = document.querySelector('[data-part-links]');
  const scriptCode = document.querySelector('[data-download-script]');
  const isoHash = document.querySelector('[data-iso-hash]');
  const variantButtons = [...document.querySelectorAll('[data-download-variant]')];
  const osButtons = [...document.querySelectorAll('[data-script-os]')];
  const canAssemble = window.isSecureContext
    && typeof window.showSaveFilePicker === 'function'
    && typeof ReadableStream !== 'undefined'
    && typeof File.prototype.stream === 'function';
  let model = null;
  let selectedVariant = 'offline';
  let selectedOs = 'windows';
  let activeController = null;
  let selectedFiles = [];

  prepareButtons.forEach((button) => { button.disabled = true; });
  if (supportBadge) {
    supportBadge.textContent = canAssemble ? 'CHROMIUM · LOKAL VERBINDEN' : 'SKRIPT-MODUS VERFÜGBAR';
    supportBadge.classList.toggle('is-supported', canAssemble);
  }
  if (!canAssemble) {
    if (filePickerLabel) filePickerLabel.classList.add('is-disabled');
    if (fileInput) fileInput.disabled = true;
  }

  function renderManualDownloads() {
    if (!model) return;
    const variant = model.variants[selectedVariant];
    if (partLinks) {
      partLinks.replaceChildren(...variant.parts.map((part, index) => {
        const link = document.createElement('a');
        link.href = part.browser_download_url;
        link.textContent = `Teil ${index + 1} · ${formatBytes(Number(part.size || 0))}`;
        link.rel = 'noopener';
        link.target = '_blank';
        return link;
      }));
    }
    if (scriptCode) scriptCode.textContent = commandFor(variant, selectedOs);
    if (isoHash) isoHash.textContent = variant.sha256;
  }

  variantButtons.forEach((button) => button.addEventListener('click', () => {
    selectedVariant = button.dataset.downloadVariant;
    variantButtons.forEach((candidate) => candidate.classList.toggle('is-active', candidate === button));
    selectedFiles = [];
    if (fileInput) fileInput.value = '';
    if (assembleButton) assembleButton.disabled = true;
    renderManualDownloads();
  }));
  osButtons.forEach((button) => button.addEventListener('click', () => {
    selectedOs = button.dataset.scriptOs;
    osButtons.forEach((candidate) => {
      const active = candidate === button;
      candidate.classList.toggle('is-active', active);
      candidate.setAttribute('aria-selected', String(active));
    });
    renderManualDownloads();
  }));

  copyScriptButton?.addEventListener('click', async (event) => {
    await copyText(scriptCode?.textContent || '');
    const original = event.currentTarget.textContent;
    event.currentTarget.textContent = 'Kopiert';
    window.setTimeout(() => { event.currentTarget.textContent = original; }, 1400);
  });
  saveScriptButton?.addEventListener('click', () => {
    if (!model) return;
    const extension = selectedOs === 'windows' ? 'ps1' : 'sh';
    const blob = new Blob([`${scriptCode?.textContent || ''}\n`], { type: 'text/plain;charset=utf-8' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `lokro-${selectedVariant}-download.${extension}`;
    link.click();
    window.setTimeout(() => URL.revokeObjectURL(link.href), 1000);
  });

  function setProgress(received, total) {
    const percent = total ? Math.min(100, received / total * 100) : 0;
    if (progressBar) progressBar.value = percent;
    if (progressPercent) progressPercent.textContent = `${percent.toFixed(1)}% · ${formatBytes(received)} / ${formatBytes(total)}`;
  }

  function chooseVariant(variantName) {
    selectedVariant = variantName;
    variantButtons.forEach((button) => button.classList.toggle('is-active', button.dataset.downloadVariant === variantName));
    selectedFiles = [];
    if (fileInput) fileInput.value = '';
    if (assembleButton) assembleButton.disabled = true;
    renderManualDownloads();
  }

  function validateSelectedFiles(files) {
    if (!model) throw new Error('Release-Daten sind noch nicht geladen');
    const variant = model.variants[selectedVariant];
    return matchFilesForVariant(variant, files);
  }

  fileInput?.addEventListener('change', () => {
    selectedFiles = [...fileInput.files];
    try {
      const ordered = validateSelectedFiles(selectedFiles);
      if (assembleButton) assembleButton.disabled = !canAssemble;
      if (statusText) statusText.textContent = `${ordered.length} passende Teile ausgewählt. Bereit zum lokalen Prüfen und Verbinden.`;
    } catch (error) {
      if (assembleButton) assembleButton.disabled = true;
      if (statusText) statusText.textContent = `Auswahl unvollständig: ${error.message}.`;
    }
  });

  async function assembleSelectedFiles() {
    if (!model || activeController) return;
    if (!canAssemble) {
      if (statusText) statusText.textContent = 'Dieser Browser kann große Dateien nicht sicher direkt schreiben. Nutze unten das passende Windows-, Linux- oder macOS-Skript.';
      document.querySelector('.download-workbench')?.scrollIntoView({ behavior: reducedMotion ? 'auto' : 'smooth' });
      return;
    }

    const variant = model.variants[selectedVariant];
    let orderedFiles;
    try {
      orderedFiles = validateSelectedFiles(selectedFiles);
    } catch (error) {
      if (statusText) statusText.textContent = `Auswahl unvollständig: ${error.message}.`;
      return;
    }
    let handle;
    try {
      handle = await window.showSaveFilePicker({
        suggestedName: variant.isoName,
        types: [{ description: 'LOKRO OS ISO', accept: { 'application/x-iso9660-image': ['.iso'] } }]
      });
    } catch (error) {
      if (error.name !== 'AbortError' && statusText) statusText.textContent = `Dateiauswahl fehlgeschlagen: ${error.message}`;
      return;
    }

    activeController = new AbortController();
    prepareButtons.forEach((button) => { button.disabled = true; });
    if (assembleButton) assembleButton.disabled = true;
    if (fileInput) fileInput.disabled = true;
    if (cancelButton) cancelButton.hidden = false;
    if (progressWrap) progressWrap.hidden = false;
    setProgress(0, variant.totalSize);
    const completeHash = new Sha256();
    let received = 0;
    let writable;

    try {
      writable = await handle.createWritable();
      for (let index = 0; index < orderedFiles.length; index += 1) {
        const { file, part } = orderedFiles[index];
        if (activeController.signal.aborted) throw new DOMException('Abgebrochen', 'AbortError');
        if (statusText) statusText.textContent = `Teil ${index + 1} von ${orderedFiles.length} wird lokal gelesen und geprüft …`;
        const reader = file.stream().getReader();
        const partHash = new Sha256();
        while (true) {
          if (activeController.signal.aborted) {
            await reader.cancel();
            throw new DOMException('Abgebrochen', 'AbortError');
          }
          const { done, value } = await reader.read();
          if (done) break;
          await writable.write(value);
          partHash.update(value);
          completeHash.update(value);
          received += value.byteLength;
          setProgress(received, variant.totalSize);
        }
        const actualPartHash = partHash.digestHex();
        if (actualPartHash !== part.sha256) throw new Error(`Prüfsumme von ${part.name} stimmt nicht`);
      }
      const actualIsoHash = completeHash.digestHex();
      if (actualIsoHash !== variant.sha256) throw new Error(`Prüfsumme der fertigen ISO stimmt nicht (${actualIsoHash})`);
      await writable.close();
      writable = null;
      setProgress(variant.totalSize, variant.totalSize);
      if (statusText) statusText.textContent = `Fertig und geprüft: ${variant.isoName}`;
    } catch (error) {
      if (writable) {
        try { await writable.abort(); } catch (_) { /* Browser may already have closed the stream. */ }
      }
      if (statusText) {
        statusText.textContent = error.name === 'AbortError'
          ? 'Zusammensetzen abgebrochen. Die Zieldatei wurde nicht fertiggestellt.'
          : `Vorgang fehlgeschlagen: ${error.message}. Nutze unten das Skript als Fallback.`;
      }
    } finally {
      activeController = null;
      prepareButtons.forEach((button) => { button.disabled = !model; });
      if (assembleButton) assembleButton.disabled = !selectedFiles.length;
      if (fileInput) fileInput.disabled = !canAssemble;
      if (cancelButton) cancelButton.hidden = true;
    }
  }

  prepareButtons.forEach((button) => button.addEventListener('click', () => {
    chooseVariant(button.dataset.browserPrepare);
    document.querySelector('.download-workbench')?.scrollIntoView({ behavior: reducedMotion ? 'auto' : 'smooth' });
    if (statusText) statusText.textContent = `Lade unten beide ${selectedVariant === 'offline' ? 'Offline' : 'Online'}-Teile herunter und wähle sie danach gemeinsam aus.`;
  }));
  assembleButton?.addEventListener('click', assembleSelectedFiles);
  cancelButton?.addEventListener('click', () => activeController?.abort());

  loadReleaseModel().then((releaseModel) => {
    model = releaseModel;
    updateReleaseLabels(model);
    renderManualDownloads();
    prepareButtons.forEach((button) => { button.disabled = false; });
    if (copyScriptButton) copyScriptButton.disabled = false;
    if (saveScriptButton) saveScriptButton.disabled = false;
    if (statusText && model.source === 'fallback') statusText.textContent = 'GitHub-Metadaten waren nicht erreichbar. Der geprüfte Alpha-24-Fallback ist geladen.';
  });
})();
