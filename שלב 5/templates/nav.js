/* nav.js – inject shared sidebar + set active link */
(function () {
  const PAGE = document.documentElement.dataset.page || '';

  const html = `
  <aside class="sidebar">
    <div class="sb-logo">
      <div class="sb-logo-name">SmartCare<em>+</em></div>
      <div class="sb-logo-sub">מרכז רפואי שיבא · 2026</div>
    </div>

    <div class="sb-section">ניהול קליני</div>
    <a class="sb-link ${PAGE==='dashboard'?'active':''}" href="index.html">
      <span class="ico">📊</span> לוח בקרה
    </a>
    <a class="sb-link ${PAGE==='monitoring'?'active':''}" href="monitoring.html">
      <span class="ico">🚨</span> ניטור קליני
    </a>
    <a class="sb-link ${PAGE==='management'?'active':''}" href="management.html">
      <span class="ico">⚙️</span> ניהול אשפוזים
    </a>

    <div class="sb-section">אנליזה ודיווח</div>
    <a class="sb-link ${PAGE==='analytics'?'active':''}" href="analytics.html">
      <span class="ico">📈</span> אנליטיקה ודוחות
    </a>

    <div class="sb-footer">
      <div class="sb-avatar">NA</div>
      <div>
        <div class="sb-user-name">נחמן אוקשי</div>
        <div class="sb-user-role">DB Administrator</div>
      </div>
    </div>
  </aside>`;

  document.getElementById('sidebar-mount').outerHTML = html;

  /* topbar date */
  const el = document.getElementById('tb-date');
  if (el) el.textContent = new Date().toLocaleDateString('he-IL',
    {weekday:'short', year:'numeric', month:'short', day:'numeric'});
})();
