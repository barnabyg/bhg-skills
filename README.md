# BHG Skills

Barnaby Golden's personal Codex skills. This repository holds the source files;
local installations link directly to them, so edits and Git updates take effect
without copying files again.

## Install

Requires Git and Bash on macOS or Linux.

```sh
git clone https://github.com/barnabyg/bhg-skills.git
cd bhg-skills
./scripts/install.sh
```

The installer links each skill into `~/.agents/skills`, Codex's documented personal
skill directory. It is safe to rerun and refuses to replace existing directories,
files, or links to other locations. If a conflict is reported, inspect that
existing installation and move it aside yourself before retrying.

To use another discovery directory:

```sh
./scripts/install.sh --target /absolute/path/to/skills
```

Codex detects skill changes automatically. Restart Codex if they do not appear.
See the [official skill documentation](https://learn.chatgpt.com/docs/build-skills)
for discovery locations and symlink support.

## Available skills

| Skill | Purpose |
| --- | --- |
| [setup-project-hygiene](skills/setup-project-hygiene/SKILL.md) | Install and verify a project-specific hygiene cycle after five completed implementation tickets. |
| [project-hygiene](skills/project-hygiene/SKILL.md) | Audit documentation, tests, and agent onboarding, then file actionable GitHub backlog issues. |
| [push](skills/push/SKILL.md) | Push a task branch, open or reuse its PR, merge when checks pass, and clean up. |

In a project chat, ask:

```text
Use $setup-project-hygiene to set up the hygiene cycle for this project.
```

For a manual audit:

```text
Use $project-hygiene to audit this project and add evidence-backed hygiene issues to GitHub.
```

Installing these skills makes the workflows available. It does not enable a
project's automatic audits; run the setup skill in each project for that.

## Maintain

Edit the skill files in this checkout, then commit and push here. To update another
machine, run `git pull --ff-only` in its checkout. After adding a skill folder under
`skills/`, rerun the installer. Keep this checkout in place while its links are
installed; if you move it, remove its old links and run the installer again.

Keep both hygiene skills installed together: setup uses the audit skill's shared
cycle contract. Each new skill needs its own `skills/<name>/SKILL.md`.

To uninstall, remove only this repository's symlinks from the discovery directory.
The source files remain in this checkout.
