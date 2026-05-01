---
name: towergame-branch-hygiene-godot
description: Use when switching branches or preparing clean TowerGame checkouts in Godot to prevent .godot and .import artifacts from blocking git operations or causing noisy diffs.
---

# TowerGame Branch Hygiene Godot

## Purpose

Executar higiene de branch para TowerGame/Godot com foco em checkout limpo, troca segura de branch e reducao de ruído operacional causado por artefatos locais do editor.

## When to Use

Use this skill when:
- O usuario pedir troca/sincronizacao de branch.
- `git checkout` falhar por arquivos locais em `.godot` ou `.import`.
- Houver necessidade de testar PR local sem sujar branch principal.
- O workspace estiver com muitos arquivos gerados sem rastreamento.

## When Not to Use

Do not use this skill when:
- A tarefa for apenas implementacao de gameplay sem operacao de git.
- O usuario pedir preservar deliberadamente arquivos temporarios locais.
- O repositorio nao for Godot.

## Required Inputs

Collect or infer:
- Branch origem/destino.
- Estado atual do `git status`.
- Politica para branch principal suja (usar worktree quando necessario).
- Escopo do teste local (PR, feature branch, main sync).

## Workflow

1. Inspecionar estado do repositorio:
- `git status --short`,
- arquivos locais em `.godot` e `.import`.
2. Classificar itens:
- temporarios gerados pelo editor,
- alteracoes reais de codigo.
3. Limpar somente o que for seguro e esperado para Godot.
4. Se checkout principal estiver sujo e o usuario quiser teste isolado:
- preferir `git worktree` para nao poluir o repo principal.
5. Realizar troca/sync de branch com comandos nao interativos.
6. Validar estado final limpo e pronto para edicao/teste.

## Output Format

Return:
- Estado inicial resumido (branch + itens que bloqueavam).
- Acoes executadas de higiene.
- Branch final e estado final do `git status`.
- Se aplicavel, caminho da worktree criada.
- Riscos/pendencias remanescentes.

## Safety and Quality Rules

- Nunca usar comandos destrutivos globais sem necessidade explicita.
- Nunca apagar alteracoes de codigo do usuario sem confirmacao.
- Tratar `.godot`/`.import` como suspeitos, mas validar antes de remover.
- Priorizar isolamento via worktree quando houver risco.
- Manter rastreabilidade do que foi limpo.

## Validation Checklist

Before finishing, verify:
- Branch alvo foi alcancada com sucesso.
- Nenhum arquivo de codigo importante foi descartado.
- Artefatos Godot que bloqueavam checkout foram tratados.
- `git status` final esta coerente com o objetivo.
- Worktree foi usada quando era a opcao mais segura.

