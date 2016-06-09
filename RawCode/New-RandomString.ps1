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



New-RandomString -UpperCase -LowerCase -Numbers -Length 20 -Unique