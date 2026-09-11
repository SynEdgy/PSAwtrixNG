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
Describe 'Get-AwtrixDisplay' {
    It 'Should request display state' {
        Mock Invoke-AwtrixApi { [PSCustomObject] @{ power = $true } }
        $result = PSAwtrixNG\Get-AwtrixDisplay -Device '192.0.2.10'
        $result.power | Should -BeTrue
        Should -Invoke Invoke-AwtrixApi -ParameterFilter { $Path -eq 'api/v1/display' } -Exactly -Times 1 -Scope It
    }
}
