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

Describe 'Get-AwtrixScreen' {
    BeforeAll {
        Mock -CommandName Invoke-AwtrixApi -MockWith {
            [PSCustomObject] @{ width = 3; height = 1; pixels = @(1, 2, 3) }
        }
    }

    It 'Should preserve the screen pixel array as one pipeline object' {
        $result = PSAwtrixNG\Get-AwtrixScreen -Device '192.0.2.10'

        $result.width | Should -Be 3
        @($result.pixels).Count | Should -Be 3
        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter { $Path -eq 'api/v1/display/screen' } -Exactly -Times 1 -Scope It
    }

    It 'Should return a structured frame when requested' {
        Mock -CommandName Invoke-AwtrixApi -MockWith {
            [PSCustomObject] @{ width = 32; height = 8; pixels = @(0..255) }
        }

        $result = PSAwtrixNG\Get-AwtrixScreen -Device '192.0.2.10' -AsFrame

        $result.PSTypeNames | Should -Contain 'PSAwtrixNG.ScreenFrame'
        $result.Width | Should -Be 32
        $result.Height | Should -Be 8
        $result.Pixels.Count | Should -Be 256
        $result.Pixels[255].X | Should -Be 31
        $result.Pixels[255].Y | Should -Be 7
    }
}
