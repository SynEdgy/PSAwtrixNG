<#
    .SYNOPSIS
        Sets or adjusts the AWTRIX NG display brightness.

    .DESCRIPTION
        Sets the display brightness to a percentage between 0 and 100, or
        increases or decreases the current percentage. Relative adjustments are
        constrained to the supported range. Percentage values are converted to
        the firmware's native 0 through 255 brightness scale.

        This command changes the manual brightness setting. If automatic
        brightness is enabled, the firmware can continue adjusting the
        effective display brightness.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Level
        Specifies the absolute brightness percentage from 0 through 100.

    .PARAMETER Increase
        Specifies how many percentage points to add to the current brightness.

    .PARAMETER Decrease
        Specifies how many percentage points to subtract from the current brightness.

    .PARAMETER PassThru
        Returns the settings object after the brightness change is verified.

    .EXAMPLE
        Set-AwtrixBrightness -Device '192.168.88.202' -Level 50

    .EXAMPLE
        Set-AwtrixBrightness -Device '192.168.88.202' -Increase 10

    .EXAMPLE
        Set-AwtrixBrightness -Device '192.168.88.202' -Decrease 5 -PassThru
#>
function Set-AwtrixBrightness
{
    [CmdletBinding(DefaultParameterSetName = 'Level', SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true, ParameterSetName = 'Level')]
        [Alias('Brightness', 'Percent')]
        [ValidateRange(0, 100)]
        [System.Int32]
        $Level,

        [Parameter(Mandatory = $true, ParameterSetName = 'Increase')]
        [ValidateRange(1, 100)]
        [System.Int32]
        $Increase,

        [Parameter(Mandatory = $true, ParameterSetName = 'Decrease')]
        [ValidateRange(1, 100)]
        [System.Int32]
        $Decrease,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        $targetLevel = $Level

        if ($PSCmdlet.ParameterSetName -ne 'Level')
        {
            $settings = Get-AwtrixSettings -Device $resolvedDevice
            $brightnessProperty = $settings.PSObject.Properties['brightness']

            if (-not $brightnessProperty)
            {
                throw "AWTRIX brightness could not be adjusted because the device did not return the 'brightness' setting."
            }

            $currentBrightness = [System.Int32] $brightnessProperty.Value

            if ($currentBrightness -lt 0 -or $currentBrightness -gt 255)
            {
                throw "AWTRIX brightness could not be adjusted because the device returned an invalid brightness value of $currentBrightness."
            }

            $currentLevel = [System.Int32] [System.Math]::Round(
                ($currentBrightness * 100) / 255,
                [System.MidpointRounding]::AwayFromZero
            )

            if ($PSCmdlet.ParameterSetName -eq 'Increase')
            {
                $targetLevel = [System.Math]::Min(100, $currentLevel + $Increase)
            }
            else
            {
                $targetLevel = [System.Math]::Max(0, $currentLevel - $Decrease)
            }
        }

        $targetBrightness = [System.Int32] [System.Math]::Round(
            ($targetLevel * 255) / 100,
            [System.MidpointRounding]::AwayFromZero
        )

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Set AWTRIX brightness to $targetLevel percent"))
        {
            $settingParameters = @{
                Device   = $resolvedDevice
                Setting  = @{ brightness = $targetBrightness }
                PassThru = $PassThru
                Confirm  = $false
            }

            Set-AwtrixSetting @settingParameters
        }
    }
}
