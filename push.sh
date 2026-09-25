#!/bin/zsh
# Publish the site: main's Output/ becomes the gh-pages branch, which GitHub
# Pages serves at inspired.software.
#
# It's pushed as a single commit with no history, so the public branch holds
# only what's live now. Earlier builds contain pages hidden for the launch and
# the old contact address, and pushing Output/'s history would publish them.
set -e
cd "$(dirname "$0")"

if [ -n "$(git status --porcelain -- Output)" ]; then
  echo "Output/ has uncommitted changes. Build with \`swift run\`, run tools/check.mjs, and commit first."
  exit 1
fi

source_commit=$(git rev-parse --short main)
snapshot=$(git commit-tree "main:Output" -m "Publish $source_commit")
git push --force origin "${snapshot}:refs/heads/gh-pages"
echo "Published main ($source_commit) to gh-pages."
