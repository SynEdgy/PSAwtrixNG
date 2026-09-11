<#
    .SYNOPSIS
        Converts typed AWTRIX payloads into JSON-ready objects.

    .DESCRIPTION
        Copies non-null properties from AWTRIX payload classes into ordered
        dictionaries. Class property names provide the canonical firmware
        casing while omitted nullable properties remain absent from JSON.

    .PARAMETER InputObject
        Specifies the value to normalize before JSON serialization.

    .EXAMPLE
        ConvertTo-AwtrixJsonObject -InputObject ([AwtrixApp] @{ text = 'Ready' })
#>
function ConvertTo-AwtrixJsonObject
{
    [CmdletBinding()]
    [OutputType(
        [System.Collections.Specialized.OrderedDictionary],
        [System.Object]
    )]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Object]
        $InputObject
    )

    if ($InputObject -isnot [AwtrixApp] -and $InputObject -isnot [AwtrixScroll])
    {
        return $InputObject
    }

    $result = [ordered] @{}
    foreach ($property in $InputObject.PSObject.Properties)
    {
        if ($null -eq $property.Value)
        {
            continue
        }

        $result[$property.Name] = if ($property.Value -is [AwtrixScroll])
        {
            ConvertTo-AwtrixJsonObject -InputObject $property.Value
        }
        else
        {
            $property.Value
        }
    }

    $result
}
