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

Describe 'Send-AwtrixNotification' {
    BeforeAll {
        Mock -CommandName Invoke-AwtrixApi
    }

    It 'Should send a notification payload to the notify endpoint' {
        PSAwtrixNG\Send-AwtrixNotification -Device '192.0.2.10' -Text 'Ready' -Color '#00FF00' -Confirm:$false

        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/notifications' -and
            $Body.text -eq 'Ready' -and
            $Body.textColor -eq '#00FF00' -and
            $Body.durationMs -eq 5000
        } -Exactly -Times 1 -Scope It
    }

    It 'Should not send a notification when WhatIf is used' {
        PSAwtrixNG\Send-AwtrixNotification -Device '192.0.2.10' -Text 'Ready' -WhatIf

        Should -Invoke -CommandName Invoke-AwtrixApi -Exactly -Times 0 -Scope It
    }
}
