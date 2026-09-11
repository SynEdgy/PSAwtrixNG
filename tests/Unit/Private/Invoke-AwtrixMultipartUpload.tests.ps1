BeforeAll {
    $script:moduleName = 'PSAwtrixNG'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
}
AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    Remove-Module -Name $script:moduleName
}
Describe 'Invoke-AwtrixMultipartUpload' {
    It 'Should expose the parameters required for a streaming file upload' {
        InModuleScope -ScriptBlock {
            $command = Get-Command -Name Invoke-AwtrixMultipartUpload

            $command.Parameters.Keys | Should -Contain 'Device'
            $command.Parameters.Keys | Should -Contain 'Path'
            $command.Parameters.Keys | Should -Contain 'Query'
            $command.Parameters.Keys | Should -Contain 'FilePath'
            $command.Parameters.Keys | Should -Contain 'FileName'
        }
    }

    It 'Should emit only a basic filename multipart disposition' {
        InModuleScope -ScriptBlock {
            $source = (Get-Command -Name Invoke-AwtrixMultipartUpload).ScriptBlock.ToString()

            $source | Should -Match 'ContentDispositionHeaderValue'
            $source | Should -Match '\$contentDisposition\.FileName'
            $source | Should -Match '\$multipart\.Add\(\$fileContent\)'
            $source | Should -Not -Match 'FileNameStar'
        }
    }
}
