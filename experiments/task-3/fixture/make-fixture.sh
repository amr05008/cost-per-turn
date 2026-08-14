#!/usr/bin/env bash
# Freeze the real commit log for GlutenOrNot iOS 1.4.0 into the fixture.
# Verbatim public history — no edits, no injected defects. Regenerate with:
#   ./make-fixture.sh ~/repos/glutenornot.com
set -euo pipefail
REPO=${1:-$HOME/repos/glutenornot.com}
git -C "$REPO" log v1.3.0..v1.4.0 --format='commit %h%nAuthor date: %ad%nSubject: %s%n%n%b%n---' --date=short \
  > "$(dirname "$0")/changelog.txt"
wc -w "$(dirname "$0")/changelog.txt"
