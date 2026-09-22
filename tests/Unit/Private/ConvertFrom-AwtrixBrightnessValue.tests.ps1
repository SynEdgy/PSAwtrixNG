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

Describe 'ConvertFrom-AwtrixBrightnessValue' {
    It 'Should convert native values to percentages' -ForEach @(
        @{ Value = 0; Expected = 0 }
        @{ Value = 128; Expected = 50 }
        @{ Value = 162; Expected = 64 }
        @{ Value = 255; Expected = 100 }
    ) {
        InModuleScope -Parameters @{
            Value    = $Value
            Expected = $Expected
        } -ScriptBlock {
            ConvertFrom-AwtrixBrightnessValue -Value $Value | Should -Be $Expected
        }
    }

    It 'Should reject a native value outside zero through 255' -ForEach @(-1, 256) {
        InModuleScope -Parameters @{ Value = $_ } -ScriptBlock {
            {
                ConvertFrom-AwtrixBrightnessValue -Value $Value
            } | Should -Throw '*invalid native brightness value*'
        }
    }
}
