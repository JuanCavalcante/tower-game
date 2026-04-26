# Issue 2 - Quebra de Tarefas (Ready)

## Padrão de serial e branch
- Serial: TG2-001, TG2-002, TG2-003...
- Branch por tarefa: feat/TG2-XXX-nome-curto
- Exemplo: feat/TG2-007-hub-scene

## Análise do que já está OK
1. TG2-OK-01 - Sistema de 3 andares carregáveis
Status: OK
Observação: fluxo de floor 1, 2 e 3 implementado.

2. TG2-OK-02 - Mini boss no andar 3
Status: OK
Observação: cena e script de mini boss presentes e instanciados no floor 3.

3. TG2-OK-03 - XP e level up básico
Status: OK
Observação: ganho de XP e level up com aumento de atributos já implementados.

4. TG2-OK-04 - Portal funcional básico
Status: OK (básico)
Observação: portal ativa ao limpar andar e carrega próximo andar.

5. TG2-OK-05 - HUD base e menu de pausa
Status: Parcial para roadmap completo
Observação: base visual existe, mas falta parte de inventário/equipamento e refinos.

## Tarefas pendentes para aba Ready

1. TG2-001 - Hub inicial (cidade) com entrada e saída da torre
Branch: feat/TG2-001-hub-base
Tipo: Cena e fluxo
Objetivo: criar uma cena de hub com ponto de spawn, NPC vendedor e portal para torre.
Critério de pronto:
- Cena do hub carregável.
- Player entra no hub após sair da torre.
- Hub possui interação básica com NPC e retorno para torre.

2. TG2-002 - NPC vendedor com interação simples
Branch: feat/TG2-002-vendor-interaction
Tipo: Gameplay
Objetivo: implementar área de interação e abertura de menu de vendedor.
Critério de pronto:
- Tecla de interação abre menu quando player estiver perto.
- NPC não abre menu fora do alcance.
- Feedback visual de interação disponível.

3. TG2-003 - Loja com compra de 1 poção de vida
Branch: feat/TG2-003-shop-potion
Tipo: Sistema
Objetivo: permitir comprar poção de vida com moedas.
Critério de pronto:
- Exibe custo.
- Valida saldo.
- Debita moedas e adiciona item ao inventário.

4. TG2-004 - Loja com 1 equipamento básico (arma melhor)
Branch: feat/TG2-004-shop-weapon
Tipo: Sistema
Objetivo: permitir comprar equipamento básico que melhore dano.
Critério de pronto:
- Compra única ou troca controlada.
- Dano do player atualizado.
- Estado salvo e restaurado ao carregar jogo.

5. TG2-005 - Inventário mínimo e uso de poção
Branch: feat/TG2-005-inventory-potion-use
Tipo: Sistema/UI
Objetivo: inventário simples para armazenar e consumir poção.
Critério de pronto:
- Contador de poções visível.
- Consumo cura player.
- Não permite uso sem item.

6. TG2-006 - UI completa do HUD (vida, XP, floor, item equipado)
Branch: feat/TG2-006-hud-complete
Tipo: UI
Objetivo: completar HUD para atender checklist de MVP.
Critério de pronto:
- Vida e XP atualizam em tempo real.
- Andar atual visível.
- Item/equipamento atual visível.

7. TG2-007 - Feedback de combate com partículas no ataque
Branch: feat/TG2-007-combat-vfx
Tipo: Polimento
Objetivo: adicionar efeito visual de impacto e ataque.
Critério de pronto:
- Partícula dispara no ataque.
- Partícula de hit no inimigo.
- Sem queda perceptível de desempenho.

8. TG2-008 - SFX básico (hit, morte inimigo, portal)
Branch: feat/TG2-008-audio-sfx
Tipo: Áudio
Objetivo: adicionar efeitos sonoros essenciais.
Critério de pronto:
- Som de hit reproduzido no dano.
- Som de morte no inimigo.
- Som de ativação/uso do portal.

9. TG2-009 - Transição com fade entre andares
Branch: feat/TG2-009-floor-fade-transition
Tipo: UX
Objetivo: inserir fade-in/fade-out nas trocas de andar.
Critério de pronto:
- Fade antes e depois da troca de cena.
- Sem teleporte visual brusco.
- Player mantém posição correta de spawn.

10. TG2-010 - Reset controlado de inimigos do andar anterior
Branch: feat/TG2-010-floor-reset-rules
Tipo: Gameplay
Objetivo: garantir regra clara de reset ao avançar de andar.
Critério de pronto:
- Ao avançar, andar anterior reseta inimigos.
- Não duplica entidades ao retornar.
- Regra documentada no código.

11. TG2-011 - Teste de loop completo 2x
Branch: chore/TG2-011-mvp-loop-test
Tipo: QA
Objetivo: validar fluxo de jogo fim a fim duas vezes sem quebrar.
Critério de pronto:
- Torre 1 a 3 concluída.
- Mini boss derrotado.
- Retorno ao hub e compra de item.
- Novo ciclo iniciado e concluído novamente.

12. TG2-012 - Ajuste final do mini boss (balanceamento)
Branch: feat/TG2-012-miniboss-balance
Tipo: Gameplay
Objetivo: garantir que mini boss esteja claramente acima do inimigo comum.
Critério de pronto:
- Vida maior.
- Pressão de ataque maior.
- Recompensa especial em moedas definida.

## Ordem recomendada (Ready)
1. TG2-001
2. TG2-002
3. TG2-003
4. TG2-004
5. TG2-005
6. TG2-006
7. TG2-009
8. TG2-010
9. TG2-008
10. TG2-007
11. TG2-012
12. TG2-011

## Modelo de card para o board (copiar e colar)
Título: [TG2-XXX] Nome da tarefa
Descrição:
- Objetivo:
- Critério de pronto:
- Dependências:
- Branch: feat/TG2-XXX-nome-curto
- Issue mãe: #2
