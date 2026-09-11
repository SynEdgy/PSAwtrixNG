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

```powershell
Set-AwtrixPushedApp -Device $clock -Name build -App @{
    text      = 'Build passed'
    textColor = '#00FF00'
}

Remove-AwtrixPushedApp -Device $clock -Name build
```

## Display settings

`Set-AwtrixSetting` uses the strict NG settings PATCH endpoint and verifies the
full settings object returned by the firmware:

```powershell
Set-AwtrixSetting -Device $clock -Setting @{
    brightness    = 100
    appDurationMs = 7000
} -PassThru
```

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
`Remove-AwtrixIcon` provide download and deletion.

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
