﻿$ErrorActionPreference = 'Stop'

# remove the old version if installed
[array]$key = Get-UninstallRegistryKey -SoftwareName "Mercury"

if ($key.Count -eq 1) {
   $RemoveProc = Start-Process -FilePath $key[0].UninstallString -ArgumentList '--mode unattended' -PassThru
   $updateId = $RemoveProc.Id
   Write-Debug "Uninstalling old version of CCDC Mercury."
   Write-Debug "Uninstall Process ID:`t$updateId"
   $RemoveProc.WaitForExit()
} elseif ($key.Count -gt 1) {
   Throw "Multiple, previous installs found!  Cannot proceed with install of new version."
}

If (Get-OSArchitectureWidth -Compare 64) {
   $InstallDir = Join-Path ${env:ProgramFiles(x86)} "\CCDC\Mercury $env:ChocolateyPackageVersion"
} else {
   $InstallDir = Join-Path $env:ProgramFiles "\CCDC\Mercury $env:ChocolateyPackageVersion"
}

$InstallArgs = @{
   packageName    = 'ccdcmercury'
   fileType       = 'EXE'
   softwareName   = "$env:ChocolateyPackageName $env:ChocolateyPackageVersion*"
   url            = 'https://downloads.ccdc.cam.ac.uk/Mercury/2020.1/mercury-2020.1.0-windows-installer.exe'
   checksumType   = 'sha256'
   checksum       = 'c2c2c98170579f382bbe3bc96d352693b81c05b3f22c2db9121fb7c15dd4fbe0'
   silentArgs     = '--mode unattended --prefix "' + $InstallDir + '"'
   validExitCodes = @(0)
}

Install-ChocolateyPackage @InstallArgs

