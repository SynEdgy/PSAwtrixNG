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

Describe 'Invoke-AwtrixHttpRequest' {
    Context 'When the firmware accepts the request' {
        BeforeAll {
            Mock -CommandName Invoke-RestMethod -MockWith { 'response' }
        }

        It 'Should build an encoded query string and invoke the REST boundary' {
            InModuleScope -ScriptBlock {
                $result = Invoke-AwtrixHttpRequest -Device '192.0.2.10' -Path 'api/v1/apps' -Query @{ name = 'build app' }

                $result | Should -Be 'response'
                Should -Invoke -CommandName Invoke-RestMethod -ParameterFilter {
                    $Uri.AbsoluteUri -eq 'http://192.0.2.10/api/v1/apps?name=build%20app'
                } -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When the firmware rejects a JSON write' {
        BeforeAll {
            Mock -CommandName Invoke-RestMethod -MockWith {
                $exception = [System.Net.WebException]::new('Unprocessable Entity')
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $exception,
                    'validationFailed',
                    [System.Management.Automation.ErrorCategory]::InvalidData,
                    $null
                )
                $errorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new(
                    '{"error":{"code":"validationFailed","message":"out of range","field":"brightness"}}'
                )
                throw $errorRecord
            }
        }

        It 'Should surface the firmware failure as an exception' {
            InModuleScope -ScriptBlock {
                {
                    Invoke-AwtrixHttpRequest -Device '192.0.2.10' -Path 'api/v1/settings' -Method Patch -Body @{ brightness = 999 }
                } | Should -Throw "*validationFailed*out of range*brightness*"
            }
        }
    }

    It 'Should send raw Berry source without JSON encoding' {
        Mock -CommandName Invoke-RestMethod -MockWith { @{ ok = $true } }

        InModuleScope -ScriptBlock {
            $null = Invoke-AwtrixHttpRequest -Device '192.0.2.10' -Path 'api/v1/apps/script/Test' -Method Put -Body 'return nil' -ContentType 'text/plain' -RawBody

            Should -Invoke -CommandName Invoke-RestMethod -ParameterFilter {
                $Body -eq 'return nil' -and $ContentType -eq 'text/plain'
            } -Exactly -Times 1 -Scope It
        }
    }

    It 'Should serialize typed payloads with canonical casing and omit unset properties' {
        Mock -CommandName Invoke-RestMethod -MockWith { @{ ok = $true } }

        InModuleScope -ScriptBlock {
            $app = [AwtrixApp] @{
                TEXT      = 'Ready'
                TEXTCOLOR = '#00FF00'
                SCROLL    = @{
                    WHENFITS = 'scroll'
                    HOLDMS   = 0
                }
            }

            $null = Invoke-AwtrixHttpRequest -Device '192.0.2.10' -Path 'api/v1/apps/pushed/build' -Method Put -Body $app

            Should -Invoke -CommandName Invoke-RestMethod -ParameterFilter {
                $Body -ceq '{"text":"Ready","textColor":"#00FF00","scroll":{"whenFits":"scroll","holdMs":0}}'
            } -Exactly -Times 1 -Scope It
        }
    }
}
