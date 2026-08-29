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

max-turns: 8
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

## Rules

Inspect only repository files needed to implement the task.

Prefer the built-in file inspection and edit tools over shell commands.

Make only changes required by the acceptance criteria.

Do not modify workflows, configuration, dependencies, package manifests,
documentation, or unrelated files.

Preserve existing behavior unless the Issue explicitly requires changing it.

After implementation, run exactly:

`npm test`

Do not run the test suite repeatedly unless a test fails and you subsequently
change the implementation.

Before finishing, verify that the resulting diff contains only changes required
by the Issue.

If every acceptance criterion is satisfied and tests pass, create exactly one
pull request using the configured Safe Output.

The pull request must state:

- what changed;
- tests executed;
- acceptance criteria satisfied.

Do not merge the pull request.

If implementation cannot be completed safely within these constraints,
report the blocker instead of making unrelated changes.
