---
name: towergame-combat-truth-validator
description: Use when changing TowerGame combat, stats, or HUD values to ensure displayed numbers match real runtime behavior for damage, attack cadence, movement speed, and survivability.
---

# TowerGame Combat Truth Validator

## Purpose

Validar que os numeros exibidos na UI do TowerGame correspondem ao comportamento real em gameplay, evitando discrepancia entre valor mostrado e valor mecanico.

## When to Use

Use this skill when:
- Houver alteracao em `autoload/PlayerStats.gd`.
- Houver alteracao em `scripts/player/player.gd`.
- Houver alteracao em HUD/painel de status (`scripts/ui/*` ou `scripts/main.gd`).
- O usuario reportar que "o numero nao bate com o que acontece no jogo".
- Houver ajuste em cooldown, attack speed, hit chance, critico, dano ou velocidade.

## When Not to Use

Do not use this skill when:
- A mudanca for apenas visual sem numero de combate.
- O escopo for apenas fluxo de cena/portal.
- O pedido for so documentacao sem impacto de runtime.

## Required Inputs

Collect or infer:
- Arquivos alterados de combate e UI.
- Metricas alvo (APS, dano, velocidade %, chance de acerto/critico, HP efetivo).
- Definicao de baseline (ex.: 100% de velocidade normal).
- Cenario de teste para reproducao.

## Workflow

1. Mapear formulas e fontes de verdade:
- `PlayerStats` para calculos.
- `player.gd` para aplicacao real (timing/animacao/hit window).
- HUD/painel para exibicao.
2. Comparar "valor exibido" vs "valor executado" por metrica.
3. Identificar causa da divergencia:
- dupla contagem de tempo (animacao + cooldown),
- arredondamento inadequado,
- leitura de variavel errada na UI,
- baseline inconsistente.
4. Aplicar correcao minima e coerente.
5. Revalidar no fluxo de jogo e no HUD.
6. Entregar diagnostico + correcao + passos de teste objetivos.

## Output Format

Return:
- Metricas verificadas (`APS`, `dano`, `velocidade`, `HP`).
- Resultado por metrica (`OK` ou `DIVERGENTE`).
- Causa raiz da divergencia encontrada.
- Arquivos alterados com codigo final completo.
- Como testar em runtime e qual resultado esperado.

## Safety and Quality Rules

- Nao aceitar aproximacao cosmetica quando valor mecanico diverge.
- Nao quebrar animacoes para "forcar" numero correto sem validar hit timing.
- Preservar convenções de nomes e calculos existentes.
- Preferir ajustes localizados antes de refatoracao ampla.
- Declarar claramente quando a validacao ficou parcial.

## Validation Checklist

Before finishing, verify:
- Cada valor exibido auditado possui fonte de calculo rastreavel.
- APS exibido bate com a cadencia real observavel.
- Velocidade percentual usa baseline consistente.
- Dano e HP exibidos refletem estado real apos aplicacao de formulas.
- Teste de reproducao foi descrito com resultado esperado.

