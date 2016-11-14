#!/bin/bash
set -euo pipefail

if [ -d ./node_modules ]; then
	echo "Node modules already installed. Skipping..."
else
	npm install
fi

if [ -d ./elm-stuff ]; then
	echo "Elm packages already installed. Skipping..."
else
	elm package install -y
fi
