<#
    .SYNOPSIS
        Updates stored configuration for an AWTRIX NG script app.

    .DESCRIPTION
        Patches declared configuration values for the named Berry script and
        returns the firmware restart result.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the script app name.

    .PARAMETER Configuration
        Specifies script configuration keys and values.

    .EXAMPLE
        Set-AwtrixScriptConfiguration -Device '192.168.88.202' -Name Weather -Configuration @{ city = 'London' }
#>
function Set-AwtrixScriptConfiguration
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
        [System.Collections.IDictionary]
        $Configuration
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Update Berry script '$Name' configuration"))
        {
            $response = Invoke-AwtrixApi -Device $resolvedDevice -Path "api/v1/apps/$Name/config" -Method Patch -Body $Configuration -Confirm:$false
            if ($response.error)
            {
                $line = if ($response.error.line) { " at line $($response.error.line)" } else { '' }
                throw "AWTRIX NG updated script '$Name' configuration but the script failed${line}: $($response.error.message)"
            }

            $response
        }
    }
}
