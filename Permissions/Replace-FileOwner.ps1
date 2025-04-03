$Path = "\\nas1\vol1" 


$Files = Get-childitem -Path $Path -Recurse


Foreach ( $F in $Files ) {
    Write-output "changing owner $($F.FullName)"
    
    $ACL = Get-ACL $F.Fullname

    $ACL.SetOwner( [System.Security.Principal.NTAccount]"domain admins" )

    Set-ACL -Path $F.FullName -AclObject $ACL

}