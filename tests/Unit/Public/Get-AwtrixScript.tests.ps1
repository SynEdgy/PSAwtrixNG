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
Describe 'Get-AwtrixScript' {
    It 'Should return raw Berry source' {
        Mock Invoke-AwtrixApi { 'return nil' }
        $result = PSAwtrixNG\Get-AwtrixScript -Device '192.0.2.10' -Name Test
        $result | Should -Be 'return nil'
        Should -Invoke Invoke-AwtrixApi -ParameterFilter { $Path -eq 'api/v1/apps/script/Test' } -Exactly -Times 1 -Scope It
    }
}
