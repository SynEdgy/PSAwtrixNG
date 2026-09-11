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
Describe 'Remove-AwtrixIcon' {
    It 'Should delete an existing icon by full device path' {
        Mock Get-AwtrixIcon {
            [PSCustomObject] @{ Id = 'logo'; Name = 'logo.gif' }
        }
        Mock Invoke-AwtrixApi { [PSCustomObject] @{ ok = $true } }

        $null = PSAwtrixNG\Remove-AwtrixIcon -Device '192.0.2.10' -Name 'logo.gif' -Confirm:$false

        Should -Invoke Invoke-AwtrixApi -ParameterFilter {
            $Path -eq 'api/v1/files' -and
            $Method -eq 'Delete' -and
            $Query.path -eq '/ICONS/logo.gif'
        } -Exactly -Times 1 -Scope It
    }
}
