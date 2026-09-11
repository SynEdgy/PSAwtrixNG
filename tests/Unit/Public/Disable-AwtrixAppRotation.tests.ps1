BeforeAll {
    $script:moduleName = 'PSAwtrixNG'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}
AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')
    Remove-Module -Name $script:moduleName
}
Describe 'Disable-AwtrixAppRotation' {
    BeforeAll {
        Mock Set-AwtrixSetting
    }

    It 'Should disable automatic app rotation' {
        PSAwtrixNG\Disable-AwtrixAppRotation -Device '192.0.2.10' -Confirm:$false

        Should -Invoke Set-AwtrixSetting -ParameterFilter {
            $Setting.autoTransition -eq $false -and $Confirm -eq $false
        } -Exactly -Times 1 -Scope It
    }

    It 'Should not change app rotation when WhatIf is used' {
        PSAwtrixNG\Disable-AwtrixAppRotation -Device '192.0.2.10' -WhatIf

        Should -Invoke Set-AwtrixSetting -Exactly -Times 0 -Scope It
    }
}
