<#
    .SYSNOPSIS
        Backup GPOs

    .DESCRIPTION
        Backing up GPOs separately from AD Backups. 

        Backups will be saved in a folder with the date they were backed up.
        root
         |
         |__2022NOV30
                {GUID}
                {GUID} 

         

    .PARAMETER BackupLocation
        Root location where the backups will be saved.

    .LINK
        AD System State Backup : https://social.technet.microsoft.com/wiki/contents/articles/51272.active-directory-automate-system-state-backup.aspx

    .NOTES
        Author : Jeff Benting
        Date : 2022 NOV 30

#>

[CmdletBinding()]
param (
    [String]$BackupLocation = 'C:\Temp'    
)

$BackupDate = (Get-Date -UFormat %Y%b%d).toUpper()

$BackupPath = Join-Path -Path $BackupLocation -ChildPath $BackupDate 

# Check if the backup date folder exists
if ( -Not ( Test-Path -Path $BackupPath ) ) { New-Item -Path $BackupPath -ItemType Directory }

# Backup the GPOs
Backup-GPO -All -Path $BackupPath


# Export GPOs

# Move to off-server location