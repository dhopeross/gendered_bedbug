# This script is for backwards compatibility for existing users
#   and has been reworked to call TF2Upload.ps1
param(
    [Parameter(HelpMessage="Path to config file (default is config.psd1 in same directory as script)")]
    [string]
    $ConfigFilePath
)

if($ConfigFilePath){
    & $PSScriptRoot/TF2Upload.ps1 -Server main -ConfigFilePath $ConfigFilePath
}
else {
    & $PSScriptRoot/TF2Upload.ps1 -Server main
}
