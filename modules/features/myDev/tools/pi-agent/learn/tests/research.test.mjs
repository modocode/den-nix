import test from "node:test";
import assert from "node:assert/strict";
import { fetchPage, htmlText, searchResults } from "../extensions/research/http.mjs";

test("search unwraps source URLs and reports challenges", () => {
  const rows = searchResults('<a class="result__a" href="//duckduckgo.com/l/?uddg=https%3A%2F%2Fexample.com%2Fpaper">Original &amp; paper</a>');
  assert.deepEqual(rows, [{ title: "Original & paper", url: "https://example.com/paper" }]);
  assert.throws(() => searchResults('<form id="challenge-form">captcha</form>'), /blocked/);
  assert.throws(() => searchResults("<p>No results</p>"), /No usable/);
});
test("retrieved HTML excludes scripts and preserves readable text", () => {
  assert.equal(htmlText("<script>doBadThings()</script><p>A &amp; B</p>"), "A & B");
});
test("fetch errors, binary content, oversized sources and cancellation stay failures", async () => {
  await assert.rejects(() => fetchPage("file:///etc/passwd"), /HTTP/);
  await assert.rejects(() => fetchPage("https://example.com", undefined, async () => new Response("", { status: 403 })), /403/);
  await assert.rejects(() => fetchPage("https://example.com", undefined, async () => new Response("pdf", { headers: { "content-type": "application/pdf" } })), /local extracted/);
  await assert.rejects(() => fetchPage("https://example.com", undefined, async () => new Response("x".repeat(1024 * 1024 + 1), { headers: { "content-type": "text/plain" } })), /1 MiB/);
  const abort = new AbortController(); abort.abort();
  await assert.rejects(() => fetchPage("https://example.com", abort.signal, async (_url, options) => {
    options.signal.throwIfAborted(); return new Response("should not arrive");
  }), /abort/i);
});
