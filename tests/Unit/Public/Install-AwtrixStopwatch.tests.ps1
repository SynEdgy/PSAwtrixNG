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
Describe 'Install-AwtrixStopwatch' {
    It 'Should install a button-driven Berry stopwatch' {
        Mock Set-AwtrixScript { [PSCustomObject] @{ ok = $true } }
        $null = PSAwtrixNG\Install-AwtrixStopwatch -Device '192.0.2.10' -Confirm:$false
        Should -Invoke Set-AwtrixScript -ParameterFilter {
            $Name -eq 'Stopwatch' -and
            $Source -match 'def on_button\(btn\)' -and
            $Source -match 'mqtt.subscribe\("awtrix/stopwatch/reset"'
        } -Exactly -Times 1 -Scope It
    }
}
