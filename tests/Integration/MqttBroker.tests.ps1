BeforeAll {
    $script:moduleName = 'PSAwtrixNG'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'
}

AfterAll {
    Get-AwtrixMqttBroker | ForEach-Object {
        Stop-AwtrixMqttBroker -Name $_.Name -Confirm:$false
    }

    Remove-Module -Name $script:moduleName
}

Describe 'AWTRIX MQTT broker integration' {
    It 'Should capture and parse a message published through the local broker' {
        $listener = [System.Net.Sockets.TcpListener]::new(
            [System.Net.IPAddress]::Loopback,
            0
        )
        $listener.Start()
        $port = ([System.Net.IPEndPoint] $listener.LocalEndpoint).Port
        $listener.Stop()

        $brokerName = 'Integration-{0}' -f [System.Guid]::NewGuid().ToString('N')

        try
        {
            $null = Start-AwtrixMqttBroker -Name $brokerName -Port $port -Confirm:$false

            $expectedFramework = if ($PSVersionTable.PSEdition -eq 'Desktop')
            {
                'net461'
            }
            else
            {
                'netstandard2.0'
            }

            $mqttFactoryType = 'MQTTnet.MqttFactory' -as [System.Type]
            $mqttAssemblyDirectory = Split-Path -Path $mqttFactoryType.Assembly.Location -Parent
            (Split-Path -Path $mqttAssemblyDirectory -Leaf) | Should -Be $expectedFramework

            $publishParameters = @{
                BrokerHost = 'localhost'
                Port       = $port
                Topic      = 'awtrix_test/stats'
                Payload    = @{ version = 'test'; battery = 90 }
                Confirm    = $false
            }

            $null = Publish-AwtrixMqttMessage @publishParameters

            $messages = @(Receive-AwtrixMqttMessage -BrokerName $brokerName -TimeoutSec 2 -ParseJson)

            $messages.Count | Should -Be 1
            $messages[0].Topic | Should -Be 'awtrix_test/stats'
            $messages[0].Data.version | Should -Be 'test'
            $messages[0].Data.battery | Should -Be 90

            $publishParameters = @{
                BrokerHost = 'localhost'
                Port       = $port
                Topic      = 'awtrix_test/text'
                Payload    = 'not-json'
                Confirm    = $false
            }

            $null = Publish-AwtrixMqttMessage @publishParameters

            $textMessages = @(Receive-AwtrixMqttMessage -BrokerName $brokerName -TimeoutSec 2 -ParseJson)

            $textMessages.Count | Should -Be 1
            $textMessages[0].Payload | Should -Be 'not-json'
            $textMessages[0].Data | Should -BeNullOrEmpty
        }
        finally
        {
            if (Get-AwtrixMqttBroker -Name $brokerName)
            {
                Stop-AwtrixMqttBroker -Name $brokerName -Confirm:$false
            }
        }
    }
}
