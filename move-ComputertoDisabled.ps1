$old = (Get-Date).AddDays(-60)
# Get-QADComputer -IncludedProperties pwdLastSet -SizeLimit 0 | where { $_.pwdLastSet -le $old } | Move-QADObject -to vbgov.com/managed/computers/disabled
Get-QADComputer -searchroot vbgov.com/managed/computers 
#omp = Get-QADComputer -searchroot vbgov.com/managed/computers -IncludedProperties pwdLastSet -SizeLimit 1
#$comp.osname