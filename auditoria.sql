/* =====================================================================
   CellGO — Consultas de auditoria
   SGBD: MySQL 8
   Execute depois de tabelas.sql, trigger.sql e dos inserts.

   Fontes da auditoria no banco:
   - AUDITORIA: registro de cada ação sensível (preço, custo, parâmetros
     de estoque, pagamentos, cancelamentos, devoluções, trocas, estornos
     e requisições de compra), com quem fez, quem autorizou e os valores
     antes e depois, gravados em JSON pelas triggers (RN-23 / RNF-07);
   - MOVIMENTACAO: histórico de status de cada aparelho, por IMEI.
   Os dois históricos não podem ser alterados nem excluídos (triggers).

   Os valores em JSON são lidos com o operador ->> do MySQL 8,
   por exemplo: Valor_Novo ->> '$.Preco_Venda'.
   ===================================================================== */

USE cellgo;


/* =====================================================================
   1. Visão geral do log de auditoria
   ===================================================================== */

/* 1.1 Log completo: o que foi feito, em qual registro, por quem e quem
       autorizou (FUNCIONARIO usado duas vezes; ação automática não tem
       funcionário) */
SELECT au.Id_Auditoria, au.Data_Hora, au.Acao, au.Tabela_Afetada, au.Registro_Id,
       COALESCE(fe.Nome, 'Automática') AS Executado_Por,
       fa.Nome                         AS Autorizado_Por,
       au.Valor_Anterior, au.Valor_Novo, au.Descricao
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO fe ON fe.Codigo_Funcionario = au.Codigo_Funcionario
  LEFT JOIN FUNCIONARIO fa ON fa.Codigo_Funcionario = au.Codigo_Autorizador
 ORDER BY au.Data_Hora DESC;

/* 1.2 Ações registradas nos últimos 7 dias */
SELECT au.Data_Hora, au.Acao, au.Tabela_Afetada, au.Registro_Id,
       COALESCE(f.Nome, 'Automática') AS Executado_Por
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO f ON f.Codigo_Funcionario = au.Codigo_Funcionario
 WHERE au.Data_Hora >= DATE_SUB(NOW(), INTERVAL 7 DAY)
 ORDER BY au.Data_Hora DESC;

/* 1.3 Quantidade de registros por tabela e por ação */
SELECT Tabela_Afetada, Acao, COUNT(*) AS Registros,
       MIN(Data_Hora) AS Primeiro, MAX(Data_Hora) AS Ultimo
  FROM AUDITORIA
 GROUP BY Tabela_Afetada, Acao
 ORDER BY Tabela_Afetada, Registros DESC;

/* 1.4 Quantidade de ações por funcionário e perfil (inclui as automáticas) */
SELECT COALESCE(f.Nome, 'Automática (sistema)') AS Funcionario,
       p.Nome_Perfil,
       COUNT(*)          AS Acoes,
       MAX(au.Data_Hora) AS Ultima_Acao
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO f   ON f.Codigo_Funcionario = au.Codigo_Funcionario
  LEFT JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
 GROUP BY f.Codigo_Funcionario, f.Nome, p.Nome_Perfil
 ORDER BY Acoes DESC;

/* 1.5 Ações autorizadas pela Diretoria (com autorizador registrado) */
SELECT au.Data_Hora, au.Acao, au.Tabela_Afetada, au.Registro_Id,
       fe.Nome AS Executado_Por, fa.Nome AS Autorizado_Por, au.Descricao
  FROM AUDITORIA au
  JOIN FUNCIONARIO fa      ON fa.Codigo_Funcionario = au.Codigo_Autorizador
  LEFT JOIN FUNCIONARIO fe ON fe.Codigo_Funcionario = au.Codigo_Funcionario
 ORDER BY au.Data_Hora DESC;

/* 1.6 Ações feitas por funcionários que hoje estão inativos */
SELECT f.Nome, f.Cargo, au.Data_Hora, au.Acao, au.Tabela_Afetada, au.Registro_Id
  FROM AUDITORIA au
  JOIN FUNCIONARIO f ON f.Codigo_Funcionario = au.Codigo_Funcionario
 WHERE f.Ativo = 0
 ORDER BY f.Nome, au.Data_Hora;


