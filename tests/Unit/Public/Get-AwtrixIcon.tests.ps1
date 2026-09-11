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
Describe 'Get-AwtrixIcon' {
    It 'Should return the icon ID without its extension' {
        Mock Get-AwtrixFile {
            [PSCustomObject] @{
                Name       = 'logo.gif'
                Path       = '/ICONS/logo.gif'
                SizeBytes  = 42
                UsedBytes  = 100
                FreeBytes  = 900
                TotalBytes = 1000
                Uri        = [System.Uri] 'http://192.0.2.10/ICONS/logo.gif'
            }
        }

        $icon = PSAwtrixNG\Get-AwtrixIcon -Device '192.0.2.10' -Name 'logo.gif'

        $icon.Id | Should -BeExactly 'logo'
        $icon.Name | Should -BeExactly 'logo.gif'
        Should -Invoke Get-AwtrixFile -ParameterFilter {
            $Directory -eq 'ICONS' -and $Name -ceq 'logo.gif'
        } -Exactly -Times 1 -Scope It
    }
}
