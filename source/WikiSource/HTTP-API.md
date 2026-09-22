# Using the HTTP API

The module accepts either a value returned by `New-AwtrixDevice` or a host name,
IP address, or URI directly through the `-Device` parameter.

## Notifications

```powershell
$notificationParameters = @{
    Device = $clock
    Text   = 'Deployment complete'
    Color  = '#00FF00'
}

Send-AwtrixNotification @notificationParameters
```

Preview a state-changing command without sending it:

```powershell
Send-AwtrixNotification -Device $clock -Text 'Preview' -WhatIf
```

## Pushed applications

AWTRIX NG pushed apps can be used as persistent-in-memory cards. This example
uploads one of the GIFs bundled with the module and combines it with text:

```powershell
$module = Get-Module -Name PSAwtrixNG
$assetPath = Join-Path -Path $module.ModuleBase -ChildPath 'Assets\heartbeat-green-compact.gif'
$icon = Set-AwtrixIcon -Device $clock -Path $assetPath

$card = @{
    text      = 'Build passed'
    textColor = '#00FF00'
    icon      = $icon.Id
}

Set-AwtrixPushedApp -Device $clock -Name build -App $card
Select-AwtrixApp -Device $clock -Name build

Remove-AwtrixPushedApp -Device $clock -Name build
```

`Set-AwtrixPushedApp` casts the supplied hashtable to `AwtrixApp`, so keys are
matched case-insensitively and sent using the exact camelCase names required by
AWTRIX NG:

```powershell
$card = [AwtrixApp] @{
    TEXT      = 'Build passed'
    TEXTCOLOR = '#00FF00'
    ICONMODE  = 'fixed'
    SCROLL    = @{
        WHENFITS = 'static'
    }
}

Set-AwtrixPushedApp -Device $clock -Name build -App $card
```

The bare `[AwtrixApp]`, `[AwtrixNotification]`, and `[AwtrixScroll]`
accelerators are registered when the module is imported. Module-qualified
forms such as `[PSAwtrixNG.AwtrixApp]` are also available when avoiding
potential type-name collisions is preferable.

## Display settings

`Set-AwtrixSetting` uses the strict NG settings PATCH endpoint and verifies the
full settings object returned by the firmware:

```powershell
Set-AwtrixSetting -Device $clock -Setting @{
    brightness    = 128
    appDurationMs = 7000
} -PassThru
```

Set an absolute brightness percentage, or adjust the current value by a number
of percentage points:

```powershell
Set-AwtrixBrightness -Device $clock -Level 50
Set-AwtrixBrightness -Device $clock -Increase 10
Set-AwtrixBrightness -Device $clock -Decrease 5
```

Read the normalized percentage, native value, and automatic-brightness state:

```powershell
Get-AwtrixBrightness -Device $clock
```

`-Level` accepts values from 0 through 100 and converts them to the firmware's
native 0 through 255 scale. Relative adjustments convert the current native
value to a percentage and are constrained to that range, so increasing 95% by
10 points results in 100% rather than an invalid value. Use `-PassThru` to
return the verified settings object, whose `brightness` property remains in the
native scale. When `autoBrightness` is enabled, the firmware may continue
adjusting the effective display brightness.

The focused commands use the `AwtrixBrightness` noun because they operate on a
single brightness value. `Get-AwtrixDisplay` remains the broader command for
matrix power, brightness, overlay, and moodlight state.

## Power and application navigation

Turn the matrix on or off without putting the device into deep sleep:

```powershell
Disable-AwtrixDisplay -Device $clock
Enable-AwtrixDisplay -Device $clock
```

Switch directly to a built-in, pushed, or script application, or move through the
application loop:

```powershell
Select-AwtrixApp -Device $clock -Name Time
Select-AwtrixApp -Device $clock -Next
Select-AwtrixApp -Device $clock -Previous
```

Stop automatic app-to-app rotation on the currently displayed app, then resume
it later:

```powershell
Disable-AwtrixAppRotation -Device $clock
Enable-AwtrixAppRotation -Device $clock
```

These commands update the persistent `autoTransition` setting. Manual
navigation with `Select-AwtrixApp` or the clock buttons remains available while
automatic rotation is disabled.

## Notifications and indicators

Dismiss the active notification:

```powershell
Remove-AwtrixNotification -Device $clock
```

Set or clear one of the three colored indicators:

```powershell
$indicatorParameters = @{
    Device    = $clock
    Indicator = 1
    Color     = '#FF0000'
    Blink     = 500
}

Set-AwtrixIndicator @indicatorParameters

Clear-AwtrixIndicator -Device $clock -Indicator 1
```

## Terminal screen preview

Render one screen snapshot directly in the terminal:

```powershell
Show-AwtrixScreen -Device $clock
```

Watch the screen and redraw the same terminal area whenever its pixels change:

```powershell
$watchParameters = @{
    Device               = $clock
    IntervalMilliseconds = 250
    DurationSec          = 60
}

Watch-AwtrixScreen @watchParameters
```

Automatic rendering uses ANSI 24-bit color when the host supports virtual
terminal sequences. Otherwise, each pixel is mapped to the nearest of the
sixteen standard console colors. Use `-RenderingMode Ansi` or
`-RenderingMode ConsoleColor` to select a mode explicitly. ANSI rendering
updates the existing frame in place; the ConsoleColor fallback appends frames.

Add `-PassThru` to receive structured frame objects while rendering. Each frame
contains its dimensions, capture time, signature, and pixels with `X`, `Y`,
`Red`, `Green`, `Blue`, `Hex`, and packed `Value` properties.

By default, unchanged frames are not redrawn or returned. Use `-ShowUnchanged`
when every poll must be visible.

## Icons and files

`Set-AwtrixIcon` uses the multipart `POST /api/v1/files` endpoint to upload GIF
and JPEG icons. `Get-AwtrixFile` lists the supported asset directories,
`Get-AwtrixIcon` returns icon IDs, and `Save-AwtrixIcon` and
`Remove-AwtrixIcon` provide download and deletion. Use `Get-AwtrixStorage` to
see total, used, and free device filesystem space.

See [Icons and files](Icons-and-Files.md) for complete examples and storage
behavior.

## Other documented endpoints

Use `Invoke-AwtrixApi` when a dedicated command is not available:

```powershell
Invoke-AwtrixApi -Device $clock -Path 'api/v1/capabilities'
```

For a write request:

```powershell
$apiParameters = @{
    Device = $clock
    Path   = 'api/v1/notifications'
    Method = 'Post'
    Body   = @{ text = 'Hello'; textColor = '#00FF00' }
    WhatIf = $true
}

Invoke-AwtrixApi @apiParameters
```

See [Safety and testing](Safety-and-Testing.md) before invoking endpoints that
reboot, reset, erase, update, or put a device into deep sleep.