/* =====================================================================
   2. Preços, custos e parâmetros (ações exclusivas da Diretoria)
   ===================================================================== */

/* 2.1 Histórico de alterações de preço e de desconto Pix, com o valor
       antes e depois, a variação e o aparelho */
SELECT au.Data_Hora, au.Registro_Id AS Imei, m.Nome_Modelo, e.Cor, e.Capacidade,
       CAST(au.Valor_Anterior ->> '$.Preco_Venda' AS DECIMAL(10,2)) AS Preco_Anterior,
       CAST(au.Valor_Novo     ->> '$.Preco_Venda' AS DECIMAL(10,2)) AS Preco_Novo,
       CAST(au.Valor_Novo ->> '$.Preco_Venda' AS DECIMAL(10,2))
     - CAST(au.Valor_Anterior ->> '$.Preco_Venda' AS DECIMAL(10,2)) AS Variacao,
       au.Valor_Anterior ->> '$.Elegivel_Desconto_Pix' AS Pix_Antes,
       au.Valor_Novo     ->> '$.Elegivel_Desconto_Pix' AS Pix_Depois,
       fa.Nome AS Autorizado_Por
  FROM AUDITORIA au
  JOIN APARELHO a               ON a.Imei = au.Registro_Id
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
  LEFT JOIN FUNCIONARIO fa      ON fa.Codigo_Funcionario = au.Codigo_Autorizador
 WHERE au.Acao = 'Alteração de preço/desconto'
 ORDER BY au.Data_Hora DESC;

/* 2.2 Reduções de preço maiores que 10% (para revisão) */
SELECT au.Data_Hora, au.Registro_Id AS Imei,
       CAST(au.Valor_Anterior ->> '$.Preco_Venda' AS DECIMAL(10,2)) AS Preco_Anterior,
       CAST(au.Valor_Novo     ->> '$.Preco_Venda' AS DECIMAL(10,2)) AS Preco_Novo,
       ROUND(100 * (1 - CAST(au.Valor_Novo ->> '$.Preco_Venda' AS DECIMAL(10,2))
                      / CAST(au.Valor_Anterior ->> '$.Preco_Venda' AS DECIMAL(10,2))), 1) AS Reducao_Percentual,
       fa.Nome AS Autorizado_Por
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO fa ON fa.Codigo_Funcionario = au.Codigo_Autorizador
 WHERE au.Acao = 'Alteração de preço/desconto'
   AND CAST(au.Valor_Novo ->> '$.Preco_Venda' AS DECIMAL(10,2))
     < CAST(au.Valor_Anterior ->> '$.Preco_Venda' AS DECIMAL(10,2)) * 0.90
 ORDER BY Reducao_Percentual DESC;

/* 2.3 Correções de custo de aquisição */
SELECT au.Data_Hora, au.Registro_Id AS Imei,
       au.Valor_Anterior ->> '$.Custo_Aquisicao' AS Custo_Anterior,
       au.Valor_Novo     ->> '$.Custo_Aquisicao' AS Custo_Novo,
       COALESCE(f.Nome, 'Automática') AS Executado_Por
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO f ON f.Codigo_Funcionario = au.Codigo_Funcionario
 WHERE au.Acao = 'Alteração de custo'
 ORDER BY au.Data_Hora DESC;

/* 2.4 Alterações de estoque mínimo e limites de giro, por especificação */
SELECT au.Data_Hora, m.Nome_Modelo, e.Cor, e.Capacidade,
       au.Valor_Anterior ->> '$.Estoque_Minimo'      AS Estoque_Min_Antes,
       au.Valor_Novo     ->> '$.Estoque_Minimo'      AS Estoque_Min_Depois,
       au.Valor_Anterior ->> '$.Limite_Dias_Atencao' AS Atencao_Antes,
       au.Valor_Novo     ->> '$.Limite_Dias_Atencao' AS Atencao_Depois,
       au.Valor_Anterior ->> '$.Limite_Dias_Critico' AS Critico_Antes,
       au.Valor_Novo     ->> '$.Limite_Dias_Critico' AS Critico_Depois,
       fa.Nome AS Autorizado_Por
  FROM AUDITORIA au
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = CAST(au.Registro_Id AS UNSIGNED)
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
  LEFT JOIN FUNCIONARIO fa      ON fa.Codigo_Funcionario = au.Codigo_Autorizador
 WHERE au.Acao = 'Alteração de parâmetros de estoque'
 ORDER BY au.Data_Hora DESC;


