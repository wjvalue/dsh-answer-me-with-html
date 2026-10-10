#!/bin/bash
# Publish dsh-answer-me-with-html to npm.
#
# Run this in your own terminal. It opens the npm login page in your browser,
# waits for you to authorise, then publishes. One step, no copying links back
# and forth.
#
#   bash "/Users/wangjian/dsh-pj/normal staff/answer-me-with-html/scripts/publish-to-npm.sh"
#
# npm's web-login session only lives about 4 minutes, so this keeps the session
# and the browser opening in the same process. If it times out, run it again.
set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if npm whoami >/dev/null 2>&1; then
  echo "already logged in as $(npm whoami)"
else
  echo "npm token is missing or expired — starting a browser login."
  npm login --auth-type=web || { echo "login failed"; exit 1; }
  npm whoami || { echo "login did not stick"; exit 1; }
fi

cd "$repo"
echo
echo "publishing $(node -p "require('./package.json').name + '@' + require('./package.json').version")"
npm publish --access public
