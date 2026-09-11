function Get-AwtrixAbsolutePath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}

function Build-AwtrixMqttNetAssets
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProjectPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PackageRoot,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LibRoot
    )

    $resolvedProjectPath = (Resolve-Path -Path $ProjectPath).Path
    $resolvedPackageRoot = Get-AwtrixAbsolutePath -Path $PackageRoot
    $resolvedLibRoot = Get-AwtrixAbsolutePath -Path $LibRoot

    & dotnet restore $resolvedProjectPath --packages $resolvedPackageRoot

    if ($LASTEXITCODE -ne 0)
    {
        throw "dotnet restore failed with exit code $LASTEXITCODE."
    }

    $mqttPackageRoot = Join-Path -Path $resolvedPackageRoot -ChildPath 'mqttnet'
    $mqttPackageVersionRoot = Join-Path -Path $mqttPackageRoot -ChildPath '4.3.7.1207'

    if (-not (Test-Path -LiteralPath $mqttPackageVersionRoot -PathType Container))
    {
        throw "MQTTnet package assets were not found at '$mqttPackageVersionRoot'."
    }

    if (Test-Path -LiteralPath $resolvedLibRoot)
    {
        Remove-Item -LiteralPath $resolvedLibRoot -Recurse -Force
    }

    $frameworks = @('net461', 'netstandard2.0')

    $dotnetBuildArguments = @(
        'build'
        $resolvedProjectPath
        '--configuration'
        'Release'
        '--framework'
        'netstandard2.0'
        '--no-restore'
    )

    & dotnet @dotnetBuildArguments

    if ($LASTEXITCODE -ne 0)
    {
        throw "dotnet build failed for the MQTT capture helper with exit code $LASTEXITCODE."
    }

    $projectRoot = Split-Path -Path $resolvedProjectPath -Parent
    $assemblySource = Join-Path -Path $projectRoot -ChildPath 'bin'
    $assemblySource = Join-Path -Path $assemblySource -ChildPath 'Release'
    $assemblySource = Join-Path -Path $assemblySource -ChildPath 'netstandard2.0'
    $assemblySource = Join-Path -Path $assemblySource -ChildPath 'PSAwtrixNG.Mqtt.dll'

    foreach ($framework in $frameworks)
    {
        $sourceDirectory = Join-Path -Path $mqttPackageVersionRoot -ChildPath 'lib'
        $sourceDirectory = Join-Path -Path $sourceDirectory -ChildPath $framework
        $targetDirectory = Join-Path -Path $resolvedLibRoot -ChildPath $framework
        $null = New-Item -Path $targetDirectory -ItemType Directory -Force

        Copy-Item -Path (Join-Path -Path $sourceDirectory -ChildPath 'MQTTnet.dll') -Destination $targetDirectory -Force
        Copy-Item -Path (Join-Path -Path $sourceDirectory -ChildPath 'MQTTnet.xml') -Destination $targetDirectory -Force
        Copy-Item -LiteralPath $assemblySource -Destination $targetDirectory -Force
    }

    $licenseSource = Join-Path -Path (Split-Path -Path $resolvedProjectPath -Parent) -ChildPath 'ThirdPartyNotices'
    $licenseSource = Join-Path -Path $licenseSource -ChildPath 'MQTTnet.LICENSE'
    Copy-Item -LiteralPath $licenseSource -Destination $resolvedLibRoot -Force
}

function Copy-AwtrixMqttNetAssetsToBuiltModule
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $LibRoot,

        [Parameter(Mandatory = $true)]
        [System.String]
        $BuiltModuleBase
    )

    $resolvedLibRoot = Get-AwtrixAbsolutePath -Path $LibRoot

    if (-not (Test-Path -LiteralPath $resolvedLibRoot -PathType Container))
    {
        throw "MQTTnet runtime assets were not found at '$resolvedLibRoot'."
    }

    $targetRoot = Join-Path -Path $BuiltModuleBase -ChildPath 'lib'
    $null = New-Item -Path $targetRoot -ItemType Directory -Force
    Copy-Item -Path (Join-Path -Path $resolvedLibRoot -ChildPath '*') -Destination $targetRoot -Recurse -Force
}

Export-ModuleMember -Function Build-AwtrixMqttNetAssets, Copy-AwtrixMqttNetAssetsToBuiltModule
