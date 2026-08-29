---
on:
  label_command:
    name: agent-build
    events: [issues]

permissions:
  contents: read

engine:
  id: copilot
  env:
    COPILOT_PROVIDER_BASE_URL: https://omniroute-cvr6.srv1921690.hstgr.cloud/v1
    COPILOT_PROVIDER_API_KEY: ${{ secrets.OMNIROUTE_API_KEY }}
    COPILOT_PROVIDER_TYPE: openai
    COPILOT_MODEL: build-combo

models:
  default-ai-credits-pricing:
    input: 0.000001
    output: 0.000001

max-turns: 12
timeout-minutes: 10

tools:
  timeout: 180

  edit:

  cli-proxy: true

  bash:
    - "npm test"
    - "git status"
    - "git status:*"
    - "git diff"
    - "git diff:*"
    - "safeoutputs:*"

network:
  allowed:
    - defaults
    - omniroute-cvr6.srv1921690.hstgr.cloud

safe-outputs:
  create-pull-request:
    max: 1
    title-prefix: "[agent] "
    fallback-as-issue: false
    protected-files: blocked
    allowed-files:
      - "src/**"
      - "test/**"
---

# BUILD

Implement the GitHub Issue below.

The Task section is the complete canonical requirement.
Do not query GitHub to rediscover the Issue.

## Task

${{ steps.sanitized.outputs.text }}

## Execution

Work directly in the checked-out repository.

1. Identify only the files needed for this task.
   - If the task names a file explicitly, open it directly.
   - Do not repeatedly search the repository.
   - Use at most one discovery/search pass when file locations are unknown.
   - Batch independent file reads in the same turn.

2. Inspect only the source and tests relevant to the acceptance criteria.
   - Do not inspect README files, git history, package manifests, configuration,
     or unrelated files unless they are directly required by the task.
   - The required test command for this workflow is already known: `npm test`.

3. Make the minimum code and test changes required.

4. Validate once after the final edit:
   - run `npm test`;
   - verify the resulting diff contains only required changes;
   - verify `git diff --check` succeeds.

5. If validation succeeds, immediately call the configured
   `create_pull_request` Safe Output.

## Git rules

Do NOT:

- create or switch branches;
- run `git add`;
- run `git commit`;
- run `git push`;
- inspect git history;
- inspect the latest commit after editing;
- repeatedly inspect git status;
- re-read files solely to confirm edits already shown by the edit tool.

The `create_pull_request` Safe Output is responsible for staging,
committing, pushing and creating the pull request.

## Pull request

Create exactly one pull request.

Its body must state:

- what changed;
- tests executed;
- acceptance criteria satisfied.

Do not merge the pull request.

If implementation or validation fails, report the blocker rather than making
unrelated changes.
