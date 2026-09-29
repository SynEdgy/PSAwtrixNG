<#
    .SYNOPSIS
        Installs an AWTRIX NG OTA firmware image.

    .DESCRIPTION
        Uploads a local AWTRIX NG OTA image to the device update endpoint. The
        command requires an explicit firmware-update opt-in and high-impact
        ShouldProcess confirmation. It validates the local file and checks the
        ESP image signature before the device validates the complete image,
        chip type, PSRAM variant, image size, and OTA slot.

        Use an OTA image such as firmware-awtrix-ng.bin. Do not use a full USB
        flash image such as usb-awtrix-ng-4mb.bin with this command. A successful
        upload causes the device to reboot.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Path
        Specifies the local AWTRIX NG OTA firmware .bin file.

    .PARAMETER AllowFirmwareUpdate
        Explicitly permits the firmware update. ShouldProcess confirmation still
        applies unless it is suppressed with -Confirm:$false.

    .EXAMPLE
        Update-AwtrixFirmware -Device 'clock.local' -Path '.\firmware-awtrix-ng.bin' -AllowFirmwareUpdate -WhatIf

    .EXAMPLE
        Update-AwtrixFirmware -Device 'clock.local' -Path '.\firmware-awtrix-ng.bin' -AllowFirmwareUpdate
#>
function Update-AwtrixFirmware
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [ValidateScript(
            {
                if (-not (Test-Path -LiteralPath $_ -PathType Leaf))
                {
                    throw "Firmware file '$_' does not exist."
                }
                $true
            }
        )]
        [System.String]
        $Path,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $AllowFirmwareUpdate
    )

    process
    {
        if (-not $AllowFirmwareUpdate)
        {
            throw 'Firmware installation requires -AllowFirmwareUpdate.'
        }

        $firmwareFile = Get-Item -LiteralPath $Path -ErrorAction Stop
        if ($firmwareFile.Extension -ine '.bin')
        {
            throw "Firmware file '$($firmwareFile.FullName)' must have a .bin extension."
        }

        if ($firmwareFile.Name -like 'usb-*')
        {
            throw "Firmware file '$($firmwareFile.Name)' is a USB flash image and cannot be installed through OTA."
        }

        $headerStream = [System.IO.File]::OpenRead($firmwareFile.FullName)
        try
        {
            $imageMagic = $headerStream.ReadByte()
        }
        finally
        {
            $headerStream.Dispose()
        }

        if ($imageMagic -ne 0xE9)
        {
            throw "Firmware file '$($firmwareFile.FullName)' does not contain a valid ESP image signature."
        }

        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        $target = [System.Uri]::new($resolvedDevice.BaseUri, 'update').AbsoluteUri
        $action = "Install firmware image '$($firmwareFile.FullName)' and reboot the device"
        if ($PSCmdlet.ShouldProcess($target, $action))
        {
            $uploadParameters = @{
                Device      = $resolvedDevice
                Path        = 'update'
                FieldName   = 'firmware'
                FilePath    = $firmwareFile.FullName
                FileName    = $firmwareFile.Name
                ContentType = 'application/octet-stream'
            }
            $response = Invoke-AwtrixMultipartUpload @uploadParameters
            if (-not $response -or $response.ok -ne $true)
            {
                throw 'AWTRIX NG did not accept the firmware update.'
            }

            [PSCustomObject] @{
                Device       = $resolvedDevice.BaseUri.AbsoluteUri
                FirmwarePath = $firmwareFile.FullName
                Accepted     = $true
                Rebooting    = $true
            }
        }
    }
}
