#!/usr/bin/env bash
# Writes data/repos.json: the owner's public repos that have GitHub Pages enabled.
#
# Usage:   scripts/fetch-repos.sh [owner]
#          (owner defaults to $GITHUB_REPOSITORY_OWNER, which Actions sets)
# Needs:   gh (authenticated; in Actions set GH_TOKEN) and jq
# Opt-in:  REQUIRED_TOPIC=showcase scripts/fetch-repos.sh
#          keeps only repos carrying that GitHub topic.
#
# Always excluded: forks, archived repos, and this homepage repo itself.
set -euo pipefail

owner="${1:-${GITHUB_REPOSITORY_OWNER:-}}"
if [[ -z "$owner" ]]; then
  echo "usage: $0 <github-owner>" >&2
  exit 1
fi
topic="${REQUIRED_TOPIC:-}"

out="$(cd "$(dirname "$0")/.." && pwd)/data/repos.json"
mkdir -p "$(dirname "$out")"

# --paginate emits one JSON array per page; jq -s collects them and .[][] flattens.
gh api --paginate "users/${owner}/repos?type=owner&per_page=100" \
  | jq -s \
      --arg owner "$owner" \
      --arg topic "$topic" \
      --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
    [ .[][]
      | select(.has_pages and (.private | not) and (.fork | not) and (.archived | not))
      | select((.name | ascii_downcase) != (($owner + ".github.io") | ascii_downcase))
      | select($topic == "" or (.topics | index($topic)))
      | {name, description, language, html_url, pushed_at, topics}
    ] as $repos
    | {owner: $owner, generated_at: $now, repos: $repos}
  ' > "$out"

echo "wrote $out ($(jq '.repos | length' "$out") repos)"
