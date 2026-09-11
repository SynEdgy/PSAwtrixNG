BeforeAll {
    $script:moduleName = 'PSAwtrixNG'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
}
AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    Remove-Module -Name $script:moduleName
}
Describe 'ConvertTo-AwtrixJsonObject' {
    It 'Should preserve ordinary objects' {
        InModuleScope -ScriptBlock {
            $inputValue = @{ MixedCase = 'value' }
            $result = ConvertTo-AwtrixJsonObject -InputObject $inputValue

            [System.Object]::ReferenceEquals($result, $inputValue) | Should -BeTrue
        }
    }

    It 'Should omit unset class properties and normalize nested scroll casing' {
        InModuleScope -ScriptBlock {
            $app = [AwtrixApp] @{
                TEXTCOLOR = '#00FF00'
                SCROLL    = @{ WHENFITS = 'scroll' }
            }

            $result = ConvertTo-AwtrixJsonObject -InputObject $app

            @($result.Keys) | Should -Be @('textColor', 'scroll')
            @($result.scroll.Keys) | Should -Be @('whenFits')
        }
    }
}
