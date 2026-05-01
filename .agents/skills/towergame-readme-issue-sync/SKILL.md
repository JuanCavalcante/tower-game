---
name: towergame-readme-issue-sync
description: Use when a TowerGame issue is completed to update README.md in the same workflow, keeping roadmap phases, pending items, and related deliveries synchronized with the current project state.
---

# TowerGame README Issue Sync

## Purpose

Garantir que toda issue concluida no TowerGame gere atualizacao correspondente no `README.md` no mesmo fluxo de trabalho, evitando divergencia entre status real do projeto e documentacao publica.

## When to Use

Use this skill when:
- Uma issue for concluida (localmente ou no GitHub) e impactar status do projeto.
- Houver merge de PR que fecha issue de roadmap.
- O estado de fases (`Concluida`, `Em andamento`, `Pendente`) mudar.
- Itens de `Pendencias principais` ou `Entregas relacionadas` precisarem ser atualizados.

## When Not to Use

Do not use this skill when:
- A issue concluida nao altera escopo/status do README.
- O pedido for apenas ajuste de codigo interno sem reflexo em roadmap/documentacao.
- O repositório alvo nao for o TowerGame.

## Required Inputs

Collect or infer:
- Numero da issue e titulo.
- Resultado entregue (o que foi implementado de fato).
- Arquivos/funcionalidades impactadas.
- Novo status de fase no roadmap.
- Se existem outras pendencias dependentes que tambem mudam de estado.

## Workflow

1. Confirmar conclusao da issue:
- validar criterio de pronto (DoD) e evidencias de entrega.

2. Mapear impacto no README:
- localizar secao de fase correspondente.
- atualizar `Pendencias principais` e `Entregas relacionadas`.
- ajustar `Proximo Marco Recomendado` quando a prioridade mudar.

3. Atualizar status de roadmap:
- mover item de pendente para concluido quando aplicavel.
- manter consistencia de texto entre fases.

4. Atualizar data de referencia:
- quando houver mudanca de estado relevante, atualizar a linha de status de referencia do roadmap.

5. Validar consistencia final:
- issue concluida precisa aparecer refletida no README.
- nao deixar item simultaneamente como concluido e pendente.

6. Entregar junto:
- codigo/documentacao da issue + README sincronizado no mesmo pacote de mudanca.

## Output Format

Return:
- Issue concluida (`#numero`, titulo).
- Secoes alteradas no README.
- Resumo objetivo do que mudou no roadmap.
- Arquivo alterado com caminho exato.
- Validacao final de consistencia (`OK` ou pendencias restantes).

## Safety and Quality Rules

- Nao marcar concluido sem evidencia de implementacao real.
- Nao deixar roadmap desatualizado apos fechamento de issue.
- Preservar linguagem e estrutura ja usadas no README.
- Evitar reescrita ampla; alterar apenas o necessario para refletir o estado atual.
- Se houver incerteza de fase, explicitar a suposicao no resultado.

## Validation Checklist

Before finishing, verify:
- A issue concluida foi refletida no `README.md`.
- `Pendencias principais` da fase foram atualizadas corretamente.
- `Entregas relacionadas` inclui a issue/PR correta.
- `Proximo Marco Recomendado` foi revisado apos a mudanca.
- Nao ha contradicao de status entre fases.
- A entrega inclui o caminho do arquivo alterado (`README.md`).

