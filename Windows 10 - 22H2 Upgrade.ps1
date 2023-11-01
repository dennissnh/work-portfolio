$dir = 'C:\Source\packages'
$url = 'https://catalog.s.download.windowsupdate.com/c/upgr/2022/07/windows10.0-kb5015684-x64_523c039b86ca98f2d818c4e6706e2cc94b634c4a.msu'
$file = "$($dir)\22H2.msu"
$cab = "$($dir)\Windows10.0-KB5015684-x64_PSFX.cab"
$dism = 'c:\windows\system32\dism.exe'
$expand = 'c:\windows\system32\expand.exe'
Download-File -Source $url -Destination $file -UseBasicDownload
$Logs = New-ImmyTempFile

Start-ProcessWithLogTail -Path $expand -ArgumentList "-f:* $file $dir" -TimeoutSeconds 20 -LogFilePath $Logs
Start-ProcessWithLogTail -Path $dism -ArgumentList "/Online /Add-Package /PackagePath:$cab /Quiet /norestart" -LogFilePath $Logs
Restart-ComputerAndWait
