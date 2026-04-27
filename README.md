# Tower Game

![Godot](https://img.shields.io/badge/Engine-Godot_4-478cbf?logo=godot-engine&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active_Development-2ea44f)
![Genre](https://img.shields.io/badge/Genre-2D_Platformer-orange)
![Combat](https://img.shields.io/badge/Combat-Melee-red)
![Language](https://img.shields.io/badge/Scripting-GDScript-6c7a89)

Jogo 2D de progressao por andares feito em Godot 4. O loop principal combina combate corpo a corpo, limpeza de sala e avancar por portal, com sistema de XP, level e economia simples no hub.

## Sumario

- [Visao Geral](#visao-geral)
- [Funcionalidades](#funcionalidades)
- [Estado Atual](#estado-atual)
- [Arquitetura](#arquitetura)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Como Executar](#como-executar)
- [Controles](#controles)
- [Fluxo de Progressao](#fluxo-de-progressao)
- [Bosses e Combate](#bosses-e-combate)
- [Persistencia](#persistencia)
- [Roadmap](#roadmap)

## Visao Geral

O jogador sobe a torre enfrentando inimigos por andar. Cada piso exige eliminar todos os mobs para liberar o portal de saida e avancar para o proximo desafio.

O projeto tambem inclui um hub inicial (cidade) com interacoes de portal e vendedor, preparando base para progressao de longo prazo com itens e economia.

## Funcionalidades

- Progressao por andares com carregamento dinamico de cenas.
- Combate melee com janela de hit sincronizada na animacao.
- Sistema de inimigos com IA base e variacoes por tipo.
- Bosses com ataque especial e comportamento dedicado.
- HUD e menu de pausa na cena principal.
- Sistema de XP e level up (autoload).
- Save/load basico de progresso.
- Hub da cidade com portal de selecao de andar e vendedor.

## Estado Atual

- Andares de combate implementados: floor 01, floor 02, floor 03 e floor 04.
- Floor 01 com logica de waves; demais andares com inimigos pre-posicionados.
- Hub (floor 00) com acesso por portal e estrutura de compra de itens.
- Melhorias recentes em hitbox do player, knockback, colisao apos morte e anti-soft-lock no miniboss.

## Arquitetura

### Autoloads

- `autoload/GameManager.gd`
	- Carrega andares, controla transicoes e reset de posicao.
	- Mapeia floor number -> path de cena.
	- Salva e carrega progresso em `user://savegame.json`.

- `autoload/PlayerStats.gd`
	- Estado global de HP, XP, level e moedas.
	- Regras de progressao de nivel.
	- Estatisticas consumidas por player, HUD e sistema de loja.

### Contratos importantes

- Contrato de andar:
	- Implementar `enemy_killed(enemy)`.
	- Ativar portal ao limpar o andar.
	- Expor um `ExitPortal` na cena.

- Contrato de inimigo:
	- Entrar no grupo `enemies` em `_ready()`.
	- Implementar `take_damage(amount, source_position)`.
	- Notificar o andar quando morrer.

## Estrutura de Pastas

- `autoload/`: singletons globais (estado e fluxo).
- `scenes/`: cenas do jogo (`main`, `world`, `enemies`, `player`).
- `scripts/`: logicas em GDScript (player, andares, inimigos, utilitarios).
- `assets/`: sprites, efeitos e recursos visuais.
- `midia/`: imagens e trilhas.

## Como Executar

1. Abra o projeto no Godot 4.
2. Execute a cena principal com `F5`.
3. Para testar uma cena especifica, use `F6`.

Observacao: nao ha pipeline de build CLI nem testes automatizados neste repositorio.

## Controles

- `A` ou `Seta Esquerda`: mover para esquerda.
- `D` ou `Seta Direita`: mover para direita.
- `W`, `Espaco` ou `Seta Cima`: pular.
- `Mouse Esquerdo`: atacar.
- `E`: interagir (portal/NPC no hub).

## Fluxo de Progressao

1. Entrar em um andar via portal.
2. Eliminar todos os inimigos.
3. Ativar e usar o portal de saida.
4. Receber XP/moedas e repetir o ciclo em andares mais dificeis.

No hub, o jogador pode acessar andares desbloqueados e comprar itens essenciais para o proximo ciclo.

## Bosses e Combate

### Mushroom Boss (MiniBoss)

![Mushroom Boss](assets/sprites/Mushroom%20with%20VFX/Mushroom-Idle.png)

- Cena: `scenes/enemies/mini_boss.tscn`
- Script: `scripts/enemies/mini_boss.gd`
- Destaques:
	- Especial toxic burst com composicao de efeitos.
	- Mecanismo anti-head-lock para reduzir soft lock.

### Skeleton Boss

![Skeleton Boss](assets/sprites/enimies/Skeleton_White/Skeleton_With_VFX/Skeleton_01_White_Idle.png)

- Cena: `scenes/enemies/skeleton_boss.tscn`
- Script: `scripts/enemies/skeleton_boss.gd`
- Destaques:
	- Pressao de dano acima do inimigo comum.
	- Combate focado em timing e posicionamento.

## Persistencia

O jogo salva progresso basico em `user://savegame.json`, incluindo estado relevante para continuidade de partida entre sessoes.

## Roadmap

- Refinar balanceamento de dano/cooldown dos especiais.
- Consolidar inventario e equipamentos no loop principal.
- Evoluir feedback audiovisual de combate (SFX e VFX).
- Criar checklist de QA manual por andar.
- Expandir andares com novos tipos de inimigos e desafios.
