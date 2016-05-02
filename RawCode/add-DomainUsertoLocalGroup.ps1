

Function Add-DomainUserToLocalGroup {

<#
    .Link
        http://blogs.technet.com/b/heyscriptingguy/archive/2010/08/19/use-powershell-to-add-domain-users-to-a-local-group.aspx
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

 get-content C:\temp\server.txt | Add-DomainUserToLocalGroup -group Administrators -domain StratusCloud1 -user SCCMNAA -Verbose
    
