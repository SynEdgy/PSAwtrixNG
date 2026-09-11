BeforeAll {
    $script:moduleName = 'PSAwtrixNG'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $script:typeAcceleratorsClass = [psobject].Assembly.GetType(
        'System.Management.Automation.TypeAccelerators'
    )
}
AfterAll {
    Remove-Module -Name $script:moduleName -ErrorAction SilentlyContinue
}
Describe 'PSAwtrixNG type accelerators' {
    It 'Should export bare and module-qualified payload classes' {
        $accelerators = $script:typeAcceleratorsClass::Get

        $accelerators['AwtrixScroll'].FullName | Should -Be 'AwtrixScroll'
        $accelerators['AwtrixApp'].FullName | Should -Be 'AwtrixApp'
        $accelerators['AwtrixNotification'].FullName | Should -Be 'AwtrixNotification'
        $accelerators['PSAwtrixNG.AwtrixScroll'].FullName | Should -Be 'AwtrixScroll'
        $accelerators['PSAwtrixNG.AwtrixApp'].FullName | Should -Be 'AwtrixApp'
        $accelerators['PSAwtrixNG.AwtrixNotification'].FullName | Should -Be 'AwtrixNotification'
    }

    It 'Should cast hashtable keys case-insensitively' {
        $app = [AwtrixApp] @{
            TEXTCOLOR = '#00FF00'
            ICONMODE  = 'push'
            SCROLL    = @{
                WHENFITS = 'scroll'
                HOLDMS   = 0
            }
        }

        $app.textColor | Should -Be '#00FF00'
        $app.iconMode | Should -Be 'push'
        $app.scroll.whenFits | Should -Be 'scroll'
        $app.scroll.holdMs | Should -Be 0
    }

    It 'Should keep bare accelerators available after a force re-import' {
        Import-Module -Name $script:moduleName -Force -ErrorAction Stop

        $accelerators = $script:typeAcceleratorsClass::Get

        $accelerators['AwtrixApp'].FullName | Should -Be 'AwtrixApp'
        $accelerators['PSAwtrixNG.AwtrixApp'].FullName | Should -Be 'AwtrixApp'
    }
}
