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
Describe 'Get-AwtrixStorage' {
    It 'Should return used and free storage information' {
        Mock Invoke-AwtrixApi {
            [PSCustomObject] @{
                files      = @()
                usedBytes  = 262144
                totalBytes = 1048576
            }
        }

        $storage = PSAwtrixNG\Get-AwtrixStorage -Device '192.0.2.10'

        $storage.PSObject.TypeNames | Should -Contain 'PSAwtrixNG.Storage'
        $storage.UsedBytes | Should -Be 262144
        $storage.FreeBytes | Should -Be 786432
        $storage.TotalBytes | Should -Be 1048576
        $storage.UsedMiB | Should -Be 0.25
        $storage.FreeMiB | Should -Be 0.75
        $storage.TotalMiB | Should -Be 1
        $storage.UsedPercent | Should -Be 25
        $storage.FreePercent | Should -Be 75
        Should -Invoke Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/files' -and $Query.dir -eq '/ICONS'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should reject inconsistent storage values' {
        Mock Invoke-AwtrixApi {
            [PSCustomObject] @{
                files      = @()
                usedBytes  = 2000
                totalBytes = 1000
            }
        }

        {
            PSAwtrixNG\Get-AwtrixStorage -Device '192.0.2.10'
        } | Should -Throw '*invalid storage values*'
    }
}
