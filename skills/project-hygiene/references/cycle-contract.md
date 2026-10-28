# Hygiene cycle contract

Read this when installing the cycle or running a configured audit. These are shared semantics, not a requirement to introduce a service or database.

## Defaults and configuration

Use `.codex/hygiene.json` for versioned project configuration. The installer selects the implementation and records concrete commands/locations; it must not leave placeholder runner commands in an enabled installation.

Defaults:

| Setting | Default |
| --- | --- |
| Threshold | 5 distinct completed implementation tickets |
| Trigger | Session-start check; existing completion workflow when suitable |
| Audit target | Recorded commit on the default branch |
| New issue cap | 3 high-confidence findings per run |
| Audit time budget | 20 minutes, configurable per project |
| Publication | Hygiene issues in the configured GitHub repository |
| Automatic fixes | None |

Record repository host/owner/name, ticket eligibility and exclusions, trigger/runner commands, issue labels, test commands, audit limits, state backend, and report location. Reuse the project's labels where possible; exclude every hygiene and control issue from the ticket count. Keep credentials in the runner's established credential store.

## Eligibility and checkpoints

Track immutable issue IDs, not issue numbers alone or a resettable integer counter. Qualifying issues must be closed as completed under the configured rule. Paginate the entire relevant result set; timestamps may narrow retrieval but must not replace ID deduplication. An API failure or incomplete listing is an unknown status, not zero tickets.

On installation, save the baseline commit and all currently eligible IDs. On subsequent checks, pending work is currently eligible IDs minus baseline IDs and IDs consumed by successful audits. A previously processed issue reopened and reclosed does not count again. Excluded issues never qualify. Changes to eligibility rules require explicit migration of the baseline rather than a silent reset.

When pending count is at least the threshold, capture its eligible IDs, UTC cutoff, and target commit in a run record. Coalesce all captured pending work into one audit even if more than five tickets accumulated. Work arriving after the snapshot remains pending for a later run. This avoids a burst of identical audits after inactivity.

Persist installation baseline, last successful audit commit/cutoff, consumed IDs, pending run metadata, publication ledger, and report location. A fresh installation has no successful audit yet. Success may have zero findings. Failure advances none of the successful checkpoint; it can still record diagnostics and confirmed issue publications.

## State and serialization

For a single-machine installation, use the repository's Git common directory for ignored runtime state, or a repository-keyed state directory shared by its worktrees. Lock the same location across worktrees; individual checkout-local locks are insufficient. Write state atomically and avoid storing it in tracked application files.

A local backend coordinates one machine only. If checks run on several machines or CI workers, use a shared durable backend and repository-wide job serialization before enabling those triggers. A GitHub issue can store a ledger, but its presence alone is not an atomic lock. Record the installed concurrency scope.

Track run ownership and a lease/heartbeat or another verifiable liveness mechanism. Concurrent checks reuse or skip the active run. Recover abandoned runs only after verifying the old worker is inactive or its lease expired; fence old owners from committing a checkpoint. A worker that loses ownership must stop publication. Retry the same run snapshot and ledger after failure where practical.

## Publication and retry

Give each finding a stable marker derived from repository, category, affected logical area, and underlying problem. Exclude run ID and commit SHA from that fingerprint, so unchanged findings match across runs. Store the marker in an issue HTML comment, for example `<!-- project-hygiene:finding=<fingerprint> -->`, and record its originating audit ID separately.

Search open and closed hygiene issues, including earlier manually filed equivalents, before creating a new issue. After a successful write, immediately record its issue ID/URL. After an uncertain response, reconcile by marker before retrying. A new run reuses an existing open finding; a dismissed finding remains suppressed until materially new evidence appears. A resolved finding can recur only with evidence that the problem returned.

Persist a bounded report with inspected scope, commit, measurements, limitations, and issue links. Important findings beyond the issue cap remain in the report for later triage; they do not become speculative issues. Finalize success only after the report and intended issue writes are confirmed. If publication partially succeeds, retry from the saved ledger instead of republishing the successful subset.

## Runner boundaries

The checker determines eligibility and dispatches work; it does not perform the audit in the foreground session. The isolated audit runner reads the skill and project configuration, claims a snapshot, inspects code and tests, files scoped issues, and finalizes state. Set a recursion guard before creating that runner so its session-start hooks cannot dispatch another audit.

Use a clean detached worktree or equivalent checkout at the recorded commit. Run diagnostic tests within that isolation; preserve the developer's active worktree. Inspect test/setup scripts before running them and use existing project execution safeguards. Limit agent time and capture failures. Cleanup must preserve reports, ledger, and unresolved run state.

The trigger's success means dispatch or a no-op check succeeded. Only the worker's successful finalization means an audit completed. Report these states distinctly, including when automatic dispatch remains disabled because authentication or runner support is missing.
