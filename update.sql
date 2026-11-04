/* =====================================================================
   CellGO — Comandos UPDATE
   SGBD: MySQL 8
   Execute depois de tabelas.sql, trigger.sql e dos inserts.

   Alterações em registros existentes, mostrando os recursos do UPDATE:
   - SET de uma ou de várias colunas, com cálculo ou subconsulta;
   - WHERE com operadores (=, IN, IS NULL, >, <=) e subconsultas;
   - ORDER BY + LIMIT: altera só o registro mais antigo ou mais urgente;
   - UPDATE com JOIN: o filtro depende de outra tabela.

   Funcionário responsável:
   - as triggers leem a variável de sessão @cellgo_funcionario para
     registrar quem fez a alteração em MOVIMENTACAO e AUDITORIA;
   - ações da Diretoria (preço, desconto Pix, parâmetros de estoque e
     decisão de requisição) exigem um funcionário ativo desse perfil.

   As triggers completam cada UPDATE: mudam os status relacionados
   (pedido, aparelho, pagamento), registram a movimentação do aparelho
   e gravam a auditoria. As consultas de conferência estão em select.sql
   e join.sql.
   ===================================================================== */

USE cellgo;


/* =====================================================================
   1. Cadastro e acesso
   ===================================================================== */

/* 1.1 Promover um funcionário ao perfil Diretoria (subconsulta no SET)
       Necessário quando os inserts não têm nenhum diretor: sem ele, as
       ações exclusivas da Diretoria são bloqueadas pelas triggers. */
