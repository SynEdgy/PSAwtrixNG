<#
    .SYNOPSIS
        Downloads an icon from an AWTRIX NG device.

    .DESCRIPTION
        Downloads a named GIF or JPEG icon to a local file. Existing local files
        are not overwritten unless Force is specified.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the exact, case-sensitive icon file name to download.

    .PARAMETER Path
        Specifies a destination directory or file path.

    .PARAMETER Force
        Overwrites an existing local destination file.

    .EXAMPLE
        Save-AwtrixIcon -Device 'clock.local' -Name 'logo.gif' -Path '.'
#>
function Save-AwtrixIcon
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.IO.FileInfo])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [ValidateLength(5, 68)]
        [ValidateScript(
            {
                [ValidateLength(1, 64)]
                [System.String] $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_)
                if ($_ -match '[/\\"]|[\x00-\x1F]' -or $_ -match '\.\.' -or
                    $_ -notmatch '(?i)\.(gif|jpg)$')
                {
                    throw "Icon name '$_' must be a traversal-safe .gif or .jpg file name with an ID no longer than 64 characters."
                }
                $true
            }
        )]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    process
    {
        $icon = Get-AwtrixIcon -Device $Device -Name $Name
        if (-not $icon)
        {
            throw "AWTRIX NG icon '$Name' was not found."
        }

        $destinationPath = if (Test-Path -LiteralPath $Path -PathType Container)
        {
            Join-Path -Path $Path -ChildPath $Name
        }
        else
        {
            $Path
        }

        $parentPath = Split-Path -Path $destinationPath -Parent
        if ($parentPath -and -not (Test-Path -LiteralPath $parentPath -PathType Container))
        {
            throw "Destination directory '$parentPath' does not exist."
        }
        if ((Test-Path -LiteralPath $destinationPath) -and -not $Force)
        {
            throw "Destination file '$destinationPath' already exists. Use -Force to overwrite it."
        }

        if ($PSCmdlet.ShouldProcess($destinationPath, "Download AWTRIX NG icon '$Name'"))
        {
            $resolvedDevice = Resolve-AwtrixDevice -Device $Device
            $requestParameters = @{
                Uri         = $icon.Uri
                OutFile     = $destinationPath
                TimeoutSec  = $resolvedDevice.TimeoutSec
                ErrorAction = 'Stop'
            }
            if ($resolvedDevice.Credential)
            {
                $networkCredential = $resolvedDevice.Credential.GetNetworkCredential()
                $basicValue = '{0}:{1}' -f $networkCredential.UserName, $networkCredential.Password
                $basicBytes = [System.Text.Encoding]::UTF8.GetBytes($basicValue)
                $basicToken = [System.Convert]::ToBase64String($basicBytes)
                $requestParameters.Headers = @{ Authorization = "Basic $basicToken" }
            }
            if ($PSVersionTable.PSVersion.Major -lt 6)
            {
                $requestParameters.UseBasicParsing = $true
            }

            $null = Invoke-WebRequest @requestParameters
            Get-Item -LiteralPath $destinationPath
        }
    }
}
