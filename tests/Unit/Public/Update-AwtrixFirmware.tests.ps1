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

Describe 'Update-AwtrixFirmware' {
    BeforeAll {
        $script:firmwarePath = Join-Path -Path $TestDrive -ChildPath 'firmware-awtrix-ng.bin'
        [System.IO.File]::WriteAllBytes(
            $script:firmwarePath,
            [System.Byte[]] @(0xE9, 0x00, 0x00, 0x00)
        )

        Mock Invoke-AwtrixMultipartUpload {
            [PSCustomObject] @{ ok = $true }
        }
    }

    It 'Should upload the firmware using the required multipart field' {
        $result = PSAwtrixNG\Update-AwtrixFirmware -Device '192.0.2.10' -Path $script:firmwarePath -AllowFirmwareUpdate -Confirm:$false

        $result.Accepted | Should -BeTrue
        $result.Rebooting | Should -BeTrue
        Should -Invoke Invoke-AwtrixMultipartUpload -ParameterFilter {
            $Path -eq 'update' -and
            $FieldName -eq 'firmware' -and
            $FilePath -eq $script:firmwarePath -and
            $FileName -eq 'firmware-awtrix-ng.bin' -and
            $ContentType -eq 'application/octet-stream'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should not upload firmware when WhatIf is used' {
        $null = PSAwtrixNG\Update-AwtrixFirmware -Device '192.0.2.10' -Path $script:firmwarePath -AllowFirmwareUpdate -WhatIf

        Should -Invoke Invoke-AwtrixMultipartUpload -Exactly -Times 0 -Scope It
    }

    It 'Should require explicit firmware update opt-in' {
        {
            PSAwtrixNG\Update-AwtrixFirmware -Device '192.0.2.10' -Path $script:firmwarePath -Confirm:$false
        } | Should -Throw '*requires -AllowFirmwareUpdate*'

        Should -Invoke Invoke-AwtrixMultipartUpload -Exactly -Times 0 -Scope It
    }

    It 'Should reject a USB full-flash image' {
        $usbImagePath = Join-Path -Path $TestDrive -ChildPath 'usb-awtrix-ng-4mb.bin'
        [System.IO.File]::WriteAllBytes($usbImagePath, [System.Byte[]] @(0xE9))

        {
            PSAwtrixNG\Update-AwtrixFirmware -Device '192.0.2.10' -Path $usbImagePath -AllowFirmwareUpdate -Confirm:$false
        } | Should -Throw '*USB flash image*'

        Should -Invoke Invoke-AwtrixMultipartUpload -Exactly -Times 0 -Scope It
    }

    It 'Should reject a file without an ESP image signature' {
        $invalidImagePath = Join-Path -Path $TestDrive -ChildPath 'invalid.bin'
        [System.IO.File]::WriteAllBytes($invalidImagePath, [System.Byte[]] @(0x00))

        {
            PSAwtrixNG\Update-AwtrixFirmware -Device '192.0.2.10' -Path $invalidImagePath -AllowFirmwareUpdate -Confirm:$false
        } | Should -Throw '*valid ESP image signature*'

        Should -Invoke Invoke-AwtrixMultipartUpload -Exactly -Times 0 -Scope It
    }

    It 'Should reject an unsuccessful firmware response' {
        Mock Invoke-AwtrixMultipartUpload {
            [PSCustomObject] @{ ok = $false }
        }

        {
            PSAwtrixNG\Update-AwtrixFirmware -Device '192.0.2.10' -Path $script:firmwarePath -AllowFirmwareUpdate -Confirm:$false
        } | Should -Throw '*did not accept the firmware update*'
    }
}
