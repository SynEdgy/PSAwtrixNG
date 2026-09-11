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
Describe 'Get-AwtrixCapability' {
    It 'Should request device capabilities' {
        Mock Invoke-AwtrixApi { [PSCustomObject] @{ effects = @('Plasma') } }
        $result = PSAwtrixNG\Get-AwtrixCapability -Device '192.0.2.10'
        $result.effects | Should -Contain 'Plasma'
        Should -Invoke Invoke-AwtrixApi -ParameterFilter { $Path -eq 'api/v1/capabilities' } -Exactly -Times 1 -Scope It
    }
}
