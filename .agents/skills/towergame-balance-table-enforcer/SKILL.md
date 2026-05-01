---
name: towergame-balance-table-enforcer
description: Use when updating TowerGame combat progression to keep docs and runtime balance tables synchronized across floors, roles, and floor-10 boss-only constraints.
---

# TowerGame Balance Table Enforcer

## Purpose

Garantir que o balanceamento do TowerGame seja consistente entre documentacao e runtime, sincronizando `docs/balance/*.md`, `scripts/balance/floor_balance.gd` e aplicacao em `scripts/base_floor.gd`.

## When to Use

Use this skill when:
- O usuario pedir ajuste de dificuldade por andar.
- Houver mudanca de HP, dano, XP, velocidade ou cooldown.
- O usuario pedir revisao de curva `1..10`.
- O PR alterar `floor_balance.gd`, `base_floor.gd` ou docs de balanceamento.
- Houver regra especifica para boss/miniboss (ex.: floor 10 boss-only).

## When Not to Use

Do not use this skill when:
- O pedido for apenas bug estrutural de cena sem ajuste numerico.
- O pedido for exclusivamente UI visual sem impacto de combate.
- Nao houver dados de alvo por andar/role.

## Required Inputs

Collect or infer:
- Objetivo de curva (onboarding, pressao moderada, endgame).
- Tabela alvo por andar e role (`minion`, `miniboss`, `boss`).
- Regras obrigatorias (ex.: floor 10 sem minions).
- Arquivos fonte de verdade no momento (docs e codigo).

## Workflow

1. Ler a tabela em `docs/balance` e o runtime em `scripts/balance/floor_balance.gd`.
2. Comparar por andar e role:
- campos obrigatorios: `hp`, `damage`, `xp`, `speed`, `attack_cooldown`.
- mitigacao quando aplicavel: `damage_reduction_ratio`, `damage_reduction_flat`.
3. Detectar drift entre docs e codigo e registrar diferencas objetivas.
4. Atualizar a fonte escolhida no pedido (normalmente runtime primeiro) com mudanca minima.
5. Validar efeitos colaterais em `scripts/base_floor.gd`:
- role detection funcionando.
- aplicacao de stats para inimigos existentes.
- regra floor 10 boss-only preservada.
6. Fornecer resumo tecnico do impacto de gameplay esperado.

## Output Format

Return:
- Tabela final consolidada por andar/role.
- Lista de arquivos alterados.
- Codigo completo dos arquivos alterados (sem fragmentos soltos).
- Regras garantidas (ex.: boss-only floor 10, proporcao boss/minion).
- Como testar em jogo (andar alvo, tempo de kill, pressao de dano, progressao).

## Safety and Quality Rules

- Nao alterar curva inteira sem necessidade do pedido.
- Evitar saltos extremos nao justificados entre andares consecutivos.
- Manter coerencia entre docs e runtime no mesmo commit.
- Nao mascarar problema mecanico com ajuste apenas visual.
- Preservar nomenclatura e estrutura existente do projeto.

## Validation Checklist

Before finishing, verify:
- Docs e runtime estao sincronizados para os andares tocados.
- Todos os roles necessarios existem na tabela final.
- Floor 10 permanece com apenas boss no runtime.
- `base_floor.gd` ainda aplica stats corretamente por role.
- Teste manual orientado foi descrito com resultado esperado.

