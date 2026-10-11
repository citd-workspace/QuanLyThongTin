// Frontend vanilla JS: chỉ trình bày dữ liệu lấy từ API (API truy vấn SQL Server).
const $ = (sel, el = document) => el.querySelector(sel);

function h(tag, props = {}, ...kids) {
  const el = document.createElement(tag);
  for (const [k, v] of Object.entries(props)) {
    if (k === 'class') el.className = v;
    else if (k.startsWith('on')) el.addEventListener(k.slice(2), v);
    else if (v !== false && v != null) el.setAttribute(k, v);
  }
  for (const kid of kids.flat()) if (kid != null) el.append(kid);
  return el;
}

async function api(url, body) {
  const res = await fetch(url, body
    ? { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }
    : undefined);
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || res.statusText);
  return data;
}

function fmt(v) {
  if (v === null || v === undefined) return 'NULL';
  if (typeof v === 'number') return v.toLocaleString('vi-VN');
  if (typeof v === 'boolean') return v ? '1' : '0';
  if (typeof v === 'string' && /^\d{4}-\d{2}-\d{2}T/.test(v)) return v.replace('T', ' ').replace(/\.\d+Z$/, '');
  return String(v);
}

function renderTable(t) {
  const box = h('div', {}, h('div', { class: 'tbl-title' }, t.title || 'Output'));
  if (!t.columns.length) { box.append(h('p', { class: 'muted' }, '(không có dữ liệu)')); return box; }
  const thead = h('thead', {}, h('tr', {}, t.columns.map((c) => h('th', {}, c))));
  const tbody = h('tbody', {}, t.rows.map((r) => h('tr', {}, t.columns.map((c) => h('td', {}, fmt(r[c]))))));
  box.append(h('div', { class: 'tbl-wrap' }, h('table', {}, thead, tbody)));
  if (!t.rows.length) box.append(h('p', { class: 'muted' }, '(0 dòng)'));
  return box;
}

const msg = (cls, text) => h('div', { class: 'msg ' + cls }, text);

// ---------- Tabs ----------
let reportsLoaded = false;
document.querySelectorAll('.tab').forEach((btn) => btn.addEventListener('click', () => {
  document.querySelectorAll('.tab').forEach((b) => b.classList.toggle('active', b === btn));
  document.querySelectorAll('.tabpane').forEach((p) => p.classList.toggle('hidden', p.id !== 'tab-' + btn.dataset.tab));
  if (btn.dataset.tab === 'trinhbay' && !reportsLoaded) { reportsLoaded = true; loadReports(); }
}));

// ---------- Kết nối ----------
api('/api/health')
  .then((r) => { const s = $('#dbStatus'); s.textContent = `Đã kết nối: ${r.server} / ${r.db}`; })
  .catch((e) => { const s = $('#dbStatus'); s.textContent = e.message; s.style.color = '#ffb4b4'; });

// ---------- Phần A ----------
const GROUPS = { procedure: 'Stored Procedure', function: 'Function', trigger: 'Trigger', cursor: 'Cursor' };
let loadToken = 0;

async function initMenu() {
  const demos = await api('/api/demos');
  const menu = $('#menu');
  for (const [key, label] of Object.entries(GROUPS)) {
    const items = demos.filter((d) => d.group === key);
    if (!items.length) continue;
    menu.append(h('h3', {}, label));
    for (const d of items) {
      menu.append(h('button', { 'data-id': d.id, onclick: () => openDemo(d) }, d.title));
    }
  }
}

