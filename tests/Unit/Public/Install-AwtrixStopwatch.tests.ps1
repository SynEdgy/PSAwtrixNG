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

Describe 'Install-AwtrixStopwatch' {
    It 'Should render and install the packaged Stopwatch application' {
        Mock Get-AwtrixBerryAppSource { 'rendered Stopwatch source' }
        Mock Set-AwtrixScript { [PSCustomObject] @{ ok = $true } }

        $installParameters = @{
            Device       = '192.0.2.10'
            Name         = 'BuildTimer'
            ResetTopic   = 'build/timer/reset'
            ControlTopic = 'build/timer/control'
            StateTopic   = 'build/timer/state'
            Confirm      = $false
        }
        $null = PSAwtrixNG\Install-AwtrixStopwatch @installParameters

        Should -Invoke Get-AwtrixBerryAppSource -ParameterFilter {
            $Name -eq 'Stopwatch' -and
            $Token.APP_NAME -eq 'BuildTimer' -and
            $Token.RESET_TOPIC -eq 'build/timer/reset' -and
            $Token.CONTROL_TOPIC -eq 'build/timer/control' -and
            $Token.STATE_TOPIC -eq 'build/timer/state'
        } -Exactly -Times 1 -Scope It
        Should -Invoke Set-AwtrixScript -ParameterFilter {
            $Name -eq 'BuildTimer' -and
            $Source -eq 'rendered Stopwatch source'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should not load the packaged application when WhatIf is used' {
        Mock Get-AwtrixBerryAppSource { throw 'Template should not be loaded.' }
        Mock Set-AwtrixScript

        $null = PSAwtrixNG\Install-AwtrixStopwatch -Device '192.0.2.10' -WhatIf

        Should -Invoke Get-AwtrixBerryAppSource -Exactly -Times 0 -Scope It
        Should -Invoke Set-AwtrixScript -Exactly -Times 0 -Scope It
    }
}
