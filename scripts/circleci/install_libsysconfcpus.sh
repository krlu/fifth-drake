#!/bin/bash
set -euo pipefail

PREFIX="$HOME/libsysconfcpus"

if [ -d $PREFIX ]; then
	echo "libsysconfcpus already installed. Skipping..."
else
	git clone https://github.com/obmarg/libsysconfcpus.git $PREFIX
	pushd $PREFIX
	$PREFIX/configure --prefix=$PREFIX
	make && make install
	popd
fi
