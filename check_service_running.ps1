# Powershell script to check if a specific service is running
#
# Author: MrCrankHank
#
# The script uses the PsService.exe. You can download it from here:
# http://technet.microsoft.com/de-de/sysinternals/bb897542.aspx
#
# Place the PsService.exe in C:\Windows\System32 or somewhere else in your path var.
#
#
# Usage in PS
# .\check_service_running.ps1 -service <name>
#
# Usage via NSClient
# check_service_running=cmd /c echo scripts\check_service_running.ps1 -service $ARG1$ | PowerShell.exe -command -
#
# $service should contain the name of the service you want to check.
#
#
# Since this script uses arguments, you need to enable them in your nsclient.ini
# Something like this should do the job:
#
# [/settings/external scripts]
# allow arguments = 1
#


param(
	[string]$service
)

$var = PsService.exe /accepteula query $service 2>1

$var = $var | Select-String -Pattern STATE
$var = $var -replace '\s',''
$var = $var -replace 'STATE:',''
$var = $var -replace '[0-9]',''

if ("$var" -like "STOPPED") {
	echo "Critical - Service $service is not running"
	$nagios_status = 2
} elseif ("$var" -like "RUNNING") {
	echo "OK - Service $service is running"
	$nagios_status = 0
} else {
	echo "Unknown - Can't get status of service $service"
	$nagios_status = 3
}

$host.SetShouldExit($nagios_status)

# Pause for debugging
# cmd /c pause | out-null
