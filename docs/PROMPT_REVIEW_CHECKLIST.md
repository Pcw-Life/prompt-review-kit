# Prompt Review Checklist

For each prompt:
- Purpose: Single, clear objective stated at the top.
- Inputs: All placeholders listed with types and examples.
- Outputs: Expected format (JSON/Markdown), keys, and constraints.
- Constraints: Style, tone, length, temperature/topp details (if applicable).
- Examples: 1–2 quality exemplars or link to fixtures.
- Safety: Refusal/guardrails; avoids revealing system/developer instructions.
- Robustness: Guidance for missing/long/noisy inputs.
- Determinism: Few-shot or structure to stabilize outputs if needed.
- Tokens: Estimated tokens; fits model limits with margin.

For the chain:
- Interfaces: Step N output matches Step N+1 input contract.
- Failure modes: What if parsing fails? Fallback/repair step defined.
- Observability: Log inputs/outputs with PII scrubbing.
- Performance: Cost/latency noted; opportunities to cache/parallelize.
- Tests: Happy-path and at least one adversarial case updated.
