# dsh-answer-me-with-html

[Answer me with HTML](https://github.com/QingYunA/answer-me-with-html) as a DeepSeek Harness plugin: an
opt-in, skill-only bundle that answers hard questions with a one-page HTML you can actually read.

The model writes a short Markdown draft; the bundled `am` CLI writes the CSS, the layout and the SVG
diagram coordinates. About 1/8 of the tokens of hand-written HTML.

## What is in here

| Path | Role |
|---|---|
| `cordis.patch.yml` | The only row: a dedicated `@deepseek-ai/dsh-skill-filesystem` provider whose single root is `skills/` |
| `skills/answer-me-with-html/` | The upstream skill, vendored verbatim — `SKILL.md`, `references/`, and the dependency-free `scripts/am.mjs` CLI |
| `scripts/update-skill.sh` | Re-vendors the folder above from upstream and checks it (`npm test`) |

There is no Host code. The skill reaches the session catalog through the bundled skill root, so nothing
is copied into `~/.dsh/skills` and no other profile is affected.

## Install

```bash
dsh plugin --profile <name> add /path/to/dsh-answer-me-with-html
```

Or install it from the plugin market / settings UI by pointing at the same directory.

## Requirements

- Node.js 20+ (the `am` CLI runs as `node <skill dir>/scripts/am.mjs`; no `npm install` step).
- Pages are written to `~/.answer-me-with-html/pages/`.

## Use

Ask a question the way you always do. The skill decides when a page is worth it:

> Explain the TCP three-way handshake
> Redis or Memcached for our cache?

The skill name is `answer-me-with-html`, and DSH passes its own base directory into the loaded skill, so
the `${CLAUDE_SKILL_DIR}` placeholders in `SKILL.md` need no edit.

> **One trap:** if you also enable the default `@deepseek-ai/dsh-skill-filesystem` provider, it scans
> `~/.dsh/skills` and `~/.agents/skills` at a higher rank than this bundle's root. An older copy of this
> skill left in either directory then shadows this one — a stale copy, silently.
>
> Before deleting that copy, check what else points at it:
>
> ```bash
> ls -la ~/.dsh/skills ~/.agents/skills ~/.claude/skills 2>/dev/null | grep answer-me-with-html
> ```
>
> `~/.agents/skills/answer-me-with-html` is often the real copy for other agents (Claude Code, ZCode,
> Hermes and WorkBuddy typically symlink to it), so deleting it breaks those. Either leave the default
> provider off — it is off unless something enables it — or update the shared copy too instead of
> removing it.

## Updating the skill

`skills/answer-me-with-html/` is a verbatim copy of the upstream `skills/answer-me-with-html` folder, so an
update is a copy and not a merge:

```bash
scripts/update-skill.sh
```

It clones upstream, and if the copy already matches, says so and exits without touching anything.
Otherwise it re-copies the folder, moves `package.json`'s version to the vendored CLI's version, and runs
the tests. It prints the upstream commit — put that hash in the commit message, because upstream has
shipped code changes without a version bump, and the hash is what identifies the vendored state.

> **The CLI's own update hint is wrong here.** After a week `am render` may print
> `! Update hint: Answer me with HTML <v> is available ... run npx skills update answer-me-with-html -y`.
> That command belongs to [vercel-labs/skills](https://github.com/vercel-labs/skills) and updates a copy
> in `~/.agents/skills` — never the copy this plugin serves. It cannot update this plugin; run
> `scripts/update-skill.sh` in this repository instead. Upstream has no DeepSeek Harness branch for this
> (checked in 0.5.0), so the hint keeps saying it.

## License

MIT. The vendored skill and CLI are MIT, © QingYunA — see [LICENSE](LICENSE).
