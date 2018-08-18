##Requires -RunAsAdministrator

#Poczatek kodu

$ErrorActionPreference = "SilentlyContinue"

Function PCClean

{
# czyszczenie plikow tymczasowych windowsa

# Tempy windowsowe
Set-Location "C:\Windows\Temp"
Remove-Item * -Recurse -Force
# Prefetche windowsowe
Set-Location "C:\Windows\Prefetch"
Remove-Item * -Recurse -Force
 

# Ustawienia uzytkownika
Set-Location "C:\Documents and Settings"
Remove-Item ".\Default\Local Settings\temp\*" -Recurse -Force 

# czyszczenie naszego %temp% ( uzytkownika )
Set-Location "C:\Users"
Remove-Item “.\*\AppData\Local\Temp\*” -Recurse -Force

#czysci appsense
Set-Location "C:\appsensevirtual"
Remove-Item * -Recurse -Force

# czysczenie smietnika

Clear-RecycleBin -Force

rmdir /s %systemdrive%\$Recycle.bin

del /s /q %systemdrive%\$Recycle.bin

rd /s 'C:\$Recycle.Bin' -Force -Recurse

Set-Location "C:\$Recycle.Bin"
Remove-Item * -Recurse -Force

Set-Location "C:\Windows\"

Remove-Item * -Include *MEMORY.DMP

Write-Host " Temporary Files have been deleted `n" -ForegroundColor "Green"

}

Function TaskClean

{

Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' -Name StateFlags0001 -ErrorAction SilentlyContinue | Remove-ItemProperty -Name StateFlags0001 -ErrorAction SilentlyContinue

New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -Name StateFlags0001 -Value 2 -PropertyType DWord

New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Name StateFlags0001 -Value 2 -PropertyType DWord

Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle Hidden -Wait

Get-Process -Name cleanmgr,dismhost -ErrorAction SilentlyContinue | Wait-Process

$UpdateCleanupSuccessful = $false

if (Test-Path $env:SystemRoot\Logs\CBS\DeepClean.log) {
    $UpdateCleanupSuccessful = Select-String -Path $env:SystemRoot\Logs\CBS\DeepClean.log -Pattern 'Total size of superseded packages:' -Quiet
}

if ($UpdateCleanupSuccessful) {
   Write-Host "for full cleaning, i recommend restarting PC "
}

}

Function InternetClean
{
# Czyszczenie Internet Explorer'a

#dziala dobrze
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 1 # Historia przegladarki
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4 # Ciasteczka
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 8 # Offline Favs oraz Historia pobierania
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 16  # Form Data
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 32  # Hasla
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4096 # Dane z Add-ons
Write-Host " Internet Explorer Temporary Files have been deleted `n" -ForegroundColor "Green"

}
#poczatek kodu

$zmienna ="0"

Write-Host "Written by Przemyslaw Poluszczyk" -ForegroundColor "Red"
 

Do
{
Write-Host "Please select what you want to do :`n 1.PC Slowness Fix`n 2.IE Slowness fix`n 3.Full Clean (very long version, clears everything) `n 4.Exit `n  "
    switch($zmienna = Read-Host){
    1{
    ###czyszczenie PC
        CLS
        PCClean

 }   2{
    ###czyszczenie IE
        CLS
        InternetClean
}  

    3{

    ###Czysci wszystko jak leci
        CLS
        PCClean
        InternetClean
        TaskClean
     }

    4{
        exit
     }

    default{

        "Invalid entry"

        CLS
    }

}
 

}Until($zmienna -Eq "4")

 

# CO PROGRAM ROBI NARAZIE

<#

Czysci Tempy ( 2 windowsowe oraz 2 userowe ) - 4 foldery
Czysci Kosz - 1 folder
Czysci Appsense -1 folder
Czysci Przegladarke kompletnie - 6 folderow

opcja 3 , leci wszystko po adminie z clean-upem

Update: 3 Sierpnia 2018r 

#>