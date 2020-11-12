# disables non-critical services that are not supposed to be enabled unless they're critical

# get critical services
$crit_services = @(Get-Content 'inputs/critservices.txt')

# remove commented lines
$temp = @()
$crit_services | ForEach-Object -Process {
    if ($_[0] -ne '#') {
        $temp += $_
    }
}
$crit_services = $temp

# ftp
if ($crit_services -notcontains "FTP") {
    try {
        Disable-WindowsOptionalFeature -Online -FeatureName IIS-FTPServer # disable the feature
        Stop-Service 'Server' -Force -Confirm # stop the service
        Write-Output "Disabled FTP Server"
    }
    catch {
        Write-Output "Failed to disable FTP Server"
    }
    
}

# rpd
if ($crit_services -notcontains "RDP") {
    try {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 1 # sets the actual toggle value to turn off rdp in the "allow rdp" menu
        Disable-WindowsOptionalFeature -Online -FeatureName Remote-Desktop-Services #turns off the feature if enabled
        Stop-Service 'Remote Desktop Services' -Force -Confirm # turn off the actual service
        Write-Output "Disabled RDP"
    } catch {
        Write-Output "Failed to disable RDP"
    }
}