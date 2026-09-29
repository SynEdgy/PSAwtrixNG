<#
    .SYNOPSIS
        Loads and renders a packaged AWTRIX NG Berry application template.

    .DESCRIPTION
        Reads a Berry application template from the module's Berry directory
        and replaces explicitly supplied double-brace tokens. It rejects missing
        templates and unresolved tokens before source is sent to a device.

    .PARAMETER Name
        Specifies the packaged Berry application directory and template name.

    .PARAMETER Token
        Specifies token names and replacement values. For example, APP_NAME
        replaces the template token {{APP_NAME}}.

    .EXAMPLE
        Get-AwtrixBerryAppSource -Name 'Stopwatch' -Token @{ APP_NAME = 'Stopwatch' }
#>
function Get-AwtrixBerryAppSource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]{1,32}$')]
        [System.String]
        $Name,

        [Parameter()]
        [System.Collections.IDictionary]
        $Token
    )

    $berryPath = Join-Path -Path $PSScriptRoot -ChildPath 'Berry'
    $appPath = Join-Path -Path $berryPath -ChildPath $Name
    $sourcePath = Join-Path -Path $appPath -ChildPath "$Name.be"
    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf))
    {
        throw "Packaged Berry application '$Name' was not found at '$sourcePath'."
    }

    $source = Get-Content -LiteralPath $sourcePath -Raw -ErrorAction Stop
    if ($Token)
    {
        foreach ($entry in $Token.GetEnumerator())
        {
            $placeholder = '{{' + [System.String] $entry.Key + '}}'
            $source = $source.Replace($placeholder, [System.String] $entry.Value)
        }
    }

    $unresolvedTokens = @(
        [System.Text.RegularExpressions.Regex]::Matches(
            $source,
            '\{\{[A-Z][A-Z0-9_]*\}\}'
        ) |
            ForEach-Object -Process { $_.Value } |
                Sort-Object -Unique
    )
    if ($unresolvedTokens.Count -gt 0)
    {
        throw "Berry application '$Name' contains unresolved tokens: $($unresolvedTokens -join ', ')."
    }

    $source
}
