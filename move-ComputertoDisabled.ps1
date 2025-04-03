# $old = (Get-Date).AddDays(-60)
# # Get-QADComputer -IncludedProperties pwdLastSet -SizeLimit 0 | where { $_.pwdLastSet -le $old } | Move-QADObject -to vbgov.com/managed/computers/disabled
# Get-QADComputer -searchroot vbgov.com/managed/computers 
#omp = Get-QADComputer -searchroot vbgov.com/managed/computers -IncludedProperties pwdLastSet -SizeLimit 1
#$comp.osname


# move and change protect
Get-ADComputer -filter {Enabled -eq $false} -SearchBase "OU=Dev-SQL-Test-GPO,OU=DEV-SQL,OU=DEV,OU=AWS,OU=Servers,OU=Domain Computers,DC=nrccua-hq,dc=local" | Set-ADobject -ProtectedFromAccidentalDeletion $False