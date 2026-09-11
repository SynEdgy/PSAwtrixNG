# Icons and files

AWTRIX NG stores static logos and animated images as files in its `/ICONS`
directory. `PSAwtrixNG` can upload, list, download, and remove those icons.

The module also includes ready-to-upload GIFs under its `Assets` directory.
Sampler copies this directory into every built and packaged module.

## Supported icon files

The AWTRIX NG file API accepts:

- Animated or static GIF files with a `.gif` extension.
- JPEG files with a `.jpg` extension.

PNG files are not accepted by the direct device API. Convert PNG images to GIF
before uploading them.

GIF frames must not exceed 32×8 pixels. A full-width 32×8 GIF is rendered as a
background. JPEG files are best kept to 8×8 pixels. AWTRIX uses the GIF when
both `<id>.gif` and `<id>.jpg` exist.

## Upload an icon

```powershell
$clock = New-AwtrixDevice -HostName '192.168.88.202'
$icon = Set-AwtrixIcon -Device $clock -Path '.\logo.gif'

$icon
$icon.Id
```

The returned `Id` is the case-sensitive file name without its extension. For
example, uploading `logo.gif` returns the ID `logo`.

Use `-Name` to choose a different destination name:

```powershell
$uploadParameters = @{
    Device = $clock
    Path   = '.\build-animation.gif'
    Name   = 'build.gif'
}
$icon = Set-AwtrixIcon @uploadParameters
```

If `Name` has no extension, the source extension is appended.

Before uploading, `Set-AwtrixIcon` reads the device's filesystem usage. When
the file cannot fit, the command writes a warning and does not start the
upload. Replacing an existing file accounts for the bytes that file currently
occupies. The preflight also retains 4096 bytes as a conservative filesystem
reserve. The completed upload is read back and its size is verified.

AWTRIX NG truncates an existing destination before it has fully received and
validated a replacement. If a replacement upload fails, the previous icon may
have been removed; the command includes that risk in its error message.

## List device files

`Get-AwtrixFile` is the AWTRIX equivalent of `Get-ChildItem` for supported asset
directories:

```powershell
Get-AwtrixFile -Device $clock
Get-AwtrixFile -Device $clock -Directory ICONS
Get-AwtrixFile -Device $clock -Directory ICONS -Name 'logo.gif'
Get-AwtrixFile -Device $clock -Directory ICONS, MELODIES
```

Supported directories are `ICONS`, `MELODIES`, `PALETTES`, and `MP3`. Each
result includes:

- `Name`, `Directory`, and full device `Path`.
- `SizeBytes`.
- `UsedBytes`, `FreeBytes`, and `TotalBytes` for the shared filesystem.
- The static file `Uri`.

Name matching is exact and case-sensitive.

## Get an icon ID

Use `Get-AwtrixIcon` to list icons or resolve one file to the ID expected by
AWTRIX payloads:

```powershell
Get-AwtrixIcon -Device $clock

$logo = Get-AwtrixIcon -Device $clock -Name 'logo.gif'
$logo.Id
```

The second example returns `logo` through the `Id` property.

## Use an uploaded icon

Pass the ID, not the file name or `/ICONS` path:

```powershell
$logo = Get-AwtrixIcon -Device $clock -Name 'logo.gif'

$notificationParameters = @{
    Device = $clock
    Text   = 'Build complete'
    Icon   = $logo.Id
}
Send-AwtrixNotification @notificationParameters
```

The same ID can be used in pushed-app payloads and Berry `icon()` calls.

## Create a card with an included icon

Pushed apps are useful as named cards containing an icon and text. Resolve the
module installation directory, upload an included 8×8 icon, then use its ID in
the card payload:

```powershell
$module = Get-Module -Name PSAwtrixNG
$assetPath = Join-Path -Path $module.ModuleBase -ChildPath 'Assets\heartbeat-green-compact.gif'
$icon = Set-AwtrixIcon -Device $clock -Path $assetPath

$card = @{
    text      = 'Service healthy'
    textColor = '#00FF00'
    icon      = $icon.Id
}

Set-AwtrixPushedApp -Device $clock -Name service_health -App $card
Select-AwtrixApp -Device $clock -Name service_health
```

Use an 8×8 asset when the icon should appear beside the text. A 32×8 GIF fills
the display and is rendered as a background behind the text.

The bundled Minecraft Creeper, Steve, and Alex heads are 8×8 side icons. If an
older 32×8 copy is already on the device, upload the asset again to replace it.

## Download an icon

Save to a directory:

```powershell
Save-AwtrixIcon -Device $clock -Name 'logo.gif' -Path '.'
```

Or choose the complete destination path:

```powershell
$saveParameters = @{
    Device = $clock
    Name   = 'logo.gif'
    Path   = '.\backup\clock-logo.gif'
    Force  = $true
}
Save-AwtrixIcon @saveParameters
```

Existing local files are not overwritten unless `-Force` is used.

## Remove an icon

```powershell
Remove-AwtrixIcon -Device $clock -Name 'logo.gif'
```

Removal uses the complete device path `/ICONS/logo.gif` and supports `-WhatIf`.

## Storage considerations

Icons, scripts, melodies, palettes, and MP3 files share the device filesystem.
Small 8×8 GIFs are inexpensive, while long or full-width animations can use
substantially more flash and runtime memory.

```powershell
Get-AwtrixFile -Device $clock -Directory ICONS |
    Select-Object Name, SizeBytes, UsedBytes, FreeBytes, TotalBytes
```

The storage values reported by the device are authoritative. A factory reset
removes stored assets.
