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
Describe 'Set-AwtrixScript' {
    It 'Should upload raw Berry source' {
        Mock Invoke-AwtrixApi { [PSCustomObject] @{ ok = $true; name = 'Test' } }
        $null = PSAwtrixNG\Set-AwtrixScript -Device '192.0.2.10' -Name Test -Source 'return nil' -Confirm:$false
        Should -Invoke Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/apps/script/Test' -and $Method -eq 'Put' -and $RawBody -and $ContentType -eq 'text/plain'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should fail when the firmware reports a compile error' {
        Mock Invoke-AwtrixApi { [PSCustomObject] @{ error = [PSCustomObject] @{ line = 2; message = 'syntax error' } } }
        {
            PSAwtrixNG\Set-AwtrixScript -Device '192.0.2.10' -Name Test -Source 'bad' -Confirm:$false
        } | Should -Throw '*line 2*syntax error*'
    }
}
