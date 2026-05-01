# TowerGame Folder Structure

## Objetivo

Padronizar a organizacao de codigo e cenas para reduzir acoplamento por caminho e facilitar manutencao.

## Estrutura Atual

- `scripts/core/`: scripts centrais de bootstrap e ciclo principal.
- `scripts/world/`: logica de mundo e elementos compartilhados de floor.
- `scripts/world/floors/`: scripts especificos dos andares.
- `scripts/entities/enemies/`: IA e comportamento de inimigos.
- `scripts/entities/player/`: comportamento do player.
- `scripts/items/`: scripts de itens/coletaveis.
- `scripts/ui/`: scripts de interface.
- `scripts/autoload/`: singletons globais.
- `scenes/world/`: cenas de mapa/floors.
- `scenes/enemies/`: cenas de inimigos.
- `scenes/player/`: cena do player.
- `scenes/ui/`: cenas de UI.
- `scenes/items/`: cenas de itens/coletaveis.

## Migracao Aplicada

- `scripts/main.gd` -> `scripts/core/main.gd`
- `scripts/base_floor.gd` -> `scripts/world/base_floor.gd`
- `scripts/exit_portal.gd` -> `scripts/world/exit_portal.gd`
- `scripts/floor_*.gd` -> `scripts/world/floors/floor_*.gd`
- `scripts/enemies/*` -> `scripts/entities/enemies/*`
- `scripts/player/player.gd` -> `scripts/entities/player/player.gd`
- `scripts/coin/coin_pickup.gd` -> `scripts/items/coin_pickup.gd`
- `scripts/coin/coin.tscn` -> `scenes/items/coin.tscn`
- `autoload/*.gd` -> `scripts/autoload/*.gd`

## Regras

- Ao mover scripts/cenas, atualizar todas as referencias `res://` em `.gd`, `.tscn`, `.tres` e `project.godot`.
- Evitar aliases redundantes de script quando houver um arquivo canonico.
- Validar com smoke headless apos qualquer alteracao estrutural.
