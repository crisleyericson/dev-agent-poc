---
on:
  workflow_dispatch:

permissions:
  contents: read

engine:
  id: copilot
  env:
    COPILOT_PROVIDER_BASE_URL: https://omniroute-cvr6.srv1921690.hstgr.cloud/v1
    COPILOT_PROVIDER_API_KEY: ${{ secrets.OMNIROUTE_API_KEY }}
    COPILOT_PROVIDER_TYPE: openai
    COPILOT_MODEL: build-combo

network:
  allowed:
    - defaults
    - omniroute-cvr6.srv1921690.hstgr.cloud
---

This is a connectivity smoke test.

Do not modify any files.
Do not create commits, branches, issues, or pull requests.

Read the repository name and README if needed.

Your final response must contain exactly:

OMNIROUTE_BYOK_OK
