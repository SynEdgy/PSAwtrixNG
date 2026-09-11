<#
    .SYNOPSIS
        Renders an AWTRIX screen frame in the current terminal.

    .DESCRIPTION
        Writes a frame using two terminal cells per pixel. ANSI mode uses
        24-bit background colors, while ConsoleColor mode maps pixels to the
        nearest color in the standard console palette.

    .PARAMETER Frame
        Specifies a structured AWTRIX screen frame.

    .PARAMETER RenderingMode
        Specifies automatic, ANSI true-color, or ConsoleColor rendering.

    .PARAMETER Redraw
        Moves the cursor to the previous frame before rendering when ANSI mode is active.

    .EXAMPLE
        Write-AwtrixScreenFrame -Frame $frame -RenderingMode Auto
#>
function Write-AwtrixScreenFrame
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost',
        '',
        Justification = 'This function intentionally renders colored pixels directly in the interactive host.'
    )]
    [CmdletBinding()]
    [OutputType([System.Void])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Frame,

        [Parameter()]
        [AwtrixTerminalRenderingMode]
        $RenderingMode = [AwtrixTerminalRenderingMode]::Auto,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Redraw
    )

    $supportsVirtualTerminal = $false
    $supportsVirtualTerminalProperty = $Host.UI.PSObject.Properties['SupportsVirtualTerminal']

    if ($supportsVirtualTerminalProperty)
    {
        $supportsVirtualTerminal = [System.Boolean] $supportsVirtualTerminalProperty.Value
    }

    $useAnsi = $RenderingMode -eq [AwtrixTerminalRenderingMode]::Ansi -or
        (
            $RenderingMode -eq [AwtrixTerminalRenderingMode]::Auto -and
            $supportsVirtualTerminal
        )

    if ($useAnsi)
    {
        $escape = [System.Char] 27

        if ($Redraw)
        {
            Write-Host -Object "$escape[$($Frame.Height)A$escape[1G" -NoNewline
        }

        for ($row = 0; $row -lt $Frame.Height; $row++)
        {
            $line = [System.Text.StringBuilder]::new()

            foreach ($pixel in $Frame.Pixels | Where-Object -Property Y -EQ -Value $row)
            {
                $pixelText = '{0}[48;2;{1};{2};{3}m  ' -f
                    $escape,
                    $pixel.Red,
                    $pixel.Green,
                    $pixel.Blue
                $null = $line.Append($pixelText)
            }

            $null = $line.Append("$escape[0m")
            Write-Host -Object $line.ToString()
        }

        return
    }

    for ($row = 0; $row -lt $Frame.Height; $row++)
    {
        foreach ($pixel in $Frame.Pixels | Where-Object -Property Y -EQ -Value $row)
        {
            $colorParameters = @{
                Red   = $pixel.Red
                Green = $pixel.Green
                Blue  = $pixel.Blue
            }
            $consoleColor = Get-AwtrixConsoleColor @colorParameters
            Write-Host -Object '  ' -BackgroundColor $consoleColor -NoNewline
        }

        Write-Host
    }
}
