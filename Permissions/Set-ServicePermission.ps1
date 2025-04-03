<#
    .LINK
        https://woshub.com/set-permissions-on-windows-service/
        https://learn.microsoft.com/en-us/windows/win32/services/service-security-and-access-rights
#>

$LocalGroup = "Restart Windows Update Service"
$Service = "wuauserv"

# get svcacct sid.  because it is a array of strings we need to only get the sid.  which looks like it is the third line
$SID = (Get-LocalGroup -Name $LocalGroup).SID.Value


$OldSDDL = sc.exe sdshow $Service
$NewPerm = "(A;;RPWP;;;$SID)"
  
if ( $OldSDDL -notcontains $NewPerm ) {

      # long perm sddl are written on multiple lines.  This merges them into one long string
      $OldSDDL = ((-split $OldSDDL) -join "")

      # find where we want to insert new sddl
      $BeforeIndex = $OldSDDL[1].indexof( 'S:' )
      $NewSDDL = "$($OldSDDL[1].Substring(0,$BeforeIndex))$NewPerm$($OldSDDL[1].Substring($BeforeIndex))"

      sc.exe sdset scmanager $NewSDDL

}

