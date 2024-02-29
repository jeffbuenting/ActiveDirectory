<#
    .SYNOPSIS
        Reports on LDAP sessions when auditing is enabled.

    .DESCRIPTION
        With auditing enabled can be used to identifiy which machines are connecting to a domain controller.  Can be used with disabling DC Discovery so you can identify what is hardcoded 
        to the DC.

    .LINK
    https://learn.microsoft.com/en-us/archive/blogs/pie/how-to-detect-applications-using-hardcoded-dc-name-or-ip
#>

Function Get-UserFromSID {

    [CmdletBinding()]
    param(
        [String]$SID
    )

    Write-Verbose "SID = $SID"

    # Give SID as input to .NET Framework Class
    $SSID = New-Object System.Security.Principal.SecurityIdentifier($SID)

    # Use Translate to find user from sid
    $objUser = $SSID.Translate([System.Security.Principal.NTAccount])

    # Print the converted SID to username value
    write-output $objUser.Value

}

#----------------------

$Data = @()

Get-WinEvent -MaxEvents 1000 -FilterHashtable @{LogName="Directory Service" ; ID=1139 } | ForEach-Object {
    if ( $_.Properties.Value[3] -match "\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}:\d*" ) {
    
        $_info = @{
            "Operation" = [string] $_.Properties.Value[0]
            "User" = Get-UserFromSID -SID ([string] $_.Properties.Value[2])
            "IP:Port" = [string] $_.Properties.Value[3]
        }

        $Data += New-Object psobject -Property $_info    
   } 
} 

$Data | Select-Object @{N="IP";E={$_.'IP:PORT'.split(':')[0]}},User,Operation | Sort-Object IP  #| Select-Object -Unique IP | sort IP | FT IP,User,Operation -AutoSize

# use this section instead if you want to only see specific IPs
$Rubrik = "10.33.71.135","10.33.72.247","10.33.76.181","10.33.86.77"

$Data | Select-Object @{N="IP";E={$_.'IP:PORT'.split(':')[0]}},User,Operation | Where { $_.IP -in $Rubrik } | Sort-Object IP  #| Select-Object -Unique IP | sort IP | FT IP,User,Operation -AutoSize