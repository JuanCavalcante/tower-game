---
name: towergame-floor-scene-integrity-checker
description: Use when creating or editing TowerGame floor scenes to validate .tscn integrity, floor script bindings, enemy references, portal anchors, and GameManager routing without breaking scene load.
---

# TowerGame Floor Scene Integrity Checker

## Purpose

Validar e corrigir integridade de andares no TowerGame para evitar erros de load, queda do player por cena invalida, referencias quebradas e mapeamento inconsistente entre `autoload/GameManager.gd`, `scenes/world/*.tscn` e `scripts/floor_*.gd`.

## When to Use

Use this skill when:
- Um andar novo foi criado ou duplicado.
- Houve ajuste em `scenes/world/floor_*.tscn`.
- Houve ajuste em `autoload/GameManager.gd` (roteamento de andares).
- O sintoma em jogo for "andar nao carrega", "player cai", "portal nao funciona" ou floor vazio.
- O PR mexe em `ext_resource`, root node, script binding ou `PackedScene` de inimigos.

## When Not to Use

Do not use this skill when:
- O pedido for somente balanceamento numerico de combate.
- O pedido for apenas UI/HUD sem impacto em floors.
- O trabalho for fora do TowerGame/Godot.

## Required Inputs

Collect or infer:
- Lista de andares alterados (ex.: `5..10`).
- Arquivos alterados em `scenes/world`, `scripts/floor_*` e `autoload/GameManager.gd`.
- Regra esperada de spawn e portal para cada andar.
- Sintoma observado no jogo (quando houver).

## Workflow

1. Ler `autoload/GameManager.gd` e extrair o mapa `floor -> scene_path`.
2. Confirmar existencia real de cada `.tscn` mapeado.
3. Em cada floor alterado, validar:
- root node coerente com o andar.
- script `ext_resource` apontando para `scripts/floor_XX.gd` correto.
- referencias de inimigos/portal sem path quebrado.
- anchors esperados (`ExitPortal`, `PortalAnchor`, ou paths alternativos do projeto).
4. Verificar consistencia entre cena e script:
- `BaseFloor` aplicado quando esperado.
- roles de inimigo detectaveis por script path (`minion/miniboss/boss`).
5. Propor ou aplicar a menor correcao segura, sem refatoracao ampla.
6. Executar smoke de carga das cenas alteradas (headless quando possivel).

## Output Format

Return:
- Integridade por andar (`OK`, `WARN`, `BROKEN`).
- Arquivos verificados e arquivos corrigidos.
- Erros encontrados (path, script, root node, resource id).
- Correcao aplicada (codigo/trecho final completo do arquivo alterado).
- Passos curtos de teste no Godot para reproduzir e validar.

## Safety and Quality Rules

- Nunca assumir path de resource sem verificar arquivo real.
- Nunca trocar em massa `.tscn` com escrita que injete BOM ou escape invalido.
- Preservar nomes e estrutura atuais do TowerGame.
- Corrigir somente o necessario para restaurar integridade.
- Se um floor depende de regra global, ajustar com impacto minimo.

## Validation Checklist

Before finishing, verify:
- Todo floor mapeado no `GameManager` existe fisicamente.
- Cada floor alterado aponta para script correto do proprio andar.
- Referencias de `PackedScene` e `ext_resource` estao resolviveis.
- Spawn/portal nao deixam o player em queda por anchor ausente.
- Smoke de carga nao retorna erro de parse/load nas cenas tocadas.

