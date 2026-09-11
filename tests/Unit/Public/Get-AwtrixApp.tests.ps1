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
Describe 'Get-AwtrixApp' {
    It 'Should request and filter the application inventory' {
        Mock Invoke-AwtrixApi {
            , @([PSCustomObject] @{ name = 'Time' }, [PSCustomObject] @{ name = 'Date' })
        }
        $result = PSAwtrixNG\Get-AwtrixApp -Device '192.0.2.10' -Name Time
        $result.name | Should -Be 'Time'
        Should -Invoke Invoke-AwtrixApi -ParameterFilter { $Path -eq 'api/v1/apps' } -Exactly -Times 1 -Scope It
    }
}
