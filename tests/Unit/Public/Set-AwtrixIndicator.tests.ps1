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

Describe 'Set-AwtrixIndicator' {
    BeforeAll {
        Mock -CommandName Invoke-AwtrixApi
    }

    It 'Should set a hexadecimal indicator color with effects' {
        $setParameters = @{
            Device    = '192.0.2.10'
            Indicator = 2
            Color     = '#00FF00'
            Blink     = 500
            Fade      = 1000
            Confirm   = $false
        }

        PSAwtrixNG\Set-AwtrixIndicator @setParameters

        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/indicators/2' -and
            $Body.color -eq '#00FF00' -and
            $Body.blinkMs -eq 500 -and
            $Body.fadeMs -eq 1000
        } -Exactly -Times 1 -Scope It
    }

    It 'Should set an RGB indicator color' {
        $setParameters = @{
            Device    = '192.0.2.10'
            Indicator = 1
            Color     = @(255, 128, 0)
            Confirm   = $false
        }

        PSAwtrixNG\Set-AwtrixIndicator @setParameters

        Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/indicators/1' -and
            $Body.color.Count -eq 3 -and
            $Body.color[0] -eq 255 -and
            $Body.color[1] -eq 128 -and
            $Body.color[2] -eq 0
        } -Exactly -Times 1 -Scope It
    }

    It 'Should reject an invalid color' {
        {
            $setParameters = @{
                Device    = '192.0.2.10'
                Indicator = 1
                Color     = @(256, 0, 0)
                Confirm   = $false
            }

            PSAwtrixNG\Set-AwtrixIndicator @setParameters
        } | Should -Throw

        Should -Invoke -CommandName Invoke-AwtrixApi -Exactly -Times 0 -Scope It
    }

    It 'Should not set an indicator when WhatIf is used' {
        $setParameters = @{
            Device    = '192.0.2.10'
            Indicator = 3
            Color     = '#0000FF'
            WhatIf    = $true
        }

        PSAwtrixNG\Set-AwtrixIndicator @setParameters

        Should -Invoke -CommandName Invoke-AwtrixApi -Exactly -Times 0 -Scope It
    }
}
