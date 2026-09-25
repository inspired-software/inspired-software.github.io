#!/bin/zsh
# Build the site and serve Output/ at http://localhost:4000
#
#   tools/preview.sh
#
# After an edit, rebuild with `swift run` in another tab and refresh.
# For rebuild-on-save with automatic browser reload instead, install Saga's
# command-line tool (`brew install loopwerk/tap/saga`) and run `saga dev`.
set -e
cd "$(dirname "$0")/.."
swift run
echo "serving http://localhost:4000"
exec python3 -m http.server 4000 --bind 127.0.0.1 --directory Output
