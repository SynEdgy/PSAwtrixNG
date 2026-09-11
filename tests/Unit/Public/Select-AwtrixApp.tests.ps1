BeforeAll {
    $script:moduleName = 'PSAwtrixNG'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')
    Remove-Module -Name $script:moduleName
}

Describe 'Select-AwtrixApp' {
    BeforeAll {
        Mock -CommandName Invoke-AwtrixApi
    }

    It 'Should switch to a named application' {
        PSAwtrixNG\Select-AwtrixApp -Device '192.0.2.10' -Name Time -Confirm:$false

        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/apps/active' -and $Method -eq 'Put' -and $Body.name -eq 'Time' -and $Body.fast
        } -Exactly -Times 1 -Scope It
    }

    It 'Should switch to the next application' {
        PSAwtrixNG\Select-AwtrixApp -Device '192.0.2.10' -Next -Confirm:$false

        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/apps/next' -and $Method -eq 'Post'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should switch to the previous application' {
        PSAwtrixNG\Select-AwtrixApp -Device '192.0.2.10' -Previous -Confirm:$false

        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/apps/previous' -and $Method -eq 'Post'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should not switch applications when WhatIf is used' {
        PSAwtrixNG\Select-AwtrixApp -Device '192.0.2.10' -Name Time -WhatIf

        Should -Invoke -CommandName Invoke-AwtrixApi -Exactly -Times 0 -Scope It
    }
}
