<#
    .DESCRIPTION
        So the thought here is that you can check your domain joined computers for any service accounts they are using
#>

# Get a list of windows server computers
$Days = 90
$Date = (Get-Date).AddDays(-$Days)

$Servers = Get-ADComputer -Filter { Enabled -eq "True" -and OperatingSystem -like "Windows Server*" -and LastLogonTimeStamp -ge $Date} -Properties Name, OperatingSystem, SamAccountName, DistinguishedName, LastLogonDate, LastLogonTimeStamp 

$Servers | Sort-Object LastLogonTimeStamp | Format-Table DNSHostName, OperatingSystem,  @{N='LastLogon';E={[DateTime]::FromFileTimeUtc($_.LastLogonTimeStamp)}}

$LocalAccounts = 'NT AUTHORITY\LocalService','LocalSystem','NT AUTHORITY\NetworkService','NT AUTHORITY\System'

$ServerOffline = @()
$ServiceAccounts = @()

Foreach ( $S in $Servers ) {
    Write-Output "$($S.DNSHostName)"

    if ( Test-Connection -ComputerName $S.DNSHostName -Quiet ) {
        Write-Output "Online..."
        $SVCAcct = Get-CimInstance -ComputerName  $S.DNSHostName -ClassName WIN32_Service | Where-Object StartName -NotIn $LocalAccounts | Select PSComputerName, Name, StartName
        $ServiceAccounts += $SVCAcct
    }
    Else {
        $ServerOffline += $S
    }
}

Write-Output "These servers are offline:"
$ServerOffline

"-----------"
"SVC Accounts"
$ServiceAccounts


#| sort-object LastLogonTimeStamp | Format-Table DNSHostName, Enabled,OperatingSystem, @{Name='LastLogonTimeStamp'; E = {Get-Date $_.LastLogonTimeStamp}},@{N='OU';E={($_.DistinguishedName).split(',')[1].split('=')[1]}}
