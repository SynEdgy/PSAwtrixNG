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
Describe 'Save-AwtrixIcon' {
    It 'Should download an icon to a directory' {
        Mock Get-AwtrixIcon {
            [PSCustomObject] @{
                Name = 'logo.gif'
                Uri  = [System.Uri] 'http://192.0.2.10/ICONS/logo.gif'
            }
        }
        Mock Invoke-WebRequest {
            [System.IO.File]::WriteAllBytes(
                $OutFile,
                [System.Text.Encoding]::ASCII.GetBytes('GIF89a')
            )
        }

        $file = PSAwtrixNG\Save-AwtrixIcon -Device '192.0.2.10' -Name 'logo.gif' -Path $TestDrive -Confirm:$false

        $file.Name | Should -Be 'logo.gif'
        $file.Length | Should -Be 6
        Should -Invoke Invoke-WebRequest -ParameterFilter {
            $Uri.AbsoluteUri -eq 'http://192.0.2.10/ICONS/logo.gif'
        } -Exactly -Times 1 -Scope It
    }

    It 'Should send an explicit authorization header for an authenticated device' {
        $destination = Join-Path -Path $TestDrive -ChildPath 'authenticated'
        $null = New-Item -Path $destination -ItemType Directory
        $credential = [PSCredential]::new(
            'clock',
            (ConvertTo-SecureString -String 'secret' -AsPlainText -Force)
        )
        $device = New-AwtrixDevice -HostName '192.0.2.10' -Credential $credential
        Mock Get-AwtrixIcon {
            [PSCustomObject] @{
                Name = 'logo.gif'
                Uri  = [System.Uri] 'http://192.0.2.10/ICONS/logo.gif'
            }
        }
        Mock Invoke-WebRequest {
            [System.IO.File]::WriteAllBytes(
                $OutFile,
                [System.Text.Encoding]::ASCII.GetBytes('GIF89a')
            )
        }

        $null = PSAwtrixNG\Save-AwtrixIcon -Device $device -Name 'logo.gif' -Path $destination -Confirm:$false

        Should -Invoke Invoke-WebRequest -ParameterFilter {
            $Headers.Authorization -eq 'Basic Y2xvY2s6c2VjcmV0'
        } -Exactly -Times 1 -Scope It
    }
}
