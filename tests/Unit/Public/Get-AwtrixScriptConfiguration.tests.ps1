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
Describe 'Get-AwtrixScriptConfiguration' {
    It 'Should request script configuration' {
        Mock Invoke-AwtrixApi { [PSCustomObject] @{ city = 'London' } }
        $result = PSAwtrixNG\Get-AwtrixScriptConfiguration -Device '192.0.2.10' -Name Weather
        $result.city | Should -Be 'London'
        Should -Invoke Invoke-AwtrixApi -ParameterFilter { $Path -eq 'api/v1/apps/Weather/config' } -Exactly -Times 1 -Scope It
    }
}
