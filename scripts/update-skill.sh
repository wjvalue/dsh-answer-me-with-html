#!/bin/bash
# Re-vendor skills/answer-me-with-html/ from upstream and verify it.
#
# The vendored folder is a verbatim copy, so an update is a copy and not a
# merge — but it must not be a copy that silently changes nothing, and it must
# not leave package.json claiming the old version. This does both:
#
#   scripts/update-skill.sh
#
# Nothing to do exits 0 and says so. After it re-vendors, put the upstream
# commit it printed in the commit message — that hash, not the version, is what
# identifies the vendored state (upstream has shipped code changes without a
# version bump before).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill="$root/skills/answer-me-with-html"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git clone -q --depth 1 https://github.com/QingYunA/answer-me-with-html.git "$tmp/upstream"
upstream="$tmp/upstream/skills/answer-me-with-html"
[ -f "$upstream/SKILL.md" ] || { echo "upstream has no skills/answer-me-with-html/SKILL.md" >&2; exit 1; }

version() { sed -n 's/^var VERSION = "\(.*\)";$/\1/p' "$1/scripts/am.mjs" | head -1; }
before="$(version "$skill")"
after="$(version "$upstream")"

if diff -rq "$skill" "$upstream" >/dev/null 2>&1; then
  echo "up to date — vendored copy is byte-identical to upstream $after"
  exit 0
fi

rm -rf "$skill"
cp -R "$upstream" "$skill"

# package.json carries the vendored version; test/resolve.test.mjs asserts the
# two match, so bump it here rather than leaving that to memory.
node -e '
const fs = require("node:fs");
const [path, version] = process.argv.slice(1);
const manifest = JSON.parse(fs.readFileSync(path, "utf8"));
manifest.version = version;
fs.writeFileSync(path, JSON.stringify(manifest, null, 2) + "\n");
' "$root/package.json" "$after"

npm --prefix "$root" test

echo
echo "re-vendored $before -> $after"
echo "upstream commit: $(git -C "$tmp/upstream" rev-parse HEAD)"
echo "now: review the diff, commit, and push"
