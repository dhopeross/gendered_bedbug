# Parameters
param(
    [Parameter(Mandatory=$true,
    HelpMessage="Target server for upload")]
    [string]
    $Server,

    [Parameter(HelpMessage="Path to config file (default is config.psd1 in same directory as script)")]
    [string]
    $ConfigFilePath
)

# Load config file
if(-not $ConfigFilePath){
    $ConfigFilePath = Join-Path $PSScriptRoot "config.psd1"
}

if(-not (Test-Path "$ConfigFilePath" -PathType Leaf)){
    Write-Error "Missing config file $ConfigFilePath!" -RecommendedAction "Update path to config file using the -ConfigFilePath parameter" -ErrorAction:Stop
}
$Config = (Get-Content -Raw "$ConfigFilePath" | Import-PowerShellDataFile)

# Check for mandatory config options
foreach ($key in @('Username', 'Password', 'MapPath')){
    if(($null -eq $Config[$key])){
        Write-Error "Can't find $key!" -RecommendedAction "Check $ConfigFilePath and make sure that parameter is present" -ErrorAction:Stop
    }
}

# Check for updated server locations
if((-not $Config.ContainsKey('ServerLocation') -or ($null -eq $Config['ServerLocation']))){
    $Config['ServerLocation'] = "server.fith.co:2121"
}
if((-not $Config.ContainsKey('RemoteMapLocations') -or ($null -eq $Config['RemoteMapLocations']))){
    $Config['RemoteMapLocations'] = @{
            main = '/tf2-maps/tf2-fight-club-maps'
            dodgeball = '/tf2-maps/tf2-fun-maps'
    }
}
Write-Output($Config['RemoteMapLocations'])
if($Server -notin $Config['RemoteMapLocations'].Keys){
    Write-Error "Server $Server not found!" -RecommendedAction "Change -Server parameter to one of $($Config['RemoteMapLocations'].Keys -join ", "); or update RemoteMapLocations in $ConfigFilePath" -ErrorAction:Stop
}

# Function to check utility path and presence of utility
function Get-UtilityPath {
    param(
        [hashtable]$Config,
        [string]$UtilityKey,
        [string]$DefaultPath
    )
    if((-not $Config.ContainsKey($UtilityKey) -or ($null -eq $Config[$UtilityKey]))){
        $ReturnPath = $DefaultPath
    }
    else {
        $ReturnPath = $Config[$UtilityKey]
    }
    if(-not (Test-Path $ReturnPath -PathType Leaf)){
        Write-Error "Utility not found at $ReturnPath!" -RecommendedAction "Please update $UtilityKey in $ConfigFilePath" -ErrorAction:Stop
    }
    return $ReturnPath
}

# Set up default paths, OS-specific utilities
if($IsWindows){
    if([Environment]::Is64BitOperatingSystem) {
        $DefaultWinSCPPath = Join-Path "$env:programfiles x86" "WinSCP" "WinSCP.com"
    }
    else {
        $DefaultWinSCPPath = Join-Path "$env:programfiles" "WinSCP" "WinSCP.com"
    }
    #Check for WinSCP installation (Windows)
    $Config['PathToWinSCP'] = Get-UtilityPath $Config 'PathToWinSCP' $DefaultWinSCPPath
}
elseif($IsLinux){
    $DefaultLFtpPath = Join-Path "/usr" "bin" "lftp"
    #Check for lftp installation (Linux)
    $Config['PathToLftp'] = Get-UtilityPath $Config 'PathToLftp' $DefaultLFtpPath
}
else{
    Write-Error "This script only supports Windows and Linux currently!" -ErrorAction:Stop
}

#Define variables for BSP Files
if(-not (Test-Path $Config['MapPath'] -PathType Container)){
    Write-Error "Directory $($Config['MapPath']) doesn't exist!" -RecommendedAction "Please update MapPath in $ConfigFilePath" -ErrorAction:Stop
}
$TargetDir = $Config['RemoteMapLocations'][$Server]

#Connect to TF2 Server FTP and upload BSP Files
Write-Output("Transferring map files to game server at $($Config['ServerLocation'])")
if($IsWindows) {
    & $Config['PathToWinSCP'] `
    /log="$(Join-Path $Config['MapPath'] "maptransfer.log")" `
    /command `
    "open ftpes://$($Config['Username']):$($Config['Password'])@$($Config['ServerLocation'])/ -certificate=`"`"e1:16:a7:65:62:75:6d:2d:13:0e:74:3d:18:7c:34:99:8d:d0:70:db`"`"" `
    "cd $TargetDir" `
    "put $(Join-Path $Config['MapPath'] "*.bsp")" `
    "exit"
}
elseif($IsLinux) {
    Write-Output("mirror -R -I *.bsp $($Config['MapPath']) $TargetDir;")
    & $Config['PathToLftp'] `
    -e `
    "set log:enabled true; `
    set log:file $(Join-Path $Config['MapPath'] "maptransfer.log"); `
    set ftp:ssl-auth TLS; `
    open ftp://$($Config['Username']):$($Config['Password'])@$($Config['ServerLocation']); `
    cd $TargetDir; `
    lcd $($Config['MapPath']); `
    mput *.bsp; `
    exit"
}
