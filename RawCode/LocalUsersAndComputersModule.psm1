#------------------------------------------------------------------------------
# Module LocalUsersandComputersModule.psm1
#
#
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function Get-LocalGroupMember
#
# Gets members of the local group.
#------------------------------------------------------------------------------

<#
	.SYNOPSIS
		Gets members of the local group.
		
	.DESCRIPTION
		Gets members of the local group.
		
	.PARAMETER LocalGroup
		Specifies the name of the local group to get the membership list.
		
	.PARAMETER Server
		Specifies the computer to get the list membersip from.  By default it is the local computer.
	
	.INPUTS
		None
	
	.OUTPUTS
		List of Members
		
	.EXAMPLE
		Get-LocalGroupMember -LocalGroup Administrators
		
		returns the membership list for the Administrators group on the local computer
		
	.EXAMPLE
		Get-LocalGroupMember -LocalGroup Administrators -Server VBAS9999
		
		Returns the membership list for the Administrators group on the server VBAS9999.
		
	.LINK
		http://powershellcommunity.org/Forums/tabid/54/aft/1528/Default.aspx
#>

Function Get-LocalGroupMember {

	param ( [String]$LocalGroup,
			[String]$Server = '.')
	
	$MemberNames = @()
	
	$Group= [ADSI]"WinNT://$Server/$LocalGroup,group"
	$Members = @($Group.psbase.Invoke("Members"))
	$Members | ForEach-Object {
		$MemberNames += $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
	} 
#	$ChildGroups | ForEach-Object {
#		$output = "" | Select-Object Server, Group, InLocalAdmin
#		$output.Server = $Server
#		$output.Group = $_
#		$output.InLocalAdmin = $MemberNames -contains $_
#		Write-Output $output
#	}

	return $MemberNames
}

#-------------------------------------------------------------------------------
# Function Add-LocalGroupMember
#
# Adds one or more members to a Local Group
#-------------------------------------------------------------------------------

<#
	.SYNOPSIS
		Adds one or more members to a Local Group
		
	.DESCRIPTION
		Adds one or more members to a Local Group
		
	.PARAMETER ADGroup
		Specifies the Activie Directory group you are adding to the local group.
	
	.PARAMETER LocalGroup
		Specifies the name of the local group to add the new member to.
		
	.PARAMETER Server
		Specifies the computer the local group in on.  By default it is the local computer.
	
	.INPUTS
		None
	
	.OUTPUTS
		None
		
	.EXAMPLE
		Add-LocalGroupMember -ADGroup 'Server Local Admin-U' -LocalGroup 'Administrators' 
		
		Adds the Server Local Admin-U group to the Local Administrators group.
#>

Function Add-LocalGroupMember {

	Param ( [String]$ADGroup,
			[String]$LocalGroup,
			[String]$Server = '.' )
		
	
			if ( $ADGroup -ne $null ) {		# ----- Add AD Group to Local Group
				$ADG = [ADSI]("WinNT://vbgov/$ADGroup") 
				$LocalG = [ADSI]("WinNT://$Server/$LocalGroup")
				try {
						$LocalG.PSBase.Invoke("Add",$ADG.PSBase.Path)
					}
					catch [System.Management.Automation.MethodInvocationException] {
						Write-Host "$ADGroup is already a member of $LocalGroup" -ForegroundColor Yellow
				}
			}
	
}

#-------------------------------------------------------------------------------

Export-ModuleMember -Function Get-LocalGroupMember, Add-LocalGroupMember