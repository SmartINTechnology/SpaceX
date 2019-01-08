$projectRoot = Resolve-Path -Path "$PSScriptRoot\.."
$moduleRoot = Split-Path -Path (Resolve-Path -Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path -Path $moduleRoot -Leaf

#Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

Describe "Help tests for $moduleName" -Tags Build {

    $functions = Get-Command -Module $moduleName
    $help = $functions | Foreach-Object -Process {Get-Help -Name $_.name}
    foreach ($node in $help)
    {
        Context $node.name {

            it "has a description" {
                $node.description | Should Not BeNullOrEmpty
            }
            it "has an example" {
                $node.examples | Should Not BeNullOrEmpty
            }
            foreach ($parameter in $node.parameters.parameter)
            {
                if ($parameter -notmatch 'whatif|confirm')
                {
                    it "parameter $($parameter.name) has a description" {
                        $parameter.Description.text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}