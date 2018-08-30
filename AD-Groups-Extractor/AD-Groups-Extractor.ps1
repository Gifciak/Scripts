Write-Host "Written By Przemyslaw Poluszczyk"

#This script allows us to Extract from shared drives all groups and their permissions( for example if there is an error, and you will have to fix it later )

# Saving results to csv which is easy to then export to Excel.

# The code is made for parts, as the Folders i was working on where just to big ( over 20 TB of data, Hundreds of thousands folders ).

$FolderPath = dir -Directory -Path "\\Your\Path\To-Check\" -Recurse -Force | Where-Object {$_.creationtime -lt "06/06/2016"}
 $Report = @()
 $i=0
 $Data =0
 Foreach ($Folder in $FolderPath) {
     $Acl = Get-Acl -Path $Folder.FullName
     Write-Host "Working now on: $Folder"
     foreach ($Access in $acl.Access)
         {
             $Properties = [ordered]@{'FolderName'=$Folder.FullName;'AD Group or User'=$Access.IdentityReference;'Permissions'=$Access.FileSystemRights}
             $Report += New-Object -TypeName PSObject -Property $Properties
          $i++   
         }
    if($i -gt 1500)
    {
    $Report | Export-Csv -Append -path "\\Your\Path\To-Check\save.csv" 
    $Data++
    $i=0
    $Report =@()
    [System.GC]::Collect()
    Write-Host "Data saved : $Data Times "
    
    }

 }
 
 $Report | Export-Csv -path "\\Your\Path\To-Check\save-leftovers.csv"

 Write-Host "FINALLY IT IS DONE , press enter to end" -ForegroundColor Green

 Read-Host

 exit
 
