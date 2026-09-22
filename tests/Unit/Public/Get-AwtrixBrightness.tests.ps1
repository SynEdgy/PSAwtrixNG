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

Describe 'Get-AwtrixBrightness' {
    It 'Should return percentage, native value, and automatic brightness state' {
        Mock -CommandName Get-AwtrixSettings -MockWith {
            [PSCustomObject] @{
                brightness     = 162
                autoBrightness = $false
            }
        }

        $result = PSAwtrixNG\Get-AwtrixBrightness -Device '192.0.2.10'

        $result.PSObject.TypeNames | Should -Contain 'PSAwtrixNG.Brightness'
        $result.Percent | Should -Be 64
        $result.NativeValue | Should -Be 162
        $result.AutoBrightness | Should -BeFalse
        Should -Invoke -CommandName Get-AwtrixSettings -Exactly -Times 1 -Scope It
    }

    It 'Should support the minimum and maximum native values' -ForEach @(
        @{ NativeValue = 0; Percent = 0 }
        @{ NativeValue = 255; Percent = 100 }
    ) {
        Mock -CommandName Get-AwtrixSettings -MockWith {
            [PSCustomObject] @{ brightness = $NativeValue }
        }

        $result = PSAwtrixNG\Get-AwtrixBrightness -Device '192.0.2.10'

        $result.Percent | Should -Be $Percent
        $result.NativeValue | Should -Be $NativeValue
        $result.AutoBrightness | Should -BeNullOrEmpty
    }

    It 'Should fail when the brightness setting is absent' {
        Mock -CommandName Get-AwtrixSettings -MockWith { [PSCustomObject] @{} }

        {
            PSAwtrixNG\Get-AwtrixBrightness -Device '192.0.2.10'
        } | Should -Throw "*did not return the 'brightness' setting*"
    }

    It 'Should fail when the native brightness is outside its supported range' {
        Mock -CommandName Get-AwtrixSettings -MockWith {
            [PSCustomObject] @{ brightness = 256 }
        }

        {
            PSAwtrixNG\Get-AwtrixBrightness -Device '192.0.2.10'
        } | Should -Throw '*invalid native brightness value of 256*'
    }
}