/* =====================================================================
   3. Rastreabilidade do aparelho (MOVIMENTACAO)
   ===================================================================== */

/* Aparelho usado nas consultas 3.1 e 3.2: por padrão, o IMEI com mais
   movimentações. Para consultar outro, troque por um IMEI fixo, por
   exemplo:  SET @imei = '356938035643809';  */
SET @imei = (SELECT Imei
               FROM MOVIMENTACAO
              GROUP BY Imei
              ORDER BY COUNT(*) DESC, Imei
              LIMIT 1);

/* 3.1 Linha do tempo completa de um IMEI, com o tempo em cada status
       (LAG: data da movimentação anterior do mesmo aparelho) */
SELECT mv.Numero_Movimentacao, mv.Data_Hora, mv.Tipo_Movimento,
       mv.Status_Anterior, mv.Status_Novo,
       COALESCE(f.Nome, 'Automática') AS Responsavel,
       DATEDIFF(mv.Data_Hora,
                LAG(mv.Data_Hora) OVER (ORDER BY mv.Data_Hora, mv.Numero_Movimentacao)) AS Dias_No_Status_Anterior
  FROM MOVIMENTACAO mv
  LEFT JOIN FUNCIONARIO f ON f.Codigo_Funcionario = mv.Codigo_Funcionario
 WHERE mv.Imei = @imei
 ORDER BY mv.Data_Hora, mv.Numero_Movimentacao;

/* 3.2 Tudo o que a AUDITORIA registrou sobre esse mesmo IMEI */
SELECT au.Data_Hora, au.Acao, au.Valor_Anterior, au.Valor_Novo,
       COALESCE(f.Nome, 'Automática') AS Executado_Por
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO f ON f.Codigo_Funcionario = au.Codigo_Funcionario
 WHERE au.Tabela_Afetada = 'APARELHO'
   AND au.Registro_Id = @imei
 ORDER BY au.Data_Hora;

/* 3.3 Origem de cada aparelho vendido: fornecedor, documento de compra,
       técnico que aprovou a entrada e cliente que comprou */
SELECT a.Imei, m.Nome_Modelo, fo.Nome AS Fornecedor, fo.Tipo_Pessoa,
       aq.Tipo_Documento_Compra, aq.Numero_Documento_Compra,
       ft.Nome AS Tecnico_Avaliador, ae.Base_Consultada,
       c.Nome AS Cliente, pe.Id_Pedido, pe.Data_Pedido
  FROM APARELHO a
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
  JOIN AVALIACAO_ENTRADA ae     ON ae.Id_Avaliacao_Entrada = a.Id_Avaliacao_Entrada
  JOIN FUNCIONARIO ft           ON ft.Codigo_Funcionario = ae.Codigo_Funcionario
  JOIN AQUISICAO aq             ON aq.Id_Aquisicao = ae.Id_Aquisicao
  JOIN FORNECEDOR fo            ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
  JOIN ITEM_PEDIDO i            ON i.Imei = a.Imei
  JOIN PEDIDO pe                ON pe.Id_Pedido = i.Id_Pedido
  JOIN CLIENTE c                ON c.Cpf_Cnpj = pe.Cpf_Cnpj
 WHERE pe.Status_Pedido IN ('Pago', 'Finalizado')
 ORDER BY pe.Data_Pedido DESC;

/* 3.4 Movimentações por tipo e por funcionário */
SELECT COALESCE(f.Nome, 'Automática') AS Responsavel, mv.Tipo_Movimento, COUNT(*) AS Quantidade
  FROM MOVIMENTACAO mv
  LEFT JOIN FUNCIONARIO f ON f.Codigo_Funcionario = mv.Codigo_Funcionario
 GROUP BY f.Codigo_Funcionario, f.Nome, mv.Tipo_Movimento
 ORDER BY Responsavel, Quantidade DESC;


