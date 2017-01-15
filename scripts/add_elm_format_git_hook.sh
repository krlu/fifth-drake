#!/bin/bash
# Adds elm format to the repository and adds githook to execute it on commit.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Figure out if we need the mac or linux tar file
KERNAL_NAME=$(uname -s)
if [[ $KERNAL_NAME == "Linux" ]]; then
	OS="linux"
elif [[ $KERNAL_NAME == "Darwin" ]]; then
	OS="mac"
else
	echo "'$KERNAL_NAME' is not a supported kernal."
	exit 1
fi

# Download the tar file and extract elm-format into the bin folder.
ELM_FORMAT_DIR="$SCRIPT_DIR/../bin"
URL="https://github.com/avh4/elm-format/releases/download/0.5.2-alpha/elm-format-0.18-0.5.2-alpha-$OS-x64.tgz"
if ! [ -x "$ELM_FORMAT_DIR/elm-format" ]; then
	echo "Downloading elm-format"
	curl -L -XGET $URL | tar -xzC $ELM_FORMAT_DIR
fi

echo "Adding git precommit hook for elm formatting"
PRECOMMIT_HOOK_SYMLINK_PATH="../../scripts/pre-commit"
HOOK_DIR="$(git rev-parse --show-toplevel)/.git/hooks"
ln -s $PRECOMMIT_HOOK_SYMLINK_PATH $HOOK_DIR
