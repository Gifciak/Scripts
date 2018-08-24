##Requires -RunAsAdministrator
#Beginning of the Code
<#
Clears Temps ( 2 windows and 2 users ) - 4 folders
Clears Bin - 1 folder
Clears Appsense -1 folder
Clears Browser entirely - 6 folders
Option 3 , Goes thru everything + PC Clean-up
Option 4 , fix for SEQ apps.
Update: 22 August 2018
#>

$ErrorActionPreference = "SilentlyContinue"

Function PCClean
{
Write-Host "Starting PC Cleaning" -ForegroundColor "Green"
#Clears Windows Temps
Set-Location "C:\Windows\Temp" 
Remove-Item * -Recurse -Force 
#Clears Windows Prefetch
Set-Location "C:\Windows\Prefetch" 
Remove-Item * -Recurse -Force
Write-Host "25% done" -ForegroundColor "Green"
# User settings
Set-Location "C:\Documents and Settings"
Remove-Item ".\Default\Local Settings\temp\*" -Recurse -Force  
#Clears %temp%
Write-host "50% done" -ForegroundColor "Green"
Set-Location "C:\Users"
Remove-Item “.\*\AppData\Local\Temp\*” -Recurse -Force 
#Clears appsense
Set-Location "C:\appsensevirtual"
Remove-Item * -Recurse -Force 
# RecycleBin cleaning ( many options because user's Trash location is weird, and one line sometimes doesn't work)

Clear-RecycleBin -Force
rmdir /s %systemdrive%\$Recycle.bin
del /s /q %systemdrive%\$Recycle.bin
 Write-Host "75% done" -ForegroundColor "Green"
rd /s 'C:\$Recycle.Bin' -Force -Recurse

Set-Location "C:\$Recycle.Bin"
Remove-Item * -Recurse -Force

Set-Location "C:\Windows\"
Remove-Item * -Include *MEMORY.DMP

Write-Host " Temporary Files have been deleted `n" -ForegroundColor "Green"
}

Function TaskClean
{
Write-Host "Please wait till script cleans computer entirely (about 5-10 minutes)" -ForegroundColor "Green"

Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' -Name StateFlags0001 -ErrorAction SilentlyContinue | Remove-ItemProperty -Name StateFlags0001 -ErrorAction SilentlyContinue

New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -Name StateFlags0001 -Value 2 -PropertyType DWord

New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Name StateFlags0001 -Value 2 -PropertyType DWord

Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle Hidden -Wait

Get-Process -Name cleanmgr,dismhost -ErrorAction SilentlyContinue | Wait-Process

Write-Host "Almost Done" -ForegroundColor "Green"

$UpdateCleanupSuccessful = $false
if (Test-Path $env:SystemRoot\Logs\CBS\DeepClean.log) {
    $UpdateCleanupSuccessful = Select-String -Path $env:SystemRoot\Logs\CBS\DeepClean.log -Pattern 'Total size of superseded packages:' -Quiet
}

if ($UpdateCleanupSuccessful) {
   Write-Host "for full cleaning, i recommend restarting PC, would you like to do it now? (y / n )"
    if(Read-Host -eq "y") 
    {
    Restart-Computer
    } elseif (Read-Host -eq "n") 
    {
    exit
    }
}

}

Function InternetClean
{
   # Cleaning of IE
Write-Host " Starting IE clear" -ForegroundColor "Green"
#dziala dobrze
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 1 # Browser History
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4 # Cookies (temporary files)
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 8 # Offline favs and Download History
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 16  # Form Data
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 32  # Passwords
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4096 # Data from Add-ons
Write-Host " Internet Explorer Temporary Files have been deleted `n" -ForegroundColor "Green"
}

