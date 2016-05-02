Function Set-ADObjectPermissions {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [PSObject[]]$ADObject,

        [String]$Group,

        [String[]]$Permissions,

        [String]$Domain
    )

    Begin {

        $RootDSE = Get-ADRootDSE -Server $Domain
        #Create a hashtable to store the GUID value of each schema class and attribute
        $guidmap = @{}
        Get-ADObject -SearchBase ($rootdse.SchemaNamingContext) -LDAPFilter "(schemaidguid=*)" -Properties lDAPDisplayName,schemaIDGUID | ForEach {$guidmap[$_.lDAPDisplayName]=[System.GUID]$_.schemaIDGUID}

        #Create a hashtable to store the GUID value of each extended right in the forest
        $extendedrightsmap = @{}
        Get-ADObject -SearchBase ($rootdse.ConfigurationNamingContext) -LDAPFilter "(&(objectclass=controlAccessRight)(rightsguid=*))" -Properties displayName,rightsGuid | ForEach {$extendedrightsmap[$_.displayName]=[System.GUID]$_.rightsGuid}


    }

    Process {
        Foreach ( $O in $ADObject ) {
            Write-Verbose "Setting Permissions on $O.Name"
            
            # ----- Get a copy of the current DACL on the object
            $ACL = Get-Acl "ad:$($O.DistinguishedName)"

            # ----- Get the SID values of each group/user we wish to delegate access to
            if ( -Not [String]::IsNullOrEmpty( $Group ) ) {
                $AddObject = Get-ADGroup -Filter "Name -eq '$Group'"
            }
            
            $sid = new-object System.Security.Principal.SecurityIdentifier $ADDObject.SID

            # ----- Create an Access Control Entry for new permission we wish to add
            $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $SID,$Permissions,"Allow",$guidmap["user"],"All"))

            # ----- Re-apply the modified DACL to the OU
            Set-ACL -ACLObject $acl -Path ("AD:\"+($O.DistinguishedName))

        }
    }
}


Get-ADGroup -Filter "Name -eq 'jbtest'" | Set-ADObjectPermissions -Group jeffb03-deploymentmanagementadmins -Permissions "GenericRead,GenericWrite,Self" -Domain Stratuslivedemo.com -Verbose