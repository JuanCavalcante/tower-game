# TowerGame Main Instancing Standardizer

## Quando usar
- Sempre que `scripts/core/main.gd` começar a concentrar criação de UI, HUD, menus, overlays ou sistemas de cena.
- Sempre que uma feature nova estiver sendo criada diretamente na `main` em vez de cena dedicada.

## Objetivo
- Manter a `main` como orquestradora.
- Fazer a `main` instanciar cenas e chamar APIs públicas, sem construir árvore de nós manualmente.
- Remover legado não utilizado após extração.

## Regras
1. `main.tscn` deve conter instâncias (`PackedScene`) para elementos de UI e gameplay que já possuem domínio próprio.
2. `main.gd` não deve criar nós de HUD/UI com `new()` (exceto casos realmente globais e temporários).
3. Cada cena extraída deve expor métodos claros (`refresh`, `set_visible_state`, `update_*`) e sinais para interação.
4. Após migrar, remover nós e código legado sem uso.
5. Manter atalhos e fluxo de pausa/menus funcionando igual antes da refatoração.

## Fluxo padrão
1. Mapear responsabilidades na `main`:
   - criação de nós,
   - atualização por frame,
   - conexões de sinais.
2. Criar/usar cena dedicada em `scenes/ui` ou domínio apropriado.
3. Mover lógica para script da cena dedicada em `scripts/ui` (ou domínio correspondente).
4. Substituir nós inline por `instance=ExtResource(...)` em `main.tscn`.
5. Trocar acesso de nó interno em `main.gd` por API da cena.
6. Remover constantes, funções e variáveis legadas da `main`.
7. Validar no Godot headless e fazer smoke manual.

## Checklist de validação
- `main.gd` ficou menor e sem construção detalhada de HUD/UI.
- Elementos continuam abrindo/fechando com atalhos e botões.
- HUD atualiza vida/mana/stamina/moedas/andar corretamente.
- Painéis de personagem e inventário continuam pausando/despausando o jogo corretamente.
- Não há warnings/erros novos de parse.

## Resultado esperado
- `main` limpa, previsível e fácil de manter.
- Componentes desacoplados e reutilizáveis.
