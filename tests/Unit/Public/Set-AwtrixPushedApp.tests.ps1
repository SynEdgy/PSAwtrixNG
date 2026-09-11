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

Describe 'Set-AwtrixPushedApp' {
    BeforeAll {
        Mock -CommandName Invoke-AwtrixApi
    }

    It 'Should put the named pushed app payload' {
        PSAwtrixNG\Set-AwtrixPushedApp -Device '192.0.2.10' -Name build -App @{ text = 'Ready' } -Confirm:$false

        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/apps/pushed/build' -and $Method -eq 'Put' -and $Body.text -eq 'Ready'
        } -Exactly -Times 1 -Scope It
    }
}
