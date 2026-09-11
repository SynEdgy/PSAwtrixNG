# Safety and testing

## Device safety

Commands that change device state support `-WhatIf` through PowerShell's
`ShouldProcess` mechanism.

The generic `Invoke-AwtrixApi` command requires `-AllowDangerousOperation` for
these endpoints:

- `api/v1/device/reboot`
- `api/v1/device/sleep`
- `api/v1/settings/reset`
- `api/v1/device/factory-reset`
- `api/v1/firmware`
- `api/v1/restore`

The switch is an explicit opt-in, not a confirmation bypass. Normal
`ShouldProcess` confirmation still applies.

```powershell
$apiParameters = @{
    Device                  = $clock
    Path                    = 'api/v1/device/reboot'
    Method                  = 'Post'
    AllowDangerousOperation = $true
    WhatIf                  = $true
}

Invoke-AwtrixApi @apiParameters
```

## Automated tests

The default test workflow does not require physical hardware:

```powershell
.\build.ps1 -Tasks test
```

It runs mocked unit tests and local integration tests, including an MQTT broker
round trip on an ephemeral port.

## Live-device tests

Playwright tests are local-only and use an environment variable rather than a
hard-coded device address:

```powershell
$env:AWTRIX_NG_URL = 'http://192.168.1.50'
.\build.ps1 -Tasks testUI
```

The reversible brightness test is disabled unless explicitly enabled:

```powershell
$env:AWTRIX_MUTATION_TESTS = 'true'
.\build.ps1 -Tasks testUI
```

The test reads the original brightness and restores it in a `finally` block. No
live automation changes Wi-Fi, authentication, firmware, or reset settings.

## Build the wiki

Generate command reference, external help, custom pages, sidebar, and the wiki
archive:

```powershell
.\build.ps1 -Tasks docs
```

Generated content is written to `output\WikiContent`. Edit the source pages
under `source\WikiSource`, not the generated output.
