#!/bin/sh
# Build dist/gtm-setup.zip for the claude.ai skill uploader.
# The ZIP's single top-level entry must be gtm-setup/ (folder name == SKILL.md name).
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
skill=gtm-setup
out="$root/dist/$skill.zip"

[ -f "$root/skills/$skill/SKILL.md" ] || { echo "missing skills/$skill/SKILL.md" >&2; exit 1; }

mkdir -p "$root/dist"
rm -f "$out"
cd "$root/skills"
zip -rq -X "$out" "$skill" -x '*.DS_Store'

# Self-check: every entry sits under gtm-setup/ and SKILL.md is there.
if zipinfo -1 "$out" | grep -v "^$skill/" >/dev/null; then
  echo "bad ZIP: entries outside $skill/" >&2; exit 1
fi
zipinfo -1 "$out" | grep -qx "$skill/SKILL.md" || { echo "bad ZIP: no $skill/SKILL.md" >&2; exit 1; }

echo "Built $out"
