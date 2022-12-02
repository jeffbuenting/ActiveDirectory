

# foreach ( $U in $DisabledList) {
#     Get-ADUser -Filter * -Properties 

# }

$DC = 'kcadcprod01'

$DisabledEvents = invoke-command -ComputerName $DC -ScriptBlock {
    Get-Event -EventIdentifier 629 
}
