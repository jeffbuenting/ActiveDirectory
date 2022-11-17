# https://stackoverflow.com/questions/7330187/how-to-find-the-windows-version-from-the-powershell-command-line

$Servers = Get-ADComputer -Filter { Enabled -eq "True" -and OperatingSystem -like "Windows Server*" -and LastLogonTimeStamp -ge $Date} -Properties Name, OperatingSystem, SamAccountName, DistinguishedName, LastLogonDate, LastLogonTimeStamp 

$Servers | Sort-Object LastLogonTimeStamp | Format-Table DNSHostName, OperatingSystem,  @{N='LastLogon';E={[DateTime]::FromFileTimeUtc($_.LastLogonTimeStamp)}}

$LocalAccounts = 'NT AUTHORITY\LocalService','LocalSystem','NT AUTHORITY\NetworkService','NT AUTHORITY\System'

$OSVersion = @()

Foreach ( $S in $Servers ) {
    Write-Output "$($S.DNSHostName)"

    if ( Test-Connection -ComputerName $S.DNSHostName -Quiet ) {
        Write-Output "Online..."
        $OS = invoke-command -ComputerName $S.DNSHostName -ScriptBlock { [System.Environment]::OSVersion.Version }
        $OS | Add-Member -MemberType NoteProperty -Name Name -Value $S.DNSHostName

        $OSVersion += $OS
    }
}

$OSVersion | FT *