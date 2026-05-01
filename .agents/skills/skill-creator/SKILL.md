---
name: skill-creator
description: Use when the user wants to create, improve, refactor, or document a Codex skill. Helps design scoped, reusable SKILL.md files with clear triggers, workflow, inputs, outputs, validation, and optional scripts/assets.
---

# Skill Creator

## Purpose

Create practical, scoped, reusable Codex skills that can be reliably triggered and executed across repeated workflows.

## When to Use

Use this skill when:
- The user asks to create a new skill folder and `SKILL.md`.
- The user asks to improve or refactor an existing skill definition.
- The user asks to document a skill with clearer triggers, boundaries, or validation.
- The user wants a reusable workflow instead of a one-off prompt.

## When Not to Use

Do not use this skill when:
- The request is a one-time task with no reusable workflow value.
- The user needs implementation work in project code, not skill authoring.
- The user asks for broad “general helper” behavior without a narrow domain.

## Required Inputs

Collect or infer:
- Target skill goal and repeated workflow.
- Scope boundaries (what the skill should and should not do).
- Intended trigger phrases or situations.
- Target folder path (default: `.agents/skills/<skill-name>/`).
- Required output format and validation expectations.

## Workflow

1. Inspect user prompt and existing repository context for naming and conventions.
2. Infer the repeated workflow, expected outputs, and common failure modes.
3. Define a narrow skill scope and write a trigger-oriented description.
4. Draft or update `SKILL.md` using the required sections and explicit boundaries.
5. Add optional folders (`references/`, `scripts/`, `assets/`) only if they clearly improve reliability.
6. Validate the skill against the checklist before finalizing.

## Output Format

Return:
- Suggested folder path: `.agents/skills/<skill-name>/`.
- Complete `SKILL.md` content (full file, not fragments).
- List of created or modified files.
- Brief validation summary confirming checklist compliance.

## Quality Rules

- Use lowercase kebab-case for skill names.
- Keep the description specific, concise, and trigger-oriented.
- Preserve repository conventions and avoid unnecessary abstractions.
- Prefer instruction-only skills unless scripts materially improve consistency.
- Do not invent paths, APIs, or files without checking context.
- Minimize questions; ask only when ambiguity blocks execution.

## Safety and Quality Rules

- Avoid creating “do-everything” skills with vague scope.
- Prevent overlap with unrelated workflows by defining clear “when not to use”.
- Keep instructions deterministic enough for repeated execution.
- Require explicit validation before considering the skill complete.
- Ensure optional automation artifacts are justified, minimal, and maintainable.

## Validation Checklist

Before finishing, verify:
- The skill has a narrow and reusable purpose.
- The description contains clear trigger words and boundaries.
- The workflow is repeatable and actionable.
- Required inputs are explicit or inferable.
- Output format is complete and unambiguous.
- Optional folders are included only when justified.
- Naming follows lowercase kebab-case.
