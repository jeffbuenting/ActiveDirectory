#--------------------------------------------------------------------------------------
# Local Groups
#--------------------------------------------------------------------------------------

Function Add-DomainUserToLocalGroup {

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
        [string]$user,
        
        [PSCredential]$Credential 
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

#--------------------------------------------------------------------------------------

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

#--------------------------------------------------------------------------------------

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

#--------------------------------------------------------------------------------------

Function Remove-LocalGroupMember {

<#
    .Synopsis
        Remove an account from a Local Group

    .Description
        Removes a member from a Local Group on a Computer

    .Parameter ComputerName
        Computer that has the Local Group

    .Parameter Group
        Name of the group to remove a user from

    .Parameter User
        User Account to remove

    .Example
        Remove-LocalGroupMember -ComputerName jeffb-sql03 -Group Administrators -User Contoso\jeffbtest

    .Link
        https://mcpmag.com/articles/2015/05/28/managing-local-groups-in-powershell.aspx

    .Note
        Author : Jeff Buenting
        Date : 2016 OCT 18
#>

    [CmdletBinding()]
    Param (
        [Parameter ( ValueFromPipeLine = $True ) ]
        [String[]]$ComputerName = $env:COMPUTERNAME,

        [Parameter ( Mandatory = $True )]
        [String]$Group,
        
        [Parameter ( Mandatory = $True )]
        [ValidateScript( { $_ -match '[A-Z,a-z,\.,\-,_]*\\?[A-Z,a-z,\.,\-,_]*' } ) ]
        [String]$User

    )

    Begin {
        # ----- Splitting Domain and User 
        if ( $User -match '\\' ) {
                $Domain = ($User.split( '\' ))[0]
                $User = ($User.split( '\' ))[1]
            }
            Else {
                $Domain = $ComputerName
        }
    }

    Process {
        Foreach ( $C in $ComputerName ) {
            If ( Test-Connection $C -Quiet ) {
                    Write-Verbose "Removing $Domain\$User From local Group $Group on $C"
                   
                    ([ADSI]"WinNT://$C/$Group,group").Remove("WinNT://$domain/$user")  
                }
                Else {
                    Throw "$C is offline or does not exist"
            }
        }
    }
}

#--------------------------------------------------------------------------------------
# Password Cmdlets
#--------------------------------------------------------------------------------------

function New-RandomString {

<#
    .Synopsis
        Get a random string

    .Description
        You can specify what type of characters MUST be in the sting.  This is useful for password complexity.

    .Parameter Length
        Length of string to retrieve.

    .parameter UpperCase
        Specifies random string should contain at least one Uppercase letter.

    .Parameter LowerCase
        Specifies random string should contain at least one Lowercase letter.

    .Parameter Number
        Specifies random string should contain at least one Number

    .Parameter SpeacialCharacter
        Specifies random string should contain at least one special character !#%&

    .Example
        New-RandomString -UpperCase -LowerCase -Numbers

        retrieves a random string containin upper and lowercase and numbers

    .Link
        Thanks to Simon Wahlin.  I modified his function.  I changed the input chars to switches instead of an array.  Removed characters that could be confused (Oo0).  And added a unique switch

        https://gallery.technet.microsoft.com/Generate-a-random-and-5c879ed5

    .Note
        Modified by Jeff Buenting
        Date : 2016 JUN 09

#>

    [CmdletBinding()]
    Param (
        [Int]$Length = 8,

        [Switch]$UpperCase,

        [Switch]$LowerCase,

        [Switch]$Numbers,

        [Switch]$SpecialCharacters,

        [Switch]$Unique
    )


    # -----  Create char arrays containing groups of possible chars
    if ( $UpperCase ) { [char[][]]$CharGroups = "ABCDEFGHIJKLMNPQRSTUVWXYZ" }
    if ( $LowerCase ) { [char[][]]$CharGroups += "abcdefghijkmnpqrstuvwxyz" }
    if ( $Numbers ) { [char[][]]$CharGroups += "23456789" }
    if ($SpecialCharacters ) { [char[][]]$CharGroups += "!#%&" }
    

    # Create char array containing all chars
    $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}


    $RandomString = @{}

    # Randomize one char from each group
    Foreach($Group in $CharGroups) {
        if($RandomString.Count -lt $Length) {
            $Index = Get-Random
            While ($RandomString.ContainsKey($Index)){
                $Index = Get-Random                       
            }
            $RandomString.Add($Index,$Group[((Get-Random) % $Group.Count)])
        }
    }

    # Fill out with chars from $AllChars
    for($i=$RandomString.Count;$i -lt $Length;$i++) {
                
        $Index = Get-Random
        While ($RandomString.ContainsKey($Index)){
            $Index = Get-Random                        
        }

        $Char = $AllChars[((Get-Random) % $AllChars.Count)]

        # ----- if required, check that the char is unique to the string
        if ( $Unique ) {
            While ( $Char -in $RandomString ) {
                $Char = $AllChars[((Get-Random) % $AllChars.Count)]
            }
        }

        $RandomString.Add($Index,$char)
    }

    Write-Output $(-join ($RandomString.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
}

#--------------------------------------------------------------------------------------

New-Alias -Name New-ADPassword -Value New-RandomString
#New-Alias -Name New-RandomString -Value New-ADPassword

#--------------------------------------------------------------------------------------

function get-ADParentObject {

<#
    .Synopsis 
        Returns the parent object of an AD object.  

    .Description
        Returns the parent object of an AD Object.  Usually a Container or an OU.

    .Parameter ADObject
        An AD Object

    .Example
        Get the OU where a user account is located

        Get-ADUSer -Filter 'Name -eq "Joe Smith"' | Get-ADParentObject

    .Link
        http://blog.uvm.edu/gcd/2012/07/12/listing-parent-of-ad-object-in-powershell-2/

    .Note
        Author : Jeff Buenting
        Date : 2016 DEC 09
#>

    [CmdletBinding()]
    Param (
        [Parameter (Mandatory = $True,ValueFromPipeline = $True)]
        [psobject[]]$ADObject
    )

    Process {
        Foreach ( $A in $ADObject ) {
            Write-Verbose "Getting parent object for $($ADObject.Name)"

            # ----- This is the magic.  splits the Distiguished name and removes the First element (the AD Object).  WHat is left is then joined back together and you are left with the DN for the Parent object.  
            $parts = $A.DistinguishedName -split '(?<![\\]),'
            $DN = $parts[1..$($parts.Count-1)] -join ','

            # ----- Convert the DN to an actual object
            Write-Output (Get-ADObject -Identity $DN)
        }
    }
}

#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------

Export-ModuleMember -Function * -Alias *