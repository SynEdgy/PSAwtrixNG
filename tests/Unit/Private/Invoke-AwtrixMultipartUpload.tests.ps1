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

Describe 'Invoke-AwtrixMultipartUpload' {
    It 'Should expose configurable multipart field and content type parameters' {
        InModuleScope -ScriptBlock {
            $command = Get-Command -Name Invoke-AwtrixMultipartUpload

            $command.Parameters.Keys | Should -Contain 'Device'
            $command.Parameters.Keys | Should -Contain 'Path'
            $command.Parameters.Keys | Should -Contain 'Query'
            $command.Parameters.Keys | Should -Contain 'FieldName'
            $command.Parameters.Keys | Should -Contain 'FilePath'
            $command.Parameters.Keys | Should -Contain 'FileName'
            $command.Parameters.Keys | Should -Contain 'ContentType'
            $command.Parameters['Query'].Attributes.Mandatory | Should -BeFalse
        }
    }

    It 'Should emit only a basic filename multipart disposition' {
        InModuleScope -ScriptBlock {
            $source = (Get-Command -Name Invoke-AwtrixMultipartUpload).ScriptBlock.ToString()

            $source | Should -Match 'ContentDispositionHeaderValue'
            $source | Should -Match '\$contentDisposition\.Name'
            $source | Should -Match '\$contentDisposition\.FileName'
            $source | Should -Match '\$multipart\.Add\(\$fileContent\)'
            $source | Should -Not -Match 'FileNameStar'
        }
    }
}
