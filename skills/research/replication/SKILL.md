---
name: replication
description: Use this when the task is to reproduce a paper result, benchmark a claim, rebuild an experiment, or evaluate whether a published result holds in practice.
---

# Replication

## When To Use

Use this skill for:
- paper reproduction
- benchmark recreation
- ablation reruns
- claim verification through code and experiments

## Procedure

1. Identify the canonical source paper and inspect it with `alpha_get_paper`.
2. Extract the exact target:
   - task
   - dataset
   - model or method
   - metrics
   - hardware or runtime assumptions
3. Use `alpha_ask_paper` to pull out the exact details missing from the report.
4. If the paper has a public repository, inspect it with `alpha_read_code`.
5. Search the local workspace for existing code, notebooks, configs, and datasets.
6. Write down the missing pieces explicitly before running anything.
7. If the environment is sufficient, implement the minimal runnable reproduction path.
8. Run the experiment with built-in file and shell tools.
9. Save:
   - commands used
   - configs
   - raw outputs
   - summarized results
10. Compare observed results with the paper and explain gaps.
11. If the paper had a practical gotcha, attach it with `alpha_annotate_paper`.

## Pitfalls

- Do not claim replication succeeded if key conditions were missing.
- Do not compare different metrics as if they were equivalent.
- Do not ignore dataset or preprocessing mismatch.
- Do not hide failed runs; record them and explain them.

## Verification

A good replication outcome includes:
- the exact command path
- the data or config used
- the observed metrics
- a clear statement of match, partial match, or mismatch
