---
description: 'Playwright tests against a live AWTRIX NG device'
applyTo: '{tests/playwright/**/*,.build/tasks/Playwright.build.ps1}'
---

# AWTRIX Playwright guidelines

- Run browser tests only through `./build.ps1 -Tasks testUI`.
- Read the target from `AWTRIX_NG_URL`; do not hard-code private device addresses in tracked test files.
- Keep live-device tests separate from the default unit-test workflow because the device is not available in CI by default.
- Read-only tests may validate documented GET endpoints such as `/api/v1/device`, `/api/v1/settings`, and `/api/v1/apps`, plus the browser live view.
- Any display mutation must be opt-in through `AWTRIX_MUTATION_TESTS=true`.
- Before a reversible mutation, read and retain the original value. Restore it in a `finally` block even when assertions fail.
- Do not test Wi-Fi, network, authentication, firmware update, reboot, erase, reset settings, or deep sleep without explicit user approval for that exact operation.
- Prefer role-based and semantic selectors for controls. Use DOM or canvas properties for live-view assertions rather than fragile pixel-perfect screenshots.
- Store traces, screenshots, videos, and JUnit output under `output/playwright`.
- Never place credentials in `package.json`, Playwright configuration, test source, screenshots, or traces. Pass optional authentication through environment variables.
