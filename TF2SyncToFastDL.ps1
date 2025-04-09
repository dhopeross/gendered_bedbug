###
### Sync map directory to fastdl server
###


### Configuration
$FastDLServer = "sftp://USERNAME:PASSWORD@hosted.nfoservers.com/"
$FastDLServerHostKey = "HirHG9VT3uH/YaMNZIZq1iH+u1AqeJdV6t0qIV3JO7E"
$RemoteMapTarget = "/usr/www/fithnet/public/FastDL/maps/"
$MapPath = "C:\Games\tf2maps"
$TransferStagingPath = Join-Path $ENV:Temp "tf2maps"

# Check WinSCP path
if([Environment]::Is64BitOperatingSystem) {
    $WinSCPPath = Join-Path ${env:programfiles(x86)} (Join-Path "WinSCP" "WinSCP.com")
}
else {
    $WinSCPPath = Join-Path $env:programfiles (Join-Path "WinSCP" "WinSCP.com")
}
if(-not (Test-Path $WinSCPPath)){
    Write-Error "$WinSCPPath is needed!" -RecommendedAction "Install WinSCP" -ErrorAction:Stop
}

# Check 7zip path
$7zPath = Join-Path $env:programfiles (Join-Path "7-zip" "7z.exe")
if (-not (Test-Path $7zPath)){
    Write-Error "$7zPath needed!" -RecommendedAction "Install 7zip" -ErrorAction:Stop
}

# Create temporary staging directory if needed
New-Item -ItemType Directory -Force -Path $TransferStagingPath

#Create BZ2 archives for each BSP file in folder
$BSPFiles = @(Get-ChildItem (Join-Path $MapPath "*.bsp"))
foreach ($BSPfile in $BSPFiles) {
	$SourcePath = Join-Path $MapPath $BSPFile.name
	$DestPath = Join-Path $TransferStagingPath "$($BSPFile.name).bz2"
	if (-not (Test-Path -Path $DestPath -PathType Leaf)) {
		(& $7zPath "a" "-mmt1" "-tbzip2" $DestPath $SourcePath)
	}
}

# Open SFTP Session to Webserver
# change to target directory
# copy BZ2 archives
& $WinSCPPath `
/log="$(Join-Path $TransferStagingPath "zzz_FITHNET.log")" `
/command `
"open $FastDLServer -hostkey=`"$FastDLServerHostKey`"" `
"synchronize remote -criteria=checksum -filemask=`"*.bz2`" $TransferStagingPath $RemoteMapTarget" `
"exit"
