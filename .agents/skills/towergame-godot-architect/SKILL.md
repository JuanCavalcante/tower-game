---
name: towergame-godot-architect
description: Use when implementing or refactoring TowerGame features in Godot GDScript that must be delivered as complete, project-integrated scripts with exact file paths, node attachment points, and concrete test steps.
---

# TowerGame Godot Architect

## Purpose

Projetar, implementar e refatorar funcionalidades do TowerGame em Godot (GDScript) com foco em integração real no projeto, sem respostas parciais.  
Esta skill garante entregas completas para inimigos, combate, movimentação e interações, preservando os padrões existentes.

## When to Use

Use this skill when:
- O pedido envolver criação/ajuste de scripts GDScript no TowerGame.
- A mudança depender de cenas `.tscn`, nodes, sinais ou estrutura de pastas do Godot.
- O usuário precisar de código completo pronto para uso, não snippets.
- O escopo incluir inimigos, sistemas de combate, movimentação, IA ou interações.
- For necessário manter compatibilidade com padrões e nomes já existentes no projeto.

## When Not to Use

Do not use this skill when:
- O pedido for apenas conceitual, sem implementação.
- O usuário pedir apenas revisão textual de documentação sem alteração de código.
- A tarefa não for do projeto TowerGame em Godot/GDScript.
- O escopo exigir mudanças fora do projeto (infra externa, serviços web, etc.).

## Required Inputs

Collect or infer:
- Objetivo funcional da feature/correção.
- Arquivos-alvo e cenas impactadas (`scripts/*`, `scenes/*`, `autoload/*`).
- Node(s) onde o script deve ser anexado.
- Padrões existentes de nomenclatura, sinais, estados e fluxo de jogo.
- Critério de aceitação observável em gameplay.

## Workflow

1. Mapear contexto real do projeto:
- Ler scripts/cenas relacionadas para identificar padrões de nomes, funções, sinais e fluxo.
- Confirmar caminhos existentes antes de propor novos arquivos.

2. Definir impacto mínimo seguro:
- Planejar a menor mudança que resolva o problema sem quebrar comportamentos atuais.
- Priorizar compatibilidade com APIs internas já usadas no TowerGame.

3. Implementar código completo:
- Sempre gerar arquivo completo (nunca trecho solto).
- Incluir dependências necessárias no próprio script (extends, exports, onready, sinais, métodos auxiliares).
- Ajustar integração com nodes e cenas quando aplicável.

4. Integrar com Godot:
- Informar exatamente o caminho do arquivo no projeto.
- Informar exatamente em qual node/cena anexar o script.
- Se houver conexão de sinais, detalhar origem/destino e método receptor.

5. Validar segurança da alteração:
- Verificar consistência de nomes, paths e referências de cena.
- Evitar sobrescrever comportamentos existentes sem necessidade.
- Verificar se a alteração não introduz regressão clara em movimentação/combate/interações.

6. Entregar no formato obrigatório:
- Código completo.
- Caminho do arquivo.
- Onde anexar no Godot.
- Como testar de forma objetiva.

## Output Format (Obrigatório)

Sempre retornar, nesta ordem:

1. **Código completo**  
- Arquivo inteiro final, pronto para uso.

2. **Caminho do arquivo**  
- Caminho exato no projeto (ex.: `scripts/enemies/skeleton.gd`).

3. **Onde anexar no Godot**  
- Cena e node exatos para attachment (ex.: `scenes/enemies/skeleton.tscn` -> node `Skeleton`).
- Instruções de sinais, quando existir integração por eventos.

4. **Como testar**  
- Passo a passo curto e verificável no editor/runtime.
- Resultado esperado de gameplay (o que deve acontecer).

## Safety and Quality Rules

- Nunca entregar snippets quando o pedido envolver implementação.
- Nunca inventar nomes de nodes/cenas/paths sem conferir o projeto.
- Preservar nomenclatura e padrões já existentes.
- Não remover ou quebrar fluxos existentes sem justificativa técnica explícita.
- Priorizar alterações pequenas, coesas e com baixo risco de regressão.
- Em caso de ambiguidade bloqueante, perguntar apenas o mínimo necessário.

## Validation Checklist

Antes de finalizar, verificar:
- A saída contém **código completo**, sem partes omitidas.
- O **caminho do arquivo** está explícito e existe no contexto esperado.
- O **local de attachment no Godot** está claro (cena + node).
- O bloco de **como testar** é executável e objetivo.
- A solução considera `.tscn`, nodes e estrutura real do projeto.
- Nomes e padrões do TowerGame foram preservados.
- A alteração evita quebrar scripts existentes.
