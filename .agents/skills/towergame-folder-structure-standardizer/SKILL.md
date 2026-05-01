---
name: towergame-folder-structure-standardizer
description: Use when planning or executing a TowerGame folder-structure refactor to reorganize scripts and scenes, remove redundant files, and update all Godot path references safely.
---

# TowerGame Folder Structure Standardizer

## Purpose

Padronizar a estrutura de pastas do TowerGame com migracao segura de caminhos `res://`, reduzindo bagunca e redundancia sem quebrar cenas, scripts ou autoloads.

## When to Use

Use this skill when:
- O usuario pedir refactor estrutural de pastas no projeto.
- Houver scripts/cenas em pastas inconsistentes ou com naming confuso.
- Existirem arquivos duplicados, aliases antigos ou scripts redundantes.
- For necessario reorganizar modulos mantendo compatibilidade de runtime.

## When Not to Use

Do not use this skill when:
- A tarefa for somente balance, UI tweak ou bugfix local sem mudanca estrutural.
- O usuario pedir apenas adicionar nova feature sem mexer em organizacao.
- O repositorio nao for Godot ou nao usar referencias `res://`.

## Required Inputs

Collect or infer:
- Estrutura atual das pastas (`scripts/`, `scenes/`, `assets/`, `autoload/`, `docs/`).
- Lista de referencias de caminho em `.gd`, `.tscn`, `.tres` e `project.godot`.
- Mapa de destino da nova estrutura por dominio (core, world, entities, ui, autoload).
- Regras para remocao de redundancia (arquivo sem referencias, alias legado, duplicata real).
- Comando de validacao local (headless smoke no Godot).

## Workflow

1. Auditar estrutura atual e mapear inconsistencias.
2. Definir estrutura alvo clara e incremental (sem big-bang cego).
3. Criar tabela de migracao `origem -> destino` antes de mover arquivos.
4. Mover usando historico preservado (`git mv`) sempre que possivel.
5. Atualizar todas as referencias de caminho:
- scripts (`extends`, `preload`, `load`);
- cenas e recursos (`ext_resource path=`);
- `project.godot` (main scene, autoloads, etc.).
6. Remover arquivos redundantes apenas apos confirmar ausencia de uso.
7. Rodar validacao:
- scan final para caminhos antigos remanescentes;
- smoke headless do Godot;
- `git diff` focado em integridade de referencias.
8. Registrar resultado com impacto, riscos residuais e proximos passos.

## Target Structure Baseline

Preferir esta base, adaptando conforme o projeto:
- `scripts/core/`
- `scripts/world/` e `scripts/world/floors/`
- `scripts/entities/player/`
- `scripts/entities/enemies/`
- `scripts/ui/`
- `scripts/autoload/`
- `scenes/world/`, `scenes/enemies/`, `scenes/player/`, `scenes/ui/`, `scenes/items/`
- `docs/architecture/` para convencoes e mapa de migracao

## Output Format

Return:
- Estrutura anterior resumida (problemas principais).
- Estrutura alvo proposta.
- Lista de arquivos movidos/renomeados e referencias atualizadas.
- Lista de redundancias removidas com justificativa.
- Resultado da validacao (scan + smoke).
- Riscos pendentes, se houver.

## Safety and Quality Rules

- Nao remover arquivo sem confirmar falta de referencia no codigo/projeto.
- Nao mover tudo de uma vez sem mapa e validacao intermediaria.
- Priorizar mudancas reversiveis e com rastreabilidade.
- Preservar nomenclatura consistente (snake_case para scripts Godot).
- Evitar alteracoes de comportamento durante refatoracao estrutural.

## Validation Checklist

Before finishing, verify:
- Nenhuma referencia `res://` antiga ficou quebrada.
- `project.godot` continua consistente com os novos caminhos.
- Cenas principais carregam sem erro de recurso ausente.
- Scripts autoload e dependencias compilam/carregam.
- Arquivos redundantes removidos nao possuem mais consumidores.
- Estrutura final ficou mais clara por dominio e responsabilidade.
