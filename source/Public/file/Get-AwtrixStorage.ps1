<#
    .SYNOPSIS
        Gets storage usage from an AWTRIX NG device.

    .DESCRIPTION
        Gets the shared filesystem capacity used by icons, melodies, palettes,
        MP3 files, and Berry scripts. Returns total, used, and free space as
        bytes and mebibytes, together with used and free percentages.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Get-AwtrixStorage -Device '192.168.88.202'
#>
function Get-AwtrixStorage
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        $response = Invoke-AwtrixApi -Device $resolvedDevice -Path 'api/v1/files' -Query @{ dir = '/ICONS' }

        if ($null -eq $response.PSObject.Properties['usedBytes'] -or
            $null -eq $response.PSObject.Properties['totalBytes'])
        {
            throw 'AWTRIX NG storage response did not include usedBytes and totalBytes.'
        }

        $usedBytes = [System.Int64] $response.usedBytes
        $totalBytes = [System.Int64] $response.totalBytes
        if ($usedBytes -lt 0 -or $totalBytes -lt 0 -or $usedBytes -gt $totalBytes)
        {
            throw "AWTRIX NG returned invalid storage values: $usedBytes used of $totalBytes total bytes."
        }

        $freeBytes = $totalBytes - $usedBytes
        $usedPercent = if ($totalBytes -eq 0)
        {
            0
        }
        else
        {
            [System.Math]::Round(($usedBytes / $totalBytes) * 100, 2)
        }

        [PSCustomObject] @{
            PSTypeName  = 'PSAwtrixNG.Storage'
            UsedBytes   = $usedBytes
            FreeBytes   = $freeBytes
            TotalBytes  = $totalBytes
            UsedMiB     = [System.Math]::Round($usedBytes / 1MB, 2)
            FreeMiB     = [System.Math]::Round($freeBytes / 1MB, 2)
            TotalMiB    = [System.Math]::Round($totalBytes / 1MB, 2)
            UsedPercent = $usedPercent
            FreePercent = [System.Math]::Round(100 - $usedPercent, 2)
        }
    }
}
