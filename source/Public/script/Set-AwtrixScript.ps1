<#
    .SYNOPSIS
        Creates or updates an AWTRIX NG Berry script app.

    .DESCRIPTION
        Uploads raw Berry source and treats a compile error returned inside an
        HTTP-success response as a command failure.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the script app name.

    .PARAMETER Source
        Specifies the raw Berry source code.

    .EXAMPLE
        Set-AwtrixScript -Device '192.168.88.202' -Name Hello -Source $berry
#>
function Set-AwtrixScript
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]{1,32}$')]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Source
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Create or update Berry script '$Name'"))
        {
            $response = Invoke-AwtrixApi -Device $resolvedDevice -Path "api/v1/apps/script/$Name" -Method Put -Body $Source -ContentType 'text/plain' -RawBody -Confirm:$false
            if ($response.error)
            {
                $line = if ($response.error.line) { " at line $($response.error.line)" } else { '' }
                throw "AWTRIX NG installed script '$Name' but could not compile it${line}: $($response.error.message)"
            }

            $response
        }
    }
}
