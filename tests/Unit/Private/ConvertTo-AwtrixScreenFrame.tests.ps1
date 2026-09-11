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

Describe 'ConvertTo-AwtrixScreenFrame' {
    It 'Should decode packed RGB24 pixels and coordinates' {
        InModuleScope -ScriptBlock {
            $pixelData = @(for ($index = 0; $index -lt 256; $index++) { 0 })
            $pixelData[33] = 0x123456

            $frame = ConvertTo-AwtrixScreenFrame -PixelData $pixelData -Width 32 -Height 8 -Device 'clock'
            $pixel = $frame.Pixels[33]

            $frame.Width | Should -Be 32
            $frame.Height | Should -Be 8
            $pixel.X | Should -Be 1
            $pixel.Y | Should -Be 1
            $pixel.Red | Should -Be 0x12
            $pixel.Green | Should -Be 0x34
            $pixel.Blue | Should -Be 0x56
            $pixel.Hex | Should -Be '#123456'
        }
    }

    It 'Should reject a screen payload with the wrong pixel count' {
        InModuleScope -ScriptBlock {
            {
                ConvertTo-AwtrixScreenFrame -PixelData @(1, 2, 3) -Width 32 -Height 8 -Device 'clock'
            } | Should -Throw '*must contain 256 pixels*'
        }
    }
}
