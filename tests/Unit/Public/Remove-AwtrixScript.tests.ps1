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
Describe 'Remove-AwtrixScript' {
    It 'Should delete the script application' {
        Mock Invoke-AwtrixApi
        PSAwtrixNG\Remove-AwtrixScript -Device '192.0.2.10' -Name Test -Confirm:$false
        Should -Invoke Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/apps/Test' -and $Method -eq 'Delete'
        } -Exactly -Times 1 -Scope It
    }
}
