---
name: experiment-design
description: Use this when the task is to turn a vague research idea into a testable experiment, define metrics, choose baselines, or plan ablations.
---

# Experiment Design

## When To Use

Use this skill when the user has:
- a hypothesis to test
- a method to evaluate
- an unclear benchmark plan
- a need for baselines, ablations, or metrics

## Procedure

1. Restate the research question as a falsifiable claim.
2. Define:
   - independent variables
   - dependent variables
   - success metrics
   - baselines
   - constraints
3. Search for prior work first with `alpha_search` so you do not reinvent an obviously flawed setup.
4. Use `alpha_get_paper` and `alpha_ask_paper` on the strongest references.
5. Prefer the smallest experiment that can meaningfully reduce uncertainty.
6. List confounders and failure modes up front.
7. If implementation is requested, create the scripts, configs, and logging plan.
8. Write the plan to disk before running expensive work.

## Pitfalls

- Avoid experiments with no baseline.
- Avoid metrics that do not connect to the claim.
- Avoid ablations that change multiple variables at once.
- Avoid broad plans that cannot be executed with the current environment.

## Deliverable

Produce:
- hypothesis
- setup
- baselines
- metrics
- ablations
- risks
- next action
