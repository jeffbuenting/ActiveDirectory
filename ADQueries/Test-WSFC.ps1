# https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc731002(v=ws.10)?WT.mc_id=academic-0000-abartolo

$ClusterNameObject = "AWS-SQL-P"
$ClusterNodes = "AWS-SQL-P1","AWS-SQL-P3"

# $OUName = "GPOs Applied"

# $OU = Get-ADOrganizationalUnit -Filter "Name -eq '$OUName'"



# $ACL = (Get-Acl -Path "AD:$($OU.DistinguishedName)").Access 

# $ACL | FT IdentityReference




# Get all OU's in the domain
$OUs = Get-ADOrganizationalUnit -Filter *
$Result = @()
ForEach($OU In $OUs){
    write-verbose "processing $($OU.DistinguishedName)"
    # Get ACL of OU
    $ACLs = (Get-Acl -Path "AD:$($OU.DistinguishedName)").Access 
    ForEach($ACL in $ACLs){

        # Only examine non-inherited ACL's
        If ($ACL.IsInherited -eq $False){
            # Objectify the result for easier handling

            # if ( $ACL.IdentityReference -like "s-1*" ) {

            #     # Give SID as input to .NET Framework Class
            #     $SID = New-Object System.Security.Principal.SecurityIdentifier("$($ACL.IdentityReference.Value)")

            #     # Use Translate to find user from sid
            #     $objUser = $SID.Translate([System.Security.Principal.NTAccount])

            #     # Print the converted SID to username value
            #     $IDRef = $objUser.Value
            # }
            # else {
            #     $IDRef = $ACL.IdentityReference
            # }
            $IDRef = $ACL.IdentityReference
            $Properties = @{
                ID = $IDRef
                Rights = $ACL.ActiveDirectoryRights
                Type = $ACL.AccessControlType
                Path = $OU.DistinguishedName
            }
            $Result += New-Object psobject -Property $Properties
        }
    }
}

$Result


