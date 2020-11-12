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
    # TODO finish this
    Disable-WindowsOptionalFeature -Online IIS-FTPServer
    Write-Output "Disabled FTP Server"
}

# rpd
if ($crit_services -notcontains "RDP") {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 1 # sets the actual toggle value to turn off rdp in the "allow rdp" menu
    Disable-WindowsOptionalFeature -Online -FeatureName Remote-Desktop-Services #turns off the actual service
    Write-Output "Disabled RDP"
}