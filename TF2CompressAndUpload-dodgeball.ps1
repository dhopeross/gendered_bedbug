#Check for WinSCP installation

$pfiles86 = ${env:programfiles(x86)}
if(-not (Test-Path "$pfiles86\WinSCP\WinSCP.com")){
    Write-Warning "$pfiles86\WinSCP\WinSCP.com is needed!" -WarningAction:Stop
}

#Check for 7-Zip installation
if (-not (Test-Path "$env:programfiles\7-zip\7z.exe")){
    Write-Warning "$env:ProgramFiles\7-zip\7z.exe needed!" -WarningAction:Stop
}

#Define variables for 7-Zip executable and BSP Files
$7z = ("$env:Programfiles\7-zip\7z.exe")
$BSPFiles = @(Get-ChildItem d:\path\to\maps\*.bsp)

#Create BZ2 archives for each BSP file in folder
    foreach ($BSPfile in $BSPFiles) {
       & $7z "a" "-tbzip2" "d:\path\to\maps\$($BSPFile.name).bz2" "d:\path\to\maps\$($BSPFile.name)"
        }


#Open SFTP Session to FITH FTP, change directory to /tf2-maps/tf2-fun-maps, copy bsp files -this will upload to the dodgeball TF2 server

& 'C:\Program Files (x86)\WinSCP\WinSCP.com' `
/log="d:\path\to\FITH.log" `
/command `
"open ftpes://<your-username>:<your-password>@216.52.148.223:2121/ -certificate=`"`"e1:16:a7:65:62:75:6d:2d:13:0e:74:3d:18:7c:34:99:8d:d0:70:db`"`"" `
"cd /tf2-maps/tf2-fun-maps/" `
"put d:\path\to\maps\*.bsp" `
"exit"

#Open SFTP Session to Webserver, change directory to /FastDL/maps/, copy BZ2 archives

& 'C:\Program Files (x86)\WinSCP\WinSCP.com' `
/log="d:\path\to\FITHNET.log" `
/command `
"open sftp://fithnet@hosted.nfoservers.com/" `
"cd /usr/www/fithnet/public/FastDL/maps/" `
"put d:\path\to\maps\*.bz2" `
"exit"
