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

Describe 'Invoke-AwtrixApi' {
    BeforeAll {
        Mock -CommandName Invoke-AwtrixHttpRequest -MockWith { 'response' }
    }

    It 'Should invoke read-only requests without ShouldProcess confirmation' {
        $result = PSAwtrixNG\Invoke-AwtrixApi -Device '192.0.2.10' -Path 'api/v1/device'

        $result | Should -Be 'response'
        Should -Invoke -CommandName Invoke-AwtrixHttpRequest -Exactly -Times 1 -Scope It
    }

    It 'Should not invoke state-changing requests when WhatIf is used' {
        $null = PSAwtrixNG\Invoke-AwtrixApi -Device '192.0.2.10' -Path 'api/v1/settings' -Method Post -Body @{} -WhatIf

        Should -Invoke -CommandName Invoke-AwtrixHttpRequest -Exactly -Times 0 -Scope It
    }

    It 'Should reject dangerous endpoints without explicit opt-in' {
        {
            PSAwtrixNG\Invoke-AwtrixApi -Device '192.0.2.10' -Path 'api/v1/device/reboot' -Method Post -Confirm:$false
        } | Should -Throw "*requires -AllowDangerousOperation*"

        Should -Invoke -CommandName Invoke-AwtrixHttpRequest -Exactly -Times 0 -Scope It
    }

    It 'Should allow a dangerous endpoint after explicit opt-in' {
        $result = PSAwtrixNG\Invoke-AwtrixApi -Device '192.0.2.10' -Path 'api/v1/device/reboot' -Method Post -AllowDangerousOperation -Confirm:$false

        $result | Should -Be 'response'
        Should -Invoke -CommandName Invoke-AwtrixHttpRequest -Exactly -Times 1 -Scope It
    }

    It 'Should protect the firmware update endpoint' {
        {
            PSAwtrixNG\Invoke-AwtrixApi -Device '192.0.2.10' -Path '/update' -Method Post -Confirm:$false
        } | Should -Throw "*requires -AllowDangerousOperation*"

        Should -Invoke -CommandName Invoke-AwtrixHttpRequest -Exactly -Times 0 -Scope It
    }
}
