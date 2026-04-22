/* main.js — Shared interactions */

function copy(btn) {
  const code = btn.parentElement.querySelector('code');
  const original = btn.textContent;
  const text = code.textContent.trim();
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(text).then(() => {
      btn.textContent = 'Copied!';
      setTimeout(() => { btn.textContent = original; }, 2000);
    }).catch(() => { btn.textContent = 'Select & copy'; });
  } else {
    btn.textContent = 'Select & copy';
  }
}

function switchTab(os) {
  document.querySelectorAll('.os-tab').forEach(t => {
    if (t.disabled) return;
    t.setAttribute('aria-selected', String(t.id === 'tab-' + os));
  });
  document.querySelectorAll('.os-panel').forEach(p => {
    p.hidden = p.id !== 'panel-' + os;
  });
}

/* Arrow-key navigation on the OS tablist (WCAG ARIA APG pattern) */
(function initTablistKeys() {
  const tabs = Array.from(document.querySelectorAll('.os-tab'));
  if (!tabs.length) return;
  tabs.forEach((tab, i) => {
    tab.addEventListener('keydown', (e) => {
      if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') return;
      e.preventDefault();
      const dir = e.key === 'ArrowLeft' ? -1 : 1;
      let next = i + dir;
      while (next >= 0 && next < tabs.length && tabs[next].disabled) next += dir;
      if (next < 0 || next >= tabs.length) return;
      const os = tabs[next].id.replace(/^tab-/, '');
      switchTab(os);
      tabs[next].focus();
    });
  });
})();
