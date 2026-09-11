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
Describe 'Set-AwtrixIcon' {
    BeforeEach {
        $script:iconPath = Join-Path -Path $TestDrive -ChildPath 'logo.gif'
        [System.IO.File]::WriteAllBytes(
            $script:iconPath,
            [System.Text.Encoding]::ASCII.GetBytes('GIF89a')
        )
    }

    It 'Should upload and verify an icon when storage is sufficient' {
        Mock Invoke-AwtrixApi {
            [PSCustomObject] @{
                files      = @([PSCustomObject] @{ name = 'logo.gif'; size = 6 })
                usedBytes  = 100
                totalBytes = 10000
            }
        }
        Mock Invoke-AwtrixMultipartUpload { [PSCustomObject] @{ ok = $true } }
        Mock Get-AwtrixIcon {
            [PSCustomObject] @{ Id = 'logo'; Name = 'logo.gif'; SizeBytes = 6 }
        }

        $icon = PSAwtrixNG\Set-AwtrixIcon -Device '192.0.2.10' -Path $script:iconPath -Confirm:$false

        $icon.Id | Should -Be 'logo'
        Should -Invoke Invoke-AwtrixMultipartUpload -ParameterFilter {
            $Path -eq 'api/v1/files' -and
            $Query.dir -eq '/ICONS' -and
            $FilePath -eq $script:iconPath -and
            $FileName -eq 'logo.gif'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should warn and skip upload when storage is insufficient' {
        Mock Invoke-AwtrixApi {
            [PSCustomObject] @{
                files      = @()
                usedBytes  = 100
                totalBytes = 100
            }
        }
        Mock Invoke-AwtrixMultipartUpload { throw 'Upload should not run.' }

        $warnings = @(PSAwtrixNG\Set-AwtrixIcon -Device '192.0.2.10' -Path $script:iconPath -Confirm:$false 3>&1)

        $warnings.Count | Should -Be 1
        $warnings[0].Message | Should -Match 'only 0 bytes are available'
        Should -Invoke Invoke-AwtrixMultipartUpload -Exactly -Times 0 -Scope It
    }

    It 'Should reject content that does not match the extension' {
        $invalidPath = Join-Path -Path $TestDrive -ChildPath 'invalid.gif'
        [System.IO.File]::WriteAllText($invalidPath, 'not a gif')

        {
            PSAwtrixNG\Set-AwtrixIcon -Device '192.0.2.10' -Path $invalidPath -Confirm:$false
        } | Should -Throw '*does not contain valid .gif icon signature bytes*'
    }

    It 'Should reject a destination icon ID longer than 64 characters' {
        $longName = 'a' * 65

        {
            PSAwtrixNG\Set-AwtrixIcon -Device '192.0.2.10' -Path $script:iconPath -Name $longName -Confirm:$false
        } | Should -Throw
    }

    It 'Should recognize a full-path firmware listing when replacing an icon' {
        Mock Invoke-AwtrixApi {
            [PSCustomObject] @{
                files      = @([PSCustomObject] @{ name = '/ICONS/logo.gif'; size = 5000 })
                usedBytes  = 10000
                totalBytes = 10000
            }
        }
        Mock Invoke-AwtrixMultipartUpload { [PSCustomObject] @{ ok = $true } }
        Mock Get-AwtrixIcon {
            [PSCustomObject] @{ Id = 'logo'; Name = 'logo.gif'; SizeBytes = 6 }
        }

        $icon = PSAwtrixNG\Set-AwtrixIcon -Device '192.0.2.10' -Path $script:iconPath -Confirm:$false

        $icon.Id | Should -Be 'logo'
        Should -Invoke Invoke-AwtrixMultipartUpload -Exactly -Times 1 -Scope It
    }
}
