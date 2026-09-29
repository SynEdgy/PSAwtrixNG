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

Describe 'Get-AwtrixBerryAppSource' {
    It 'Should render the packaged Stopwatch template' {
        InModuleScope -ScriptBlock {
            $token = @{
                APP_NAME      = 'BuildTimer'
                RESET_TOPIC   = 'build/timer/reset'
                CONTROL_TOPIC = 'build/timer/control'
                STATE_TOPIC   = 'build/timer/state'
            }

            $source = Get-AwtrixBerryAppSource -Name 'Stopwatch' -Token $token

            $source | Should -Match '# @name BuildTimer'
            $source | Should -Match 'mqtt.subscribe\("build/timer/reset"'
            $source | Should -Match 'mqtt.subscribe\("build/timer/control"'
            $source | Should -Match 'mqtt.publish\("build/timer/state", "running"\)'
            $source | Should -Match 'def update_display\(elapsed, color\)'
            $source | Should -Not -Match '\{\{[A-Z][A-Z0-9_]*\}\}'
        }
    }

    It 'Should reject unresolved template tokens' {
        InModuleScope -ScriptBlock {
            {
                Get-AwtrixBerryAppSource -Name 'Stopwatch' -Token @{
                    APP_NAME = 'Stopwatch'
                }
            } | Should -Throw '*unresolved tokens*'
        }
    }

    It 'Should reject an unknown packaged application' {
        InModuleScope -ScriptBlock {
            {
                Get-AwtrixBerryAppSource -Name 'MissingApp'
            } | Should -Throw "*Packaged Berry application 'MissingApp' was not found*"
        }
    }
}
