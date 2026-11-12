# sinback.github.io

Source for the homepage at <https://sinback.github.io/>: a [Zola](https://www.getzola.org/) site that lists every public repo with GitHub Pages enabled. A scheduled GitHub Action rebuilds it daily, so a new project appears without anyone touching this repo.

> ## ⚠️ READ THIS FIRST: the daily rebuild will silently stop
>
> **GitHub automatically disables scheduled workflows in a public repo after 60 days with no repository activity.** When that happens:
>
> - the site keeps serving the last build, so nothing looks broken;
> - new projects quietly stop appearing;
> - there is no failing run to notice, because the schedule just stops firing.
>
> **How to notice:** the page footer says *"Project list last refreshed YYYY-MM-DD"*. If that date is old, this is almost certainly why.
>
> **How to fix it:** Actions tab → **Build and deploy homepage** → **Enable workflow**, then **Run workflow** to rebuild now. Any commit to this repo also resets the 60-day clock.
>
> **How to avoid it:** set a calendar reminder for ~45 days out, and remember that any commit here counts as activity.

## How it works

```
scripts/fetch-repos.sh  ->  data/repos.json  ->  zola build  ->  GitHub Pages
 (gh api, filters repos)     (generated, not      (templates/index.html
                              committed)           loops over the list)
```

1. `.github/workflows/deploy.yml` runs on push to `main`, daily on a schedule, and on demand (`workflow_dispatch`).
2. `scripts/fetch-repos.sh` lists the owner's repos with the workflow's built-in `GITHUB_TOKEN` and keeps those that have Pages enabled. It skips forks, archived repos, and this repo itself.
3. Zola reads `data/repos.json` and renders one card per repo. **The repo description is the blurb**, and the link is `https://<owner>.github.io/<repo>/`.
4. The built `public/` directory is deployed to Pages.

Repos don't need to know this site exists. Their own Pages setup (including the Jekyll built-in pipeline, with no workflow at all) is unaffected.

## One-time setup

1. Create a **public** repo named exactly `<your-username>.github.io`. That name is what makes it the root site.
2. Push this project to its `main` branch.
3. Settings → Pages → **Build and deployment → Source: GitHub Actions**.
4. Check `base_url` in `config.toml` matches `https://<your-username>.github.io`.
5. Run the workflow once from the Actions tab to publish.

## Day to day

- **Rebuild now:** Actions tab → *Build and deploy homepage* → **Run workflow**.
- **Edit the intro or "Who is sinback?" blurb:** `content/_index.md`. The heading text and the one-line intro are in its front matter and body.
- **Change the look:** `static/style.css` (colors are the variables at the top) and `templates/`.
- **Descriptions are public copy.** Whatever a repo's GitHub description says is what visitors read, so tidy them before an interview.
- **Opt-in instead of everything:** to show only repos with a given GitHub topic (say `showcase`), uncomment `REQUIRED_TOPIC` in the workflow's "Discover repos" step and add that topic to the repos you want listed.

## Local preview

Requires [Zola](https://www.getzola.org/documentation/getting-started/installation/), the [GitHub CLI](https://cli.github.com/) (`gh auth login`), and `jq`.

```sh
scripts/fetch-repos.sh <your-username>   # writes data/repos.json (gitignored)
zola serve                               # http://127.0.0.1:1111
```

Without `data/repos.json` the page still builds, with a "No project data found" notice where the cards go.

The Zola version CI uses is pinned in `deploy.yml` (`ZOLA_VERSION`). Bump it deliberately when you want a newer one.

## Gotchas

- **Project sites live under a subpath** (`/repo-name/`). An app that loads assets from root-absolute paths like `/assets/app.js` will break there. Use relative paths or configure the app's base path.
- **A new project shows up at the next run**, which is at most a day, or immediately via *Run workflow*.
- **Private repos never appear.** The list comes from the public-repos API.
