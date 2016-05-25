Function Get-LocalGroup {

<#
    .Synopsis
        Returns a list of local computer groups

    .Description
        Returns either all or a select list of local computer Groups

    .Parameter ComputerName
        Name of the computer to get the groups from.

    .Parameter Group
        Name of the group to retrieve information.

    .Example
        Get-LocalGroup -ComputerName ServerA

    .Note
        Author : Jeff Buenting
        Date : 2016 MAY 24
#>

    [cmdletBinding()] 
    Param( 
        [Parameter(ValueFromPipeline=$True)] 
        [string[]]$computerName = $env:ComputerName,

        [String[]]$Group
    )

    Process {
        Foreach ( $C in $ComputerName ) {
            Write-Verbose "Getting Groups on $C"
            if ( -Not $Group ) {
                    Write-Verbose "Getting all"
                    [ADSI]$S = "WinNT://$C"
                    Write-Output ($S.children.where({$_.class -eq 'group'}))
                }
                else {
                    Write-Verbose "Getting group "
                    [ADSI]$S = "WinNT://$C"
                    Write-Output ($S.children.where({$_.class -eq 'group' -and $_.Name -in $Group}))
            }
        }
    }
}


Function Get-LocalGroupMember {

<#
    .Synopsis
        Returns Local Group Membership

    .Description
        Gets a list of users who are members of the Local Group

    .Parameter Group
        Group Object.  

    .Example
        Get-LocalGroup | Get-LocalGroupMember

    .Note
        Author : Jeff Buenting
        Date : 2016 May 24
        
#>

    [cmdletBinding()] 
    Param( 
        [Parameter(Mandatory = $True,ValueFromPipeline = $True)]
        [PSObject[]]$Group
    )

    Process {
        Foreach ( $G in $Group) {
            
            Write-Verbose "Getting Group members for $($G.Name) on $($G.Parent)"
           
           $Members = $G.psbase.invoke("Members")
          
           $members | ForEach-Object {
                try {
                        Write-Output ($_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null))
                    }
                    Catch {
                }
            }


        }
    }

}

Get-LocalGroup | Get-LocalGroupMember -Verbose