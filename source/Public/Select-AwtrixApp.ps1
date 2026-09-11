<#
    .SYNOPSIS
        Switches the application displayed by an AWTRIX NG device.

    .DESCRIPTION
        Switches directly to a named built-in, pushed, or script application, or moves to
        the next or previous application in the device loop.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the built-in, pushed, script, or module application name to display.

    .PARAMETER Next
        Switches to the next application in the device loop.

    .PARAMETER Previous
        Switches to the previous application in the device loop.

    .EXAMPLE
        Select-AwtrixApp -Device '192.168.88.202' -Name Time

    .EXAMPLE
        Select-AwtrixApp -Device '192.168.88.202' -Next
#>
function Select-AwtrixApp
{
    [CmdletBinding(DefaultParameterSetName = 'Name', SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'Next')]
        [System.Management.Automation.SwitchParameter]
        $Next,

        [Parameter(Mandatory = $true, ParameterSetName = 'Previous')]
        [System.Management.Automation.SwitchParameter]
        $Previous
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device

        if ($Next)
        {
            $path = 'api/v1/apps/next'
            $action = 'Switch to the next AWTRIX application'
            $body = ''
        }
        elseif ($Previous)
        {
            $path = 'api/v1/apps/previous'
            $action = 'Switch to the previous AWTRIX application'
            $body = ''
        }
        else
        {
            $path = 'api/v1/apps/active'
            $action = "Switch to AWTRIX application '$Name'"
            $body = @{ name = $Name; fast = $true }
        }

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, $action))
        {
            $invokeParameters = @{
                Device  = $resolvedDevice
                Path    = $path
                Method  = if ($PSCmdlet.ParameterSetName -eq 'Name') { 'Put' } else { 'Post' }
                Confirm = $false
            }

            if ($PSCmdlet.ParameterSetName -eq 'Name')
            {
                $invokeParameters.Body = $body
            }

            Invoke-AwtrixApi @invokeParameters
        }
    }
}
