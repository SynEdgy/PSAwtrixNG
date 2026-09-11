<#
    .SYNOPSIS
        Sends an HTTP request to an AWTRIX NG API endpoint.

    .DESCRIPTION
        Resolves the target device, constructs a safe request URI and query string,
        serializes JSON bodies, applies authentication, and invokes the REST request.

    .PARAMETER Device
        Specifies the AWTRIX connection object or address used for the HTTP request.

    .PARAMETER Path
        Specifies the path relative to the device base URI.

    .PARAMETER Method
        Specifies the HTTP method used to invoke the endpoint.

    .PARAMETER Body
        Specifies an optional string or object request body.

    .PARAMETER ContentType
        Specifies the body media type. JSON is used by default.

    .PARAMETER RawBody
        Sends Body without JSON serialization, for example when uploading Berry source.

    .PARAMETER Query
        Specifies optional query-string keys and values.

    .EXAMPLE
        Invoke-AwtrixHttpRequest -Device '192.0.2.10' -Path 'api/v1/device'
#>
function Invoke-AwtrixHttpRequest
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

        [Parameter()]
        [ValidateSet('Get', 'Post', 'Put', 'Patch', 'Delete', 'Head', 'Options')]
        [System.String]
        $Method = 'Get',

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Body,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ContentType = 'application/json',

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $RawBody,

        [Parameter()]
        [System.Collections.IDictionary]
        $Query
    )

    $resolvedDevice = Resolve-AwtrixDevice -Device $Device
    $relativePath = $Path.TrimStart('/')
    $requestUri = [System.Uri]::new($resolvedDevice.BaseUri, $relativePath)
    $uriBuilder = [System.UriBuilder]::new($requestUri)

    if ($Query -and $Query.Count -gt 0)
    {
        $queryParts = foreach ($entry in $Query.GetEnumerator())
        {
            '{0}={1}' -f [System.Uri]::EscapeDataString([System.String] $entry.Key),
                [System.Uri]::EscapeDataString([System.String] $entry.Value)
        }

        $uriBuilder.Query = $queryParts -join '&'
    }

    $requestParameters = @{
        Uri         = $uriBuilder.Uri
        Method      = $Method
        TimeoutSec  = $resolvedDevice.TimeoutSec
        ErrorAction = 'Stop'
    }

    if ($resolvedDevice.Credential)
    {
        $requestParameters.Credential = $resolvedDevice.Credential
    }

    if ($PSBoundParameters.ContainsKey('Body'))
    {
        $requestParameters.ContentType = $ContentType
        $requestParameters.Body = if ($RawBody)
        {
            [System.String] $Body
        }
        elseif ($null -eq $Body -or $Body -eq '')
        {
            ''
        }
        elseif ($Body -is [System.String])
        {
            $Body
        }
        else
        {
            $jsonObject = ConvertTo-AwtrixJsonObject -InputObject $Body
            ConvertTo-Json -InputObject $jsonObject -Depth 20 -Compress
        }
    }

    try
    {
        Invoke-RestMethod @requestParameters
    }
    catch
    {
        $responseBody = $null

        if ($_.ErrorDetails -and $_.ErrorDetails.Message)
        {
            $responseBody = $_.ErrorDetails.Message
        }
        elseif ($_.Exception.Response)
        {
            try
            {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = [System.IO.StreamReader]::new($stream)
                $responseBody = $reader.ReadToEnd()
                $reader.Dispose()
            }
            catch
            {
                $responseBody = $null
            }
        }

        $detail = $null
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
                    if ($errorResponse.error.field)
                    {
                        $detail = "$detail (field: $($errorResponse.error.field))"
                    }
                }
            }
            catch
            {
                $detail = $responseBody
            }
        }

        $message = "AWTRIX NG request to '$($uriBuilder.Uri.AbsoluteUri)' failed: $($_.Exception.Message)"
        if ($detail)
        {
            $message = "$message - $detail"
        }

        throw $message
    }
}
