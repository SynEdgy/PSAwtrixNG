<#
    .SYNOPSIS
        Sends a one-time notification to an AWTRIX NG device.

    .DESCRIPTION
        Posts a notification payload to the AWTRIX NG notifications endpoint.
        The command supports common text options and additional payload fields.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Text
        Specifies the text displayed in the AWTRIX notification.

    .PARAMETER Icon
        Specifies an AWTRIX icon identifier, local icon name, or base64 icon value.

    .PARAMETER Color
        Specifies a six-digit hexadecimal text color such as #00FF00.

    .PARAMETER Duration
        Specifies how many seconds the notification remains visible.

    .PARAMETER Hold
        Keeps the notification visible until it is dismissed.

    .PARAMETER Wakeup
        Temporarily wakes the matrix when the notification is displayed.

    .PARAMETER Property
        Specifies additional AWTRIX notification properties. Hashtable keys are
        matched case-insensitively and serialized with canonical firmware casing.

    .EXAMPLE
        Send-AwtrixNotification -Device 'clock.local' -Text 'Build complete' -Color '#00FF00'
#>
function Send-AwtrixNotification
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Text,

        [Parameter()]
        [System.String]
        $Icon,

        [Parameter()]
        [ValidatePattern('^#?[0-9A-Fa-f]{6}$')]
        [System.String]
        $Color,

        [Parameter()]
        [ValidateRange(1, 86400)]
        [System.Int32]
        $Duration = 5,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Hold,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Wakeup,

        [Parameter()]
        [AwtrixNotification]
        $Property
    )

    process
    {
        $payload = [AwtrixNotification]::new()
        $payload.text = $Text
        $payload.durationMs = $Duration * 1000

        if ($Icon) { $payload.icon = $Icon }
        if ($Color) { $payload.textColor = $Color }
        if ($Hold) { $payload.hold = $true }
        if ($Wakeup) { $payload.wakeup = $true }

        if ($Property)
        {
            foreach ($propertyEntry in $Property.PSObject.Properties)
            {
                if ($null -ne $propertyEntry.Value)
                {
                    $payload.($propertyEntry.Name) = $propertyEntry.Value
                }
            }
        }

        $resolvedDevice = Resolve-AwtrixDevice -Device $Device

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, 'Send AWTRIX notification'))
        {
            Invoke-AwtrixApi -Device $resolvedDevice -Path 'api/v1/notifications' -Method Post -Body $payload -Confirm:$false
        }
    }
}
