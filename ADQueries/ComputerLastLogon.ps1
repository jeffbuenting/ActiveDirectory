<#
    .SYNOPSIS
        retrieves computers from AD that have not logged into the domain is the past XX days.

    .NOTES
        Per the link, LastLogonTimestamp for each object is replicated to all domain controllers.  However, it is up to 14 days behind the actuall logon time.  

    .LINK
        LastLogonTimestamp meaning https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/8220-the-lastlogontimestamp-attribute-8221-8211-8220-what-it-was/ba-p/396204
#>

$Days = 90

$Date = (Get-Date).AddDays(-$Days)

$C = Get-ADComputer -Filter {LastLogonTimeStamp -lt $Date -and Enabled -eq "True"} -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName, LastLogonDate, LastLogonTimeStamp #| sort-object LastLogonTimeStamp | Format-Table DNSHostName, Enabled,OperatingSystem, @{Name='LastLogonTimeStamp'; E = {Get-Date $_.LastLogonTimeStamp}},@{N='OU';E={($_.DistinguishedName).split(',')[1].split('=')[1]}}

$C = $C | Where OperatingSystem -Like 'Windows Server *'

$C | Sort-object LastLogonTimeStamp | FT DNSHostName, Enabled, OperatingSystem, @{N='OU';E={($_.DistinguishedName).split(',')[1].split('=')[1]}}, @{N='LastLogon';E={[DateTime]::FromFileTimeUtc($_.LastLogonTimeStamp)}}

foreach ( $S in $C ) {
    ping $S
}