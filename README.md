# Tower Game

![Godot](https://img.shields.io/badge/Engine-Godot_4-478cbf?logo=godot-engine&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active_Development-2ea44f)
![Genre](https://img.shields.io/badge/Genre-2D_Action_RPG-orange)
![Language](https://img.shields.io/badge/Scripting-GDScript-6c7a89)

Jogo 2D em Godot 4 com loop de hub + torre: o jogador evolui atributos, enfrenta inimigos por andar, coleta moedas, compra no vendedor e avanca pelos portais.

## Visao Geral

Estado atual da `main`:

- Hub de cidade (`floor_00_city`) como ponto central do loop.
- Andares jogaveis mapeados no `GameManager`: `0, 1, 2, 3, 4`.
- Combate melee com hit chance, critico, cooldown dinamico e escalonamento por atributos.
- Sistema global de stats, XP, level, moedas, poucoes e arma equipada.
- Painel de status/atributos (`tecla C`) com distribuicao de pontos e tooltips contextuais.
- Save/load em `user://savegame.json`.

## Funcionalidades Implementadas

### Loop de jogo

- Novo jogo e continuar do save.
- Continuar sempre retorna para o hub preservando progresso.
- Portal do hub com selecao de andares e bloqueio por desbloqueio.
- Portal de saida nos andares de combate (ativa ao limpar o andar).

### Combate e inimigos

- Player com ataque melee e verificacao de acerto por chance.
- Inimigos com IA base (`idle/chase/attack`) e knockback.
- Coin drops magneticos com coleta automatica por proximidade.
- Mini boss (mushroom) com especial toxico e mecanica anti-head-lock.
- Skeleton boss com padrao de ataques e especial ciclico.

### Progressao e atributos

- Atributos: Forca, Vitalidade, Destreza, Inteligencia e Sorte.
- Level up concede +5 pontos de atributo por nivel.
- Escalonamento por nivel:
  - Recursos base (HP/SP/MP): +10 por nivel, e +25 em niveis multiplos de 5.
  - Dano base adicional: +2 por nivel.
- Regras principais:
  - Forca: multiplicador percentual no dano fisico.
  - Vitalidade: +5 HP e +10 SP por ponto.
  - Destreza: acerto, velocidade de movimento e velocidade de ataque.
  - Inteligencia: MP maximo e multiplicador percentual de dano magico.
  - Sorte: chance de critico.

### UI

- HUD com:
  - `HP atual/maximo`
  - `Moedas`
  - `Andar atual`
  - Toggle de `Modo Dev`.
- Menu principal, menu de pausa e controle de volume/musica.
- Painel de status (`C`) com:
  - Coluna esquerda: status detalhados do jogador.
  - Coluna direita: atributos, pontos disponiveis/total e botoes `+`.
  - Tooltips contextuais ao passar o mouse.

## Estrutura Principal

- `autoload/GameManager.gd`: fluxo global (load de andares, desbloqueio, save/load).
- `autoload/PlayerStats.gd`: estado persistente e formulas de progressao/atributos.
- `scenes/main.tscn`: raiz do jogo (Game + UI + audio).
- `scripts/main.gd`: orquestracao de menu, HUD, pausa e painel de status.
- `scripts/floor_00_city.gd`: logica do hub (portal e vendedor).
- `scripts/base_floor.gd`: contrato base de clear de andar.
- `scripts/enemies/*.gd`: IA e variacoes de inimigos/bosses.
- `scripts/coin/coin_pickup.gd`: coleta de moedas com magnetismo.
- `scenes/ui/player_status_panel.tscn`: UI do painel de status/atributos.

## Andares e Cenas

Mapeados e carregados atualmente:

- `0 -> scenes/world/floor_00_city.tscn`
- `1 -> scenes/world/floor_01.tscn`
- `2 -> scenes/world/floor_02.tscn`
- `3 -> scenes/world/floor_03.tscn`
- `4 -> scenes/world/floor_04.tscn`

Observacao:

- Existem scripts `floor_05.gd` e `floor_06.gd`, mas estes andares ainda nao estao ligados ao mapa de `floors` no `GameManager`.

## Controles

- `A` / `Seta Esquerda`: mover para esquerda.
- `D` / `Seta Direita`: mover para direita.
- `W` / `Espaco` / `Seta Cima`: pular.
- `Mouse Esquerdo`: atacar.
- `E`: interagir (hub).
- `Q`: usar pocao.
- `C`: abrir/fechar painel de status do jogador.
- `Esc`: pausar/retomar (quando aplicavel).

## Como Executar

1. Abra o projeto no Godot 4.6.
2. Rode `scenes/main.tscn` (F5).

Sem pipeline de build/teste automatizado no repositorio neste momento.

## Persistencia

Save em JSON no caminho:

- `user://savegame.json`

Dados persistidos:

- andar atual
- andares desbloqueados
- estado completo de `PlayerStats` (nivel, xp, recursos, moedas, atributos etc.)

## Limitacoes Conhecidas

- Fluxo de portal entre andares ainda e automatico ao entrar no `ExitPortal` ativo (sem escolha de "voltar cidade / proximo andar" no portal de combate).
- Inventario/equipamentos completos (drag and drop) ainda nao implementados.
- Tela de morte dedicada com botao de renascer ainda nao esta integrada ao loop principal.
