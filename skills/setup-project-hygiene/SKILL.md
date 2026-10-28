---
name: setup-project-hygiene
description: Install, update, or repair a repository's recurring project hygiene cycle, including its ticket threshold, audit runner, hooks or completion trigger, and retry state. Use for project setup, not an individual audit or the resulting fixes.
---

# Set up project hygiene

Install a working project-specific cycle that dispatches `project-hygiene` after five completed implementation tickets and files useful GitHub backlog issues. The companion audit skill must be installed alongside this skill.

Read [the shared cycle contract](../project-hygiene/references/cycle-contract.md) before implementing configuration or runtime behavior. Read the companion [audit skill](../project-hygiene/SKILL.md) when preparing its runner instructions. Keep the contract as the single source of truth for checkpoint and publication semantics.

## Discover the project

Inspect repository instructions, Git remotes/default branch, existing hooks and CI, ticket labels/completion conventions, test commands and timing reports, and any existing hygiene installation. Resolve the intended repository from that evidence before asking for information.

Confirm which tickets represent completed implementation work. Prefer closed GitHub issues with completion reason `completed`, with exclusions for hygiene/control work and the project's cancelled/duplicate conventions. When completed issues do not map reliably to shipped work, use merged linked PRs as an additional eligibility condition. Ask only if competing conventions would materially change what is counted.

Reuse an installed cycle and preserve its state. A setup rerun must not reset the baseline, consume pending tickets, or duplicate hooks. Keep unrelated hook definitions, agent instructions, and working-tree edits intact.

## Choose and prepare the trigger

Default to a fast session-start check for this user's workflow. If the project already has a reliable ticket-completion workflow, prefer adding the check there. Implement one automatic trigger unless an additional trigger serves a demonstrated need.

For Codex hooks, use current official documentation through the available OpenAI Docs skill before editing the hook schema. Inspect both project and user hooks to avoid duplicate execution. Merge into the project's existing hook representation. Match startup/resume rather than compaction or subagent events, and suppress the check in the audit worker. A local hook runs a command; it is not an agent scheduler by itself.

Prepare the check, runner, and configuration before enabling the hook. The checker obtains qualifying tickets, compares them with the durable state, and dispatches at most one isolated audit. It should return promptly and let ordinary work continue after an offline/API/runner failure, while leaving an actionable diagnostic and pending work intact.

The audit must run outside the user's active ticket turn. Use the project's available authenticated runner, such as a local Codex CLI worker or an existing CI agent job. Verify actual executable capabilities, authentication, noninteractive permissions, and skill discovery. Pass a bounded task scoped to the configured repository and audit snapshot. Do not copy credentials into project files or assume a CLI inherits desktop connector credentials.

A local worker needs an independent process lifecycle, captured diagnostics, an isolated checkout, a recursion guard, and cleanup. In CI, use the project's secret management and a repository concurrency group. If the runner cannot use installed personal skills, package the audit instructions and contract into its environment and track their installed version. Avoid absolute personal paths in committed configuration.

If unattended issue creation or the runner cannot operate with existing authorization, finish the inspectable configuration and keep automatic dispatch disabled. State the specific missing access or capability and the required next action. A notice-only hook is a partial installation, not a working automatic cycle.

## Install the cycle

Create or adapt the following small project artifacts:

- `.codex/hygiene.json`: repository identity, threshold, ticket eligibility/exclusions, runner, audit limits, issue labels, test commands, and state/report locations.
- A deterministic checker and lifecycle helper, using the project's existing scripting language where practical. The helper exposes a read-only status check, dispatch, run claim, success/failure finalization, and a dry-run/test mode.
- A trigger definition and bounded audit runner prompt that loads the audit skill, uses the configured snapshot, publishes issues, and finalizes the run.
- Ignored runtime state/reports or the project's existing durable state backend, plus one short discovery pointer in the appropriate project instructions when useful.

Keep shared audit criteria in the skill; project files contain only project-specific facts and runtime machinery. Use the smallest implementation that meets the contract. Scope publication to hygiene issues in the configured repository; setup does not authorize application changes, PRs, or messages elsewhere.

Seed a fresh installation at the current default-branch commit and currently eligible issue IDs, so the first automatic audit follows the next five completions. Record this as an installation baseline, not a successful audit. An initial baseline audit can be run if the user requests it.

## Verify before enabling

Use temporary state and a fake ticket source/runner to verify observable behavior:

- Four new eligible IDs do nothing; five dispatch one audit.
- Excluded tickets and reopened/reclosed processed IDs do not increase the count.
- Concurrent checks across worktrees dispatch once; an audit worker never triggers itself.
- Setup reruns preserve hooks, baseline, and pending work.
- A failed runner, API outage, or interrupted publication preserves the checkpoint and can retry without duplicate issues.
- A successful zero-finding run consumes exactly the captured pending IDs; tickets completed during it remain pending.

Validate hook/config syntax and run a read-only live status check. Verify the installed runner can access the repository and GitHub without creating a test issue. Only enable dispatch after these checks pass. Distinguish fixture verification from an actual end-to-end audit; never manufacture five live ticket closures to test setup.

Finish with changed paths, the selected ticket rule and trigger, installation baseline, verification results, and any remaining blocker. Give the invocation for a manual audit and show how to inspect status or disable the installed trigger.
