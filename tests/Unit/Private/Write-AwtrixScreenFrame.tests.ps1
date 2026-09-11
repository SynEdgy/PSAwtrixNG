BeforeAll {
    $script:moduleName = 'PSAwtrixNG'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')
    Remove-Module -Name $script:moduleName
}

Describe 'Write-AwtrixScreenFrame' {
    It 'Should accept an empty frame without changing pipeline output' {
        InModuleScope -ScriptBlock {
            $frame = [PSCustomObject] @{
                Width  = 32
                Height = 0
                Pixels = @()
            }

            $result = Write-AwtrixScreenFrame -Frame $frame -RenderingMode Ansi

            $result | Should -BeNullOrEmpty
        }
    }
}
