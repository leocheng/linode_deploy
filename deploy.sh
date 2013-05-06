#!/usr/bin/env bash
set -o nounset
set -o errexit

source "./env"

CURL_PARAMS="curl -s -X POST"
API_URL="https://api.linode.com"

function get_script {
	RESULT_GETSCRIPT=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=stackscript.list -d StackScriptID=$1)
	echo $RESULT_GETSCRIPT
}

function linode_reboot {
	RESULT_REBOOT=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=linode.reboot -d LinodeID=$LINODE_ID)
	echo $(echo $RESULT_REBOOT | sed -n -e "s/.*JobID\":\([0-9]*\)}.*$/\1/p")
}

function linode_boot {
	RESULT_BOOT=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=linode.boot -d LinodeID=$LINODE_ID -d ConfigID=$2)
	echo $(echo $RESULT_BOOT | sed -n -e "s/.*JobID\":\([0-9]*\)}.*$/\1/p")
}

function linode_shutdown {
	RESULT_SHUTDOWN=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=linode.shutdown -d LinodeID=$LINODE_ID)
	#echo $RESULT_SHUTDOWN 
	echo $(echo $RESULT_SHUTDOWN | sed -n -e "s/.*JobID\":\([0-9]*\)}.*$/\1/p") 
}

function get_current_root_id {
	RESULT_ROOT_ID=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=linode.disk.list -d LinodeID=$LINODE_ID)
	echo $(echo $RESULT_ROOT_ID | sed -n -e "s/.*LABEL\":\"disk_\([0-9]*\)\".*DISKID\":\([0-9]*\).*/\2/p")
}

function get_current_config_id {
	RESULT_CONFIG_ID=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=linode.config.list -d LinodeID=$LINODE_ID)
	echo $(echo $RESULT_CONFIG_ID | sed -n -e "s/.*Label\":\"config_\([0-9]*\)\".*ConfigID\":\([0-9]*\).*/\2/p")
}


function delete_disk {
	RESULT_DELETE_DISK=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=linode.disk.delete -d LinodeID=$LINODE_ID -d DiskID=$1)
	echo $(echo $RESULT_DELETE_DISK | sed -n -e "s/.*DiskID\":\([0-9]*\).*$/\1/p")
}

function delete_config {
	RESULT_DELETE_CONFIG=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=linode.config.delete -d LinodeID=$LINODE_ID -d ConfigID=$1)
	echo $(echo $RESULT_DELETE_CONFIG | sed -n -e "s/.*ConfigID\":\([0-9]*\).*$/\1/p")
}

function create_disk {
	RESULT_CREATE_DISK=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=linode.disk.createfromstackscript -d LinodeID=$LINODE_ID -d StackScriptId=$1 \
	-d DistributionID=$2 -d Label=disk_${3} -d Size=$4 -d rootPass=$5 \
	--data-urlencode \
StackScriptUDFResponses=\
"{
\"admin_user_name\":\""${6}"\",
\"admin_user_passwd\":\"${7}\",
\"admin_user_gid\":\"${8}\",
\"ssh_pubkey_url\":\"${9}\",
\"ssh_passphrase\":\"${10}\",
\"gmail_account\":\"${11}\",
\"gmail_pass\":\"${12}\",
\"ssh_port\":\"${13}\",
\"ssmtp_port\":\"${14}\",
\"http_port\":\"${15}\",
\"tor_port\":\"${16}\",
\"privoxy_port\":\"${17}\",
\"privoxy_tor_port\":\"${18}\",
\"transmission_user\":\"${19}\",
\"transmission_passwd\":\"${20}\",
\"transmission_port\":\"${21}\",
\"opt_disk\":\"${22}\",
\"allow_ip\":\"${23}\",
\"tz_data\":\"${24}\",
\"label_data\":\"${25}\"
}")
	#echo $RESULT_CREATE_DISK 2>&1
	echo $(echo $RESULT_CREATE_DISK | sed -n -e "s/.*DiskID\":\([0-9]*\)}.*$/\1/p")
}

