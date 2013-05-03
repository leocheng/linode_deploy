linode_deploy
=============

This script has to work with the StackScript: https://manager.linode.com/linodes/deploy/linode264945?StackScriptID=6577

The bash script to deploy a new linode with curl
The script will do the following:

  1. Shutdown your linode.
  2. Create the root disk from the StackScript.
  3. Create the configuration
  4. Boot your linode with the new deploy.

usage
=============
  1. Edit the "env.dummy" file as you need, after you have finished the editing, rename it to "env".
  2. Run "deploy.sh" 
  3. You will see message like:

  Shutdown linode successfully, job id: 999999
  Create disk successfully, disk id: 999999
  Create config successfully, config id: 999999
  Boot linode successfully, job id: 999999


