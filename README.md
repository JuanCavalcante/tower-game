# Tower Game

2D platformer feito em Godot 4, com progressao por andares, combate corpo a corpo e portais de saida.

## Resumo

- O jogador sobe andares enfrentando ondas de inimigos.
- Cada andar e limpo ao derrotar todos os mobs.
- Ao limpar o andar, o portal de saida e ativado.
- Ha sistema de XP e level up pelo autoload `PlayerStats`.

## Como rodar

1. Abra o projeto no Godot 4.
2. Rode a cena principal com `F5`.
3. Para testar uma cena especifica, use `F6`.

Nao ha pipeline de build por CLI nem testes automatizados neste repositorio.

## Controles

- `A` / `Seta Esquerda`: mover para esquerda
- `D` / `Seta Direita`: mover para direita
- `W` / `Espaco` / `Seta Cima`: pular
- `Botao esquerdo do mouse` (ou tecla configurada): atacar

## Estrutura principal

- `autoload/GameManager.gd`
  - Gerencia troca de andares e save/load em `user://savegame.json`.
- `autoload/PlayerStats.gd`
  - Vida, XP e level do jogador.
- `scenes/main.tscn`
  - Cena raiz com jogo + UI.
- `scenes/world/`
  - Andares (`floor_01.tscn`, `floor_02.tscn`, ...).
- `scenes/enemies/`
  - Cenas dos inimigos e bosses.
- `scripts/enimies/`
  - IA e comportamento base dos inimigos.

## Regras de andares e inimigos

### Contrato dos andares

Cada script de andar deve:

1. estender `Node2D`;
2. implementar `enemy_killed(enemy)`;
3. ativar o portal ao limpar o andar (`portal.activate()`).

### Contrato dos inimigos

Cada inimigo deve:

1. entrar no grupo `"enemies"` no `_ready()`;
2. implementar `take_damage(amount, source_position: Vector2)`;
3. ao morrer, dar XP e notificar o andar atual.

## Notas da versao atual

- IA base com melhor distribuicao de mobs (menos aglomeracao).
- Patrulha curta aleatoria logo apos spawn, interrompida ao detectar jogador.
- Barrinha de vida por inimigo.
- Floor 1 reformulada para spawn por wave mais estavel.
- Melhorias em bosses (cogumelo e caveira), com ataques especiais e efeitos visuais.

## Proximos passos recomendados

- Balancear dano/cooldown dos especiais dos bosses em runtime.
- Ajustar quantidade e delay das waves por dificuldade alvo.
- Adicionar testes de smoke/manual checklist por andar.
