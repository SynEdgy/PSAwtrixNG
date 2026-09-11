<#
    .SYNOPSIS
        Displays an AWTRIX NG screen frame in the terminal.

    .DESCRIPTION
        Retrieves or accepts an AWTRIX screen frame and renders its matrix using
        two terminal cells per pixel.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Frame
        Specifies a frame returned by Get-AwtrixScreen with the AsFrame switch.

    .PARAMETER RenderingMode
        Specifies automatic, ANSI true-color, or ConsoleColor rendering.

    .PARAMETER PassThru
        Returns the structured frame after rendering it.

    .EXAMPLE
        Show-AwtrixScreen -Device '192.168.88.202'

    .EXAMPLE
        Get-AwtrixScreen -Device '192.168.88.202' -AsFrame | Show-AwtrixScreen
#>
function Show-AwtrixScreen
{
    [CmdletBinding(DefaultParameterSetName = 'Device')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Device')]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Frame')]
        [PSTypeName('PSAwtrixNG.ScreenFrame')]
        [System.Object]
        $Frame,

        [Parameter()]
        [AwtrixTerminalRenderingMode]
        $RenderingMode = [AwtrixTerminalRenderingMode]::Auto,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    process
    {
        $screenFrame = if ($PSCmdlet.ParameterSetName -eq 'Frame')
        {
            $Frame
        }
        else
        {
            Get-AwtrixScreen -Device $Device -AsFrame
        }

        Write-AwtrixScreenFrame -Frame $screenFrame -RenderingMode $RenderingMode

        if ($PassThru)
        {
            $screenFrame
        }
    }
}
