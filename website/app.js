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

  async function refreshRelease() {
    const fallback = 'v0.1.0-alpha.24';
    try {
      const response = await fetch('https://api.github.com/repos/jamjam1312/LOKROOS-Arch-based/releases?per_page=10', {
        headers: { Accept: 'application/vnd.github+json' }
      });
      if (!response.ok) return;
      const releases = await response.json();
      const release = releases.find((item) => !item.draft) || null;
      if (!release) return;
      document.querySelectorAll('.release-link').forEach((link) => { link.href = release.html_url; });
      const clean = release.tag_name.replace(/^v/, '').replace('0.1.0-', '').replace('alpha.', 'ALPHA ');
      const label = document.querySelector('[data-release-label]');
      if (label) label.textContent = `${clean.toUpperCase()} · EXPERIMENTELL`;
    } catch (_) {
      document.querySelectorAll('.release-link').forEach((link) => {
        link.href = `https://github.com/jamjam1312/LOKROOS-Arch-based/releases/tag/${fallback}`;
      });
    }
  }

  refreshRelease();
})();
