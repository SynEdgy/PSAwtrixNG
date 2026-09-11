<#
    .SYNOPSIS
        Removes an icon from an AWTRIX NG device.

    .DESCRIPTION
        Removes a named GIF or JPEG file from the AWTRIX NG ICONS directory.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the exact, case-sensitive icon file name to remove.

    .EXAMPLE
        Remove-AwtrixIcon -Device '192.168.88.202' -Name 'logo.gif'
#>
function Remove-AwtrixIcon
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
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
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        $icon = Get-AwtrixIcon -Device $resolvedDevice -Name $Name
        if (-not $icon)
        {
            throw "AWTRIX NG icon '$Name' was not found."
        }

        if ($PSCmdlet.ShouldProcess(
                "$($resolvedDevice.BaseUri)ICONS/$Name",
                "Remove AWTRIX NG icon '$Name'"
            ))
        {
            Invoke-AwtrixApi -Device $resolvedDevice -Path 'api/v1/files' -Method Delete -Query @{
                path = "/ICONS/$Name"
            } -Confirm:$false
        }
    }
}
