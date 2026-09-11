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

Describe 'Get-AwtrixSettings' {
    BeforeAll {
        Mock -CommandName Invoke-AwtrixApi -MockWith { [PSCustomObject] @{ BRI = 100 } }
    }

    It 'Should request the settings API endpoint' {
        $result = PSAwtrixNG\Get-AwtrixSettings -Device '192.0.2.10'

        $result.BRI | Should -Be 100
        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter { $Path -eq 'api/v1/settings' } -Exactly -Times 1 -Scope It
    }
}
