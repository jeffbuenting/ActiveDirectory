#------------------------------------------------------------------------------
# Backup-ADGPO.ps1
#
# Automates the backup of GPOs
# will keep that last two weeks of GPO Backups.  Automatically Deletes Backups older than $Days.
#
# Notes: 
#	  - Troubleshooting script by adding true to the list of arguments.  This will include additional output to the screen as well as write events to the event log.
#     - Script is configured to run on non Windows 2008 or above system.  To get it to run on the newer OSes, removed the lines 
#			New-PSSession
#			Invoke-command
#			Param
#			}
#		and change the source in the eventlog entries to GroupPolicy
#	  - If script thows an error, the error will be written to an event log as a warning.  Event ID 9999
#------------------------------------------------------------------------------

param ( [String]$Debug = 'false' )

if ( $Debug.tolower() -eq 'true' ) {
	Write-eventlog -logname 'System' -Source 'Srv' -eventID 9990 -Entrytype Information -message "Backup-ADGPO.ps1 Starting`n`n" 
}

try {
#		$ComputerName = 'VBDC0001' 		# ----- Runs the GPO-Backup command from this server ( only needed if the server scheduling is not windows 2008 R2 or above )


		$Days = 30			# ----- Number of days to keep

		# ----- Get today's date
		$Date = "{0:yyyy-MMM-dd}" -f (Get-Date)

		# ----- Create the directory where the GPOs will be saved ( uses Date to differentiate )
		$BackupToLocation = "\\vbgov.com\deploy\Disaster_Recovery\Group_Policy\Data\GPO Backup\$Date"
		New-Item -Path $BackupToLocation -itemtype directory -Force

#		$Session = New-Pssession -ComputerName $ComputerName 
#		Invoke-Command -Session $Session -ArgumentList $BackupToLocation -ErrorAction SilentlyContinue -ScriptBlock  {
#			
#			param ( $BackupToLocation )
			
			import-module grouppolicy
			Backup-GPO -All -Path $BackupToLocation -Domain vbgov.com
#		}

		# ----- Clean up older GPO Backups
		$Date = (Get-Date).adddays(-$Days)
		
		if ( $Debug.tolower() -eq 'true' ) {  Write-Host "Deleting files older than this date: $Date" -ForegroundColor Yellow }
		
		$GPOBackupsPath = "\\vbgov.com\deploy\Disaster_Recovery\Group_Policy\Data\GPO Backup"
		 
		Get-ChildItem $GPOBackupsPath | where { $_.Lastwritetime -lt $Date } | foreach {
		    $Filename = $GPOBackupsPath+'\'+$_.name
			if ( $Debug.tolower() -eq 'true' ) { write-host $Filename -ForegroundColor Blue }
		    remove-item -path $Filename -Recurse -Force
		}
	}
	Catch {
		Write-eventlog -logname 'System' -source 'Srv' -eventID 9999 -Entrytype Warning -message "Backup-ADGPO.ps1`n`n  Error running script`n`n$_.Exception" 
}

if ( $Debug.tolower() -eq 'true' ) {
	Write-eventlog -logname 'System' -source 'Srv' -eventID 9999 -Entrytype Information -message "Backup-ADGPO.ps1 Ending`n`n" 
}