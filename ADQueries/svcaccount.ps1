# $S = get-aduser -searchbase 'OU=ServiceAccounts,DC=nrccua-hq,DC=local' -filter *  -Properties Description,lastlogondate,lastlogontimestamp,PasswordLastSet | where lastlogondate -lt (Get-Date 01/01/2022) | Sort-object lastlogontimestamp  | Select-Object SamAccountName,Name,lastlogondate, @{N='LastLogon';E={[DateTime]::FromFileTimeUtc($_.LastLogonTimeStamp)}},PasswordLastSet,Description, enabled

$S = get-aduser -searchbase 'OU=ServiceAccounts,DC=nrccua-hq,DC=local' -filter "Enabled -eq 'true'"  -Properties Description,lastlogondate,lastlogontimestamp,PasswordLastSet  | Sort-object lastlogontimestamp  | Select-Object SamAccountName,Name,lastlogondate, @{N='LastLogon';E={[DateTime]::FromFileTimeUtc($_.LastLogonTimeStamp)}},PasswordLastSet,Description, enabled

$S | FT samaccountname,Name, lastlogondate, Description, Enabled -AutoSize




$GroupMembers = @()
$Groups = Get-LocalGroup 
Foreach ($G in $Groups) {
    $GroupMembers += [PSCustomObject]@{
        Group = $G.Name
        Users = $G | Get-LocalGroupMember  | Select-object -ExpandProperty Name
    }
    
}


$LocalUsers = @()
get-localuser | Foreach {
    $LocalUsers += [PSCustomObject]@{
        Computer = $Env:COMPUTERNAME
        Name = $_.Name
        Enabled = $_.Enabled
        Description = $_.Description
        LastLogon = $_.LastLogon
        GroupMembership = ($GroupMembers | where-object Users -Contains $_.Name).Group
    }
}

$localUsers


