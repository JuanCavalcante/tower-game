---
name: towergame-headless-smoke-runner
description: Use before merge or handoff to run TowerGame Godot headless smoke checks, catch parse/load regressions early, and report actionable failures by file and scene.
---

# TowerGame Headless Smoke Runner

## Purpose

Executar uma validacao rapida e repetivel do TowerGame via Godot headless para capturar regressao de parse, load de cena e erros de script antes de teste manual completo.

## When to Use

Use this skill when:
- Foi alterado qualquer `.gd` ou `.tscn` critico.
- Antes de commit, push ou PR.
- O usuario pedir "teste no Godot" de forma rapida.
- Houve merge de branch com risco de conflito estrutural.

## When Not to Use

Do not use this skill when:
- O usuario precisa validacao completa de gameplay/balance (nao so smoke).
- O ambiente nao tem executavel Godot disponivel e sem alternativa.
- O pedido e apenas documental.

## Required Inputs

Collect or infer:
- Caminho do projeto (`--path`).
- Caminho do executavel Godot console/headless.
- Lista de cenas alteradas (para foco do diagnostico).
- Criterio de aprovacao (ex.: sem parse errors, sem load errors).

## Workflow

1. Confirmar mudancas locais e identificar arquivos de maior risco (`.gd`, `.tscn`).
2. Executar smoke principal:
- `Godot_v4.6.2-stable_win64_console.exe --headless --path <repo> --quit`
3. Quando necessario, executar smoke focado por cena alterada.
4. Coletar erros e classificar:
- parse/type errors
- resource/path load errors
- node path/runtime warnings criticos
5. Apontar arquivos e causas provaveis com proxima acao objetiva.
6. Reportar status final (`PASS`, `PASS_WITH_WARNINGS`, `FAIL`).

## Output Format

Return:
- Comando(s) executado(s).
- Status final (`PASS`, `PASS_WITH_WARNINGS`, `FAIL`).
- Lista de erros com arquivo e contexto.
- Cenas validadas no smoke.
- Proximo passo recomendado (correcao ou teste manual adicional).

## Safety and Quality Rules

- Nao declarar sucesso sem executar o comando.
- Nao ocultar warnings relevantes de carga de cena.
- Nao misturar troubleshooting generico; apontar causa por arquivo.
- Se o executavel nao for encontrado, reportar claramente e sugerir path esperado.
- Manter o teste leve e focado para feedback rapido.

## Validation Checklist

Before finishing, verify:
- O comando headless foi executado de fato.
- O resultado foi classificado em PASS/PASS_WITH_WARNINGS/FAIL.
- Erros estao mapeados para arquivos/cenas especificos.
- O relatorio inclui passos objetivos para reproduzir e corrigir.
- Ficou claro se ainda falta teste manual de gameplay.

