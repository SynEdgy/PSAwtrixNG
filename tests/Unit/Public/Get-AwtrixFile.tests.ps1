BeforeAll {
    $script:moduleName = 'PSAwtrixNG'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}
AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')
    Remove-Module -Name $script:moduleName
}
Describe 'Get-AwtrixFile' {
    It 'Should list files with storage metadata' {
        Mock Invoke-AwtrixApi {
            [PSCustomObject] @{
                files      = @([PSCustomObject] @{ name = 'logo.gif'; size = 42 })
                usedBytes  = 100
                totalBytes = 1000
            }
        }

        $file = PSAwtrixNG\Get-AwtrixFile -Device '192.0.2.10' -Directory ICONS

        $file.Name | Should -Be 'logo.gif'
        $file.Directory | Should -Be 'ICONS'
        $file.Path | Should -Be '/ICONS/logo.gif'
        $file.SizeBytes | Should -Be 42
        $file.FreeBytes | Should -Be 900
        $file.Uri.AbsoluteUri | Should -Be 'http://192.0.2.10/ICONS/logo.gif'
    }

    It 'Should use a case-sensitive exact name filter' {
        Mock Invoke-AwtrixApi {
            [PSCustomObject] @{
                files = @(
                    [PSCustomObject] @{ name = 'Logo.gif'; size = 42 }
                    [PSCustomObject] @{ name = 'logo.gif'; size = 43 }
                )
                usedBytes  = 100
                totalBytes = 1000
            }
        }

        $file = PSAwtrixNG\Get-AwtrixFile -Device '192.0.2.10' -Directory ICONS -Name 'logo.gif'

        $file.Name | Should -BeExactly 'logo.gif'
        $file.SizeBytes | Should -Be 43
    }

    It 'Should normalize a firmware file name returned as a full path' {
        Mock Invoke-AwtrixApi {
            [PSCustomObject] @{
                files      = @([PSCustomObject] @{ name = '/ICONS/logo.gif'; size = 42 })
                usedBytes  = 100
                totalBytes = 1000
            }
        }

        $file = PSAwtrixNG\Get-AwtrixFile -Device '192.0.2.10' -Directory ICONS

        $file.Name | Should -BeExactly 'logo.gif'
        $file.Path | Should -BeExactly '/ICONS/logo.gif'
        $file.Uri.AbsoluteUri | Should -Be 'http://192.0.2.10/ICONS/logo.gif'
    }
}
