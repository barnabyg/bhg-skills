---
name: push
description: Push the current task branch, open or reuse its pull request, merge when checks are green, and clean up after the merge. Use for requests covering the full PR workflow.
---

# Push

1. Identify the task branch and intended base. Follow repository guidance and the global pre-push verification policy. Include only the task's changes. Push the branch and reuse its open PR if one exists. Use the `pr` skill when writing a PR body.
2. Monitor CI for the latest PR commit until it succeeds or a concrete blocker requires the user. Diagnose failures and fix those within the task's scope, then check the new commit. Where the repository has no CI, use the repository's full local verification as the gate. Merge once verification is green and repository merge requirements are met. Recheck the head commit before merging and use the repository's allowed merge method, respecting the user's history rules.
3. Confirm the merge through the hosting service. Follow the global AGENTS.md post-merge cleanup guidance. Verify that the merged work is preserved before removing or archiving task-owned branches, worktrees, or other resources. Report the PR link, the branch pushed, the merge outcome, and anything retained or blocked.
