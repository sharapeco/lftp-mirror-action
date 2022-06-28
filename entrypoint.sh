#!/bin/sh -l

INPUT_MAX_RETRIES=${INPUT_MAX_RETRIES:-1}
INPUT_SSL_VERIFY_CERT=${INPUT_SSL_VERIFY_CERT:-true}
INPUT_SSL_FORCE=${INPUT_SSL_FORCE:-false}

# "NORMAL:%COMPAT:+VERS-TLS1.0"
#SSL_PRIORITY=${SSL_PRIORITY}

URI=""

if [ ! -n $INPUT_PORT ]; then
    URI=$URI:$INPUT_PORT
fi

#USERNAME
#ARGS
#REMOTE_PATH
#LOCAL_PATH

ARGS="${INPUT_MIRROR_ARGS}"

SSH_KEY=./.ssh/id_dsa_deploy

mkdir -p ./.ssh && chmod 700 ./.ssh
echo "${INPUT_SSH_PRIVATE_KEY}" > $SSH_KEY && chmod 600 $SSH_KEY

lftp <<- TRANSFER
    set net:max-retries ${INPUT_MAX_RETRIES}
    set ssl:priority ${INPUT_SSL_PRIORITY}
    set ssl:verify-certificate ${INPUT_SSL_VERIFY_CERT}
    set ftp:ssl-force ${INPUT_SSL_FORCE}
    set sftp:connect-program "ssh -a -x -i $SSH_KEY -o StrictHostKeyChecking=no"
    connect sftp://${INPUT_USERNAME}:@${INPUT_HOST}

    #--reverse sends file to the server from the LOCAL_PATH
    mirror --verbose --reverse $ARGS $INPUT_LOCAL_PATH $INPUT_REMOTE_PATH

    exit
TRANSFER
