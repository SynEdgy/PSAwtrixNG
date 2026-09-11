<#
    .SYNOPSIS
        Uploads a local file to an AWTRIX NG multipart endpoint.

    .DESCRIPTION
        Creates a streaming multipart/form-data request that works on Windows
        PowerShell 5.1 and PowerShell 7, applies device authentication and
        timeout settings, and surfaces structured AWTRIX API errors.

    .PARAMETER Device
        Specifies the resolved AWTRIX device or an address accepted by New-AwtrixDevice.

    .PARAMETER Path
        Specifies the API-relative multipart endpoint path.

    .PARAMETER Query
        Specifies query-string parameters appended to the upload endpoint.

    .PARAMETER FilePath
        Specifies the full path of the local file to stream.

    .PARAMETER FileName
        Specifies the file name included in the multipart content disposition.

    .EXAMPLE
        Invoke-AwtrixMultipartUpload -Device $device -Path 'api/v1/files' -Query @{ dir = '/ICONS' } -FilePath '.\logo.gif' -FileName 'logo.gif'
#>
function Invoke-AwtrixMultipartUpload
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Query,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FileName
    )

    $resolvedDevice = Resolve-AwtrixDevice -Device $Device
    $requestUri = [System.Uri]::new($resolvedDevice.BaseUri, $Path.TrimStart('/'))
    $uriBuilder = [System.UriBuilder]::new($requestUri)
    $queryParts = foreach ($entry in $Query.GetEnumerator())
    {
        '{0}={1}' -f [System.Uri]::EscapeDataString([System.String] $entry.Key),
            [System.Uri]::EscapeDataString([System.String] $entry.Value)
    }
    $uriBuilder.Query = $queryParts -join '&'

    Add-Type -AssemblyName System.Net.Http -ErrorAction Stop
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $client = [System.Net.Http.HttpClient]::new($handler)
    $client.Timeout = [System.TimeSpan]::FromSeconds($resolvedDevice.TimeoutSec)

    if ($resolvedDevice.Credential)
    {
        $networkCredential = $resolvedDevice.Credential.GetNetworkCredential()
        $basicValue = '{0}:{1}' -f $networkCredential.UserName, $networkCredential.Password
        $basicBytes = [System.Text.Encoding]::UTF8.GetBytes($basicValue)
        $basicToken = [System.Convert]::ToBase64String($basicBytes)
        $client.DefaultRequestHeaders.Authorization =
            [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Basic', $basicToken)
    }

    $multipart = [System.Net.Http.MultipartFormDataContent]::new()
    $stream = $null
    $fileContent = $null
    $response = $null

    try
    {
        $stream = [System.IO.File]::OpenRead($FilePath)
        $fileContent = [System.Net.Http.StreamContent]::new($stream)
        $contentDisposition =
            [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data')
        $contentDisposition.Name = '"file"'
        $contentDisposition.FileName = '"{0}"' -f $FileName
        $fileContent.Headers.ContentDisposition = $contentDisposition
        $multipart.Add($fileContent)
        $response = $client.PostAsync($uriBuilder.Uri, $multipart).GetAwaiter().GetResult()
        $responseBody = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()

        if (-not $response.IsSuccessStatusCode)
        {
            $detail = $responseBody
            if ($responseBody)
            {
                try
                {
                    $errorResponse = $responseBody | ConvertFrom-Json -ErrorAction Stop
                    if ($errorResponse.error)
                    {
                        $detail = $errorResponse.error.message
                        if ($errorResponse.error.code)
                        {
                            $detail = "$($errorResponse.error.code): $detail"
                        }
                    }
                }
                catch
                {
                    $detail = $responseBody
                }
            }

            throw "AWTRIX NG upload to '$($uriBuilder.Uri.AbsoluteUri)' failed with HTTP $([System.Int32] $response.StatusCode): $detail"
        }

        if ($responseBody)
        {
            return $responseBody | ConvertFrom-Json -ErrorAction Stop
        }
    }
    catch
    {
        if ($_.Exception.Message -like 'AWTRIX NG upload*')
        {
            throw
        }

        throw "AWTRIX NG upload of '$FileName' to '$($uriBuilder.Uri.AbsoluteUri)' failed: $($_.Exception.Message)"
    }
    finally
    {
        if ($response)
        {
            $response.Dispose()
        }
        if ($fileContent)
        {
            $fileContent.Dispose()
        }
        if ($stream)
        {
            $stream.Dispose()
        }
        $multipart.Dispose()
        $client.Dispose()
        $handler.Dispose()
    }
}
