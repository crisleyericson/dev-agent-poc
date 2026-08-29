---
on:
  slash_command:
    name: build
    events: [issues, issue_comment]

permissions:
  contents: read
  issues: read

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

tools:
  edit:
  bash:
    - "git:*"
    - "node:*"
    - "npm:*"
    - "cat"
    - "ls"
    - "pwd"
  github:
    toolsets: [repos, issues]

network:
  allowed:
    - defaults
    - node
    - omniroute-cvr6.srv1921690.hstgr.cloud

safe-outputs:
  create-pull-request:
    title-prefix: "[agent] "
    protected-files: fallback-to-issue
    allowed-files:
      - "src/**"
      - "test/**"
      - "package.json"
---

Implement the task described in the triggering GitHub issue.

Requirements:

1. Read the complete issue and its acceptance criteria.
2. Inspect the existing repository before changing anything.
3. Make only the changes required by the issue.
4. Run the existing test suite with `npm test`.
5. Do not modify files outside the allowed application files.
6. Do not modify GitHub workflows.
7. Do not merge anything.
8. If implementation and tests succeed, create a pull request using the configured safe output.
9. The pull request must explain:
   - what changed;
   - which tests were executed;
   - whether all acceptance criteria were satisfied.
10. If the task cannot be completed safely, report the blocker instead of inventing a solution.
