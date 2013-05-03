linode_deploy
=============

This script has to work with below StackScript.
https://manager.linode.com/linodes/deploy/linode264945?StackScriptID=6577

The bash script to deploy a new linode with curl
The script will do the following:

  1. Shutdown your linode.
  2. Create the root disk from the StackScript.
  3. Create the configuration
  4. Reboot your linode with the new deploy.

usage
=============
  1. Edit the "env.dummy" file as you need, after you have finished the editing, rename it to "env".
  2. run "deploy.sh" 
