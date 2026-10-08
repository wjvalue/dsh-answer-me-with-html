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
> skill left in either directory then shadows this one. Delete it (`rm -rf ~/.agents/skills/answer-me-with-html`)
> if both are enabled.

## Updating the skill

`skills/answer-me-with-html/` is a verbatim copy of the upstream `skills/answer-me-with-html` folder, so an
update is a copy, not a merge:

```bash
git clone --depth 1 https://github.com/QingYunA/answer-me-with-html.git /tmp/amwh
rm -rf skills/answer-me-with-html
cp -R /tmp/amwh/skills/answer-me-with-html skills/
```

## License

MIT. The vendored skill and CLI are MIT, © QingYunA — see [LICENSE](LICENSE).
