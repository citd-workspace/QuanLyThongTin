require('dotenv').config();
const express = require('express');
const path = require('path');
const fs = require('fs');
const sql = require('mssql');
const demos = require('./demos');
const reports = require('./reports');

// ---------- Kết nối SQL Server ----------
const config = {
  server: process.env.DB_SERVER || 'localhost',
  port: parseInt(process.env.DB_PORT || '1433', 10),
  database: process.env.DB_NAME || 'QuanLySieuThi',
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: process.env.DB_ENCRYPT === 'true',
    trustServerCertificate: process.env.DB_TRUST_CERT !== 'false',
  },
  pool: { max: 10, min: 0, idleTimeoutMillis: 30000 },
};
if (process.env.DB_INSTANCE) {
  config.options.instanceName = process.env.DB_INSTANCE;
  delete config.port;
}

let poolPromise = null;
function getPool() {
  if (!poolPromise) {
    poolPromise = new sql.ConnectionPool(config).connect().catch((err) => {
      poolPromise = null;
      err.message = 'Khong ket noi duoc SQL Server: ' + err.message;
      throw err;
    });
  }
  return poolPromise;
}

// ---------- Tien ich ----------
const wrap = (fn) => (req, res) =>
  fn(req, res).catch((err) => {
    console.error(err.message);
    res.status(err.status || 500).json({ error: err.message });
  });

const badRequest = (msg) => Object.assign(new Error(msg), { status: 400 });

// Gan tham so (co kiem tra kieu) -> luon dung parameterized query, khong noi chuoi SQL.
function bindParams(request, defs, values) {
  for (const d of defs) {
    let raw = values && values[d.name];
    if (raw === undefined || raw === null) raw = d.default;
    if (d.type === 'int') {
      const n = Number(raw);
      if (raw === '' || !Number.isInteger(n)) throw badRequest(`"${d.label}" phải là số nguyên`);
      request.input(d.name, sql.Int, n);
    } else if (d.type === 'float') {
      const n = Number(raw);
      if (raw === '' || !Number.isFinite(n)) throw badRequest(`"${d.label}" phải là số`);
      request.input(d.name, sql.Float, n);
    } else if (d.type === 'date') {
      if (!/^\d{4}-\d{2}-\d{2}$/.test(String(raw))) throw badRequest(`"${d.label}" phải có dạng yyyy-mm-dd`);
      request.input(d.name, sql.VarChar(10), String(raw));
    } else if (d.type === 'varchar') {
      request.input(d.name, sql.VarChar(255), String(raw).slice(0, 255));
    } else {
      request.input(d.name, sql.NVarChar(255), String(raw).slice(0, 255));
    }
  }
}

function makeRequest(target, defs, values, messages) {
  const req = target.request(); // target: ConnectionPool hoặc Transaction
  bindParams(req, defs, values);
  if (messages) req.on('info', (info) => messages.push(info.message)); // thu PRINT / thông báo
  return req;
}

const toTable = (rs) => ({ columns: Object.keys(rs.columns || {}), rows: Array.from(rs) });

async function loadTables(target, demo, values) {
  const out = [];
  for (const t of demo.tables) {
    const r = await makeRequest(target, demo.params, values).query(t.sql);
    out.push({ title: t.title, ...toTable(r.recordset) });
  }
  return out;
}

const findDemo = (id) => {
  const d = demos.find((x) => x.id === id);
  if (!d) throw Object.assign(new Error('Không tìm thấy chức năng demo'), { status: 404 });
  return d;
};

// ---------- API ----------
const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/health', wrap(async (req, res) => {
  const pool = await getPool();
  const r = await pool.request().query('SELECT DB_NAME() AS db, @@SERVERNAME AS server');
  res.json(r.recordset[0]);
}));

// Danh sách chức năng (metadata)
app.get('/api/demos', (req, res) => {
  res.json(demos.map(({ id, group, title, problem, object, exec, params }) => ({ id, group, title, problem, object, exec, params })));
});

// B2: mã nguồn Procedure/Function/Trigger đọc trực tiếp từ SQL Server
app.get('/api/demos/:id/definition', wrap(async (req, res) => {
  const demo = findDemo(req.params.id);
  if (!demo.object) return res.json({ definition: demo.exec });
  const pool = await getPool();
  const r = await pool.request()
    .input('n', sql.NVarChar(200), 'dbo.' + demo.object)
    .query('SELECT OBJECT_DEFINITION(OBJECT_ID(@n)) AS def');
  res.json({ definition: r.recordset[0].def || null });
}));

// B3: các bảng liên quan (trước khi thực thi)
app.post('/api/demos/:id/tables', wrap(async (req, res) => {
  const demo = findDemo(req.params.id);
  const pool = await getPool();
  res.json({ tables: await loadTables(pool, demo, req.body.params) });
}));

// B4 + B5: thực thi câu lệnh, rồi đọc lại các bảng liên quan
app.post('/api/demos/:id/run', wrap(async (req, res) => {
  const demo = findDemo(req.params.id);
  const values = req.body.params;
  const rollbackAfter = !!req.body.rollback;
  const pool = await getPool();

  const tx = new sql.Transaction(pool);
  await tx.begin();

  const messages = [];
  let recordsets = [], rowsAffected = [], error = null, alive = true;
  try {
    const r = await makeRequest(tx, demo.params, values, messages).query(demo.exec);
    recordsets = r.recordsets.map(toTable);
    rowsAffected = r.rowsAffected;
  } catch (e) {
    alive = false;
    error = { message: e.message, number: e.number || (e.originalError && e.originalError.info && e.originalError.info.number) || null };
    try { await tx.rollback(); } catch (_) { /* trigger đã tự ROLLBACK */ }
  }

  let after, rolledBack = false;
  if (alive) {
    after = await loadTables(tx, demo, values); // đọc trong cùng transaction để thấy thay đổi
    if (rollbackAfter) { await tx.rollback(); rolledBack = true; } else { await tx.commit(); }
  } else {
    after = await loadTables(pool, demo, values);
    rolledBack = true;
  }
  res.json({ error, messages, recordsets, rowsAffected, after, rolledBack });
}));

// ---------- Phần B: báo cáo ----------
app.get('/api/reports', (req, res) => {
  res.json(reports.map(({ id, title, unit }) => ({ id, title, unit })));
});

app.get('/api/reports/:id/data', wrap(async (req, res) => {
  const rep = reports.find((x) => x.id === req.params.id);
  if (!rep) throw Object.assign(new Error('Không tìm thấy báo cáo'), { status: 404 });
  const pool = await getPool();
  const r = await pool.request().query(rep.sql);
  res.json({ title: rep.title, unit: rep.unit, rows: Array.from(r.recordset) });
}));

// Ảnh chụp màn hình Tableau / Power BI: bỏ file vào public/reports/
app.get('/api/report-images', (req, res) => {
  const dir = path.join(__dirname, 'public', 'reports');
  const files = fs.existsSync(dir)
    ? fs.readdirSync(dir).filter((f) => /\.(png|jpe?g|gif|webp)$/i.test(f)).sort()
    : [];
  res.json(files.map((f) => '/reports/' + encodeURIComponent(f)));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Demo chạy tại http://localhost:${PORT}`));
