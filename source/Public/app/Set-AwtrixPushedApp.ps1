<#
    .SYNOPSIS
        Creates or updates an AWTRIX NG pushed app.

    .DESCRIPTION
        Creates or updates a RAM-only pushed app. Existing apps with the same
        name are updated immediately and pushed apps are lost after reboot.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies a pushed app name containing letters, numbers, underscores,
        or hyphens.

    .PARAMETER App
        Specifies the pushed app payload. Hashtable keys are matched
        case-insensitively and serialized with the firmware's canonical casing.

    .EXAMPLE
        $card = @{
            text      = 'Build passed'
            textColor = '#00FF00'
            icon      = 'heartbeat-green-compact'
        }

        Set-AwtrixPushedApp -Device '192.168.88.202' -Name build -App $card
#>
function Set-AwtrixPushedApp
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]{1,32}$')]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [AwtrixApp]
        $App
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Create or update AWTRIX pushed app '$Name'"))
        {
            Invoke-AwtrixApi -Device $resolvedDevice -Path "api/v1/apps/pushed/$Name" -Method Put -Body $App -Confirm:$false
        }
    }
}
