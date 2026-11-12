# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [Zola](https://www.getzola.org/) static site for <https://sinback.github.io/> that auto-lists every public repo of the owner with GitHub Pages enabled. There is no test suite or linter; the "build" is `zola build`.

## Commands

```sh
scripts/fetch-repos.sh <github-username>   # writes data/repos.json (gitignored); needs gh (authenticated) + jq
zola serve                                 # local preview at http://127.0.0.1:1111
zola build                                 # builds into public/ (gitignored)
```

The site builds without `data/repos.json` — the page then shows a "No project data found" notice instead of cards.

## Architecture

The data pipeline (run by `.github/workflows/deploy.yml` on push to main, daily cron, and `workflow_dispatch`):

1. `scripts/fetch-repos.sh` queries the GitHub API (`gh api`) for the owner's repos, keeps those with Pages enabled (excluding forks, archived repos, and this repo itself), and writes `data/repos.json`. Setting `REQUIRED_TOPIC=<topic>` switches to opt-in mode: only repos with that GitHub topic are kept.
2. `templates/index.html` loads `data/repos.json` via Zola's `load_data(required=false)` and renders one card per repo, sorted by `pushed_at` descending. The card link is always `https://<owner>.github.io/<repo>/`; the blurb is the repo's GitHub description.
3. CI uploads `public/` to GitHub Pages.

Key consequence: `data/repos.json` is generated, never committed. Content shown on the site lives in other repos' GitHub metadata (descriptions, topics), not here. The only prose in this repo is `content/_index.md` (hero title/intro in front matter, "Who is sinback?" section in the body).

Other pieces:
- `templates/base.html` — HTML skeleton; `index.html` and `404.html` extend it.
- `static/style.css` — all styling; theme colors are CSS variables at the top.
- `config.toml` — `base_url` must match `https://<username>.github.io`.
- The Zola version CI uses is pinned via `ZOLA_VERSION` in `deploy.yml`; bump deliberately.

## Operational gotchas (from README)

- **GitHub disables the daily cron after 60 days of no repo activity.** The site keeps serving the last build, so the failure is silent — new projects just stop appearing. The footer's "Project list last refreshed" date is the tell. Fix: re-enable and run the workflow from the Actions tab; any commit also resets the clock.
- Project sites are served under a subpath (`/repo-name/`), so root-absolute asset paths in those projects break — but that's a concern for the listed repos, not this one.
- Repo descriptions on GitHub are the public copy visitors read.