UPDATE FUNCIONARIO
   SET Id_Perfil = (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Diretoria'),
       Cargo     = 'Sócio-diretor'
 WHERE Login = 'carlos.silva';

/* 1.2 Reativar uma funcionária que voltou à empresa
       (o cadastro nunca é excluído, só ativado ou desativado) */
UPDATE FUNCIONARIO
   SET Ativo = 1
 WHERE Login = 'fernanda.costa'
   AND Ativo = 0;

/* 1.3 Atualizar o e-mail de um cliente (o CHECK valida o formato) */
UPDATE CLIENTE
   SET Email = 'ana.beatriz.carvalho@gmail.com'
 WHERE Cpf_Cnpj = '32165498700';

/* 1.4 Marcar o endereço residencial do cliente como endereço de entrega */
UPDATE ENDERECO
   SET Tipo_Endereco = 'Entrega'
 WHERE Cpf_Cnpj = '32165498700'
   AND Tipo_Endereco = 'Residencial';


/* =====================================================================
   Funcionários responsáveis pelas próximas alterações
   Cada variável recebe o primeiro funcionário ativo do perfil.
   ===================================================================== */
SET @diretor = (SELECT f.Codigo_Funcionario
                  FROM FUNCIONARIO f
                  JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
                 WHERE p.Nome_Perfil = 'Diretoria' AND f.Ativo = 1
                 ORDER BY f.Codigo_Funcionario LIMIT 1);

SET @estoque = (SELECT f.Codigo_Funcionario
                  FROM FUNCIONARIO f
                  JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
                 WHERE p.Nome_Perfil = 'Estoque e Logística' AND f.Ativo = 1
                 ORDER BY f.Codigo_Funcionario LIMIT 1);

SET @tecnico = (SELECT f.Codigo_Funcionario
                  FROM FUNCIONARIO f
                  JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
                 WHERE p.Nome_Perfil = 'Assistência Técnica' AND f.Ativo = 1
                 ORDER BY f.Codigo_Funcionario LIMIT 1);

SET @financeiro = (SELECT f.Codigo_Funcionario
                     FROM FUNCIONARIO f
                     JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
                    WHERE p.Nome_Perfil = 'Financeiro/Administrativo' AND f.Ativo = 1
                    ORDER BY f.Codigo_Funcionario LIMIT 1);

/* Sem funcionário no perfil, a variável fica NULL e a ação é registrada
   como automática, exceto nas ações da Diretoria, que são bloqueadas. */


/* =====================================================================
   2. Estoque
   ===================================================================== */

/* 2.1 Alteração de preço pela Diretoria (RF-20)
       Moto G73 encalhado: de R$ 1.899,00 para R$ 1.750,00 (decisão 2 da
       seção 8.4). Mesmo com os 7% do Pix, a margem fica em 20,1%.
       A trigger confere o perfil e grava o preço anterior e o novo na
       AUDITORIA. */
SET @cellgo_funcionario = @diretor;

UPDATE APARELHO
   SET Preco_Venda = 1750.00
 WHERE Imei = '789012345678901'
   AND Status = 'Disponível';

/* 2.2 Incluir no desconto Pix os aparelhos parados além do limite de
       atenção que ainda não são elegíveis (UPDATE com JOIN, RN-05) */
UPDATE APARELHO a
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
   SET a.Elegivel_Desconto_Pix = 1
 WHERE a.Status = 'Disponível'
   AND a.Elegivel_Desconto_Pix = 0
   AND DATEDIFF(CURDATE(), a.Data_Disponivel) > e.Limite_Dias_Atencao;

/* 2.3 Aumentar em 1 o estoque mínimo das especificações do Galaxy S23,
       o modelo de boa margem (cálculo no SET + JOIN com MODELO) */
UPDATE ESPECIFICACAO_APARELHO e
  JOIN MODELO m ON m.Id_Modelo = e.Id_Modelo
   SET e.Estoque_Minimo = e.Estoque_Minimo + 1
 WHERE m.Nome_Modelo = 'Galaxy S23';

/* 2.4 Análise financeira da requisição de compra mais antiga
       (ORDER BY + LIMIT: só a primeira da fila) */
SET @cellgo_funcionario = @financeiro;

UPDATE REQUISICAO_COMPRA
   SET Status             = 'Aguardando Aprovação da Diretoria',
       Parecer_Financeiro = 'Orçamento disponível para reposição dentro do limite mensal.'
 WHERE Status = 'Aguardando Análise Financeira'
 ORDER BY Data_Abertura
 LIMIT 1;

/* 2.5 Diretoria recusa as requisições de especificações que já têm
       aparelho encalhado (UPDATE com JOIN, RN-06) */
SET @cellgo_funcionario = @diretor;

UPDATE REQUISICAO_COMPRA r
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = r.Id_Especificacao
  JOIN APARELHO a               ON a.Id_Especificacao = r.Id_Especificacao
   SET r.Status             = 'Recusada',
       r.Codigo_Funcionario = @diretor,
       r.Data_Decisao       = CURDATE(),
       r.Motivo_Recusa      = 'Especificação com aparelho encalhado no estoque.'
 WHERE r.Status = 'Aguardando Aprovação da Diretoria'
   AND a.Status = 'Disponível'
   AND DATEDIFF(CURDATE(), a.Data_Disponivel) > e.Limite_Dias_Critico;

/* 2.6 Diretoria aprova a requisição restante mais antiga */
UPDATE REQUISICAO_COMPRA
   SET Status             = 'Aprovada',
       Codigo_Funcionario = @diretor,
       Data_Decisao       = CURDATE()
 WHERE Status = 'Aguardando Aprovação da Diretoria'
 ORDER BY Data_Abertura
 LIMIT 1;


/* =====================================================================
   3. Entrada de aparelhos (fim da quarentena, RN-25)
   ===================================================================== */

/* 3.1 Registrar a nova consulta do IMEI dos aparelhos com a quarentena
       vencida (UPDATE com JOIN). O resultado vem da consulta na base. */
SET @cellgo_funcionario = @estoque;

UPDATE AVALIACAO_ENTRADA ae
  JOIN APARELHO a ON a.Id_Avaliacao_Entrada = ae.Id_Avaliacao_Entrada
   SET ae.Data_Reconsulta_Imei      = NOW(),
       ae.Resultado_Reconsulta_Imei = 'Regular'
 WHERE a.Status = 'Em quarentena'
   AND a.Data_Fim_Quarentena <= CURDATE()
   AND ae.Resultado_Reconsulta_Imei IS NULL;

/* 3.2 Liberar para venda os aparelhos com reconsulta Regular
       (a trigger preenche Data_Disponivel e gera a MOVIMENTACAO
       'Fim de quarentena') */
UPDATE APARELHO a
  JOIN AVALIACAO_ENTRADA ae ON ae.Id_Avaliacao_Entrada = a.Id_Avaliacao_Entrada
   SET a.Status = 'Disponível'
 WHERE a.Status = 'Em quarentena'
   AND a.Data_Fim_Quarentena <= CURDATE()
   AND ae.Resultado_Reconsulta_Imei = 'Regular';


/* =====================================================================
   4. Vendas
   ===================================================================== */

/* 4.1 Pedido Aberto mais antigo que já tem aparelho passa para
       Aguardando pagamento (subconsulta no WHERE) */
SET @cellgo_funcionario = NULL;   -- ação do próprio cliente na loja on-line

UPDATE PEDIDO
   SET Status_Pedido = 'Aguardando pagamento'
 WHERE Status_Pedido = 'Aberto'
   AND Id_Pedido IN (SELECT Id_Pedido FROM ITEM_PEDIDO)
 ORDER BY Data_Pedido
 LIMIT 1;

/* 4.2 Aprovar o pagamento pendente mais antigo que pode ser aprovado
       A trigger confere se o pedido está Aguardando pagamento, se o valor
       é o Valor_Final atual e se os aparelhos continuam Disponíveis (RN-04).
       Aprovado: pedido Pago, aparelhos Vendidos e início da garantia.
       O pagamento é escolhido antes, em uma variável: o UPDATE não pode
       filtrar por PEDIDO porque a trigger altera essa tabela (erro 1442). */
SET @pagamento = (SELECT pg.Id_Pagamento
                    FROM PAGAMENTO pg
                    JOIN PEDIDO pe ON pe.Id_Pedido = pg.Id_Pedido
                   WHERE pg.Status = 'Pendente'
                     AND pe.Status_Pedido = 'Aguardando pagamento'
                     AND pg.Valor = pe.Valor_Final
                   ORDER BY pg.Data_Tentativa
                   LIMIT 1);

UPDATE PAGAMENTO
   SET Status           = 'Aprovado',
       Data_Confirmacao = NOW(),
       Codigo_Transacao = COALESCE(Codigo_Transacao, CONCAT('TX-', LPAD(Id_Pagamento, 6, '0')))
 WHERE Id_Pagamento = @pagamento;

/* 4.3 Despachar a entrega mais antiga que aguarda envio, exceto as de
       pedidos com cancelamento solicitado (RN-13) */
SET @cellgo_funcionario = @estoque;

UPDATE ENTREGA
   SET Status_Entrega     = 'Em transporte',
       Data_Despacho      = NOW(),
       Origem_Atualizacao = 'Manual'
 WHERE Status_Entrega = 'Aguardando envio'
   AND Id_Pedido NOT IN (SELECT Id_Pedido FROM CANCELAMENTO WHERE Status = 'Solicitado')
 ORDER BY Id_Pedido
 LIMIT 1;

/* 4.4 Confirmar como Entregues as entregas em transporte há mais de
       5 dias, depois de conferir o rastreio (RF-23). A trigger finaliza o
       pedido (venda) ou conclui a troca (reposição). */
UPDATE ENTREGA
   SET Status_Entrega     = 'Entregue',
       Data_Entrega       = NOW(),
       Origem_Atualizacao = 'Manual'
 WHERE Status_Entrega = 'Em transporte'
   AND DATEDIFF(CURDATE(), Data_Despacho) > 5;

/* 4.5 Concluir o cancelamento solicitado há mais tempo cujo aparelho
       ainda não saiu para entrega (RN-13)
       Pedido Pago só vira Cancelado por um cancelamento concluído: a
       trigger muda o pedido para Cancelado e devolve os aparelhos para
       Disponível. O cancelamento é escolhido antes, em uma variável,
       porque a trigger altera PEDIDO e APARELHO (erro 1442). */
SET @cellgo_funcionario = @diretor;   -- a Diretoria tem acesso a todas as áreas

SET @cancelamento = (SELECT ca.Codigo_Cancelamento
                       FROM CANCELAMENTO ca
                      WHERE ca.Status = 'Solicitado'
                        AND ca.Id_Pedido NOT IN (SELECT en.Id_Pedido
                                                   FROM ENTREGA en
                                                  WHERE en.Codigo_Troca IS NULL
                                                    AND en.Status_Entrega IN ('Em transporte', 'Entregue'))
                      ORDER BY ca.Data_Solicitacao
                      LIMIT 1);

UPDATE CANCELAMENTO
   SET Status = 'Concluído'
 WHERE Codigo_Cancelamento = @cancelamento;


/* =====================================================================
   5. Pós-venda
   ===================================================================== */

/* 5.1 Solicitações abertas que já receberam avaliação técnica passam
       para Em análise (subconsulta no WHERE) */
SET @cellgo_funcionario = @tecnico;

UPDATE POS_VENDA
   SET Status = 'Em análise'
 WHERE Status = 'Aberta'
   AND Id_PosVenda IN (SELECT Id_PosVenda FROM AVALIACAO_DANO);

/* 5.2 Recusar as solicitações em que a avaliação confirmou mau uso,
       sem cobertura da garantia (UPDATE com JOIN, RN-18) */
UPDATE POS_VENDA pv
  JOIN AVALIACAO_DANO ad ON ad.Id_PosVenda = pv.Id_PosVenda
   SET pv.Status = 'Recusada'
 WHERE pv.Status IN ('Aberta', 'Em análise')
   AND ad.Classificacao_Dano = 'Mau uso'
   AND ad.Cobertura_Garantia = 0;

/* 5.3 Concluir as devoluções pendentes cuja nota fiscal de entrada já
       foi emitida (subconsulta no WHERE, RN-20) */
UPDATE DEVOLUCAO
   SET Status = 'Concluída'
 WHERE Status = 'Pendente'
   AND Id_PosVenda IN (SELECT Id_PosVenda
                         FROM NOTA_FISCAL
                        WHERE Tipo_Nota = 'Entrada (Devolução)'
                          AND Status = 'Emitida');


/* =====================================================================
   6. Fiscal e financeiro
   ===================================================================== */

/* 6.1 Registrar a autorização da SEFAZ na nota mais antiga ainda não
       emitida: número, chave de acesso de 44 dígitos e data de emissão.
       Número e chave são únicos: o próximo número vem de uma variável,
       porque o MySQL não aceita subconsulta na própria tabela do UPDATE.
       Chave: UF (35) + ano/mês (2611) + CNPJ da loja + modelo (55) +
       série (001) + número (9 dígitos) + tipo de emissão (1) + código
       (8 dígitos) + dígito verificador (3). */
SET @cellgo_funcionario = @financeiro;
SET @proxima_nota = (SELECT COALESCE(MAX(Numero_Nota), 0) + 1 FROM NOTA_FISCAL);

UPDATE NOTA_FISCAL
   SET Status       = 'Emitida',
       Numero_Nota  = @proxima_nota,
       Chave_Acesso = CONCAT('352611', '12345678000190', '55', '001',
                             LPAD(@proxima_nota, 9, '0'), '1',
                             LPAD(@proxima_nota, 8, '0'), '3'),
       Data_Emissao = NOW()
 WHERE Status IN ('Aguardando emissão', 'Pendente')
 ORDER BY Id_Nota
 LIMIT 1;

/* 6.2 Recusar os estornos pendentes de devoluções classificadas como mau
       uso, depois de a revisão da avaliação confirmar o diagnóstico
       (UPDATE com JOIN, RN-18; decisão 4 da seção 8.4) */
UPDATE ESTORNO es
  JOIN DEVOLUCAO d       ON d.Codigo_Devolucao = es.Codigo_Devolucao
  JOIN AVALIACAO_DANO ad ON ad.Id_PosVenda = d.Id_PosVenda
   SET es.Status         = 'Recusado',
       es.Data_Conclusao = NOW()
 WHERE es.Status = 'Pendente'
   AND ad.Classificacao_Dano = 'Mau uso';

/* 6.3 Processar o estorno pendente mais próximo do prazo-limite de
       15 dias (RN-19). A trigger muda o pagamento para Estornado.
       Só entra estorno de pagamento ainda Aprovado: se o pagamento já
       estiver Estornado (segundo estorno do mesmo pagamento), a trigger
       trg_pagamento_bu bloqueia a operação. */
SET @estorno = (SELECT es.Id_Estorno
                  FROM ESTORNO es
                  JOIN PAGAMENTO pg ON pg.Id_Pagamento = es.Id_Pagamento
                 WHERE es.Status = 'Pendente'
                   AND pg.Status = 'Aprovado'
                 ORDER BY es.Prazo_Limite
                 LIMIT 1);

UPDATE ESTORNO
   SET Status         = 'Processado',
       Data_Conclusao = NOW()
 WHERE Id_Estorno = @estorno;


/* =====================================================================
   7. Testes que devem FALHAR (descomente para demonstrar as triggers)
   ===================================================================== */

/* 7.1 Funcionário sem perfil Diretoria alterando o preço
       "Somente a Diretoria pode alterar o preço ou a elegibilidade ao desconto Pix."
SET @cellgo_funcionario = @estoque;
UPDATE APARELHO SET Preco_Venda = 1700.00 WHERE Imei = '789012345678901';
*/

/* 7.2 Cancelar um pedido Pago direto, sem cancelamento concluído
       "Pedido pago só pode ser cancelado por um cancelamento concluído."
UPDATE PEDIDO SET Status_Pedido = 'Cancelado' WHERE Status_Pedido = 'Pago' LIMIT 1;
*/

/* 7.3 Voltar uma entrega entregue para Em transporte
       "O status da entrega não pode voltar para uma etapa anterior."
UPDATE ENTREGA SET Status_Entrega = 'Em transporte', Data_Entrega = NULL
 WHERE Status_Entrega = 'Entregue' LIMIT 1;
*/

/* 7.4 Alterar um registro de auditoria
       "Registros de auditoria não podem ser alterados."
UPDATE AUDITORIA SET Descricao = 'Alterado' LIMIT 1;
*/


-- Limpa a variável de sessão ao final
SET @cellgo_funcionario = NULL;
