import express from "express";

const app = express();
const PORT = Number(process.env.PORT ?? 4000);

app.get("/health", (_req, res) => {
  res.json({ ok: true, ts: Date.now() });
});

app.listen(PORT, () => {
  console.log(`[api] listening on http://localhost:${PORT}`);
});