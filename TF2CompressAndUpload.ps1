#Check for WinSCP installation

if(-not (Test-Path "$env:programfiles x86\WinSCP\WinSCP.com")){
    Write-Warning "$env:programfiles x86\WinSCP\WinSCP.com is needed!" -WarningAction:Stop
}

#Check if 7-zip is installed
if (-not (Test-Path "$env:programfiles\7-zip\7z.exe")){
    Write-Warning "$env:ProgramFiles\7-zip\7z.exe needed!" -WarningAction:Stop
}

#Define variables for 7-Zip executable and BSP Files
$7z = ("$env:Programfiles\7-zip\7z.exe")
$BSPFiles = @(Get-ChildItem D:\path\to\maps\*.bsp)

#Create BZ2 archives for each BSP file in folder
    foreach ($BSPfile in $BSPFiles) {
       & $7z "a" "-tbzip2" "D:\path\to\maps\$($BSPFile.name).bz2" "d:\path\to\maps\$($BSPFile.name)"
        }


#Connect to FITH TF2 Server FTP and upload BSP Files



#Open SFTP Session to Webserver, change directory to /FastDL/maps/, copy BZ2 archives

& 'C:\Program Files (x86)\WinSCP\WinSCP.com' `
/log="d:\writable\path\winscp.log" `
/command `
"open sftp://fithnet@hosted.nfoservers.com/" `
"cd /usr/www/fithnet/public/FastDL/maps/" `
"put D:\path\to\maps\*.bz2" `
"exit"
