get-aduser -SearchBase 'OU=uwwp,OU=CloudCRM,DC=Stratuslivecloud1,DC=com' -Filter {Name -Notlike "*email*" -and Name -Notlike "*clickd*"}  -Properties * | where CannotChangePassword -eq $True  | set-aduser -CannotChangePassword $False 



