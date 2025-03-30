### Sync map directory to fastdl server
###
### This script assumes that 

### Configuration
$FastDLServer = "sftp://fithnet:CHANGETHISPASSWORD@hosted.nfoservers.com/"
$RemoteMapTarget = "/usr/www/fithnet/public/FastDL/maps/"
$MapPath = "C:\Games\tf2maps"
$TransferStagingPath = Join-Path $ENV:Temp "tf2maps"

# Check WinSCP path
if([Environment]::Is64BitOperatingSystem) {
    $WinSCPPath = Join-Path ${env:programfiles(x86)} "WinSCP" "WinSCP.com"
}
else {
    $WinSCPPath = Join-Path $env:programfiles "WinSCP" "WinSCP.com"
}
if(-not (Test-Path $WinSCPPath)){
    Write-Error "$WinSCPPath is needed!" -RecommendedAction "Install WinSCP" -ErrorAction:Stop
}

# Check 7zip path
$7zPath = Join-Path $env:programfiles "7-zip" "7z.exe"
if (-not (Test-Path $7zPath)){
    Write-Error "$7zPath needed!" -RecommendedAction "Install 7zip" -ErrorAction:Stop
}

# Create temporary staging directory if needed
New-Item -ItemType Directory -Force -Path $TransferStagingPath

#Create BZ2 archives for each BSP file in folder
$BSPFiles = @(Get-ChildItem (Join-Path $MapPath "*.bsp"))
foreach ($BSPfile in $BSPFiles) {
    & $7zPath "a" "-tbzip2" (Join-Path $TransferStagingPath "$($BSPFile.name).bz2") (Join-Path $MapPath $BSPFile.name)
}

# Open SFTP Session to Webserver
# change to target directory
# copy BZ2 archives
& $WinSCPPath `
/log="$(Join-Path $TransferStagingPath "FITHNET.log")" `
/command `
"open $FastDLServer" `
"cd $RemoteMapTarget" `
"put $(Join-Path $TransferStagingPath "*.bz2")" `
"exit"