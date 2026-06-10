# Marten Audit Harness Report

Threat model: Black-box, generation-only, aggregate memorization-risk audit for small/distilled open-weight LLMs. Not proof of individual membership.

Claim strength: demo-only
Samples: 3
Exact recall rate: 0.0000
Partial recall rate: 0.0000
Member-like overlap: 0.0556
Non-member control overlap: 0.0556
Risk score: 0.0000
Bootstrap CI: 0.0000 - 0.0500

Limitations:
- Generation-only overlap is weaker than token-loss or logprob membership inference.
- Matched controls and prompt-visible-token exclusion reduce but do not eliminate false positives.
- Small sample counts should be treated as demo-only.
