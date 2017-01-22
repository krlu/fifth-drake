#!/bin/bash
set -euo pipefail
BASE_DIR="$(git rev-parse --show-toplevel)/scripts/setup"

usage() {
    echo "Usage: $0 <Riot Games API Key>"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

$BASE_DIR/install_front_end_dependencies.sh
$BASE_DIR/download_champion_icons.sh -a "$1"
$BASE_DIR/add_elm_format_git_hook.sh
