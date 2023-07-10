function Test-PendingReboot {

<#
    .SYSNOPSIS
        Check if computer needs a reboot.

    .LINKS
        https://ilovepowershell.com/windows-powershell-legacy/how-to-check-if-a-server-needs-a-reboot/#:~:text=It%20turns%20out%20that%20a,the%20built%2Din%20PowerShell%20providers!
#>

    if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
    
    try { 
        $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $status = $util.DetermineIfRebootPending()
        if(($status -ne $null) -and $status.RebootPending){
            return $true
        }
    }catch{}
    
    return $false
}