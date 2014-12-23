# Powershell script to check if yesterdays or todays windows backup succeeded
# Author MrCrankhank

#Write backup history in temp dir
wbadmin get versions > $env:temp/backups.txt

#Get yesterdays date
$yesterday = (Get-Date).AddDays(-1).Date

#Get todays date
$today = (Get-Date)

#Count lines in backup history
$logcount = (gc $env:temp/backups.txt | measure-object )
$lines = $logcount.Count

#Delete last empty line
$lines = $lines - 1

#Format date
$yesterday = $yesterday.ToString("dd/MM/yyyy")
$today = $today.ToString("dd/MM/yyyy")

#Get line with backup time
$line5 =  Get-Content  $env:temp/backups.txt | Select-Object  -Index  ($lines -5)
$line4 =  Get-Content  $env:temp/backups.txt | Select-Object  -Index  ($lines -4)

#echo $line5
#echo $line4

#Check if yesterdays or todays backup is there
$date_exist_yesterday_5 = $line5.Contains($yesterday)
$date_exist_yesterday_4 = $line4.Contains($yesterday)
$date_exist_today_4 = $line4.Contains($today)
$date_exist_today_5 = $line5.Contains($today)

#echo $date_exist_yesterday_5
#echo $date_exist_yesterday_4
#echo $date_exist_today_4
#echo $date_exist_today_5

if ($date_exist_yesterday_5 -ne 'True') {
	if ($date_exist_yesterday_4 -ne 'True') {
		if ($date_exist_today_5 -ne 'True') {
			if ($date_exist_today_4 -ne 'True') {
				echo "Critical - It seems like windows backup failed" 
				$nagios_status = 2
				}
			else {
				echo "OK - $line4"
				$nagios_status = 0
				}
			}
		else {
			echo "OK - $line5"
			$nagios_status = 0
			}
		}
	else {
		echo "OK - $line4"
		$nagios_status = 0
		}
	}
else  {
	echo "OK - $line5"
	$nagios_status = 0
	}

rm $env:temp/backups.txt
$host.SetShouldExit($nagios_status)
#cmd /c pause | out-null
