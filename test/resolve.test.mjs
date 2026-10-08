// The one thing that can silently break this plugin is the !!js expression in
// cordis.patch.yml: it resolves the bundled skill root from the installed npm
// identity anchored at the DSH profile. If it throws or resolves elsewhere, the
// skill disappears from every session with no error the user would see.
//
// This reads the SHIPPED expression out of the patch file and runs it the way
// the loader does, against a fake profile that links this package. Run it after
// touching package.json, the patch, or the skills/ layout:
//
//   node test/resolve.test.mjs
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, symlinkSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import assert from 'node:assert/strict';

const root = dirname(dirname(fileURLToPath(import.meta.url)));

const patch = readFileSync(join(root, 'cordis.patch.yml'), 'utf8');
const expr = patch.match(/bundledSkillDir:\s*!!js\s*(.+)$/m)?.[1];
assert.ok(expr, 'cordis.patch.yml has no `bundledSkillDir: !!js <expr>` line');

const manifest = JSON.parse(readFileSync(join(root, 'package.json'), 'utf8'));
const name = manifest.name;

// A stand-in for the DSH profile directory: `createRequire(baseUrl)` must find
// this package the way an installed bundle is found.
const profile = mkdtempSync(join(tmpdir(), 'amwh-profile-'));
try {
  mkdirSync(join(profile, 'node_modules'));
  symlinkSync(root, join(profile, 'node_modules', name), 'dir');

  // Run the shipped expression verbatim, with `baseUrl` bound the way the loader binds it.
  const dir = new Function('baseUrl', `return ${expr}`)(profile + '/');

  assert.equal(dir, join(root, 'skills'), 'bundledSkillDir resolved to the wrong directory');
  assert.ok(existsSync(join(dir, 'answer-me-with-html', 'SKILL.md')), 'the skill has no SKILL.md');
  assert.ok(existsSync(join(dir, 'answer-me-with-html', 'scripts', 'am.mjs')), 'the skill has no am.mjs CLI');

  const fm = readFileSync(join(dir, 'answer-me-with-html', 'SKILL.md'), 'utf8').split('---')[1];
  assert.match(fm, /^name:\s*answer-me-with-html$/m, 'SKILL.md name must be the kebab-case skill name');
  assert.match(fm, /^description:/m, 'SKILL.md needs a description or the provider skips it');

  console.log('ok — bundledSkillDir:', dir);
} finally {
  rmSync(profile, { recursive: true, force: true });
}
