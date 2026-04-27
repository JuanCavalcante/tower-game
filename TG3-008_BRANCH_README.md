# TG3-008 - Ajustes de Combate e Correcoes de Bugs

## Resumo
Este branch implementa as correcoes da issue #18 com foco em estabilidade de combate, consistencia de hitbox e eliminacao de soft lock sem quebrar a logica de clean all dos andares.

## Objetivo
- Melhorar a conexao visual do ataque do player com o registro real de dano.
- Corrigir comportamento de knockback exagerado no miniboss do andar 3.
- Reduzir cenarios de soft lock por sobreposicao inimigo/player.
- Remover bloqueio de colisao apos morte dos inimigos.

## Escopo Implementado

### 1) Hitbox do Player
Arquivo: scripts/player/player.gd
- Aumentado levemente o alcance efetivo do golpe para reduzir falso negativo em contato visual.
- Adicionada tolerancia vertical de ataque para lidar com diferenca pequena de altura.
- Ajustado criterio de frente para permitir acerto quando o inimigo esta quase sobre o eixo do player.

### 2) Knockback do Miniboss
Arquivos: scripts/enemies/base_enemy.gd, scripts/enemies/slime.gd
- Criado calculo padronizado de knockback com limites de componente vertical.
- Slime (e consequentemente miniboss) passou a usar o mesmo calculo, evitando lancamento vertical exagerado.
- Mantido impacto horizontal minimo para preservar feedback de golpe.

### 3) Soft Lock Inimigo sobre Player
Arquivos: scripts/player/player.gd, scripts/enemies/base_enemy.gd, scripts/enemies/mini_boss.gd
- Player ganhou janela de acerto mais robusta para casos de sobreposicao vertical controlada.
- Ataque de inimigos (base e miniboss) agora valida hitbox antes de aplicar dano, reduzindo hit fantasma e inconsistencias de contato.
- Miniboss ganhou mecanismo anti-head-lock: ao ficar sobre a cabeca do player, ativa escape lateral com bypass temporario de colisao e pisao especial com efeito.

### 4) Colisao apos Morte
Arquivos: scripts/enemies/base_enemy.gd, scripts/enemies/skeleton.gd
- Colisao do corpo e da DamageArea e desligada ao iniciar o estado de morte.
- Inimigo nao bloqueia movimentacao do player durante animacao de morte.
- Skeleton/skeleton_boss agora entram em modo ghost ja no inicio da animacao de morte, evitando bloqueio de passagem antes do queue_free.
- Fluxo de XP, coins, enemy_killed e queue_free mantido.

## Evidencias

### Evidencia de Codigo Alterado
- scripts/player/player.gd
- scripts/enemies/base_enemy.gd
- scripts/enemies/slime.gd
- scripts/enemies/mini_boss.gd

### Evidencia de Cobertura dos Criterios
- Ataque do player mais consistente com animacao: ajuste de alcance + tolerancia vertical.
- Miniboss sem knockback vertical exagerado: padronizacao com clamp no eixo Y.
- Menor risco de inimigo inalcancavel em sobreposicao: janela de acerto mais tolerante no player.
- Inimigos mortos sem bloqueio de caminho: desligamento de collision layer/mask e shapes.
- Clean all preservado: sem alteracoes em scripts/base_floor.gd e scripts/floor_01.gd.

## Riscos Conhecidos
1. O ajuste de hitbox do player pode facilitar ligeiramente acertos em borda de alcance; requer validacao de game feel.
2. O clamp vertical do knockback reduz picos extremos, mas pode diminuir variacao visual em alguns hits.
3. Cenarios com muitos inimigos empilhados ainda dependem de teste de campo no Godot (colisao dinamica em runtime).

## Testes Recomendados (Manual)
1. Andar 3: repetir combate com miniboss varias vezes e confirmar ausencia de lancamento vertical extremo.
2. Combate em plataforma: deixar inimigos cairem sobre o player e testar se continuam atingiveis.
3. Sequencia de mortes: matar inimigos encostado e confirmar passagem imediata sem bloqueio.
4. Regressao clean all: validar que portal ativa apenas apos eliminar todos inimigos do andar.

## Proximos Passos
1. Validar game feel de alcance do player com o time de design.
2. Se necessario, expor tolerancias de hitbox como @export para ajuste fino sem alterar codigo.
3. Consolidar checklist da issue #18 no PR e anexar video curto de reproducao dos testes criticos.

## Checklist de Aceite (Issue #18)
- [x] Ataques do player conectam de forma mais consistente com o visual.
- [x] Miniboss sem deslocamento vertical exagerado ao receber dano.
- [x] Reducao de cenarios de inimigo inalcancavel por sobreposicao com player.
- [x] Inimigos mortos nao bloqueiam movimento do jogador.
- [x] Fluxo clean all preservado (sem mudanca de regra de conclusao).
