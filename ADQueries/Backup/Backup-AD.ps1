$TargetPath = "\\nas1\main\Departments\Information Technology\ADSystemStateBackups"

# if ( -Not (Test-Path -Path $TargetPath ) ) { New-Item -Path $TargetPath -ItemType Directory }

$policy = New-WBPolicy
Add-WBSystemState -Policy $Policy

$Target = New-WBBackupTarget -NetworkPath $TargetPath -Credential $Cred

Add-WBBackupTarget -Policy $policy -Target $target

Start-WBBackup -Policy $policy