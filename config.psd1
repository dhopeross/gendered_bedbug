### FITH map upload scripts config file
###
### Update the following values as needed
###
### DO NOT remove the '@{' or '}' brackets
###  at the beginning and end or it will break
@{
    ### Mandatory
    ## Username
    Username = "ftpuser-myusername"
    ## Password
    Password = "mypassword"
    ## Local directory containing the maps you wish to upload
    MapPath = "C:\Maps"

    ### Optional
    ## Path to WinSCP.com (Windows only)
    ## Uncomment and update this if you've installed WinSCP to a non-standard directory
    #PathToWinSCP = "C:\WinSCP\WinSCP.com"
    ## Path to ftp (Linux only)
    ## Uncomment and update this if you've installed lftp to a non-standard directory
    #PathToLFtp = "/opt/ftp/ftp"

    ## Game Server location
    ## Uncomment and update this if the game server has spontaneously changed IP/domain name
    #ServerLocation = "server.fith.co:2121"

    ## Remote map locations
    ## Uncomment and update this if the remote map directories have changed
    ## This affects the available entries for the -Server parameter
    #RemoteMapLocations = @{
    #    main = '/tf2-maps/tf2-fight-club-maps/'
    #    dodgeball = '/tf2-maps/tf2-fun-maps/'
    #}
}