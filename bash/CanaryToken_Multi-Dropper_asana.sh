#!/bin/bash
#CanayToken_Multi-Dropper_asana.sh


#Set Canary Console connection variables here
# Enter your Console domain between the . e.g. 1234abc.canary.tools
DOMAIN="0d571862.canary.tools"
# Enter your Factory auth key. e.g a1bc3e769fg832hij3 Docs available here. https://docs.canary.tools/canarytokens/factory.html#create-canarytoken-factory-auth-string
FACTORYAUTH="$4"
# Enter desired flock to place tokens in. Docs available here. https://docs.canary.tools/flocks/queries.html#list-flock-sensors
FLOCKID="flock:0a74151ea0ee0f5916b37570f12b3959"

####################################################################################################################################################################################################################################

HOSTNAME=$(hostname)
USER=$(users)

####################################################################################################################################################################################################################################

#Drops an AWS API Token
create_token_AWS(){
TokenType="aws-id"
#Set Token target directory here.
TargetDirectory="$HOME/.ct_aws"
#Set Token file name here
TokenFilename="credentials"

MEMO="Canary token for $TokenType on host: $HOSTNAME username: $USER"

OUTPUTFILENAME="$TargetDirectory/$TokenFilename"

if [ -f "$OUTPUTFILENAME" ];
then
printf "\n \e[1;33m $OUTPUTFILENAME already exists.";
return
fi

CREATE_TOKEN=$(curl -L -s -X POST --tlsv1.2 --tls-max 1.2 "https://${DOMAIN}/api/v1/canarytoken/factory/create" -d factory_auth=$FACTORYAUTH -d memo="$MEMO" -d flock_id=$FLOCKID -d kind=$TokenType)

if [[ $CREATE_TOKEN == *"\"result\": \"success\""* ]];
then
TOKEN_ID=$(printf "$CREATE_TOKEN" | grep -o '"canarytoken": ".*"' | sed 's/"canarytoken": //' | sed 's/"//g')
else
printf "\n \e[1;31m $OUTPUTFILENAME Token failed to be created."
return
fi

curl -L -s -G --tlsv1.2 --tls-max 1.2 --create-dirs --output "$OUTPUTFILENAME" -J "https://$DOMAIN/api/v1/canarytoken/factory/download" -d factory_auth=$FACTORYAUTH -d canarytoken=$TOKEN_ID

printf "\n \e[1;32m $OUTPUTFILENAME Successfully Created"


#create "config" file to seem more authentic
echo "[default]" > "$TargetDirectory/config"
echo "region = us-east-1" >> "$TargetDirectory/config"
echo "output = json" >> "$TargetDirectory/config"


}
create_token_AWS






####################################################################################################################################################################################################################################

#Drops an Slack API Token
create_token_slack(){
TokenType="slack-api"
#Set Token target directory here.
TargetDirectory="$HOME/.ct_slack_directory"
#Set Token file name here
TokenFilename="Slack_API_Keys.txt"

MEMO="Canary token for $TokenType on host: $HOSTNAME username: $USER"

OUTPUTFILENAME="$TargetDirectory/$TokenFilename"

if [ -f "$OUTPUTFILENAME" ];
then
printf "\n \e[1;33m $OUTPUTFILENAME already exists.";
return
fi

CREATE_TOKEN=$(curl -L -s -X POST --tlsv1.2 --tls-max 1.2 "https://${DOMAIN}/api/v1/canarytoken/factory/create" -d factory_auth=$FACTORYAUTH -d memo="$MEMO" -d flock_id=$FLOCKID -d kind=$TokenType)

if [[ $CREATE_TOKEN == *"\"result\": \"success\""* ]];
then
TOKEN_ID=$(printf "$CREATE_TOKEN" | grep -o '"canarytoken": ".*"' | sed 's/"canarytoken": //' | sed 's/"//g')
else
printf "\n \e[1;31m $OUTPUTFILENAME Token failed to be created."
return
fi

curl -L -s -G --tlsv1.2 --tls-max 1.2 --create-dirs --output "$OUTPUTFILENAME" -J "https://$DOMAIN/api/v1/canarytoken/factory/download" -d factory_auth=$FACTORYAUTH -d canarytoken=$TOKEN_ID

printf "\n \e[1;32m $OUTPUTFILENAME Successfully Created"

}
create_token_slack

####################################################################################################################################################################################################################################

printf "\n \e[1;32m [*] Token Dropper Complete."


# for security reasons, we should unset/wipe all variables that contained an auth token, or evidence of Canary/Canarytokens
unset DOMAIN
unset FACTORYAUTH
unset FLOCKID

exit
