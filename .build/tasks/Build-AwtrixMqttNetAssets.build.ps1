param
(
    [Parameter()]
    [System.String]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output'))
)

$helperPath = Join-Path -Path $PSScriptRoot -ChildPath 'Build-AwtrixMqttNetAssets.build.psm1'
Import-Module -Name $helperPath -Force -ErrorAction Stop

task Build_Awtrix_MqttNet_Assets {
    . Set-SamplerTaskVariable -AsNewBuild

    $projectPath = Get-SamplerAbsolutePath -Path 'PSAwtrixNG.csproj' -RelativeTo $BuildRoot
    $packageRoot = Get-SamplerAbsolutePath -Path 'NuGetPackages' -RelativeTo $OutputDirectory
    $libRoot = Get-SamplerAbsolutePath -Path 'lib' -RelativeTo $OutputDirectory

    Build-AwtrixMqttNetAssets -ProjectPath $projectPath -PackageRoot $packageRoot -LibRoot $libRoot
}

task Copy_Awtrix_MqttNet_Assets_To_Built_Module {
    . Set-SamplerTaskVariable

    $libRoot = Get-SamplerAbsolutePath -Path 'lib' -RelativeTo $OutputDirectory
    Copy-AwtrixMqttNetAssetsToBuiltModule -LibRoot $libRoot -BuiltModuleBase $BuiltModuleBase
}
