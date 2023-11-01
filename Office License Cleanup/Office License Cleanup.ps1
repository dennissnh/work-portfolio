if ($OLicenseCleanup) { 
   $OLicenseCleanup | FileShould-Be -InPath "C:\Source\OLicenseCleanup.vbs"
}

Invoke-ImmyCommand {
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings"
    New-ItemProperty -Path $registryPath -Name "Enabled" -Value 1 -PropertyType DWORD -Force | Out-Null
    Cscript.exe "C:\Source\OLicenseCleanup.vbs"
    New-ItemProperty -Path $registryPath -Name "Enabled" -Value 0 -PropertyType DWORD -Force | Out-Null
}
