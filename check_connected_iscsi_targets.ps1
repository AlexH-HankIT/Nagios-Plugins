# Powershell Script to check count of connected iSCSI Targets
#
# Author: MrCrankHank
#
# Usage in PS
# .\check_connected_iscsi_targets.ps1 -targets <int> -version <2008|2012>
#
# Usage via NSClient
# check_connected_iscsi_targets=cmd /c echo scripts\check_connected_iscsi_targets.ps1 -targets $ARG1$ -version $ARG2$ | PowerShell.exe -command -
#
# Targets
# This argument should contain the count of all connected iscsi targets. If the count is greater or smaller, the script will trigger a critical alert.
#
# Version
# Values are 2008 or 2012
#
# Windows Server 2012 has a better iscsi cmdlet. If you set version to 2012 the new cmdlet will be used. 
# Version 2008 will use the old one, which will probably also work on 2012 and above. But the implementation in this script is ugly. 
# So I recommended the new method if running 2012 or above.
#
# Since this script uses arguments, you need to enable them in your nsclient.ini
# Something like this should do the job:
#
#	[/settings/external scripts]
#	allow arguments = 1
#

param(
	[int]$targets,
	[int]$version
)

if ($version -eq 2012) {
	$var = Get-IscsiSession
	$lines = $var | Where-Object {$_ -notmatch "(\s?)+'"} | Measure-Object
	$lines = write-output $lines.count

	if ($lines -eq $targets) {
		if ($lines -eq 1) {
			echo "OK - $lines target is connected"
		} else {
			echo "OK - $lines of $targets targets are connected"
		}
		$nagios_status = 0
	} else {		
		if ($lines -eq 0) {
			echo "Critical - No target is connected"
		} elseif ($lines -eq 1) {
			echo "Critical - $lines of $targets is connected"
		} else {
			echo "Critical - $lines of $targets targets are connected"
		}	
		$nagios_status = 2
	}

	$host.SetShouldExit($nagios_status)
	
} elseif ($version -eq 2008) {
	$var = iscsicli SessionList
	$lines = $var | Where-Object {$_ -notmatch "(\s?)+'"} | Measure-Object
	$lines = write-output $lines.count
	
	$lines = $lines - 5
	$count = 30 * $targets + 1
	$connected = ($lines -1) / 30
	
	if ($lines -eq $count) {
		if ($connected -eq 1) {
			echo "OK - $connected target is connected"
		} else {
			echo "OK - $connected of $targets targets are connected"
		}	
		$nagios_status = 0
	} else {
		if ($connected -eq 0) {
			echo "Critical - No target is connected"
		} elseif ($connected -eq 1) {
			echo "Critical - $connected of $targets is connected"
		} else {
			echo "Critical - $connected of $targets targets are connected"
		}
		$nagios_status = 2
	}

	$host.SetShouldExit($nagios_status)
}

# Pause for debugging
# cmd /c pause | out-null
