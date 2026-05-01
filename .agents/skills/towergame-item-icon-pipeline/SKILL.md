---
name: towergame-item-icon-pipeline
description: Use when creating TowerGame item icons with gpt-image-2 in a consistent 32x32 transparent pipeline and integrating them into inventory slots without UI regressions.
---

# TowerGame Item Icon Pipeline

## Purpose

Padronizar a criacao de icones de item para o TowerGame com qualidade consistente, fundo transparente real e integracao completa no inventario.

## When to Use

Use this skill when:
- O pedido envolver criar sprites 2D de itens para inventario/equipamentos.
- O usuario pedir icones 32x32 com fundo transparente.
- For necessario ligar os icones nas boxes do inventario no jogo.

## When Not to Use

Do not use this skill when:
- O pedido for para animacao de personagem ou tileset de cenario.
- O asset desejado for vetor/SVG dentro de um sistema existente.
- O usuario quiser apenas mockup sem integracao no jogo.

## Required Inputs

Collect or infer:
- Lista exata de itens alvo (por exemplo, itens do mercador).
- Pasta de destino dos sprites no projeto.
- Scripts/fontes de dados dos itens (ex.: `floor_00_city.gd`, `inventory_slot.gd`).

## Workflow

1. Mapear itens reais no codigo:
- localizar origem dos itens (mercador, drop, reward).
- confirmar nome de exibicao e `item_type`.

2. Gerar imagem base com `gpt-image-2`:
- um prompt por item.
- estilo: pixel art legivel em tamanho pequeno.
- impor fundo chroma key solido (`#00ff00`) sem sombra/gradiente/textura.

3. Preparar transparencia:
- copiar gerados para pasta de trabalho no projeto.
- remover chroma com:
  `python "$CODEX_HOME/skills/.system/imagegen/scripts/remove_chroma_key.py" ...`
- validar canal alpha (sem fundo visivel).

4. Normalizar 32x32:
- recortar bbox do alpha.
- redimensionar sprite interno mantendo aspecto.
- centralizar em canvas final 32x32 transparente.

5. Publicar assets:
- salvar finais em `assets/sprites/items/<grupo>/`.
- remover arquivos temporarios (`*_src`, `*_alpha`) se nao forem necessarios.

6. Integrar no jogo:
- adicionar `icon_path` nos dicionarios dos itens de origem.
- no slot de inventario, renderizar icone quando existir `icon_path`.
- manter fallback por `item_type` para resiliencia.

7. Validar:
- smoke tecnico com Godot headless.
- confirmar no jogo que os itens aparecem dentro das boxes.

## Prompt Pattern

Para cada item, usar base minima:

- `Pixel art RPG inventory icon, 32x32 composition, <item subject>, centered, crisp outlines, high readability at tiny size, no text, no frame.`
- `Background must be a perfectly flat solid #00ff00 chroma key with zero gradients, zero shadows, zero texture.`

## Output Format (Obrigatorio)

Sempre retornar:

1. Assets gerados
- lista de paths finais dos PNGs 32x32.

2. Integracao
- arquivos alterados para `icon_path` e render de slot.

3. Validacao
- comando executado e resultado do smoke.
- comportamento observado no inventario.

4. Observacoes
- itens cobertos e itens fora do fluxo (se houver).

## Safety and Quality Rules

- Nao inventar itens: usar apenas itens existentes no codigo.
- Nao deixar asset de jogo somente em pasta temporaria do Codex.
- Nao quebrar drag/drop do inventario ao adicionar icone.
- Preservar nomes e convencoes do projeto.

## Validation Checklist

Before finishing, verify:
- cada icone final esta em 32x32.
- cada icone final tem alpha funcional.
- `icon_path` aponta para arquivos existentes.
- inventario continua abrindo e exibindo itens.
- Godot headless conclui sem erro de parse/load.
