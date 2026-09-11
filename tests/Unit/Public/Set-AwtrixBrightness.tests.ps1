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

Describe 'Set-AwtrixBrightness' {
    BeforeEach {
        Mock -CommandName Set-AwtrixSetting
    }

    It 'Should set an absolute brightness percentage' {
        PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Level 42 -Confirm:$false

        Should -Invoke -CommandName Set-AwtrixSetting -ParameterFilter {
            $Setting.brightness -eq 107 -and $Confirm -eq $false
        } -Exactly -Times 1 -Scope It
    }

    It 'Should accept zero and one hundred percent' -ForEach @(0, 100) {
        PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Level $_ -Confirm:$false

        Should -Invoke -CommandName Set-AwtrixSetting -ParameterFilter {
            $Setting.brightness -eq ($_ * 255 / 100)
        } -Exactly -Times 1 -Scope It
    }

    It 'Should reject an absolute value outside zero through one hundred' -ForEach @(-1, 101) {
        {
            PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Level $_ -Confirm:$false
        } | Should -Throw

        Should -Invoke -CommandName Set-AwtrixSetting -Exactly -Times 0 -Scope It
    }

    It 'Should increase the current brightness' {
        Mock -CommandName Get-AwtrixSettings -MockWith { [PSCustomObject] @{ brightness = 102 } }

        PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Increase 15 -Confirm:$false

        Should -Invoke -CommandName Set-AwtrixSetting -ParameterFilter {
            $Setting.brightness -eq 140
        } -Exactly -Times 1 -Scope It
    }

    It 'Should decrease the current brightness' {
        Mock -CommandName Get-AwtrixSettings -MockWith { [PSCustomObject] @{ brightness = 102 } }

        PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Decrease 15 -Confirm:$false

        Should -Invoke -CommandName Set-AwtrixSetting -ParameterFilter {
            $Setting.brightness -eq 64
        } -Exactly -Times 1 -Scope It
    }

    It 'Should constrain an increase to one hundred percent' {
        Mock -CommandName Get-AwtrixSettings -MockWith { [PSCustomObject] @{ brightness = 242 } }

        PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Increase 20 -Confirm:$false

        Should -Invoke -CommandName Set-AwtrixSetting -ParameterFilter {
            $Setting.brightness -eq 255
        } -Exactly -Times 1 -Scope It
    }

    It 'Should constrain a decrease to zero percent' {
        Mock -CommandName Get-AwtrixSettings -MockWith { [PSCustomObject] @{ brightness = 13 } }

        PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Decrease 20 -Confirm:$false

        Should -Invoke -CommandName Set-AwtrixSetting -ParameterFilter {
            $Setting.brightness -eq 0
        } -Exactly -Times 1 -Scope It
    }

    It 'Should fail when the device does not return its current brightness' {
        Mock -CommandName Get-AwtrixSettings -MockWith { [PSCustomObject] @{} }

        {
            PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Increase 10 -Confirm:$false
        } | Should -Throw "*did not return the 'brightness' setting*"

        Should -Invoke -CommandName Set-AwtrixSetting -Exactly -Times 0 -Scope It
    }

    It 'Should pass through the verified settings when requested' {
        Mock -CommandName Set-AwtrixSetting -MockWith { [PSCustomObject] @{ brightness = 153 } }

        $result = PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Level 60 -PassThru -Confirm:$false

        $result.brightness | Should -Be 153
        Should -Invoke -CommandName Set-AwtrixSetting -ParameterFilter {
            $PassThru -eq $true
        } -Exactly -Times 1 -Scope It
    }

    It 'Should fail when the device returns a brightness outside its native range' {
        Mock -CommandName Get-AwtrixSettings -MockWith { [PSCustomObject] @{ brightness = 256 } }

        {
            PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Increase 10 -Confirm:$false
        } | Should -Throw '*invalid brightness value of 256*'

        Should -Invoke -CommandName Set-AwtrixSetting -Exactly -Times 0 -Scope It
    }

    It 'Should not change brightness when WhatIf is used' {
        PSAwtrixNG\Set-AwtrixBrightness -Device '192.0.2.10' -Level 50 -WhatIf

        Should -Invoke -CommandName Set-AwtrixSetting -Exactly -Times 0 -Scope It
    }
}
