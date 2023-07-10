$Logins = @()

Get-WinEvent -LogName "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational" | Foreach {
    $M = $_.Message | Select-String -Pattern "User: (.*)"

    if ( $M ) {
        $L = [PSCustomObject]@{
            User = $M.Matches.Groups[1].Value
            Time = $_.TimeCreated
        }

            

        $Logins += $L
        
    }
}

$Logins | Sort-Object Time | FT Time, User -AutoSize 