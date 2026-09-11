<#
    .SYNOPSIS
        Uploads a GIF or JPEG icon to an AWTRIX NG device.

    .DESCRIPTION
        Uploads a GIF or JPEG file to the AWTRIX NG ICONS directory using a
        PowerShell 5.1-compatible multipart request. Before uploading, the
        command compares the file size with available device storage. It emits
        a warning and does not upload when the file cannot fit.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Path
        Specifies the local GIF or JPEG file to upload.

    .PARAMETER Name
        Specifies the destination file name. When omitted, the local file name
        is used. A name without an extension inherits the source extension.

    .EXAMPLE
        Set-AwtrixIcon -Device '192.168.88.202' -Path '.\logo.gif'

    .EXAMPLE
        Set-AwtrixIcon -Device '192.168.88.202' -Path '.\build.gif' -Name 'status.gif'
#>
function Set-AwtrixIcon
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [ValidateScript(
            {
                if (-not (Test-Path -LiteralPath $_ -PathType Leaf))
                {
                    throw "Icon file '$_' does not exist."
                }
                $true
            }
        )]
        [System.String]
        $Path,

        [Parameter()]
        [ValidateLength(1, 68)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name
    )

    process
    {
        $resolvedPath = Get-Item -LiteralPath $Path -ErrorAction Stop
        $sourceExtension = $resolvedPath.Extension.ToLowerInvariant()
        if ($sourceExtension -notin @('.gif', '.jpg'))
        {
            throw "AWTRIX NG icon uploads support only .gif and .jpg files."
        }

        $destinationName = if ($Name)
        {
            if ([System.String]::IsNullOrEmpty([System.IO.Path]::GetExtension($Name)))
            {
                "$Name$sourceExtension"
            }
            else
            {
                $Name
            }
        }
        else
        {
            $resolvedPath.Name
        }

        [ValidateLength(1, 64)]
        [System.String] $destinationId = [System.IO.Path]::GetFileNameWithoutExtension($destinationName)
        if ($destinationName -match '[/\\"]|[\x00-\x1F]' -or
            $destinationName -match '\.\.' -or
            $destinationName -notmatch '(?i)\.(gif|jpg)$')
        {
            throw "Icon name '$destinationName' must be a traversal-safe .gif or .jpg file name with an ID no longer than 64 characters."
        }

        $destinationExtension = [System.IO.Path]::GetExtension($destinationName).ToLowerInvariant()
        if ($destinationExtension -ne $sourceExtension)
        {
            throw "Icon name extension '$destinationExtension' does not match source format '$sourceExtension'."
        }

        $header = [System.Byte[]]::new(6)
        $headerStream = [System.IO.File]::OpenRead($resolvedPath.FullName)
        try
        {
            $headerLength = 0
            while ($headerLength -lt $header.Length)
            {
                $readLength = $headerStream.Read(
                    $header,
                    $headerLength,
                    $header.Length - $headerLength
                )
                if ($readLength -eq 0)
                {
                    break
                }
                $headerLength += $readLength
            }
        }
        finally
        {
            $headerStream.Dispose()
        }
        $contentIsValid = if ($sourceExtension -eq '.gif')
        {
            $headerLength -ge 6 -and
                [System.Text.Encoding]::ASCII.GetString($header, 0, 6) -in @('GIF87a', 'GIF89a')
        }
        else
        {
            $headerLength -ge 3 -and
                $header[0] -eq 0xFF -and $header[1] -eq 0xD8 -and $header[2] -eq 0xFF
        }

        if (-not $contentIsValid)
        {
            throw "File '$($resolvedPath.FullName)' does not contain valid $sourceExtension icon signature bytes."
        }

        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        $storage = Invoke-AwtrixApi -Device $resolvedDevice -Path 'api/v1/files' -Query @{ dir = '/ICONS' }
        $existingFile = @($storage.files) |
            Where-Object {
                [System.IO.Path]::GetFileName([System.String] $_.name) -ceq $destinationName
            } |
            Select-Object -First 1
        $replaceableBytes = if ($existingFile) { [System.Int64] $existingFile.size } else { 0 }
        $availableBytes = [System.Int64] $storage.totalBytes -
            [System.Int64] $storage.usedBytes +
            $replaceableBytes
        $storageReserveBytes = 4096

        if ($resolvedPath.Length + $storageReserveBytes -gt $availableBytes)
        {
            Write-Warning ("Icon '{0}' requires {1} bytes plus a {2}-byte filesystem reserve, but only {3} bytes are available on the AWTRIX NG device. The file was not uploaded." -f
                $destinationName, $resolvedPath.Length, $storageReserveBytes, $availableBytes)
            return
        }

        if ($PSCmdlet.ShouldProcess(
                "$($resolvedDevice.BaseUri)ICONS/$destinationName",
                "Upload AWTRIX NG icon from '$($resolvedPath.FullName)'"
            ))
        {
            $uploadParameters = @{
                Device   = $resolvedDevice
                Path     = 'api/v1/files'
                Query    = @{ dir = '/ICONS' }
                FilePath = $resolvedPath.FullName
                FileName = $destinationName
            }
            try
            {
                $null = Invoke-AwtrixMultipartUpload @uploadParameters
            }
            catch
            {
                $replacementWarning = if ($existingFile)
                {
                    " The previous '$destinationName' may have been removed because AWTRIX NG truncates replacement files before streaming the new content."
                }
                else
                {
                    ''
                }
                throw "$($_.Exception.Message)$replacementWarning"
            }

            $uploadedIcon = Get-AwtrixIcon -Device $resolvedDevice -Name $destinationName
            if (-not $uploadedIcon -or $uploadedIcon.SizeBytes -ne $resolvedPath.Length)
            {
                throw "AWTRIX NG icon upload verification failed for '$destinationName'."
            }

            $uploadedIcon
        }
    }
}
