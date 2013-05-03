linode_deploy
=============
    This is the script I use to deploy my own linode working machine.
    The script will call linode API with curl and set up: 
      sshd, privoxy, tor, transmission, ssmtp, stunnel, ufw, nginx, timezone, etc.
    This script has to work with below StackScript:
    https://manager.linode.com/linodes/deploy/linode264945?StackScriptID=6577

    The script will do the following:

      1. Shutdown your linode.
      2. Create the root disk from the StackScript.
      3. Create the configuration.
      4. Boot your linode with the new deploy.

    For more information about the Linode API, check:
      http://www.linode.com/api/

usage
=============
    1. Edit the "env.dummy" file as you need, after you have finished the editing, rename it to "env".
    2. Run "deploy.sh" 
    3. You will see message like:


    Shutdown linode successfully, job id: 999999
    Create disk successfully, disk id: 999999
    Create config successfully, config id: 999999
    Boot linode successfully, job id: 999999


