# Evidências

Esta pasta reúne o que comprova o funcionamento do banco do CellGO.

## Testes das regras

| Arquivo | O que comprova |
|---|---|
| [`testes_triggers.sql`](testes_triggers.sql) | As triggers aceitam as operações corretas e barram as erradas (135 testes) |
| [`testes_validacoes.sql`](testes_validacoes.sql) | As restrições das tabelas barram dados preenchidos de forma errada (171 testes) |

Os testes devem rodar em um banco limpo, depois de [`tabelas.sql`](../sql/ddl/tabelas.sql) e [`trigger.sql`](../sql/ddl/trigger.sql). Cada teste roda dentro de uma transação desfeita no final, então o banco não é alterado.

## Etapa 8: análise de dados

| Documento | Conteúdo |
|---|---|
| [Indicadores](etapa8/CellGO_Etapa8_Indicadores.docx) | 8.1 e 8.2: margem bruta, tempo em estoque e taxa de recusa, com as consultas SQL |
| [Informações Gerenciais](etapa8/CellGO_Etapa8_Informacoes_Gerenciais.docx) | 8.3: painel de vendas, pós-venda e estornos e histórico do cliente |
| [Tomada de Decisão](etapa8/CellGO_Etapa8_Tomada_de_Decisao.docx) | 8.4: decisões apoiadas pelos dados |
| [Business Intelligence](etapa8/CellGO_Etapa8_BI.docx) | 8.5: modelo estrela e painéis de BI |
| [Aplicações de IA](etapa8/CellGO_Etapa8_IA.docx) | 8.6: aplicações futuras de IA |
