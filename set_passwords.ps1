# sets secure passwords for every user listed in the users and admins files combined, minus the current user
# verified working as intended on Server 2016 11/12/2020

# generates a secure string object using the password string
$password = ConvertTo-SecureString "Password123!@#" -AsPlainText -Force

# get content of users.txt and store it as an array, where each array item is a line of the file
$users_file_data = Get-Content 'inputs/users.txt'

# get content of admins.txt and store it asn an array, where each array item is a line of the file
$admins_file_data = Get-Content 'inputs/admins.txt'

# combine the two arrays to get one arraylist with both the admin and user account names
# (it has to be an arraylist because the current user's name has to be removed, and only arraylist support removals)
[System.Collections.ArrayList]$auth_users = $users_file_data + $admins_file_data

# remove the current user name from the array
$current_user_name = $env:USERNAME # the username of the current user
$auth_users.Remove($current_user_name)

# loop through each user in the array
$auth_users | ForEach-Object -Process {

    # check to make sure the user exists for logging purposes
    try {
        Get-LocalUser -Name $_

        # this means that the user exists, so set their password
        Set-LocalUser -Name $_ -Password $password -Confirm

        # write that the password was set
        Write-Output "Set password for LocalUser $_."
    }
    catch {
        # if it failed, it means the user didn't exist, write to the console
        Write-Output "LocalUser $_ does not exist. Their password was not changed."
    }
}