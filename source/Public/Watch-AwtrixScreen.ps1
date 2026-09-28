<#
    .SYNOPSIS
        Watches and renders an AWTRIX NG screen in the terminal.

    .DESCRIPTION
        Polls the AWTRIX screen endpoint and redraws the matrix whenever its
        pixels change. The watch runs until interrupted unless DurationSec or
        FrameCount is specified.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER IntervalMilliseconds
        Specifies the delay between screen polls in milliseconds.

    .PARAMETER DurationSec
        Specifies the maximum watch duration in seconds. Zero means no time limit.

    .PARAMETER FrameCount
        Specifies the maximum number of screen polls. Zero means no frame limit.

    .PARAMETER RenderingMode
        Specifies automatic, ANSI true-color, or ConsoleColor rendering.

    .PARAMETER ShowUnchanged
        Redraws frames even when their pixel data has not changed.

    .PARAMETER PassThru
        Returns each rendered frame for additional processing.

    .EXAMPLE
        Watch-AwtrixScreen -Device 'clock.local'

    .EXAMPLE
        Watch-AwtrixScreen -Device 'clock.local' -DurationSec 30 -PassThru
#>
function Watch-AwtrixScreen
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Device,

        [Parameter()]
        [ValidateRange(100, 60000)]
        [System.Int32]
        $IntervalMilliseconds = 500,

        [Parameter()]
        [ValidateRange(0, 86400)]
        [System.Int32]
        $DurationSec = 0,

        [Parameter()]
        [ValidateRange(0, 1000000)]
        [System.Int32]
        $FrameCount = 0,

        [Parameter()]
        [AwtrixTerminalRenderingMode]
        $RenderingMode = [AwtrixTerminalRenderingMode]::Auto,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ShowUnchanged,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $pollCount = 0
    $lastSignature = $null

    while (
        ($FrameCount -eq 0 -or $pollCount -lt $FrameCount) -and
        ($DurationSec -eq 0 -or $stopwatch.Elapsed.TotalSeconds -lt $DurationSec)
    )
    {
        $frame = Get-AwtrixScreen -Device $Device -AsFrame
        $pollCount++

        if ($ShowUnchanged -or $frame.Signature -ne $lastSignature)
        {
            $renderParameters = @{
                Frame         = $frame
                RenderingMode = $RenderingMode
                Redraw        = $null -ne $lastSignature
            }

            Write-AwtrixScreenFrame @renderParameters
            $lastSignature = $frame.Signature

            if ($PassThru)
            {
                $frame
            }
        }

        $hasMoreFrames = $FrameCount -eq 0 -or $pollCount -lt $FrameCount
        $hasMoreTime = $DurationSec -eq 0 -or $stopwatch.Elapsed.TotalSeconds -lt $DurationSec

        if ($hasMoreFrames -and $hasMoreTime)
        {
            Start-Sleep -Milliseconds $IntervalMilliseconds
        }
    }
}
