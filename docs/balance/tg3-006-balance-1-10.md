# TG3-006 - Tabela de Balanceamento 1..10

Objetivo: vertical slice de 20-30 minutos com curva clara e boss final no andar 10 sem minions.

## Curva

- Andares 1..3: onboarding e baixo risco.
- Andares 4..6: pressao moderada.
- Andares 7..9: alta pressao controlada.
- Andar 10: encounter final com apenas 1 boss.

## Waves (andar 1)

| Wave | Inimigos | Delay spawn | Tempo de respiro |
|---|---:|---:|---:|
| 1 | 3 | 0.85s | 1.4s |
| 2 | 4 | 0.80s | 1.3s |
| 3 | 5 | 0.75s | 1.2s |

## Tabela de stats por role

| Andar | Role | HP | Dano | XP | Velocidade | Attack cooldown | Armadura |
|---|---|---:|---:|---:|---:|---:|---|
| 1 | Minion | 30 | 8 | 18 | 95 | 1.10 | - |
| 2 | Minion | 36 | 9 | 20 | 100 | 1.05 | - |
| 3 | Minion | 44 | 10 | 24 | 105 | 1.00 | - |
| 4 | Minion | 50 | 11 | 28 | 112 | 0.95 | - |
| 5 | Minion | 58 | 12 | 32 | 118 | 0.92 | - |
| 5 | Miniboss | 140 | 26 | 84 | 236 | 0.46 | - |
| 6 | Minion | 68 | 13 | 36 | 124 | 0.90 | - |
| 7 | Minion | 80 | 14 | 40 | 132 | 0.88 | - |
| 8 | Minion | 94 | 16 | 45 | 140 | 0.86 | - |
| 9 | Minion | 108 | 18 | 50 | 148 | 0.84 | - |
| 10 | Boss Unico | 1400 | 58 | 220 | 340 | 0.28 | 48% + 2 flat |

## Regras obrigatorias atendidas

- Miniboss e Boss Unico configurados com dano e velocidade >= 2x minions da mesma faixa.
- Andar 10 remove minions automaticamente em runtime e mantem apenas boss.
- Boss do andar 10 recebe mitigacao adicional quando player esta abaixo do nivel 12.