Function AWB
{
PCClean
Write-Host "Please wait till script clears AWB" -ForegroundColor "Green"

RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4 # Cookies

REG DELETE HKLM\Software\Microsoft\AppV\Client\PackageGroups\E386098B-7394-449D-9724-A69FD648EAB1
REG DELETE HKLM\Software\Microsoft\AppV\Client\PackageGroups\526F5866-0F67-469C-B9A2-92AE86005846
REG DELETE HKLM\Software\Microsoft\AppV\Client\PackageGroups\eac22bd3-5ea9-4b5b-a7c5-e22336601caa
REG DELETE HKLM\Software\Microsoft\AppV\Client\PackageGroups\b1a696ab-c06a-4124-980c-a4d1cd5e5136
Powershell.exe sync-appvpublishingserver 1

Write-Host "ABOUT TO FLUSH ALL CONNECTION GROUPS AND ALL PACKAGES . . ." 

ForEach ($userHive in Get-ChildItem Registry::HKU) {
    If (Test-Path Registry::"$userHive\Volatile Environment") {
        $loggedInUserSID = $userHive.PSChildName
    }
}
Get-AppVClientconnectiongroup -All | Stop-AppvClientConnectiongroup -Global
Get-AppVClientconnectiongroup -All | Remove-AppvClientConnectiongroup

Get-AppvClientPackage -All | Stop-AppvClientPackage -Global
Get-AppvClientPackage -All | Unpublish-AppvClientPackage -UserSID $loggedInUserSID
Get-AppvClientPackage -All | Remove-AppvClientPackage

xcopy /c /y \\vfipffil005\transfer\RobertW\3-Excel_Libraries\MSCOM\MSCOMCTL.OCX C:\Windows\SysWOW64\*.*
xcopy /c /y \\vfipffil005\transfer\RobertW\3-Excel_Libraries\MSCOM\MSCOMCT2.OCX C:\Windows\SysWOW64\*.*
xcopy /c /y \\vfipffil005\transfer\RobertW\3-Excel_Libraries\MSCOM\FM20.DLL C:\Windows\SysWOW64\*.*
xcopy /c /y \\vfipffil005\transfer\RobertW\3-Excel_Libraries\MSCOM\MSCAL.OCX C:\Windows\SysWOW64\*.*
echo:
Write-Host "Registering libraries ..."
%systemroot%\SysWOW64\regsvr32 /s C:\Windows\SysWOW64\MSCOMCTL.OCX
%systemroot%\SysWOW64\regsvr32 /s C:\Windows\SysWOW64\MSCOMCT2.OCX
%systemroot%\SysWOW64\regsvr32 /s C:\Windows\SysWOW64\FM20.DLL
%systemroot%\SysWOW64\regsvr32 /s C:\Windows\SysWOW64\MSCAL.OCX

Write-Host "`nAgent WorkBench Temporary Files have been deleted, IE Temps deleted" -ForegroundColor "Green"
Write-Host "Launching App-V Client, don't forget to accept the Flush pop-up!" -ForegroundColor "red" -BackgroundColor "White"
Start-Sleep -Seconds 3
Start-Process -FilePath "C:\Program Files (x86)\Microsoft Application Virtualization\Client UI\AppVClientUX.exe" 

powershell.exe -executionpolicy bypass -windowstyle hidden -noninteractive -nologo -file "\\uk\appvcontent\Prod\1\CacheClean\admin_appv_all_v4.ps1"
powershell.exe -executionpolicy Restricted


}
 $zmienna ="0"
Write-Host "Written by Przemyslaw Poluszczyk" -ForegroundColor "Red"

#Main loop
Do
{
Write-Host "Please select what you want to do :`n 
1.PC Slowness Fix`n 
2.IE Slowness fix`n 
3.Full Clean (very long version, clears everything) `n 
4.SEQ Apps (AWB, SAP, UCIT) Slowness/Hungs/Crashes/ doesn't load up`n
5.Exit `n
  "
    switch($zmienna = Read-Host){
    1{
    ###Clears PC
        CLS
        PCClean

}   2{
    ###Clears IE
        CLS
        InternetClean
}   
    3{
    ###Option 1 + Option 2 + extras
        CLS
        PCClean
        InternetClean
        TaskClean
     }
    4{
    ### FIX for SEQ apps.
        CLS
        AWB
    }
    5{
        exit
     }
    default{
        "Invalid entry"
        CLS
    }
}
}Until($zmienna -Eq "5")
 
