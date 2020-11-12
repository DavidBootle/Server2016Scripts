# removes unauthorized users, demotes unauthorized admins, and adds users that should exist but don't
# verified working as intended on Server 2016 - 11/12/2020

# get authorized user and admins from the text files
$users_file_data = Get-Content 'inputs/users.txt'
$admins_file_data = Get-Content 'inputs/admins.txt'

# combine both the users and admins to get every authorized user on the computer
[System.Collections.ArrayList]$auth_users = $users_file_data + $admins_file_data

# add the windows user accounts that would cause a major issue if the script tried to delete them
$auth_users += "Administrator", "Guest", "HelpAssistant", "DefaultAccount", "WDAGUtilityAccount"

# REMOVE UNAUTHORIZED USERS
# loop through every user account actually on the computer
Get-LocalUser | ForEach-Object -Process {
    # Name : $_.Name
    # Enabled : $_.Enabled
    # Description: $_.Description

    if ($auth_users -notcontains $_) {
        # if the name of the user is not in the authorized user list, delete the user
        try {
            Remove-LocalUser $_ -Confirm
            Write-Output "Removed unauthorized user $_"
        } catch {
            Write-Output "Failed to remove unauthorized user $_"
        }
        
    }
}

# REMOVE UNAUTHORIZED ADMINS
# make a list of all authorized admins, and add default accounts
[System.Collections.ArrayList]$auth_admins = $admins_file_data
$auth_admins += "Administrator"

# group user account names are formatted as COMPUTERNAME\username, so add COMPUTERNAME\ to each user in the auth admins list so that they can be compared
$auth_admins = $auth_admins | ForEach-Object -Process { "$env:COMPUTERNAME\$_" }

# loop through every administrator
Get-LocalGroupMember -Group "Administrators" | ForEach-Object -Process {
    # if the name of the administrator is not in the authorized user list, remove the user from administrators
    if ($auth_admins -notcontains $_.Name) {
        try {
            Remove-LocalGroupMember -Group "Administrators" -Member $_.Name -Confirm
            Write-Output "Removed $($_.Name) from Administrators"
        } catch {
            Write-Output "Failed to remove $($_.Name) from Administrators"
        }
    }
}

# ADD USERS
# get a new auth_users without the default accounts
$auth_users = $users_file_data

# get current users
$current_users = Get-LocalUser

# get a secure string
$password = ConvertTo-SecureString "Password123!@#" -AsPlainText -Force

# loop through auth users
$auth_users | ForEach-Object -Process {
    # if the user doesn't already exist, add the user
    if ($current_users.Name -notcontains $_) {
        try {
            New-LocalUser $_ -Password $password -Confirm | Out-Null # pipe to null so that extra text is not shown on the logs
            Write-Output "Added user $_"
        } catch {
            Write-Output "Failed to add user $_"
        }
    }
}