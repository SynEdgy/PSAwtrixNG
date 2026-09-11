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
            $Source -match 'gap >= 350 && gap <= 1200' -and
            $Source -match 'self.selectCount >= 3' -and
            $Source -match 'var hundredths = int\(\(elapsed % 1000\) / 10\)' -and
            $Source -match 'secondsText \+ "\." \+ hundredthsText' -and
            $Source -match 'mqtt.subscribe\("awtrix/stopwatch/reset"' -and
            $Source -match 'mqtt.subscribe\("awtrix/stopwatch/control"' -and
            $Source -match 'command == "start"' -and
            $Source -match 'command == "pause"' -and
            $Source -match 'command == "toggle"' -and
            $Source -match 'command == "reset"' -and
            $Source -match 'command == "restart"'
        } -Exactly -Times 1 -Scope It
    }
}
