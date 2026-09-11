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

Describe 'Show-AwtrixScreen' {
    BeforeAll {
        $script:testFrame = [PSCustomObject] @{
            PSTypeName = 'PSAwtrixNG.ScreenFrame'
            Width      = 32
            Height     = 8
            Signature  = 'test'
            Pixels     = @()
        }

        Mock -CommandName Get-AwtrixScreen -MockWith { $script:testFrame }
        Mock -CommandName Write-AwtrixScreenFrame
    }

    It 'Should retrieve and render a device frame' {
        PSAwtrixNG\Show-AwtrixScreen -Device '192.0.2.10'

        Should -Invoke -CommandName Get-AwtrixScreen -ParameterFilter { $AsFrame } -Exactly -Times 1 -Scope It
        Should -Invoke -CommandName Write-AwtrixScreenFrame -Exactly -Times 1 -Scope It
    }

    It 'Should return the rendered frame with PassThru' {
        $result = PSAwtrixNG\Show-AwtrixScreen -Frame $script:testFrame -PassThru

        $result.Signature | Should -Be 'test'
        Should -Invoke -CommandName Get-AwtrixScreen -Exactly -Times 0 -Scope It
    }
}
