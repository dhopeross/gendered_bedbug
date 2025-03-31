# gendered_bedbug

## Usage:
- update `config.psd1` as needed
  - `Username`, `Password` and `MapPath` are mandatory
  - the other options are not required unless WinSCP and/or lftp are installed in non-standard directories or something changed on the server side
- run `TF2Upload.ps1 -server main` (or `-server dodgeball`, or whatever)
  - The `TF2CompressAndUpload-main.ps1` and `TF2CompressAndUpload-dodgeball.ps1` call `TF2Upload.ps1` with server names pre-populated, for compatibility with the previous version of the scripts
