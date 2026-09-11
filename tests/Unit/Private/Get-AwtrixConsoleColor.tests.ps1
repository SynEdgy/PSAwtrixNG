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

Describe 'Get-AwtrixConsoleColor' {
    It 'Should map exact RGB palette values to console colors' {
        InModuleScope -ScriptBlock {
            Get-AwtrixConsoleColor -Red 255 -Green 0 -Blue 0 |
                Should -Be ([System.ConsoleColor]::Red)

            Get-AwtrixConsoleColor -Red 0 -Green 0 -Blue 0 |
                Should -Be ([System.ConsoleColor]::Black)
        }
    }
}
