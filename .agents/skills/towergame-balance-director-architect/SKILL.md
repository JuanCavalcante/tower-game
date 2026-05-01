---
name: towergame-balance-director-architect
description: Use when implementing adaptive TowerGame balancing in Godot with a Balance Director that reads run state and subtly adjusts pressure, waves, and rewards without breaking existing floor rules.
---

# TowerGame Balance Director Architect

## Purpose

Projetar e implementar um sistema de balanceamento adaptativo para o TowerGame baseado em estado da run, mantendo o balanceamento base manual e aplicando ajustes sutis de dificuldade, wave e recompensa.

O objetivo nao e "adivinhar tudo", e sim decidir com regras claras:
- quando aliviar pressao,
- quando manter normal,
- quando aumentar tensao,
sem parecer trapaça para o jogador.

## When to Use

Use this skill when:
- O usuario pedir dificuldade dinamica por performance do jogador.
- Houver necessidade de ajustar `waves`, quantidade de inimigos, HP/dano/XP e ritmo por andar.
- O time quiser evitar ajuste manual numero a numero em cada alteracao.
- O design exigir regras especiais para miniboss/boss (ex.: boss do floor 10 solo).
- O pedido incluir camadas de diretores (`BalanceDirector`, `WaveDirector`, `RewardDirector`).

## When Not to Use

Do not use this skill when:
- O pedido for balanceamento totalmente fixo e estatico sem adaptacao.
- O escopo for somente bug tecnico de cena sem relacao com dificuldade.
- Nao houver dados minimos de estado do jogador/run para tomada de decisao.
- O usuario pedir tuning rapido pontual de um unico valor sem sistema.

## Required Inputs

Collect or infer:
- Tabela base atual (`FloorBalance`) por andar e role.
- Regras obrigatorias do jogo (ex.: floor 10 com boss unico sem minions/reforcos).
- Dados de run disponiveis:
  - andar atual,
  - vida atual/maxima,
  - pocoes,
  - upgrades comprados,
  - tempo medio de clear,
  - mortes recentes/acumuladas,
  - dano recebido recente.
- Pontos de integracao existentes em `scripts/base_floor.gd`, `autoload/*` e spawners.

## Workflow

1. Inspecionar o contrato de balanceamento atual:
- mapear onde os valores base sao definidos e aplicados.
- preservar `FloorBalance` como fonte base fixa.

2. Definir modelo de estado da run:
- criar snapshot simples (Dictionary estruturado ou classe) com metricas da run.
- padronizar thresholds para classificar estado: `mercy`, `relief`, `normal`, `pressure`.

3. Implementar `BalanceDirector`:
- ler snapshot da run.
- classificar estado de dificuldade.
- aplicar multiplicadores sutis com clamp e conversao para tipos corretos.
- manter comportamento deterministico e auditavel.

4. Implementar `WaveDirector`:
- decidir se o andar usa waves ou encounter pre-setado.
- controlar quantidade de waves, contagem por wave e ritmo de spawn.
- nunca violar regra especial de boss solo do floor 10.

5. Implementar `RewardDirector`:
- ajustar XP/moedas/chance de pocao com variacao moderada.
- evitar snowball extremo (positivo ou negativo).

6. Integrar sem regressao:
- conectar os diretores ao fluxo atual de spawn/aplicacao de stats.
- manter fallback para `normal` quando dados de run estiverem incompletos.
- preservar nomes e padroes ja existentes do projeto.

7. Validar gameplay:
- testar cenarios de run fraca, media e forte.
- confirmar que as mudancas sao percebidas como tensao gradual, nao "rubber band" escancarado.

## Output Format (Obrigatorio)

Sempre retornar nesta ordem:

1. Codigo completo
- Arquivos completos finais (nunca snippet solto).

2. Caminho do arquivo
- Path exato de cada arquivo no projeto.

3. Onde anexar/ligar no Godot
- Cena/node/script de integracao (ou ponto de chamada em autoload/scripts).
- Sinais/callbacks necessarios, quando houver.

4. Como testar
- Passo a passo objetivo com ao menos 3 cenarios:
  - jogador em vantagem (`pressure`),
  - jogador em risco (`relief/mercy`),
  - fluxo normal (`normal`).
- Resultado esperado por cenario.

## Safety and Quality Rules

- Nao substituir o balanceamento base; o diretor apenas ajusta.
- Nao fazer mudancas abruptas (ex.: dobrar inimigos de uma vez).
- Preferir ajustes pequenos e consistentes (laminas sutis):
  - HP: variacao moderada,
  - dano: variacao moderada,
  - XP/recompensa: compensacao proporcional.
- Nunca quebrar regras de design fixas (ex.: floor 10 boss solo).
- Nao introduzir comportamento opaco: logar/explicar decisao do estado quando necessario para debug.
- Evitar acoplamento excessivo; separar responsabilidades por diretor.

## Validation Checklist

Before finishing, verify:
- `FloorBalance` continua como base fixa.
- Estado de dificuldade e classificado por regras claras e reproduziveis.
- Multiplicadores usam clamps e conversao segura de tipo.
- `WaveDirector` respeita regras por andar e boss-only no floor 10.
- `RewardDirector` nao gera inflacao ou punição excessiva.
- A saida contem codigo completo, caminhos exatos, ponto de integracao e teste.
- Nao ha quebra de scripts/cenas existentes.

