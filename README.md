# Tower Game

![Godot](https://img.shields.io/badge/Engine-Godot_4.6-478cbf?logo=godot-engine&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active_Development-2ea44f)
![Language](https://img.shields.io/badge/Scripting-GDScript-6c7a89)

Jogo 2D em Godot 4 com loop de **hub + torre**: o jogador evolui atributos, enfrenta inimigos por andar, coleta moedas, compra itens e progride pelos portais.

## Estado Atual

- Hub de cidade funcional (`floor_00_city`) como ponto central.
- Andares jogáveis mapeados de `0` a `10`.
- Combate melee com acerto crítico, cooldown dinâmico e escalonamento por atributos.
- Sistema persistente de `XP`, `level`, `moedas`, `poções` e equipamentos.
- Painéis de personagem (`C`) e inventário (`I`).
- Save/load em `user://savegame.json`.

## Funcionalidades Principais

### Loop de jogo
- Novo jogo e continuar do save.
- Retorno ao hub preservando progresso.
- Portal do hub com bloqueio/desbloqueio de andares.
- Portal de saída nos andares de combate após limpar inimigos.

### Combate e inimigos
- Player com ataque melee e regras de hit por direção/alcance.
- IA base para inimigos (`idle/chase/attack`).
- Miniboss no andar 5 e boss final no andar 10.
- Regra do andar 10: apenas boss único (sem minions).

### Progressão
- Atributos: Força, Vitalidade, Destreza, Inteligência e Sorte.
- Level up com pontos de atributo.
- Escalonamento de HP/Stamina/Mana por nível + atributos.
- Redução de dano por armadura/equipamentos.

## Estrutura do Projeto

### Scripts
- `scripts/core/` - fluxo principal (`main.gd`).
- `scripts/autoload/` - singletons (`GameManager`, `PlayerStats`).
- `scripts/world/` - lógica de mundo e contrato base de floors.
- `scripts/world/floors/` - scripts específicos por andar.
- `scripts/entities/` - player e inimigos.
- `scripts/items/` - itens/coletáveis.
- `scripts/ui/` - painéis e componentes de interface.
- `scripts/balance/` - tabela de balanceamento em runtime.

### Cenas
- `scenes/main.tscn` - cena raiz.
- `scenes/world/floor_00_city.tscn` - hub.
- `scenes/world/floors/floor_01_10/` - andares 1..10.
- `scenes/enemies/`, `scenes/player/`, `scenes/ui/`, `scenes/items/`.

### Escalabilidade de andares
A convenção atual organiza os andares por faixa:
- `floor_01_10`
- `floor_11_20`
- `floor_21_30`
- ...

Isso evita um diretório único muito grande em `scenes/world`.

## Fonte de Verdade Técnica

- Mapa de carregamento de andares: `scripts/autoload/GameManager.gd`
- Balanceamento aplicado em runtime: `scripts/balance/floor_balance.gd`
- Documentação de estrutura: `docs/architecture/folder_structure.md`

## Controles

- `A` / `Seta Esquerda`: mover para esquerda.
- `D` / `Seta Direita`: mover para direita.
- `W` / `Espaço` / `Seta Cima`: pular.
- `Mouse Esquerdo`: atacar.
- `E`: interagir.
- `Q`: usar poção.
- `C`: painel de status.
- `I`: inventário.
- `Esc`: pausa.

## Como Executar

### Editor
1. Abrir no Godot 4.6.
2. Rodar `scenes/main.tscn` (`F5`).

### Smoke headless
```powershell
& "C:\Users\juanc\Desktop\Godot_v4.6.2-stable_win64.exe\Godot.exe" --headless --path D:\projeto_game_mvp\tower-game --quit
```

## Persistência

Arquivo de save:
- `user://savegame.json`

Dados persistidos:
- andar atual
- andares desbloqueados
- estado completo de `PlayerStats`

## Limitações Conhecidas

- Ainda não há suíte automatizada de testes de gameplay.
- O smoke headless pode encerrar com warning de `ObjectDB instances leaked` (não bloqueia o carregamento principal).

## Skills de Trabalho (Agentes)

- `.agents/skills/towergame-folder-structure-standardizer`
- `.agents/skills/towergame-post-change-mechanics-guard`
- `.agents/skills/towergame-cross-agent-governance`
