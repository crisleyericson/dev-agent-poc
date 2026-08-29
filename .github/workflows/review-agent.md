---
on:
  label_command:
    name: agent-review
    events: [pull_request]

permissions:
  contents: read
  pull-requests: read

checkout:
  fetch-depth: 0

engine:
  id: copilot
  env:
    COPILOT_PROVIDER_BASE_URL: https://omniroute-cvr6.srv1921690.hstgr.cloud/v1
    COPILOT_PROVIDER_API_KEY: ${{ secrets.OMNIROUTE_API_KEY }}
    COPILOT_PROVIDER_TYPE: openai
    COPILOT_MODEL: review-combo

models:
  default-ai-credits-pricing:
    input: 0.000001
    output: 0.000001

max-turns: 12
timeout-minutes: 10

tools:
  timeout: 180

  cli-proxy: true

  bash:
    - "npm test"
    - "git diff"
    - "git diff:*"
    - "safeoutputs:*"

network:
  allowed:
    - defaults
    - omniroute-cvr6.srv1921690.hstgr.cloud

safe-outputs:
  submit-pull-request-review:
    max: 1
    target: triggering
    allowed-events:
      - COMMENT
---

# REVIEW

Perform an independent review of the triggering pull request.

This is a review-only workflow.

Do not modify files.
Do not create branches.
Do not stage or commit files.
Do not push anything.
Do not merge anything.

## Pull request context

${{ steps.sanitized.outputs.text }}

Base commit: `${{ github.event.pull_request.base.sha }}`
Head commit: `${{ github.event.pull_request.head.sha }}`

## Review procedure

1. Inspect the pull request diff using:

   `git diff ${{ github.event.pull_request.base.sha }}...${{ github.event.pull_request.head.sha }}`

2. Inspect only files needed to understand the changed behavior.

3. Evaluate:
   - correctness;
   - acceptance criteria described by the pull request;
   - regressions;
   - test coverage;
   - security issues relevant to the change;
   - unintended changes.

4. Ignore purely stylistic preferences unless they affect correctness,
   maintainability, or established repository conventions.

5. Run the existing test suite exactly once:

   `npm test`

6. Do not fix findings yourself.

## Decision

Choose exactly one status:

`APPROVED`

Use when:
- the implementation satisfies the stated requirements;
- tests pass;
- no blocking defect is found.

`CHANGES_REQUESTED`

Use when:
- there is at least one concrete defect that should be fixed before merge;
- an acceptance criterion is not satisfied;
- the change introduces a regression;
- required test coverage is missing.

`BLOCKED`

Use only when:
- the review cannot be completed reliably because required information,
  repository state, or validation capability is unavailable.

## Output

Submit exactly one pull request review using the configured
`submit_pull_request_review` Safe Output.

The review event must be `COMMENT`.

Submit the review by piping the final JSON directly to the Safe Output CLI.

Do not create a temporary JSON file.
Do not use `cat` redirection, Python, jq, or another helper to construct the payload.
Do not call `--help` to rediscover the schema.

Use exactly these payload fields:
- `event`: `COMMENT`
- `pull_request_number`: `${{ github.event.pull_request.number }}`
- `body`: the complete review body

Pipe the JSON directly using `printf` into:

`safeoutputs submit_pull_request_review .`

The first line of the review body must be exactly one of:

`STATUS: APPROVED`

`STATUS: CHANGES_REQUESTED`

`STATUS: BLOCKED`

Then include:

## Summary

A concise review summary.

## Findings

List concrete findings ordered by severity.

If there are no findings, write:

`No blocking findings.`

## Validation

State which validation was executed and its result.

Do not claim a test or validation was executed unless you actually ran it.
