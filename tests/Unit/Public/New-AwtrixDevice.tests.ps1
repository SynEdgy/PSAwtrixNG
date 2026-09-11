BeforeAll {
    $script:moduleName = 'PSAwtrixNG'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}

Describe 'New-AwtrixDevice' {
    It 'Should create a typed reusable device object' {
        $device = PSAwtrixNG\New-AwtrixDevice -HostName '192.0.2.10' -Name 'TestClock' -TimeoutSec 20

        $device.PSTypeNames | Should -Contain 'PSAwtrixNG.Device'
        $device.Name | Should -Be 'TestClock'
        $device.BaseUri.AbsoluteUri | Should -Be 'http://192.0.2.10/'
        $device.TimeoutSec | Should -Be 20
    }
}
