

$users = Import-Csv c:\temp\data.csv 

foreach ($U in $Users ) {
        
		
		    set-QADUser -Identity $U.uname -userpassword 'P@ssword'       ## test existance of user
        	
		    Enable-QADUser $U.uname
		
}

