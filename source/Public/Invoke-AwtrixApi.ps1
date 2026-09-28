<#
    .SYNOPSIS
        Invokes an AWTRIX NG HTTP API endpoint.

    .DESCRIPTION
        Provides direct access to documented AWTRIX NG HTTP API endpoints while
        handling device objects, JSON serialization, query strings, authentication,
        timeouts, and ShouldProcess for requests that can change device state.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Path
        Specifies the API-relative path, such as api/v1/device.

    .PARAMETER Method
        Specifies the HTTP method used for the AWTRIX API request.

    .PARAMETER Body
        Specifies the request body. Non-string values are serialized to JSON.

    .PARAMETER ContentType
        Specifies the request media type. JSON is used by default.

    .PARAMETER RawBody
        Sends Body without JSON serialization, for example when uploading Berry source.

    .PARAMETER Query
        Specifies query-string keys and values appended to the request URI.

    .PARAMETER AllowDangerousOperation
        Explicitly permits endpoints that can reboot, reset, erase, update, or put
        the device into deep sleep. ShouldProcess confirmation still applies.

    .EXAMPLE
        Invoke-AwtrixApi -Device 'clock.local' -Path 'api/v1/device'
#>
function Invoke-AwtrixApi
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
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
        $Query,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $AllowDangerousOperation
    )

    process
    {
        $parameters = @{
            Device = $Device
            Path   = $Path
            Method = $Method
        }

        if ($PSBoundParameters.ContainsKey('Body'))
        {
            $parameters.Body = $Body
            $parameters.ContentType = $ContentType
            $parameters.RawBody = $RawBody
        }

        if ($Query)
        {
            $parameters.Query = $Query
        }

        if ($Method -eq 'Get')
        {
            return Invoke-AwtrixHttpRequest @parameters
        }

        $normalizedPath = $Path.Trim('/').ToLowerInvariant()
        $dangerousPaths = @(
            'api/v1/device/reboot'
            'api/v1/device/sleep'
            'api/v1/settings/reset'
            'api/v1/device/factory-reset'
            'api/v1/firmware'
            'api/v1/restore'
        )

        if ($normalizedPath -in $dangerousPaths -and -not $AllowDangerousOperation)
        {
            throw "Endpoint '$Path' requires -AllowDangerousOperation."
        }

        $resolvedDevice = Resolve-AwtrixDevice -Device $Device

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "$Method $Path"))
        {
            Invoke-AwtrixHttpRequest @parameters
        }
    }
}
