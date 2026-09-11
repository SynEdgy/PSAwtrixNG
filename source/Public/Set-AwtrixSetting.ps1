<#
    .SYNOPSIS
        Updates one or more AWTRIX NG display settings.

    .DESCRIPTION
        Patches selected settings through the AWTRIX NG settings endpoint and
        verifies that every requested value was applied by the firmware.
        This command does not expose Wi-Fi, authentication, or firmware settings.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Setting
        Specifies AWTRIX display setting keys and values, such as BRI, ABRI, or ATIME.

    .PARAMETER SkipVerification
        Skips the follow-up settings read and returns the firmware write response.

    .PARAMETER PassThru
        Returns the settings object read after successful verification.

    .EXAMPLE
        Set-AwtrixSetting -Device '192.168.88.202' -Setting @{ BRI = 100 } -WhatIf
#>
function Set-AwtrixSetting
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Management.Automation.PSCustomObject], [System.Object])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.IDictionary]
        $Setting,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $SkipVerification,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        $settingNames = @($Setting.Keys) -join ', '

        if (-not $PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Update AWTRIX display settings: $settingNames"))
        {
            return
        }

        $writeResponse = Invoke-AwtrixApi -Device $resolvedDevice -Path 'api/v1/settings' -Method Patch -Body $Setting -Confirm:$false

        if ($SkipVerification)
        {
            return $writeResponse
        }

        $updatedSettings = $writeResponse

        foreach ($entry in $Setting.GetEnumerator())
        {
            $actualProperty = $updatedSettings.PSObject.Properties[[System.String] $entry.Key]

            if (-not $actualProperty)
            {
                throw "AWTRIX settings verification failed because '$($entry.Key)' was not returned by the device."
            }

            $expectedJson = ConvertTo-Json -InputObject $entry.Value -Depth 20 -Compress
            $actualJson = ConvertTo-Json -InputObject $actualProperty.Value -Depth 20 -Compress

            if ($actualJson -cne $expectedJson)
            {
                throw "AWTRIX settings verification failed for '$($entry.Key)'. Expected $expectedJson but received $actualJson."
            }
        }

        if ($PassThru)
        {
            $updatedSettings
        }
    }
}
