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
Describe 'Set-AwtrixScriptConfiguration' {
    It 'Should patch script configuration' {
        Mock Invoke-AwtrixApi { [PSCustomObject] @{ city = 'London' } }
        $null = PSAwtrixNG\Set-AwtrixScriptConfiguration -Device '192.0.2.10' -Name Weather -Configuration @{ city = 'London' } -Confirm:$false
        Should -Invoke Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/apps/Weather/config' -and $Method -eq 'Patch' -and $Body.city -eq 'London'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should fail when restarting the configured script reports an error' {
        Mock Invoke-AwtrixApi {
            [PSCustomObject] @{ error = [PSCustomObject] @{ line = 4; message = 'runtime error' } }
        }

        {
            PSAwtrixNG\Set-AwtrixScriptConfiguration -Device '192.0.2.10' -Name Weather -Configuration @{ city = 'London' } -Confirm:$false
        } | Should -Throw '*line 4*runtime error*'
    }
}
