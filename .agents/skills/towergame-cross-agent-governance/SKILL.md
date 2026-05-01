---
name: towergame-cross-agent-governance
description: Use when multiple AI agents (Codex, Claude, Copilot or similar) contribute to TowerGame, enforcing a shared delivery contract for branching, code quality, testing, and reporting.
---

# TowerGame Cross Agent Governance

## Purpose

Padronizar como agentes diferentes devem trabalhar neste repositorio para evitar conflito de abordagem, quebra de caminho, regressao funcional e entrega sem validacao.

## When to Use

Use this skill when:
- Mais de um agente pode atuar no projeto (ex.: Codex, Claude, Copilot).
- O usuario pede regras comuns para qualquer agente seguir.
- Ha tarefas de refactor, gameplay ou PR com alto risco de regressao.

## When Not to Use

Do not use this skill when:
- A tarefa for local/trivial e sem colaboracao entre agentes.
- O usuario definir um protocolo diferente e explicito para aquele turno.

## Mandatory Contract For Any Agent

Todo agente deve:
- Trabalhar em branch dedicada (prefixo `codex/` quando aplicavel).
- Usar Conventional Commits.
- Evitar mudancas destrutivas sem pedido explicito.
- Preservar padroes de clean code e responsabilidade unica por modulo.
- Atualizar paths `res://` com seguranca ao mover arquivos.
- Rodar validacao minima antes de handoff.
- Reportar arquivos alterados, testes rodados e riscos restantes.

## Workflow

1. Confirmar escopo e limites tecnicos da tarefa.
2. Mapear impacto em scripts/cenas/recursos/autoload.
3. Implementar alteracoes pequenas e rastreaveis.
4. Atualizar referencias e dependencias afetadas.
5. Rodar validacao (usar skill `towergame-post-change-mechanics-guard`).
6. Entregar resumo objetivo:
- o que mudou,
- por que mudou,
- como foi validado,
- o que ainda pode quebrar.

## Output Format

Return:
- Escopo executado.
- Lista de arquivos alterados.
- Commits aplicados (Conventional Commit).
- Validacoes e resultado (PASS/FAIL/NAO VALIDADO).
- Pendencias/riscos para proxima iteracao.

## Safety and Quality Rules

- Nao commitar sem explicar impacto tecnico.
- Nao afirmar estabilidade sem evidencias de validacao.
- Nao ocultar falhas ou testes nao executados.
- Nao duplicar logica se for possivel reutilizar modulo existente.

## Validation Checklist

Before finishing, verify:
- Regras de branch e commit foram cumpridas.
- Mudancas seguem responsabilidade clara por pasta/modulo.
- Validacao funcional minima foi executada.
- Entrega final permite continuidade por qualquer outro agente.
