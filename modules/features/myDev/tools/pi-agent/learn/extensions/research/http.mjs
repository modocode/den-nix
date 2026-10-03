export function htmlText(html) {
  return html.replace(/<(script|style|nav|noscript)\b[^>]*>[\s\S]*?<\/\1>/gi, " ")
    .replace(/<[^>]+>/g, " ").replace(/&nbsp;/g, " ").replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"').replace(/&#39;|&apos;/g, "'").replace(/&lt;/g, "<").replace(/&gt;/g, ">")
    .replace(/&#(\d+);/g, (_, n) => String.fromCodePoint(Math.min(Number(n), 0x10ffff)))
    .replace(/\s+/g, " ").trim();
}
export async function fetchPage(url, signal, fetcher = fetch) {
  const parsed = new URL(url);
  if (!["http:", "https:"].includes(parsed.protocol)) throw new Error("Only HTTP(S) source URLs are supported.");
  const timeout = AbortSignal.timeout(20000);
  const response = await fetcher(parsed, { signal: signal ? AbortSignal.any([signal, timeout]) : timeout,
    headers: { "User-Agent": "pi-learn/1.0 (learning research)" } });
  if (!response.ok) throw new Error("Source unavailable: HTTP " + response.status);
  const type = response.headers.get("content-type") ?? "";
  if (!/text\/|application\/(json|xml|xhtml)/i.test(type)) throw new Error("This tool reads text/HTML sources. For PDF or other formats provide a local extracted document.");
  let bytes = 0;
  const reader = response.body.getReader(), parts = [];
  try {
    while (true) {
      const chunk = await reader.read();
      if (chunk.done) break;
      bytes += chunk.value.length;
      if (bytes > 1024 * 1024) throw new Error("Source exceeded the 1 MiB limit; fetch a smaller source.");
      parts.push(Buffer.from(chunk.value));
    }
  } finally { await reader.cancel().catch(() => {}); }
  const raw = Buffer.concat(parts).toString("utf8");
  return { url: response.url || String(parsed), type, raw, text: /html/i.test(type) ? htmlText(raw) : raw };
}
export function searchResults(html) {
  if (/anomaly\.js|challenge-form|bots use DuckDuckGo|captcha/i.test(html)) throw new Error("DuckDuckGo blocked automated search. Verification remains incomplete; use supplied URLs or try later.");
  const results = [];
  for (const match of html.matchAll(/<a\b([^>]*class=["'][^"']*result__a[^"']*["'][^>]*)>([\s\S]*?)<\/a>/gi)) {
    const href = match[1].match(/href=["']([^"']+)["']/i)?.[1];
    if (!href) continue;
    let target = href.replaceAll("&amp;", "&");
    try {
      const u = new URL(target, "https://duckduckgo.com");
      target = u.searchParams.get("uddg") ?? u.href;
      if (!/^https?:\/\//.test(target)) continue;
    } catch { continue; }
    results.push({ title: htmlText(match[2]), url: target });
    if (results.length === 6) break;
  }
  if (!results.length) throw new Error("No usable public-search results. Do not treat this as verification; use a known source URL.");
  return results;
}
