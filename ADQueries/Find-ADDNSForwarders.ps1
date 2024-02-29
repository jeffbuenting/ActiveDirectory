Get-ADDomainController -Filter * | foreach {
    $_.Hostname
    Get-DnsServerForwarder -ComputerName $_.Hostname
}