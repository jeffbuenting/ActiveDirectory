﻿Function Add-DomainUserToLocalGroup {

<#
    .Synopsis
        Add a Domain user / group to a local group

    .Description
        Add either a Domain user or A Domain Group to a local group membership

    .Parameter Computername
        Computer Name where the LocalGroup Lives

    .Parameter Group
        Name of the local group.

    .Parameter Domain
        Domain where the user/group is located

    .Parameter User
        User or group name to be added to Local Group.

    .Example
        Add contoso/ServerA_Admins group to the local Administrators group on ServerA

        Add-DomainUsertoLocalGroup -ComputerName ServerA -Domain Contoso.com -user ServerA_Admins -Group Administrators
            
    .Link
        http://blogs.technet.com/b/heyscriptingguy/archive/2010/08/19/use-powershell-to-add-domain-users-to-a-local-group.aspx

    .Note
        Credit to the Scripting Guys.  I wrapped their function in a module and added the help info.  A discussion of the function can be found at the provided link.
#>

 
    [cmdletBinding()] 
    Param( 
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)] 
        [string[]]$computerName, 

        [Parameter(Mandatory=$True)] 
        [string]$group,
         
        [Parameter(Mandatory=$True)] 
        [string]$domain, 

        [Parameter(Mandatory=$True)] 
        [string]$user 
    )
    
    Process { 
        Foreach ( $C in $computerName ) {
            If ( Test-Connection $C -Quiet ) {
                    Write-Verbose "Adding $Domain\$User to local Group $Group on $C"
                   # $group = [ADSI]"WINNT://$C/$Group,Group"

                    #$Group | FL *
                    #$Group.Add("WinNT://$domain/$username") 
                    ([ADSI]"WinNT://$C/$Group,group").Add("WinNT://$domain/$user")  
  

                }
                Else {
                    Write-Error "$C is offline or does not exist"
            }
        }
    } 

} #end function Add-DomainUserToLocalGroup 