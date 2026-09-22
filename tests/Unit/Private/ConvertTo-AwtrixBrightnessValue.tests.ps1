BeforeAll {
    $script:moduleName = 'PSAwtrixNG'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    Remove-Module -Name $script:moduleName
}

Describe 'ConvertTo-AwtrixBrightnessValue' {
    It 'Should convert percentages to native values' -ForEach @(
        @{ Percent = 0; Expected = 0 }
        @{ Percent = 50; Expected = 128 }
        @{ Percent = 64; Expected = 163 }
        @{ Percent = 100; Expected = 255 }
    ) {
        InModuleScope -Parameters @{
            Percent  = $Percent
            Expected = $Expected
        } -ScriptBlock {
            ConvertTo-AwtrixBrightnessValue -Percent $Percent | Should -Be $Expected
        }
    }

    It 'Should reject a percentage outside zero through 100' -ForEach @(-1, 101) {
        InModuleScope -Parameters @{ Percent = $_ } -ScriptBlock {
            {
                ConvertTo-AwtrixBrightnessValue -Percent $Percent
            } | Should -Throw
        }
    }
}