function create_config {
	RESULT_CREATE_CONFIG=$($CURL_PARAMS $API_URL -d api_key=$API_KEY -d api_action=linode.config.create -d LinodeID=$LINODE_ID -d KernelID=$1 -d Label=config_${2} -d DiskList="$3,$4,$5")
	echo $(echo $RESULT_CREATE_CONFIG | sed -n -e "s/.*ConfigID\":\([0-9]*\)}.*$/\1/p")
}




#
SHUTDOWN_ID=$(linode_shutdown)
if [ -z "$SHUTDOWN_ID" ]
then
	echo "Failed to shutdown linode"
	exit 1
else
	echo "Shutdown linode successfully, job id: $SHUTDOWN_ID"
fi 

#
CURRENT_ROOT_ID=$(get_current_root_id)
if [ -z "$CURRENT_ROOT_ID" ]
then
	echo "Failed to get current root disk id"
	exit 1
else
	echo "Current root disk id: $CURRENT_ROOT_ID"
fi 

CURRENT_CONFIG_ID=$(get_current_config_id)
if [ -z "$CURRENT_CONFIG_ID" ]
then
	echo "Failed to get current config id"
	exit 1
else
	echo "Current config id: $CURRENT_CONFIG_ID"
fi 

echo "CAUTION!!!!! YOU ARE ABOUT TO REMOVE THE CURRENT CONFIG AND ROOT DISK !!!!!!!!"
echo "CAUTION!!!!! THE REMOVED CONFIG AND DISK ARE NOT RECOVERIABLE !!!!!!!!"
echo "CAUTION!!!!! HIT ENTER TO CONTINUE... !!!!!!!!"
read

DELETED_ROOT_ID=$(delete_disk $CURRENT_ROOT_ID)
if [ "$CURRENT_ROOT_ID" -ne "$DELETED_ROOT_ID" ]
then
	echo "Failed to delete root disk with id: $CURRENT_ROOT_ID"
	exit 1
else
	echo "Successfully delete root disk with id: $CURRENT_ROOT_ID"
fi 


DELETED_CONFIG_ID=$(delete_config $CURRENT_CONFIG_ID)
if [ "$CURRENT_CONFIG_ID" -ne "$DELETED_CONFIG_ID" ]
then
	echo "Failed to delete config with id: $CURRENT_CONFIG_ID"
	exit 1
else
	echo "Successfully delete config with id: $CURRENT_CONFIG_ID"
fi 

# wait for the root disk being deleted
echo "Waiting for the root disk being deleted...."
sleep 5

#
ROOT_ID=$(create_disk $STACKSCRIPT_ID $DISTRIBUTION_ID $LABEL $SIZE $ROOT_PASS \
	$UDF_ADMIN_USER_NAME \
	$UDF_ADMIN_USER_PASSWD \
	$UDF_ADMIN_USER_GID \
	$UDF_SSH_PUBKEY_URL \
	$UDF_SSH_PASSPHRASE \
	$UDF_GMAIL_ACCOUNT \
	$UDF_GMAIL_PASS \
	$UDF_SSH_PORT \
	$UDF_SSMTP_PORT \
	$UDF_HTTP_PORT \
	$UDF_TOR_PORT \
	$UDF_PRIVOXY_PORT \
	$UDF_PRIVOXY_TOR_PORT \
	$UDF_TRANSMISSION_USER \
	$UDF_TRANSMISSION_PASSWD \
	$UDF_TRANSMISSION_PORT \
	$UDF_OPT_DISK \
	$UDF_ALLOW_IP \
	$UDF_TZ_DATA \
	$UDF_LABEL_DATA \
	)
	
if [ -z "$ROOT_ID" ]
then
	echo "Failed to create disk"
	exit 1
else
	echo "Create disk successfully, disk id: $ROOT_ID"
fi 

#
CONFIG_ID=$(create_config $KERNEL_ID $LABEL $ROOT_ID $SWAP_ID $OPT_ID)

if [ -z "$CONFIG_ID" ]
then
	echo "Failed to create config"
	exit 1
else
	echo "Create config successfully, config id: $CONFIG_ID"
fi 

#
BOOT_ID=$(linode_boot $LINODE_ID $CONFIG_ID)
if [ -z "$BOOT_ID" ]
then
	echo "Failed to boot linode"
	exit 1
else
	echo "Boot linode successfully, job id: $BOOT_ID"
fi 


exit 0

