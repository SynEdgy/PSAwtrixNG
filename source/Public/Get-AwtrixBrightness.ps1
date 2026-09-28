<#
    .SYNOPSIS
        Gets the AWTRIX NG display brightness.

    .DESCRIPTION
        Reads the current brightness setting and returns both a normalized
        percentage and the firmware's native 0 through 255 value. The result
        also indicates whether automatic brightness is enabled.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Get-AwtrixBrightness -Device 'clock.local'
#>
function Get-AwtrixBrightness
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
        $settings = Get-AwtrixSettings -Device $Device
        $brightnessProperty = $settings.PSObject.Properties['brightness']

        if (-not $brightnessProperty)
        {
            throw "AWTRIX brightness could not be read because the device did not return the 'brightness' setting."
        }

        $nativeValue = [System.Int32] $brightnessProperty.Value
        $autoBrightnessProperty = $settings.PSObject.Properties['autoBrightness']

        [PSCustomObject] @{
            PSTypeName     = 'PSAwtrixNG.Brightness'
            Percent        = ConvertFrom-AwtrixBrightnessValue -Value $nativeValue
            NativeValue    = $nativeValue
            AutoBrightness = if ($autoBrightnessProperty)
            {
                [System.Boolean] $autoBrightnessProperty.Value
            }
            else
            {
                $null
            }
        }
    }
}
