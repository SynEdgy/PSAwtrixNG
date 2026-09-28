<#
    .SYNOPSIS
        Gets icons stored on an AWTRIX NG device.

    .DESCRIPTION
        Gets GIF and JPEG icon metadata from the AWTRIX NG ICONS directory. The
        returned Id is the case-sensitive file name without its extension and
        is the value used by notification, pushed-app, and Berry icon fields.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies an exact, case-sensitive icon file name, including .gif or .jpg.

    .EXAMPLE
        Get-AwtrixIcon -Device 'clock.local'

    .EXAMPLE
        Get-AwtrixIcon -Device 'clock.local' -Name 'logo.gif'
#>
function Get-AwtrixIcon
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter()]
        [ValidateLength(5, 68)]
        [ValidateScript(
            {
                [ValidateLength(1, 64)]
                [System.String] $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_)
                if ($_ -match '[/\\"]|[\x00-\x1F]' -or $_ -match '\.\.' -or
                    $_ -notmatch '(?i)\.(gif|jpg)$')
                {
                    throw "Icon name '$_' must be a traversal-safe .gif or .jpg file name with an ID no longer than 64 characters."
                }
                $true
            }
        )]
        [System.String]
        $Name
    )

    process
    {
        $parameters = @{
            Device    = $Device
            Directory = 'ICONS'
        }
        if ($Name)
        {
            $parameters.Name = $Name
        }

        foreach ($file in @(Get-AwtrixFile @parameters))
        {
            [PSCustomObject] @{
                PSTypeName = 'PSAwtrixNG.Icon'
                Id         = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                Name       = $file.Name
                Path       = $file.Path
                SizeBytes  = $file.SizeBytes
                UsedBytes  = $file.UsedBytes
                FreeBytes  = $file.FreeBytes
                TotalBytes = $file.TotalBytes
                Uri        = $file.Uri
            }
        }
    }
}
