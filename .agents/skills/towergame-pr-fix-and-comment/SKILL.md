---
name: towergame-pr-fix-and-comment
description: Use when taking a TowerGame pull request from review to completion by reproducing locally, applying targeted fixes, validating in Godot, pushing to the correct branch, and posting a concise technical PR comment.
---

# TowerGame PR Fix and Comment

## Purpose

Executar manutencao completa de PR do TowerGame: trazer branch correta localmente, reproduzir o problema, corrigir com impacto minimo, validar no Godot, publicar e comentar no PR com resumo tecnico objetivo.

## When to Use

Use this skill when:
- O usuario pedir para corrigir um PR especifico.
- O usuario quiser "passar o PR para a maquina" para teste no Godot.
- Houver necessidade de publicar ajuste direto na branch do PR.
- O usuario pedir comentario profissional no PR apos fix.

## When Not to Use

Do not use this skill when:
- O pedido for criar feature nova sem PR existente.
- O usuario nao quiser publicar nada remoto.
- O repositorio alvo nao for o TowerGame.

## Required Inputs

Collect or infer:
- Numero do PR e repositorio.
- Branch real do PR (nao assumir por nome de issue).
- Caminho local do checkout (ou necessidade de worktree).
- Criterio de validacao (headless, teste manual, ambos).

## Workflow

1. Descobrir branch real do PR e sync local.
2. Preparar ambiente de teste seguro:
- usar branch local isolada ou worktree quando necessario.
3. Reproduzir bug/risco reportado no PR.
4. Implementar correcao minima com foco no comportamento esperado.
5. Validar no Godot (headless + smoke funcional relevante).
6. Commitar/push na branch correta do PR.
7. Comentar no PR:
- problema encontrado,
- correcao aplicada,
- validacao executada.

## Output Format

Return:
- PR alvo e branch real usada.
- Arquivos alterados com codigo final completo.
- Validacao executada (comando e resultado).
- SHA/branch publicada.
- Texto do comentario tecnico deixado no PR.

## Safety and Quality Rules

- Nunca publicar em branch errada.
- Nunca comentar "fixado" sem validacao local.
- Manter comentario curto, tecnico e verificavel.
- Evitar refatoracoes paralelas fora do escopo do PR.
- Preservar alteracoes existentes do usuario no checkout principal.

## Validation Checklist

Before finishing, verify:
- Branch correta do PR foi identificada.
- Bug foi reproduzido ou diagnosticado com evidencia.
- Correcao foi validada em Godot.
- Push ocorreu no destino correto.
- Comentario no PR resume problema, fix e validacao.

