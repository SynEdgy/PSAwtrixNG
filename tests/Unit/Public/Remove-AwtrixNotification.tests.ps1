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

Describe 'Remove-AwtrixNotification' {
    BeforeAll {
        Mock -CommandName Invoke-AwtrixApi
    }

    It 'Should post an empty body to the dismiss endpoint' {
        PSAwtrixNG\Remove-AwtrixNotification -Device '192.0.2.10' -Confirm:$false

        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/notifications/active' -and $Method -eq 'Delete'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should not dismiss a notification when WhatIf is used' {
        PSAwtrixNG\Remove-AwtrixNotification -Device '192.0.2.10' -WhatIf

        Should -Invoke -CommandName Invoke-AwtrixApi -Exactly -Times 0 -Scope It
    }
}
