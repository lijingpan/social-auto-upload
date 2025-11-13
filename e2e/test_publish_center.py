import asyncio
import time
import sys
import http.client
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as pw:
        browser = await pw.chromium.launch(headless=True)
        context = await browser.new_context()
        page = await context.new_page()
        start = time.time()
        await page.goto("http://localhost:5173/#/publish-center")
        await page.wait_for_load_state("networkidle")
        elapsed = int((time.time() - start) * 1000)
        errors = []
        page.on("console", lambda msg: errors.append(msg) if msg.type == "error" else None)
        title = await page.title()
        ok = title is not None and len(title) > 0
        await context.close()
        await browser.close()
        print(f"page_load_ms={elapsed}")
        print(f"title_ok={ok}")
        print(f"console_error_count={len(errors)}")
        sys.exit(0 if ok else 1)

def check(url):
    try:
        u = url.replace("http://", "")
        host, path = u.split("/", 1)
        path = "/" + path
        conn = http.client.HTTPConnection(host, timeout=5)
        conn.request("GET", path)
        resp = conn.getresponse()
        return resp.status < 500
    except Exception:
        return False

async def main():
    for _ in range(60):
        if check("http://localhost:5409/") and check("http://localhost:5173/"):
            break
        await asyncio.sleep(1)
    await run()

if __name__ == "__main__":
    asyncio.run(main())
