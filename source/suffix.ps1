<#
    Export bare and module-qualified type accelerators so classes can be used by
    callers without a parse-time `using module` statement.
#>
$typesToExportAsIs = @(
    'AwtrixScroll'
    'AwtrixApp'
    'AwtrixNotification'
)

$typesToExportWithNamespace = @(
    'AwtrixScroll'
    'AwtrixApp'
    'AwtrixNotification'
)

$typeAcceleratorsClass = [psobject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)
$moduleName = $MyInvocation.MyCommand.ScriptBlock.Module.Name

$typeAcceleratorExports = @(
    foreach ($typeName in $typesToExportAsIs)
    {
        $type = $typeName -as [System.Type]

        if (-not $type)
        {
            throw "Unable to register type accelerator '$typeName'. Type '$typeName' was not found."
        }

        [PSCustomObject] @{
            AcceleratorName = $typeName
            Type            = $type
        }
    }

    foreach ($typeName in $typesToExportWithNamespace)
    {
        $type = $typeName -as [System.Type]
        $acceleratorName = '{0}.{1}' -f $moduleName, $typeName

        if (-not $type)
        {
            throw "Unable to register type accelerator '$acceleratorName'. Type '$typeName' was not found."
        }

        [PSCustomObject] @{
            AcceleratorName = $acceleratorName
            Type            = $type
        }
    }
)

$existingTypeAccelerators = $typeAcceleratorsClass::Get
foreach ($typeAcceleratorExport in $typeAcceleratorExports)
{
    if ($typeAcceleratorExport.AcceleratorName -in $existingTypeAccelerators.Keys)
    {
        $null = $typeAcceleratorsClass::Remove($typeAcceleratorExport.AcceleratorName)
    }

    $null = $typeAcceleratorsClass::Add(
        $typeAcceleratorExport.AcceleratorName,
        $typeAcceleratorExport.Type
    )
}

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    foreach ($typeAcceleratorExport in $typeAcceleratorExports)
    {
        $null = $typeAcceleratorsClass::Remove($typeAcceleratorExport.AcceleratorName)
    }
}.GetNewClosure()
