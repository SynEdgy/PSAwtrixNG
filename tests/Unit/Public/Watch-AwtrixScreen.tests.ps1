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

Describe 'Watch-AwtrixScreen' {
    BeforeAll {
        $script:testFrame = [PSCustomObject] @{
            PSTypeName = 'PSAwtrixNG.ScreenFrame'
            Width      = 32
            Height     = 8
            Signature  = 'unchanged'
            Pixels     = @()
        }

        Mock -CommandName Get-AwtrixScreen -MockWith { $script:testFrame }
        Mock -CommandName Write-AwtrixScreenFrame
        Mock -CommandName Start-Sleep
        Mock -CommandName Write-Host
    }

    It 'Should render only changed frames by default' {
        $watchParameters = @{
            Device               = '192.0.2.10'
            FrameCount           = 2
            IntervalMilliseconds = 100
            PassThru             = $true
        }

        $result = @(PSAwtrixNG\Watch-AwtrixScreen @watchParameters)

        $result.Count | Should -Be 1
        Should -Invoke -CommandName Get-AwtrixScreen -Exactly -Times 2 -Scope It
        Should -Invoke -CommandName Write-AwtrixScreenFrame -Exactly -Times 1 -Scope It
    }

    It 'Should render unchanged frames when requested' {
        $watchParameters = @{
            Device               = '192.0.2.10'
            FrameCount           = 2
            IntervalMilliseconds = 100
            ShowUnchanged        = $true
        }

        PSAwtrixNG\Watch-AwtrixScreen @watchParameters

        Should -Invoke -CommandName Write-AwtrixScreenFrame -Exactly -Times 2 -Scope It
    }
}
