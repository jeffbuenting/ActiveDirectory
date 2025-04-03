[CmdletBinding()]
Param ( 
    [String]$LogPath = "C:\ProgramData\_sysops\EnableWINRMHTTPS",

    [String]$LogName = "EnableWINRM_GPO.log"
)

$Log = Join-Path -Path $LogPath -ChildPath $LogName

if ( -Not (Test-Path -Path $LogPath) ) { New-Item -ItemType Directory -Path $LogPath }

"$(Get-Date -Format 'yyy-MM-dd HH:mm:ss') -         - -------------------------------------------" | Out-File -FilePath $Log -Append

"$(Get-Date -Format 'yyy-MM-dd HH:mm:ss') -         - Does the WINRM Cert Exist?" | Out-File -FilePath $Log -Append

$templateName = "WinRM over HTTPS" 
$Cert = Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object{ $_.Extensions | Where-Object{ ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $templateName) }}

if ( -Not $Cert ) {
    "$(Get-Date -Format 'yyy-MM-dd HH:mm:ss') -         - Cannot Find Cert that uses the template: $TemplateName" | Out-File -FilePath $Log -Append

    Throw "$(Get-Date -Format 'yyy-MM-dd HH:mm:ss') -         - Cannot Find Cert that uses the template: $TemplateName"
}

"$(Get-Date -Format 'yyy-MM-dd HH:mm:ss') -         - Get Listeners." | Out-File -FilePath $Log -Append
# Get Listeners as object
$Listeners = @()
get-childitem WSMan:\localhost\Listener | foreach { 
    $L = [PSCustomObject]@{}
    get-childitem WSMan:\localhost\Listener\$($_.name) | foreach {
      #  $_.Name
      #  $_.value
            

         $L | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
    }
    $Listeners += $L
} 

"$(Get-Date -Format 'yyy-MM-dd HH:mm:ss') -         - $($Listeners | Out-String)" | Out-File -FilePath $Log -Append

if ( $Listeners | where Transport -eq HTTPS) {
    #Remove listener
    "$(Get-Date -Format 'yyy-MM-dd HH:mm:ss') -         - Update HTTPS Listener" | Out-File -FilePath $Log -Append

    Remove-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="https"}
}

# Create HTTPS listener
"$(Get-Date -Format 'yyy-MM-dd HH:mm:ss') -         - Create HTTPS Listener..." | Out-File -FilePath $Log -Append

New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint –Force


# # https://4sysops.com/archives/powershell-remoting-over-https-with-a-self-signed-ssl-certificate/


#     #Firewall Rule
#     New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "Windows Remote Management (HTTPS-In)" -Profile Any -LocalPort 5986 -Protocol TCP


