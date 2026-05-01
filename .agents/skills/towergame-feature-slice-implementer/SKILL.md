---
name: towergame-feature-slice-implementer
description: Use when implementing a TowerGame gameplay slice end-to-end in Godot with complete scripts, exact file paths, node attachment instructions, and concrete test steps.
---

# TowerGame Feature Slice Implementer

## Purpose

Implementar slices de feature no TowerGame de ponta a ponta, com integracao real em cenas/nodes/scripts e entrega pronta para uso no projeto.

## When to Use

Use this skill when:
- O pedido envolver nova feature de gameplay (inimigo, combate, movimentacao, interacao).
- A entrega exigir alteracoes em varios arquivos conectados.
- O usuario quiser resposta pronta para aplicar e testar no Godot.
- Houver criterio de aceite funcional claro.

## When Not to Use

Do not use this skill when:
- O pedido for apenas brainstorming de ideias.
- O escopo for somente ajuste de numero sem implementacao estrutural.
- O pedido for exclusivamente de review sem alteracao.

## Required Inputs

Collect or infer:
- Objetivo funcional da feature.
- Cenas e nodes impactados.
- Scripts novos/alterados e dependencias.
- Comportamento esperado e como validar em jogo.

## Workflow

1. Inspecionar contexto real:
- scripts, cenas, autoloads e padroes existentes.
2. Definir plano minimo de implementacao:
- arquivos a criar/alterar,
- pontos de integracao (node path, sinais, load flow).
3. Implementar com arquivo completo:
- nunca snippet isolado.
4. Integrar no Godot:
- informar exatamente onde anexar cada script.
- detalhar conexao de sinais quando aplicavel.
5. Validar funcionalmente:
- smoke tecnico + teste de gameplay do fluxo alterado.
6. Entregar no formato obrigatorio.

## Output Format (Obrigatorio)

Sempre retornar:

1. Codigo completo  
- Arquivo(s) final(is) completo(s).

2. Caminho do arquivo  
- Path exato no projeto para cada arquivo.

3. Onde anexar no Godot  
- Cena e node exatos para attachment.
- Sinais a conectar (origem -> metodo).

4. Como testar  
- Passos curtos no editor/jogo.
- Resultado esperado observavel.

## Safety and Quality Rules

- Nao entregar respostas genericas.
- Nao inventar nodes/cenas/paths sem validar.
- Preservar nomes e convencoes existentes do TowerGame.
- Evitar quebrar fluxo atual ao adicionar nova feature.
- Priorizar alteracao coesa e de menor risco.

## Validation Checklist

Before finishing, verify:
- Todos os arquivos foram entregues completos.
- Cada arquivo possui caminho explicito.
- Cada script possui local de attachment especificado.
- O roteiro de teste permite validar o comportamento final.
- A implementacao respeita padroes existentes do projeto.

