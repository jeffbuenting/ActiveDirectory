<#
    .DESCRIPTION
        When migrating files from one location to another, Keeping the same folder structure, in theory with datasync or robocopy the permissions are supposed to transfer but it
        like they do not.  Using this script you can find where the differ and then manually fix.
#>

[CmdletBinding()]
param (
    [String]$Path = "\\nas2-new\alteryxdata",
    
    $Log = "C:\temp\PermissionLog.log",

    $NewNas = 'nas2-new',

    $OldNas = 'nas2',

    $ExcludeID = ( "BUILTIN\Administrators","BUILTIN\Users","NRCCUA_HQ\FSX_Admins","NT AUTHORITY\Authenticated Users" )
)

"===================================" | Tee-Object -FilePath $Log -Append
"===================================" | Tee-Object -FilePath $Log -Append
Get-Date | Tee-Object -FilePath $Log -Append
"===================================" | Tee-Object -FilePath $Log -Append


Get-ChildItem -Path $Path -recurse | Where-Object PSIsContainer -eq $True | ForEach-Object {
    "--------------" | Tee-Object -FilePath $Log -Append
    "Item = $($_.FullName)" | Tee-Object -FilePath $Log -Append

    $OLdACLs = (Get-ACL -Path $_.FullName.replace($NewNas,$Oldnas )).Access | Where-Object { $_.IdentityReference -notin $ExcludeID }

    $NewACLs = (Get-ACL -Path $_.FullName).Access | Where-Object { $_.IdentityReference -notin $ExcludeID }

    $Result = Compare-Object $OLdACLs $NewACLs -IncludeEqual 

    if ( $Result.SideIndicator -ne "==" ) {
         "Old" | Tee-Object -FilePath $Log -Append
        $($OldACLs | Out-String) | Tee-Object -FilePath $Log -Append

        "New" | Tee-Object -FilePath $Log -Append
        $($NewACLs | Out-String) | Tee-Object -FilePath $Log -Append

    }
}
