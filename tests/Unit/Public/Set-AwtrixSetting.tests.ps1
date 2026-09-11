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

Describe 'Set-AwtrixSetting' {
    Context 'When the firmware applies the requested settings' {
        BeforeAll {
            Mock -CommandName Invoke-AwtrixApi -MockWith {
                [PSCustomObject] @{
                    brightness     = 100
                    autoBrightness = $false
                }
            }
        }

        It 'Should write and verify every requested value including false' {
            $result = PSAwtrixNG\Set-AwtrixSetting -Device '192.0.2.10' -Setting @{
                brightness     = 100
                autoBrightness = $false
            } -PassThru -Confirm:$false

            $result.brightness | Should -Be 100
            $result.autoBrightness | Should -BeFalse
            Should -Invoke -CommandName Invoke-AwtrixApi -ParameterFilter {
                $Path -eq 'api/v1/settings' -and $Method -eq 'Patch'
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the firmware does not apply a requested setting' {
        BeforeAll {
            Mock -CommandName Invoke-AwtrixApi -MockWith { [PSCustomObject] @{ brightness = 120 } }
        }

        It 'Should throw a verification error' {
            {
                PSAwtrixNG\Set-AwtrixSetting -Device '192.0.2.10' -Setting @{ brightness = 100 } -Confirm:$false
            } | Should -Throw "*verification failed for 'brightness'*"
        }
    }

    Context 'When WhatIf is used' {
        BeforeAll {
            Mock -CommandName Invoke-AwtrixApi
        }

        It 'Should not call the write or verification endpoints' {
            $null = PSAwtrixNG\Set-AwtrixSetting -Device '192.0.2.10' -Setting @{ brightness = 100 } -WhatIf

            Should -Invoke -CommandName Invoke-AwtrixApi -Exactly -Times 0 -Scope It
        }
    }
}
