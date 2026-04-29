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

| Andar | Role | HP | Dano | XP | Velocidade | Attack cooldown |
|---|---|---:|---:|---:|---:|---:|
| 1 | Minion | 30 | 8 | 18 | 95 | 1.10 |
| 2 | Minion | 36 | 9 | 20 | 100 | 1.05 |
| 3 | Minion | 44 | 10 | 24 | 105 | 1.00 |
| 3 | Miniboss | 96 | 20 | 56 | 210 | 0.52 |
| 4 | Minion | 50 | 11 | 28 | 112 | 0.95 |
| 4 | Boss | 120 | 24 | 72 | 224 | 0.48 |
| 5 | Minion | 58 | 12 | 32 | 118 | 0.92 |
| 5 | Boss | 140 | 26 | 84 | 236 | 0.46 |
| 6 | Minion | 68 | 13 | 36 | 124 | 0.90 |
| 6 | Boss | 164 | 28 | 98 | 248 | 0.44 |
| 7 | Minion | 80 | 14 | 40 | 132 | 0.88 |
| 7 | Boss | 192 | 31 | 116 | 264 | 0.42 |
| 8 | Minion | 94 | 16 | 45 | 140 | 0.86 |
| 8 | Boss | 226 | 34 | 136 | 280 | 0.40 |
| 9 | Minion | 108 | 18 | 50 | 148 | 0.84 |
| 9 | Boss | 264 | 38 | 160 | 296 | 0.38 |
| 10 | Boss | 340 | 44 | 220 | 320 | 0.34 |

## Regras obrigatorias atendidas

- Boss e miniboss configurados com dano e velocidade >= 2x minions da mesma faixa.
- Andar 10 remove minions automaticamente em runtime e mantem apenas boss.