/* =====================================================================
   4. Verificações de integridade do histórico
   (o resultado esperado é vazio; qualquer linha indica inconsistência)
   ===================================================================== */

/* 4.1 Aparelhos cujo status atual não bate com a última movimentação */
SELECT a.Imei, a.Status AS Status_Atual, ult.Status_Novo AS Status_Na_Ultima_Movimentacao
  FROM APARELHO a
  JOIN (SELECT Imei, Status_Novo,
               ROW_NUMBER() OVER (PARTITION BY Imei
                                  ORDER BY Data_Hora DESC, Numero_Movimentacao DESC) AS Ordem
          FROM MOVIMENTACAO) ult
    ON ult.Imei = a.Imei AND ult.Ordem = 1
 WHERE a.Status <> ult.Status_Novo;

/* 4.2 Aparelhos sem a movimentação de Entrada no estoque */
SELECT a.Imei, a.Data_Entrada, a.Status
  FROM APARELHO a
  LEFT JOIN MOVIMENTACAO mv ON mv.Imei = a.Imei AND mv.Tipo_Movimento = 'Entrada'
 WHERE mv.Numero_Movimentacao IS NULL;

/* 4.3 Aparelhos vendidos sem movimentação de Venda */
SELECT a.Imei, a.Status
  FROM APARELHO a
  LEFT JOIN MOVIMENTACAO mv ON mv.Imei = a.Imei AND mv.Tipo_Movimento = 'Venda'
 WHERE a.Status = 'Vendido'
   AND mv.Numero_Movimentacao IS NULL;

/* 4.4 Alterações de preço registradas sem autorizador da Diretoria */
SELECT au.Id_Auditoria, au.Data_Hora, au.Registro_Id AS Imei
  FROM AUDITORIA au
 WHERE au.Acao = 'Alteração de preço/desconto'
   AND au.Codigo_Autorizador IS NULL;


/* =====================================================================
   5. Entrada de aparelhos e prevenção de fraude
   ===================================================================== */

/* 5.1 Avaliações recusadas por IMEI irregular (roubado, bloqueado ou
       adulterado), com o fornecedor que tentou vender */
SELECT ae.Data_Consulta, ae.Imei_Avaliado, ae.Resultado_Consulta_Imei, ae.Base_Consultada,
       fo.Nome AS Fornecedor, fo.Cpf_Cnpj_Fornecedor, fo.Tipo_Pessoa,
       ft.Nome AS Tecnico, ae.Motivo_Recusa
  FROM AVALIACAO_ENTRADA ae
  JOIN AQUISICAO aq   ON aq.Id_Aquisicao = ae.Id_Aquisicao
  JOIN FORNECEDOR fo  ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
  JOIN FUNCIONARIO ft ON ft.Codigo_Funcionario = ae.Codigo_Funcionario
 WHERE ae.Resultado_Consulta_Imei <> 'Regular'
 ORDER BY ae.Data_Consulta DESC;

/* 5.2 Fornecedores com mais de uma tentativa de venda de aparelho com
       IMEI irregular */
SELECT fo.Cpf_Cnpj_Fornecedor, fo.Nome, fo.Tipo_Pessoa, COUNT(*) AS Imeis_Irregulares
  FROM AVALIACAO_ENTRADA ae
  JOIN AQUISICAO aq  ON aq.Id_Aquisicao = ae.Id_Aquisicao
  JOIN FORNECEDOR fo ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
 WHERE ae.Resultado_Consulta_Imei <> 'Regular'
 GROUP BY fo.Cpf_Cnpj_Fornecedor, fo.Nome, fo.Tipo_Pessoa
HAVING COUNT(*) > 1;

/* 5.3 Fornecedores pessoa física que chegaram ao limite de 3 aparelhos
       aprovados no mesmo dia (RN-25) */
