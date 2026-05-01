---
name: towergame-post-change-mechanics-guard
description: Use after any TowerGame code or scene change to validate core mechanics, catch regressions early, and report a clear pass/fail checklist before handoff.
---

# TowerGame Post Change Mechanics Guard

## Purpose

Executar validacao padrao de mecanicas apos qualquer alteracao no TowerGame para evitar regressao de gameplay, progressao ou UI.

## When to Use

Use this skill when:
- Qualquer script, cena, recurso ou autoload for alterado.
- Houver refactor estrutural com mudanca de caminhos.
- Um PR precisar de verificacao funcional antes de merge.
- O usuario pedir confirmacao de que tudo segue funcionando.

## When Not to Use

Do not use this skill when:
- A tarefa nao mudou comportamento de jogo (ex.: docs apenas).
- O usuario pedir explicitamente para pular validacao.

## Required Inputs

Collect or infer:
- Lista de arquivos alterados.
- Comando de smoke headless do Godot no ambiente atual.
- Lista de mecanicas impactadas pelas mudancas.

## Workflow

1. Classificar mudancas:
- combate,
- movimento,
- progressao/hub/portais,
- UI/inventario/status,
- save/load.
2. Rodar smoke headless:
- `Godot_v4.6.2-stable_win64_console.exe --headless --path <repo> --quit`
3. Executar checklist funcional minimo:
- player move/jump/attack;
- dano e morte de inimigo;
- spawn/transicao de floor;
- retorno ao hub;
- toggle de paineis (`C`, `I`);
- fluxo save/continue.
4. Conferir logs/erros de parse, load e resource missing.
5. Reportar resultado objetivo por item (PASS/FAIL) com evidencias.
6. Se houver falha, bloquear handoff ate corrigir ou registrar risco aceito.

## Output Format

Return:
- Escopo validado.
- Resultado do smoke headless.
- Checklist de mecanicas com `PASS` ou `FAIL`.
- Falhas encontradas com arquivo/causa.
- Riscos residuais e recomendacao final.

## Safety and Quality Rules

- Nunca declarar "ok" sem rodar ao menos smoke + checklist minimo.
- Se nao der para validar algo, marcar explicitamente como `NAO VALIDADO`.
- Priorizar evidencias reproduziveis em vez de impressao subjetiva.
- Nao mascarar regressao conhecida.

## Validation Checklist

Before finishing, verify:
- Smoke headless sem erro fatal.
- Nenhum `res://` quebrado apos mudancas.
- Mecanicas principais tiveram verificacao explicita.
- Resultado final tem status claro (aprovado, aprovado com risco, reprovado).
