$BeforeDate = (Get-date ).AddDays(-180)

$users = get-aduser -SearchBase "OU=Active User Accounts,DC=nrccua-hq,DC=local" -filter {enabled -eq $True}  -Properties Description,lastlogondate,lastlogontimestamp,PasswordLastSet | Where-Object lastlogondate -lt $BeforeDate 

$users | Sort-object lastlogontimestamp  | FT Name,Enabled,lastlogondate, @{N='LastLogon';E={[DateTime]::FromFileTimeUtc($_.LastLogonTimeStamp)}},PasswordLastSet,Description