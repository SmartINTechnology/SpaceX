<#
.Synopsis
Installs and loads all the required modules for the build.
.Description
Installs and loads all the required modules for the build.
.Notes
Version | Date | Author
1.0.0 | 2019/01/07 | francois-xavier cat (@lazywinadm)
-initial version based on Kevin Marquette/Warren Frame version
.Link
https://lazywinadmin.com
#>
PARAM($Task='default')

"Start Build"

# Grab nuget bits, install modules, set build variables, start build.
"  Install Dependent Modules"
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
Install-Module -Name InvokeBuild, PSDeploy, BuildHelpers, PSScriptAnalyzer, PlatyPS -force -Scope CurrentUser
Install-Module -Name Pester, PowerShellGet -Force -SkipPublisherCheck -Scope CurrentUser -AllowClobber

"  Import Dependent Modules"
Import-Module -Name InvokeBuild, BuildHelpers, PSScriptAnalyzer

# Normalize build system and project details into environment variables
Set-BuildEnvironment

"  InvokeBuild"
Invoke-Build -Task $Task -Result result
if ($Result.Error)
{
    exit 1
}
else
{
    exit 0
}

<#
Write-Output -InputObject 'Running AppVeyor build script'
Write-Output -InputObject "ModuleName    : $env:ModuleName"
Write-Output -InputObject "Build version : $env:APPVEYOR_BUILD_VERSION"
Write-Output -InputObject "Author        : $env:APPVEYOR_REPO_COMMIT_AUTHOR"
Write-Output -InputObject "Branch        : $env:APPVEYOR_REPO_BRANCH"
write-output -InputObject "Build Folder  : $env:APPVEYOR_BUILD_FOLDER"
write-output -InputObject "Project Name  : $env:APPVEYOR_PROJECT_NAME"


Get-ChildItem env:/appv*

#---------------------------------# 
# Main                            # 
#---------------------------------# 
Install-Module -Name Pester
Import-Module -Name Pester

write-output "BUILD_FOLDER: $($env:APPVEYOR_BUILD_FOLDER)"
write-output "PROJECT_NAME: $($env:APPVEYOR_PROJECT_NAME)"

$ModuleClonePath = Join-Path -Path $env:APPVEYOR_BUILD_FOLDER -ChildPath $env:APPVEYOR_PROJECT_NAME
Write-Output "MODULE CLONE PATH: $($ModuleClonePath)"

$moduleName = "$($env:APPVEYOR_PROJECT_NAME)"
Get-Module $moduleName

#Pester Tests
write-verbose "invoking pester"
$Results = Invoke-Pester -Path "$($env:APPVEYOR_BUILD_FOLDER)\Tests" -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru

#Uploading Testresults to Appveyor
(New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path -Path .\TestsResults.xml))

if ($Results.FailedCount -gt 0 -or $Results.PassedCount -eq 0) { 
    throw "$($Results.FailedCount) tests failed - $($Results.PassedCount) successfully passed"
}
#>