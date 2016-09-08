
# ----- Get list of Domain controllers
$localdomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() | % { $_.DomainControllers } | Select name


$NTDS = @()

foreach ( $DC in $localdomain ) {
	$DC.name
	$FileInfo = New-Object system.object
	$FileInfo | Add-Member -type NoteProperty -Name Server -Value $DC.name
	$FileInfo | Add-Member -type NoteProperty -Name FileName -Value "NTDS.dit"
	$Path = "\\"+$DC.Name+"\c$\windows\NTDS\ntds.dit"
	$FileInfo | Add-Member -type NoteProperty -Name FileSize -Value (((Get-Item -Path $Path).length)/1KB)
	$NTDS += $FileInfo
}

$NTDS | Sort-Object Server

$excel = New-Object -ComObject excel.application
$excel.visible = $True
$Workbook = $excel.workbooks.open( "\\vbgov.com\deploy\Disaster_Recovery\ActiveDirectory\Scripts\ntds.dit_size.xlsx" )
$Worksheet = $Workbook.worksheets.item(1)
$NextRow = $Worksheet.usedrange.rows.count
$NextRow

$Worksheet.Cells.item($NextRow+1,1) = Get-Date -format d
$C = 2
foreach ( $File in $NTDS ) {
	$Worksheet.Cells.item($NextRow+1,$C) = $File.Server
	$Worksheet.Cells.item($NextRow+1,$C+1) = $File.FileSize
	$C = $C + 2
}

$Workbook.save()
$excel.Quit()


