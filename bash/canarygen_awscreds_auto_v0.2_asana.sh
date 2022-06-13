#!/bin/bash
# Generate AWS Creds 0.2
# canarygen_awscreds.sh

# This is the "auto" version of this script. Run it unattended and it will
# automatically grab username and hostname variables from the system it is
# run on.

# Set the following variables to the correct values for your:
# 1. Unique Canary Console URL
# 2. Canary Console API Key
# 3. Memo/reminder for the token (this is what you see when you get an alert!)
# 4. Flock Name
# 5. Path where file will be created (defaults to root of home directory)
export console=0d571862.canary.tools
export token=deadbeef02082f1ad8bbc9cdfbfffeef
export tokenmemo="Canary AWS Creds on host: $HOSTNAME username: $USER"
export flock='Endpoint'
export filepath=~/.ct_aws
export filename='credentials'

# Get current date for part of file name
export filedate=`date "+%Y%m%d%H%M%S"`

# Get FlockID from flock name
flockid=$(curl -s -k "https://${console}/api/v1/flocks/filter?auth_token=${token}&filter_str=${flock}" | grep -Eo '"flock_id":.*?[^\\]",' | awk -F '[":"]' '{print $5,$6}' OFS=":")
echo -e "\nFlockID is $flockid"

# Create the token
echo -e "Creating token"
awscreds=$(curl -s https://$console/api/v1/canarytoken/create \
  -d auth_token=$token \
  -d memo="'$tokenmemo'" \
  -d kind=aws-id \
  -d flock_id=$flockid)

# Write the token to a local text file
mkdir -p $filepath
echo "[default]" > $filepath/filename
echo $awscreds | grep -oE "aws_access_key_id = .{20}" >> $filepath/$filename
echo $awscreds | grep -Eo "aws_secret_access_key = .{40}" >> $filepath/$filename
echo -e "\nCreds written to $filepath/$filename"

#create "config" file to seem more authentic
echo "[default]" > "$filepath/config"
echo "region = us-east-1" >> "$filepath/config"
echo "output = json" >> "$filepath/config"

# for security reasons, we should unset/wipe all variables that contained an auth token, or evidence of Canary/Canarytokens
unset console
unset token
unset tokenmemo
unset flock
unset ping
unset flockid
unset filename

#delete the file (which contains a token)
rm $(dirname $(readlink -f $0))/$(basename $0)

exit
