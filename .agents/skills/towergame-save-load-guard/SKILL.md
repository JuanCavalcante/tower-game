---
name: towergame-save-load-guard
description: Use when modifying TowerGame progression, stats, or floor flow to preserve save/load compatibility and prevent player progress loss.
---

# TowerGame Save Load Guard

## Purpose

Proteger compatibilidade de save/load no TowerGame ao alterar progressao, stats, andares e fluxo do jogo, evitando corrupcao de save ou perda de progresso do jogador.

## When to Use

Use this skill when:
- Houver alteracao em `autoload/GameManager.gd`.
- Houver alteracao em `autoload/PlayerStats.gd`.
- Houver mudanca de schema em `to_save_data()` ou `load_save_data()`.
- Houver nova regra de desbloqueio de andares/progresso.
- O usuario reportar regressao ao usar `continue game`.

## When Not to Use

Do not use this skill when:
- A alteracao for somente visual, sem persistencia.
- O pedido for estritamente sobre combate momentaneo sem dados salvos.
- O projeto alvo nao utilizar o save atual.

## Required Inputs

Collect or infer:
- Campos atuais serializados em save.
- Campos novos/removidos da mudanca.
- Comportamento esperado de fallback para saves antigos.
- Regras de floor unlock e retorno ao hub.

## Workflow

1. Mapear schema atual do save:
- chaves de `GameManager` e `PlayerStats`.
2. Revisar impacto da mudanca:
- campos adicionados/removidos/renomeados.
3. Definir compatibilidade retroativa:
- defaults seguros para campos ausentes,
- sanitizacao de tipos e ranges.
4. Atualizar leitura/escrita com menor impacto possivel.
5. Validar fluxos essenciais:
- novo jogo,
- salvar/carregar,
- continuar jogo existente,
- retorno ao hub mantendo progresso.
6. Documentar o que mudou no schema e como foi mantida a compatibilidade.

## Output Format

Return:
- Tabela de schema (`campo`, `origem`, `default`, `observacao`).
- Arquivos alterados.
- Codigo final completo dos arquivos modificados.
- Matriz de validacao de fluxo (`new game`, `save`, `continue`, `hub return`).
- Risco residual (se houver) e proximo passo.

## Safety and Quality Rules

- Nunca quebrar save antigo sem declarar migracao.
- Nunca assumir tipo de dado sem validacao defensiva.
- Manter fallback seguro para campos ausentes.
- Evitar alteracoes desnecessarias no contrato de persistencia.
- Preservar progresso do jogador como prioridade.

## Validation Checklist

Before finishing, verify:
- Save atual continua carregando sem erro.
- Campos novos possuem fallback quando ausentes.
- Unlock de andares permanece consistente apos load.
- `continue game` leva ao estado esperado do jogo.
- Mudancas de schema foram explicitadas no output.

