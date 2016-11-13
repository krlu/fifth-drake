#!/bin/bash

set -euo pipefail

CLIMB_USER=CLIMB
CLIMB_SERVER=climb.gg

LOCAL_PATH=$CIRCLE_ARTIFACTS
REMOTE_PATH="/data/fifth-drake"

# The 141 avoids
# http://stackoverflow.com/questions/22464786/ignoring-bash-pipefail-for-error-code-141
ARTIFACT_LOCAL=$(find $LOCAL_PATH -name *.zip | head -n 1 || [ $? -eq 141 ])
ARTIFACT_NAME=$(basename $ARTIFACT_LOCAL)
ARTIFACT_REMOTE="$REMOTE_PATH/$ARTIFACT_NAME"

EXECUTABLE_REMOTE="${ARTIFACT_REMOTE/.zip/}/bin/fifth-drake"

scp $ARTIFACT_LOCAL $CLIMB_USER@$CLIMB_SERVER:$ARTIFACT_REMOTE
ssh $CLIMB_USER@$CLIMB_SERVER unzip -d $REMOTE_PATH $ARTIFACT_REMOTE

# Kill any previous running servers
ssh $CLIMB_USER@$CLIMB_SERVER \
	find $REMOTE_PATH -name RUNNING_PID \| \
	xargs cat \| \
	kill

# run the new server
ssh $CLIMB_USER@$CLIMB_SERVER nohup EXECUTABLE_REMOTE \
	-Dplay.cryto.secret="thisissimplystaging" \
	\> $REMOTE_PATH/logs/${ARTIFACT_NAME/.zip/}.log
