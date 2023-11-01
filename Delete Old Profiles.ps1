param(
[Parameter(Position=0,Mandatory=$True,HelpMessage=@'
Specify when the last logon time should be, in months
'@)]
[ValidateScript({$_ -gt 2})]
[Int32]$Months
)

$profilepath = Invoke-ImmyCommand {Get-ChildItem -Path C:\Users -Exclude administrator,cadmin,default}
$users = $profilepath.name


switch($method){
    "test"
    {
        $test = 0
        foreach ($user in $users) {
            $deleterequired = Invoke-ImmyDomainController {if (Get-ADUser $Using:user -Properties lastLogonDate | Where-Object {$_.LastLogonDate -lt (Get-Date).AddMonths(-$Using:Months)}) {return $true}}
            if ($deleterequired) {
                $test++
            }
        }
        if ($test -eq 0) {
            return $true
        }else {
            Write-Warning "$test profiles will be deleted"
            return $false
        }
    }

    "get"
    {
        return
    }
    "set"
    {
        foreach ($user in $users) {

            $remove = Invoke-ImmyDomainController {if (Get-ADUser $Using:user -Properties lastLogonDate | Where-Object {$_.LastLogonDate -lt (Get-Date).AddMonths(-$Using:Months)}) {return $true}}

            if ($remove) {
                Write-Warning "$user profile is older than $Months months"
                Write-Progress "Removing $user user profile..."
                Invoke-ImmyCommand {Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $Using:user } | Remove-CimInstance}
            }
        }
    }
}

#testing
