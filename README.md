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

## Roadmap por Fases

Status de referencia atualizado em `2026-04-29`, com base na `main`, PRs mergeados e issues do board `Projects/TowerGame > Current iteration`.

### Fase 1 - Fundacao jogavel (Concluida)

- Loop base de combate + HUD + pausa.
- Estrutura de save/load funcional.
- Base de andares iniciais e bosses em funcionamento.

Entregas relacionadas:
- Fluxo base consolidado na `main`.

### Fase 2 - Hub da Cidade e Progressao de Acesso (Concluida)

- Floor 0 (cidade/hub) implementado.
- Portal central com selecao de andares 1..10.
- Andares bloqueados/desbloqueados com persistencia em save.
- Fluxo cidade <-> torre com spawn consistente.

Entregas relacionadas:
- #6 (TG3-001) concluida.
- #7 (TG3-002) concluida.
- #8 (TG3-003) concluida.
- #9 (TG3-004) concluida.

### Fase 3 - Qualidade de Combate e UX de Morte/Status (Concluida)

- Ajustes de hitbox/knockback/colisao para reduzir soft lock.
- Painel de status (tecla `C`) com atributos e tooltips.
- Fluxo de morte com animacao, overlay `Voce morreu` e botao `Renascer`.

Entregas relacionadas:
- #18 (TG3-008) concluida.
- #12 (TG3-007) concluida.
- #24 (TG3-011) concluida.

### Fase 4 - Escala de Conteudo 1..10 e Balanceamento (Em andamento)

Objetivo:
- Fechar pacote de andares jogaveis ate 10.
- Aplicar curva de dificuldade coerente (HP/dano/XP/spawn/waves).

Pendencias principais:
- #10 (TG3-005) em aberto.
- #11 (TG3-006) em aberto.

### Fase 5 - UX de Portal Tatico e HUD de Vida (Pendente)

Objetivo:
- Dar ao jogador decisao explicita no portal do andar.
- Melhorar legibilidade de sobrevivencia em combate.

Pendencias principais:
- #23 (TG3-010): escolha `Retornar a cidade` vs `Ir Proximo Andar`.
- #25 (TG3-012): barra de vida no HUD com `HP atual/maximo`.

### Fase 6 - Inventario RPG e Equipamentos (Pendente)

Objetivo:
- Sistema de inventario com drag and drop entre mochila e equipamentos.
- Base para progressao de itens e customizacao de build.

Pendencia principal:
- #22 (TG3-009) em aberto.

## Proximo Marco Recomendado

Para fechar o ciclo atual com menor risco tecnico:

1. Concluir #10 (andares 7-10).
2. Concluir #11 (balanceamento 1-10).
3. Concluir #23 (decisao de portal no fim do andar).
4. Concluir #25 (barra de vida da HUD).
5. Iniciar #22 (inventario/equipamentos).
