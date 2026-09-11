const INTERVAL_MS = Number(process.env.INTERVAL_MS ?? 5000);

console.log(`[keeper] scaffold OK: interval=${INTERVAL_MS}ms`);

// 保持进程存活；周 6 会替换为真正的清算扫描循环
setInterval(() => {}, 1 << 30);