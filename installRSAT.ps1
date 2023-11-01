$currentWU = Invoke-ImmyCommand {Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer}

Invoke-ImmyCommand {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
    Restart-Service wuauserv
}

$dism = 'c:\windows\system32\dism.exe'
$Logs = New-ImmyTempFile

Start-ProcessWithLogTail -Path $dism -ArgumentList "/Online /add-capability /CapabilityName:Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -LogFilePath $Logs
Invoke-ImmyCommand {Start-Sleep -Seconds 10}
Start-ProcessWithLogTail -Path $dism -ArgumentList "/Online /add-capability /CapabilityName:Rsat.Dns.Tools~~~~0.0.1.0" -LogFilePath $Logs
Invoke-ImmyCommand {Start-Sleep -Seconds 10}
Start-ProcessWithLogTail -Path $dism -ArgumentList "/Online /add-capability /CapabilityName:Rsat.FileServices.Tools~~~~0.0.1.0" -LogFilePath $Logs
Invoke-ImmyCommand {Start-Sleep -Seconds 10}
Start-ProcessWithLogTail -Path $dism -ArgumentList "/Online /add-capability /CapabilityName:Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0" -LogFilePath $Logs
Invoke-ImmyCommand {Start-Sleep -Seconds 10}
Start-ProcessWithLogTail -Path $dism -ArgumentList "/Online /add-capability /CapabilityName:Rsat.ServerManager.Tools~~~~0.0.1.0" -LogFilePath $Logs
Invoke-ImmyCommand {Start-Sleep -Seconds 10}
Start-ProcessWithLogTail -Path $dism -ArgumentList "/Online /add-capability /CapabilityName:Rsat.DHCP.Tools~~~~0.0.1.0" -LogFilePath $Logs

Invoke-ImmyCommand{
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU
    Restart-Service wuauserv
}
