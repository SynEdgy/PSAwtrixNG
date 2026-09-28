<#
    .SYNOPSIS
        Lists files stored on an AWTRIX NG device.

    .DESCRIPTION
        Lists files in one or more AWTRIX NG asset directories and returns file
        metadata together with the device storage usage. This is the AWTRIX
        equivalent of using Get-ChildItem for supported device asset folders.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Directory
        Specifies one or more asset directories. All supported directories are
        listed by default.

    .PARAMETER Name
        Specifies an exact, case-sensitive file name to return.

    .EXAMPLE
        Get-AwtrixFile -Device 'clock.local' -Directory ICONS

    .EXAMPLE
        Get-AwtrixFile -Device 'clock.local' -Directory ICONS -Name logo.gif
#>
function Get-AwtrixFile
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter()]
        [ValidateSet('ICONS', 'MELODIES', 'PALETTES', 'MP3')]
        [System.String[]]
        $Directory = @('ICONS', 'MELODIES', 'PALETTES', 'MP3'),

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device

        foreach ($directoryName in $Directory)
        {
            $directoryPath = "/$directoryName"
            $response = Invoke-AwtrixApi -Device $resolvedDevice -Path 'api/v1/files' -Query @{ dir = $directoryPath }
            $usedBytes = [System.Int64] $response.usedBytes
            $totalBytes = [System.Int64] $response.totalBytes

            foreach ($file in @($response.files))
            {
                if ($Name -and [System.String] $file.name -cne $Name)
                {
                    continue
                }

                $fileName = [System.String] $file.name
                $fileName = $fileName.Substring($fileName.LastIndexOf('/') + 1)
                $filePath = "$directoryPath/$fileName"
                $escapedName = [System.Uri]::EscapeDataString($fileName)

                [PSCustomObject] @{
                    PSTypeName = 'PSAwtrixNG.File'
                    Name       = $fileName
                    Directory  = $directoryName
                    Path       = $filePath
                    SizeBytes  = [System.Int64] $file.size
                    UsedBytes  = $usedBytes
                    FreeBytes  = $totalBytes - $usedBytes
                    TotalBytes = $totalBytes
                    Uri        = [System.Uri]::new($resolvedDevice.BaseUri, "$directoryName/$escapedName")
                }
            }
        }
    }
}