SELECT fo.Cpf_Cnpj_Fornecedor AS Cpf, fo.Nome, aq.Data_Aquisicao, COUNT(*) AS Aparelhos_Aprovados
  FROM AVALIACAO_ENTRADA ae
  JOIN AQUISICAO aq  ON aq.Id_Aquisicao = ae.Id_Aquisicao
  JOIN FORNECEDOR fo ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
 WHERE fo.Tipo_Pessoa = 'PF'
   AND ae.Resultado = 'Aprovado'
 GROUP BY fo.Cpf_Cnpj_Fornecedor, fo.Nome, aq.Data_Aquisicao
HAVING COUNT(*) >= 3
 ORDER BY aq.Data_Aquisicao DESC;

/* 5.4 Reconsultas de IMEI ao fim da quarentena (RF-25) e o resultado */
SELECT au.Data_Hora, au.Valor_Novo ->> '$.Imei' AS Imei,
       au.Valor_Novo ->> '$.Resultado_Reconsulta_Imei' AS Resultado_Reconsulta,
       COALESCE(f.Nome, 'Automática') AS Executado_Por
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO f ON f.Codigo_Funcionario = au.Codigo_Funcionario
 WHERE au.Acao = 'Reconsulta de IMEI'
 ORDER BY au.Data_Hora DESC;

/* 5.5 Aparelhos cuja reconsulta deu irregular depois da compra */
SELECT ae.Imei_Avaliado, ae.Resultado_Consulta_Imei AS Primeira_Consulta,
       ae.Resultado_Reconsulta_Imei AS Reconsulta, ae.Data_Reconsulta_Imei,
       fo.Nome AS Fornecedor, a.Status AS Status_Atual
  FROM AVALIACAO_ENTRADA ae
  JOIN AQUISICAO aq  ON aq.Id_Aquisicao = ae.Id_Aquisicao
  JOIN FORNECEDOR fo ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
  LEFT JOIN APARELHO a ON a.Id_Avaliacao_Entrada = ae.Id_Avaliacao_Entrada
 WHERE ae.Resultado_Reconsulta_Imei <> 'Regular';


/* =====================================================================
   6. Financeiro: pagamentos, cancelamentos, devoluções e estornos
   ===================================================================== */

/* 6.1 Trilha de status de cada pagamento (registro e mudanças) */
SELECT au.Registro_Id AS Id_Pagamento, au.Data_Hora, au.Acao,
       au.Valor_Anterior ->> '$.Status' AS Status_Antes,
       au.Valor_Novo     ->> '$.Status' AS Status_Depois,
       COALESCE(f.Nome, 'Automática') AS Executado_Por
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO f ON f.Codigo_Funcionario = au.Codigo_Funcionario
 WHERE au.Tabela_Afetada = 'PAGAMENTO'
 ORDER BY CAST(au.Registro_Id AS UNSIGNED), au.Data_Hora;

/* 6.2 Pedidos com mais de uma tentativa de pagamento */
SELECT pg.Id_Pedido, COUNT(*) AS Tentativas,
       SUM(pg.Status = 'Recusado') AS Recusadas,
       SUM(pg.Status = 'Expirado') AS Expiradas,
       SUM(pg.Status = 'Aprovado') AS Aprovadas
  FROM PAGAMENTO pg
 GROUP BY pg.Id_Pedido
HAVING COUNT(*) > 1
 ORDER BY Tentativas DESC;

/* 6.3 Cancelamentos, devoluções e trocas registrados na auditoria */
SELECT au.Data_Hora, au.Acao, au.Registro_Id,
       au.Valor_Anterior ->> '$.Status' AS Status_Antes,
       au.Valor_Novo     ->> '$.Status' AS Status_Depois,
       au.Valor_Novo     ->> '$.Motivo' AS Motivo,
       COALESCE(f.Nome, 'Automática') AS Executado_Por
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO f ON f.Codigo_Funcionario = au.Codigo_Funcionario
 WHERE au.Acao IN ('Cancelamento', 'Devolução', 'Troca')
 ORDER BY au.Data_Hora DESC;

