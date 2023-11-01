$TestFile = "RecreateProfile-Test"

switch($method){
    "test"
    {
        Invoke-ImmyCommand {
            if (Test-Path -Path ("C:\Users\$Using:username" + "\$Using:TestFile" + ".txt") -PathType Leaf) {
                Remove-Item –path ("C:\Users\$Using:username" + "\$Using:TestFile" + ".txt") -force
                return $true
            }else{
                return $false
            }
        }
    }
    "get"
    {
        return
    }
    "set"
    {
        Write-Progress "Getting user SID"
        $SID = get-aduser $username | %{$_.SID.Value}

        Invoke-ImmyCommand {
            $sessionId = ((quser | Where-Object { $_ -match $Using:username }) -split ' +')[2]
            if ($sessionId) {
                Write-Progress "Logging off user..."
                logoff $sessionId
            }else {
                Write-Progress "User already logged off, proceeding..."
            }
        }

        Write-Progress "Rebooting machine..."
        Restart-ComputerAndWait
        
        Invoke-ImmyCommand {
            Write-Progress "Renaming profile path"
            Rename-item –path "C:\Users\$Using:username" –newname ("C:\Users\$Using:username" + ".old") -force
            Write-Progress "Removing old profile"
            Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $Using:username } | Remove-CimInstance
            }
        Write-Progress "Recreating profile"
        Ensure-UserProfileExists -UserName $Username -SID $SID

        if ($UserData) {
            Write-Progress "Copying user data"
            Invoke-ImmyCommand {
                robocopy  ("C:\Users\$Using:username" + ".old" + "\Desktop") ("C:\Users\$Using:username" + "\Desktop") /COPYALL /ZB /R:2 /W:2 /E
                robocopy  ("C:\Users\$Using:username" + ".old" + "\Documents") ("C:\Users\$Using:username" + "\Documents") /COPYALL /ZB /R:2 /W:2 /E
                robocopy  ("C:\Users\$Using:username" + ".old" + "\Downloads") ("C:\Users\$Using:username" + "\Downloads") /COPYALL /ZB /R:2 /W:2 /E
                robocopy  ("C:\Users\$Using:username" + ".old" + "\Music") ("C:\Users\$Using:username" + "\Music") /COPYALL /ZB /R:2 /W:2 /E
                robocopy  ("C:\Users\$Using:username" + ".old" + "\Pictures") ("C:\Users\$Using:username" + "\Pictures") /COPYALL /ZB /R:2 /W:2 /E
                robocopy  ("C:\Users\$Using:username" + ".old" + "\Videos") ("C:\Users\$Using:username" + "\Videos") /COPYALL /ZB /R:2 /W:2 /E
                Write-Progress "Done!"
            }
        }

        if ($BrowserData) {
            Invoke-ImmyCommand {
                Write-Progress "Copying browser data"
                robocopy  ("C:\Users\$Using:username" + ".old" + "\AppData\Local\Google\Chrome\User Data") ("C:\Users\$Using:username" + "\AppData\Local\Google\Chrome\User Data") /COPYALL /ZB /R:2 /W:2 /E
                robocopy  ("C:\Users\$Using:username" + ".old" + "\AppData\Local\Microsoft\Edge\User Data") ("C:\Users\$Using:username" + "\AppData\Local\Microsoft\Edge\User Data") /COPYALL /ZB /R:2 /W:2 /E
                Write-Progress "Done!"
            }
        }

        if ($StickyNotes) {
            Invoke-ImmyCommand {
                Write-Progress "Copying Sticky Notes"
                robocopy  ("C:\Users\$Using:username" + ".old" + "\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe") ("C:\Users\$Using:username" + "\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe") /COPYALL /ZB /R:2 /W:2 /E
                Write-Progress "Done!"
            }
        }

        Invoke-ImmyCommand {
            Write-Progress "Removing old profile data"
            Remove-Item –path ("C:\Users\$Using:username" + ".old") –recurse -force
            New-Item –path ("C:\Users\$Using:username" + "\$Using:TestFile" + ".txt")
            Write-Progress "Created test file"
        }
    }
}


# This has been written by Dennis Singh
