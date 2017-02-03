#!/bin/bash
set -euo pipefail

CLIMB_USER=climb
CLIMB_SERVER=climb.gg

LOCAL_PATH=$CIRCLE_ARTIFACTS
REMOTE_PATH="/data/fifth-drake/staging"

# The 141 avoids
# http://stackoverflow.com/questions/22464786/ignoring-bash-pipefail-for-error-code-141
ARTIFACT_LOCAL=$(find $LOCAL_PATH -name *.zip | head -n 1 || [ $? -eq 141 ])
ARTIFACT_NAME=$(basename $ARTIFACT_LOCAL)
ARTIFACT_REMOTE="$REMOTE_PATH/$ARTIFACT_NAME"

EXECUTABLE_REMOTE="${ARTIFACT_REMOTE/.zip/}/bin/fifth-drake"

echo "Copying artifact to server"
scp $ARTIFACT_LOCAL $CLIMB_USER@$CLIMB_SERVER:$ARTIFACT_REMOTE

echo "Unziping artifact"
ssh $CLIMB_USER@$CLIMB_SERVER unzip -ud $REMOTE_PATH $ARTIFACT_REMOTE

echo "Killing any previous running servers"
ssh $CLIMB_USER@$CLIMB_SERVER \
	find $REMOTE_PATH -name RUNNING_PID \| \
	xargs cat \| \
	xargs -r kill

echo "Ensuring log path exists"
ssh $CLIMB_USER@$CLIMB_SERVER \
	mkdir -p $REMOTE_PATH/logs

echo "Running the new server"
ssh $CLIMB_USER@$CLIMB_SERVER \
  cd $REMOTE_PATH \; \
  nohup $EXECUTABLE_REMOTE \
    -Dclimb.pgDbName="league_analytics" \
	-Dclimb.pgUserName="climb" \
	-Dclimb.pgPassword="fukenny" \
	-Dplay.crypto.secret="thisissimplystaging" \
	 \> $REMOTE_PATH/logs/${ARTIFACT_NAME/.zip/}.log \
	2\> $REMOTE_PATH/logs/${ARTIFACT_NAME/.zip/}.err \
	1\< /dev/null \&