/* 6.4 Estornos concluídos fora do prazo de 15 dias (RN-19) */
SELECT es.Id_Estorno, es.Valor, es.Data_Abertura, es.Prazo_Limite, es.Data_Conclusao,
       DATEDIFF(es.Data_Conclusao, es.Prazo_Limite) AS Dias_De_Atraso,
       pe.Id_Pedido, c.Nome AS Cliente
  FROM ESTORNO es
  JOIN PAGAMENTO pg ON pg.Id_Pagamento = es.Id_Pagamento
  JOIN PEDIDO pe    ON pe.Id_Pedido = pg.Id_Pedido
  JOIN CLIENTE c    ON c.Cpf_Cnpj = pe.Cpf_Cnpj
 WHERE es.Status = 'Processado'
   AND es.Data_Conclusao > es.Prazo_Limite;

/* 6.5 Estornos pendentes com o prazo já vencido */
SELECT es.Id_Estorno, es.Valor, es.Data_Abertura, es.Prazo_Limite,
       DATEDIFF(NOW(), es.Prazo_Limite) AS Dias_Vencido,
       pe.Id_Pedido, c.Nome AS Cliente
  FROM ESTORNO es
  JOIN PAGAMENTO pg ON pg.Id_Pagamento = es.Id_Pagamento
  JOIN PEDIDO pe    ON pe.Id_Pedido = pg.Id_Pedido
  JOIN CLIENTE c    ON c.Cpf_Cnpj = pe.Cpf_Cnpj
 WHERE es.Status = 'Pendente'
   AND es.Prazo_Limite < NOW();

/* 6.6 Notas fiscais de venda canceladas, com o pedido e o cliente */
SELECT nf.Id_Nota, nf.Numero_Nota, nf.Chave_Acesso, nf.Data_Emissao,
       pe.Id_Pedido, pe.Status_Pedido, c.Nome AS Cliente, pe.Valor_Final
  FROM NOTA_FISCAL nf
  JOIN PEDIDO pe  ON pe.Id_Pedido = nf.Id_Pedido
  JOIN CLIENTE c  ON c.Cpf_Cnpj = pe.Cpf_Cnpj
 WHERE nf.Tipo_Nota = 'Venda'
   AND nf.Status = 'Cancelada';


/* =====================================================================
   7. Requisições de compra (RN-06)
   ===================================================================== */

/* 7.1 Trilha de cada requisição: abertura e cada etapa até a decisão */
SELECT au.Registro_Id AS Id_Requisicao, au.Data_Hora, au.Acao,
       au.Valor_Anterior ->> '$.Status' AS Status_Antes,
       au.Valor_Novo     ->> '$.Status' AS Status_Depois,
       au.Valor_Novo     ->> '$.Parecer_Financeiro' AS Parecer_Financeiro,
       au.Valor_Novo     ->> '$.Motivo_Recusa' AS Motivo_Recusa,
       COALESCE(fe.Nome, 'Automática') AS Executado_Por,
       fa.Nome AS Decidido_Por
  FROM AUDITORIA au
  LEFT JOIN FUNCIONARIO fe ON fe.Codigo_Funcionario = au.Codigo_Funcionario
  LEFT JOIN FUNCIONARIO fa ON fa.Codigo_Funcionario = au.Codigo_Autorizador
 WHERE au.Tabela_Afetada = 'REQUISICAO_COMPRA'
 ORDER BY CAST(au.Registro_Id AS UNSIGNED), au.Data_Hora;

/* 7.2 Decisões da Diretoria sobre requisições e o tempo até a decisão */
SELECT r.Id_Requisicao, m.Nome_Modelo, e.Cor, e.Capacidade, r.Status,
       f.Nome AS Diretor, r.Data_Abertura, r.Data_Decisao,
       DATEDIFF(r.Data_Decisao, r.Data_Abertura) AS Dias_Ate_Decisao,
       r.Motivo_Recusa
  FROM REQUISICAO_COMPRA r
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = r.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
  JOIN FUNCIONARIO f            ON f.Codigo_Funcionario = r.Codigo_Funcionario
 WHERE r.Status IN ('Aprovada', 'Recusada')
 ORDER BY r.Data_Decisao DESC;
