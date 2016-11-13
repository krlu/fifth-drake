#!/bin/bash
set -euo pipefail

PREFIX="$HOME/libsyconfcpus"
INSTALLED="Installed"
NOT_INSTALLED="Not Installed"
STATUS=$(type syconfcpus > /dev/null 2>&1 && echo $INSTALLED || echo $NOT_INSTALLED)

if [ "$STATUS" == "$INSTALLED" ]; then
	echo "libsysconfcpus already installed. Skipping..."
else
	git clone https://github.com/obmarg/libsysconfcpus.git $PREFIX
	pushd $PREFIX
	$PREFIX/configure --prefix=$HOME
	make && make install
	popd
fi
