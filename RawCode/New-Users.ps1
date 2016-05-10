$users = import-csv C:\scripts\ad\newusers.txt

$Users | FL *

$users | foreach {
    $_.'Full Name'
    #get-aduser -Identity "uwwp.$($_.'Full Name'.substring(0,1))$(($_.'Full Name'  -Split ' ')[1])"
    #New-ADUser -Name ($_.'Full Name') -AccountPassword (ConvertTo-SecureString -AsPlainText $_.Password -Force) -CannotChangePassword $False -ChangePasswordAtLogon $False -DisplayName $_.'Full Name' -EmailAddress "$($_.UserName)$($_.OrgName)" -Enabled $True -GivenName ($_.'Full Name'  -Split ' ')[0] -OfficePhone $_.'Main Phone' -SamAccountName "uwwp.$($_.'Full Name'.substring(0,1))$(($_.'Full Name'  -Split ' ')[1])" -Surname($_.'Full Name'  -Split ' ')[1] -Path 'OU=UWWP,OU=CloudCRM,DC=StratusLiveCloud1,DC=com'
    #New-ADUser -Name ($_.'Full Name') -AccountPassword (ConvertTo-SecureString -AsPlainText $_.Password -Force) -CannotChangePassword $False -ChangePasswordAtLogon $False -DisplayName $_.'Full Name' -EmailAddress "$($_.UserName)$($_.OrgName)" -Enabled $True -GivenName ($_.'Full Name'  -Split ' ')[0] -OfficePhone $_.'Main Phone' -SamAccountName $_.UserName -Surname($_.'Full Name'  -Split ' ')[1] -Path $_.OU
    
    New-ADUser -Name ($_.'Full Name') -AccountPassword (ConvertTo-SecureString -AsPlainText $_.Password -Force) -CannotChangePassword $False -ChangePasswordAtLogon $False -DisplayName $_.'Full Name' -EmailAddress $_.Email -Enabled $True -GivenName ($_.'Full Name'  -Split ' ')[0] -OfficePhone $_.'Main Phone' -SamAccountName $_.UserName -Surname($_.'Full Name'  -Split ' ')[1] -Path $_.OU -UserPrincipalName "$($_.UserName )$(($_.Email).substring( $_.Email.Indexof('@')))"
   
    #"$($_.UserName )$(($_.Email).substring( $_.Email.Indexof('@')))"
}

$Users #| Select-object 'Full Name',@{N='UserName'; e={"stratuscloud1\$($_.username)"}},Password | out-file c:\scripts\ad\newuserspassword.txt
