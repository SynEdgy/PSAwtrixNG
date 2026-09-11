<#
    .SYNOPSIS
        Gets the current AWTRIX NG matrix pixel data.

    .DESCRIPTION
        Reads the AWTRIX display screen endpoint and returns its width, height,
        and packed RGB24 pixel values. Use AsFrame to expand the values into
        structured pixels with coordinates and color channels.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER AsFrame
        Returns a structured frame with coordinates and RGB channels for each pixel.

    .EXAMPLE
        $screen = Get-AwtrixScreen -Device '192.168.88.202'

    .EXAMPLE
        $frame = Get-AwtrixScreen -Device '192.168.88.202' -AsFrame
#>
function Get-AwtrixScreen
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $AsFrame
    )

    process
    {
        $screen = Invoke-AwtrixApi -Device $Device -Path 'api/v1/display/screen'

        if ($AsFrame)
        {
            $resolvedDevice = Resolve-AwtrixDevice -Device $Device
            $frameParameters = @{
                PixelData = @($screen.pixels)
                Width     = [System.Int32] $screen.width
                Height    = [System.Int32] $screen.height
                Device    = $resolvedDevice
            }
            return ConvertTo-AwtrixScreenFrame @frameParameters
        }

        $screen
    }
}
