# ----- Using Get-SCVirtualMachine here instead of get-ADComputer.  Get-ADComputer has stale computer account from old computers. (need to clean up)
# ----- Might work or be better if I used Get-ADComputer and checked for an OS.  But this would still have issues with cluster names and such.
$Servers = get-scvirtualmachine | where { $_.status -eq 'Running' -and $_.OperatingSystem -notlike 'Unknown*' } | Sort-object name | Select-Object -ExpandProperty Name -First 10

$LocalGroupName = "Administrators"
$ADGroupName = "-Admins"
$Description = "Members of this group have full admin access to"

foreach ( $S in $Servers ) {
    Write-Output "Checking Server $S"

    if (-Not( Get-ADGroup -Filter "Name -eq '$S$ADGroupName'" ) ) {
        Write-Output "$S$ADGroupName does not exist, creating AD Group"
        $GroupName = "$S$ADGroupName"
        New-ADGroup -Name $GroupName -SamAccountName $GroupName -GroupCategory Security -GroupScope Global -DisplayName $GroupName -path "CN=Users,DC=Stratuslivecloud1,DC=com" -Description "$Description $S"
    }
    
    $LocalMembers = Get-LocalGroup -computerName $S -Group administrators | Get-LocalGroupMember | Foreach {
        Write-Output "Getting AD User SamAccountName -eq $_"
        $DomainUser = Get-ADUser -Filter "SamAccountName -eq '$_'" -searchbase "OU=StratusLive,OU=CloudCRM,DC=StratusLiveCloud1,DC=com" -ErrorAction SilentlyContinue
        $DomainUser
        
        # ----- Check if user is not null
        if ( $DomainUser ) {
            
            Add-ADGroupMember -Identity $S$ADGroupName -Member $Domainuser
            # Remove-LocalGroupMember -ComputerName $S -Group $LocalGroupName -User "$((($DomainUser.CanonicalName).split('\'))[0])\$($DomainUser.SamAccountName)"
        }
    }
    Add-DomainUserToLocalGroup -computerName $S -group $LocalGroupName -domain StratusCloud1 -user $S$ADGroupName -ErrorAction SilentlyContinue -verbose
    
}