function openDemo(d) {
  document.querySelectorAll('#menu button').forEach((b) => b.classList.toggle('active', b.dataset.id === d.id));
  const panel = $('#panel');
  panel.replaceChildren();

  // B2: mã nguồn lấy từ DB
  const defPre = h('pre', {}, 'Đang tải mã nguồn từ SQL Server...');
  api(`/api/demos/${d.id}/definition`)
    .then((r) => { defPre.textContent = r.definition || '-- Chưa có object này trong database. Hãy chạy file DDL_querries.sql trước.'; })
    .catch((e) => { defPre.textContent = '-- ' + e.message; });

  // B3: tham số + bảng liên quan
  const inputs = {};
  const form = h('div', { class: 'params' });
  for (const p of d.params) {
    const type = p.type === 'date' ? 'date' : (p.type === 'int' || p.type === 'float') ? 'number' : 'text';
    const input = h('input', { type, value: p.default, step: p.type === 'float' ? 'any' : null });
    input.addEventListener('change', loadTables);
    inputs[p.name] = input;
    form.append(h('label', {}, p.label + ' (@' + p.name + ')', input));
  }
  const getValues = () => Object.fromEntries(Object.entries(inputs).map(([k, i]) => [k, i.value]));
  const tablesBox = h('div');

  async function loadTables() {
    const token = ++loadToken;
    tablesBox.replaceChildren(h('p', { class: 'muted' }, 'Đang tải dữ liệu từ SQL Server...'));
    try {
      const r = await api(`/api/demos/${d.id}/tables`, { params: getValues() });
      if (token === loadToken) tablesBox.replaceChildren(...r.tables.map(renderTable));
    } catch (e) {
      if (token === loadToken) tablesBox.replaceChildren(msg('bad', e.message));
    }
  }

  // B4: nút thực thi
  const rollbackChk = h('input', { type: 'checkbox', id: 'rb', checked: 'checked' });
  const resultBox = h('div', {}, h('p', { class: 'muted' }, 'Chưa thực thi. Bấm nút ở bước B4.'));
  const runBtn = h('button', { class: 'run' }, 'Thực thi');
  runBtn.addEventListener('click', async () => {
    runBtn.disabled = true;
    resultBox.replaceChildren(h('p', { class: 'muted' }, 'Đang thực thi...'));
    try {
      const r = await api(`/api/demos/${d.id}/run`, { params: getValues(), rollback: rollbackChk.checked });
      resultBox.replaceChildren(...renderResult(r));
    } catch (e) {
      resultBox.replaceChildren(msg('bad', e.message));
    } finally {
      runBtn.disabled = false;
    }
  });

  panel.append(
    h('h2', {}, d.title),
    h('div', { class: 'step' }, h('h3', {}, 'B1. Bài toán'), h('p', {}, d.problem)),
    h('div', { class: 'step' }, h('h3', {}, 'B2. Câu truy vấn SQL (đọc từ database)'), defPre),
    h('div', { class: 'step' },
      h('h3', {}, 'B3. Các bảng dữ liệu liên quan (trước khi thực thi)'),
      d.params.length ? form : null, tablesBox),
    h('div', { class: 'step' },
      h('h3', {}, 'B4. Thực thi'),
      h('pre', {}, d.exec),
      h('label', {}, rollbackChk, ' Hoàn tác (ROLLBACK) sau khi demo để có thể chạy lại nhiều lần'),
      h('div', { style: 'margin-top:8px' }, runBtn)),
    h('div', { class: 'step' }, h('h3', {}, 'B5. Kết quả sau khi thực thi'), resultBox),
  );
  loadTables();
}

function renderResult(r) {
  const out = [];
  if (r.error) {
    out.push(msg('bad', 'Câu lệnh bị chặn / báo lỗi: ' + r.error.message));
    out.push(msg('info', 'Giao dịch đã được ROLLBACK, dữ liệu không thay đổi.'));
  } else {
    const affected = r.rowsAffected && r.rowsAffected.length ? ` (rows affected: ${r.rowsAffected.join(', ')})` : '';
    out.push(msg('ok', 'Thực thi thành công' + affected + (r.rolledBack ? ' – đã hoàn tác dữ liệu sau khi demo.' : ' – đã COMMIT.')));
  }
  if (r.messages.length) {
    out.push(h('div', { class: 'tbl-title' }, 'LOG (PRINT từ SQL Server)'));
    out.push(h('pre', {}, r.messages.join('\n')));
  }
  r.recordsets.forEach((t, i) => out.push(renderTable({ ...t, title: 'Output #' + (i + 1) + ' (kết quả trả về)' })));
  r.after.forEach((t) => out.push(renderTable({ ...t, title: t.title + ' – SAU khi thực thi' })));
  return out;
}

// ---------- Phần B ----------
async function loadReports() {
  const imgBox = $('#images');
  try {
    const imgs = await api('/api/report-images');
    if (!imgs.length) imgBox.append(h('p', { class: 'muted' }, 'Chưa có ảnh. Hãy bỏ ảnh chụp report Tableau/Power BI vào thư mục public/reports/ rồi tải lại trang.'));
    imgs.forEach((src) => imgBox.append(h('img', { src, alt: 'Report' })));
  } catch (e) { imgBox.append(msg('bad', e.message)); }

  const chartBox = $('#charts');
  const list = await api('/api/reports');
  for (const rep of list) {
    const box = h('div', { class: 'chart' }, h('h3', {}, rep.title + ' (' + rep.unit + ')'), h('p', { class: 'muted' }, 'Đang tải...'));
    chartBox.append(box);
    try {
      const data = await api(`/api/reports/${rep.id}/data`);
      const max = Math.max(...data.rows.map((r) => Number(r.value)), 1);
      box.replaceChildren(h('h3', {}, rep.title + ' (' + rep.unit + ')'));
      if (!data.rows.length) box.append(h('p', { class: 'muted' }, '(không có dữ liệu)'));
      for (const r of data.rows) {
        const bar = h('div', { class: 'bar' });
        bar.style.width = (Number(r.value) / max * 100).toFixed(1) + '%';
        box.append(h('div', { class: 'bar-row' },
          h('span', { class: 'lbl', title: r.label }, r.label),
          h('div', { class: 'bar-wrap' }, bar),
          h('span', { class: 'val' }, fmt(Number(r.value)))));
      }
    } catch (e) { box.replaceChildren(msg('bad', e.message)); }
  }
}

initMenu().catch((e) => $('#menu').append(msg('bad', e.message)));
