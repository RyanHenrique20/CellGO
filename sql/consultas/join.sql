/* =====================================================================
   CellGO — Consultas com JOIN
   SGBD: MySQL 8
   Execute depois de tabelas.sql, trigger.sql e dos inserts.

   Consultas que cruzam duas ou mais tabelas:
   - INNER JOIN: só os registros que têm correspondência nas tabelas;
   - LEFT JOIN: todos os registros da tabela da esquerda, mesmo sem
     correspondência (os campos da direita ficam NULL);
   - auto-relacionamento (self join): a mesma tabela usada duas vezes.
   ===================================================================== */

USE cellgo;


/* =====================================================================
   1. Cadastro e acesso
   ===================================================================== */

/* 1.1 Funcionários com o perfil de acesso (INNER JOIN) */
SELECT f.Codigo_Funcionario, f.Nome, f.Cargo, p.Nome_Perfil, p.Nivel_Acesso,
       IF(f.Ativo = 1, 'Ativo', 'Inativo') AS Situacao
  FROM FUNCIONARIO f
  JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
 ORDER BY p.Nome_Perfil, f.Nome;

/* 1.2 Clientes com todos os endereços cadastrados */
SELECT c.Nome, e.Tipo_Endereco, e.Rua, e.Numero, e.Complemento,
       e.Bairro, e.Cidade, e.CEP
  FROM CLIENTE c
  JOIN ENDERECO e ON e.Cpf_Cnpj = c.Cpf_Cnpj
 ORDER BY c.Nome, e.Tipo_Endereco;

/* 1.3 Clientes com os telefones em uma linha só (GROUP_CONCAT) */
SELECT c.Nome, c.Email,
       GROUP_CONCAT(CONCAT('(', t.DDD, ') ', t.Numero_Telefone) SEPARATOR ' / ') AS Telefones
  FROM CLIENTE c
  JOIN TELEFONE t ON t.Cpf_Cnpj = c.Cpf_Cnpj
 GROUP BY c.Cpf_Cnpj, c.Nome, c.Email
 ORDER BY c.Nome;

/* 1.4 Clientes que ainda não fizeram nenhum pedido (LEFT JOIN + IS NULL) */
SELECT c.Cpf_Cnpj, c.Nome, c.Email
  FROM CLIENTE c
  LEFT JOIN PEDIDO pe ON pe.Cpf_Cnpj = c.Cpf_Cnpj
 WHERE pe.Id_Pedido IS NULL;


/* =====================================================================
   2. Estoque
   ===================================================================== */

/* 2.1 Catálogo de aparelhos disponíveis: modelo, marca, cor e capacidade
       (APARELHO → ESPECIFICACAO_APARELHO → MODELO) */
SELECT a.Imei, m.Marca, m.Nome_Modelo, e.Cor, e.Capacidade AS Capacidade_GB,
       a.Condicao, a.Preco_Venda,
       IF(a.Elegivel_Desconto_Pix = 1, 'Sim', 'Não') AS Desconto_Pix
  FROM APARELHO a
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
 WHERE a.Status = 'Disponível'
 ORDER BY m.Marca, m.Nome_Modelo, a.Preco_Venda;

/* 2.2 Imagens de cada aparelho com o nome do modelo */
SELECT a.Imei, m.Nome_Modelo, e.Cor, i.URL
  FROM IMAGEM_APARELHO i
  JOIN APARELHO a               ON a.Imei = i.Imei
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
 ORDER BY a.Imei;

/* 2.3 Especificações sem nenhum aparelho disponível (LEFT JOIN com
       condição no ON, para manter as especificações sem estoque) */
SELECT e.Id_Especificacao, m.Nome_Modelo, e.Cor, e.Capacidade, e.Estoque_Minimo
  FROM ESPECIFICACAO_APARELHO e
  JOIN MODELO m        ON m.Id_Modelo = e.Id_Modelo
  LEFT JOIN APARELHO a ON a.Id_Especificacao = e.Id_Especificacao
                      AND a.Status = 'Disponível'
 WHERE a.Imei IS NULL
 ORDER BY m.Nome_Modelo;

/* 2.4 Histórico de movimentações de cada aparelho com o funcionário
       responsável (LEFT JOIN: movimentação automática não tem funcionário) */
SELECT mv.Imei, m.Nome_Modelo, mv.Tipo_Movimento, mv.Status_Anterior, mv.Status_Novo,
       mv.Data_Hora, COALESCE(f.Nome, 'Automática') AS Responsavel
  FROM MOVIMENTACAO mv
  JOIN APARELHO a               ON a.Imei = mv.Imei
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
  LEFT JOIN FUNCIONARIO f       ON f.Codigo_Funcionario = mv.Codigo_Funcionario
 ORDER BY mv.Imei, mv.Data_Hora;

/* 2.5 Requisições de compra com o aparelho e o diretor que decidiu
       (LEFT JOIN: requisição em aberto ainda não tem decisor) */
SELECT r.Id_Requisicao, m.Nome_Modelo, e.Cor, e.Capacidade,
       r.Qtd_Atual_Estoque, r.Estoque_Minimo, r.Qtd_Sugerida, r.Status,
       f.Nome AS Decidido_Por, r.Data_Decisao
  FROM REQUISICAO_COMPRA r
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = r.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
  LEFT JOIN FUNCIONARIO f       ON f.Codigo_Funcionario = r.Codigo_Funcionario
 ORDER BY r.Data_Abertura DESC;


/* =====================================================================
   3. Entrada de aparelhos (compra de fornecedores)
   ===================================================================== */

/* 3.1 Aquisições com o fornecedor e o funcionário que registrou */
SELECT aq.Id_Aquisicao, aq.Data_Aquisicao, fo.Nome AS Fornecedor, fo.Tipo_Pessoa,
       aq.Tipo_Documento_Compra, aq.Valor_Total, aq.Status, fu.Nome AS Registrado_Por
  FROM AQUISICAO aq
  JOIN FORNECEDOR fo  ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
  JOIN FUNCIONARIO fu ON fu.Codigo_Funcionario = aq.Codigo_Funcionario
 ORDER BY aq.Data_Aquisicao DESC;

/* 3.2 Avaliações de entrada com fornecedor, técnico e aparelho cadastrado
       (LEFT JOIN: avaliação recusada não gera aparelho) */
SELECT ae.Id_Avaliacao_Entrada, ae.Imei_Avaliado, fo.Nome AS Fornecedor,
       fu.Nome AS Tecnico, ae.Resultado_Consulta_Imei, ae.Resultado, ae.Motivo_Recusa,
       a.Status AS Status_No_Estoque
  FROM AVALIACAO_ENTRADA ae
  JOIN AQUISICAO aq   ON aq.Id_Aquisicao = ae.Id_Aquisicao
  JOIN FORNECEDOR fo  ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
  JOIN FUNCIONARIO fu ON fu.Codigo_Funcionario = ae.Codigo_Funcionario
  LEFT JOIN APARELHO a ON a.Id_Avaliacao_Entrada = ae.Id_Avaliacao_Entrada
 ORDER BY ae.Data_Consulta DESC;


/* =====================================================================
   4. Vendas
   ===================================================================== */

/* 4.1 Pedidos com o nome do cliente */
SELECT pe.Id_Pedido, pe.Data_Pedido, c.Nome AS Cliente, pe.Forma_Pagamento,
       pe.Numero_Parcelas, pe.Valor_Final, pe.Status_Pedido
  FROM PEDIDO pe
  JOIN CLIENTE c ON c.Cpf_Cnpj = pe.Cpf_Cnpj
 ORDER BY pe.Data_Pedido DESC;

/* 4.2 Itens de cada pedido com o aparelho vendido e as garantias
       (PEDIDO → ITEM_PEDIDO → APARELHO → ESPECIFICACAO → MODELO) */
SELECT pe.Id_Pedido, c.Nome AS Cliente, m.Nome_Modelo, e.Cor, e.Capacidade,
       a.Condicao, i.Imei, i.Preco_Unitario,
       i.Data_Fim_Garantia_Loja, i.Data_Fim_Garantia_Fabricante
  FROM PEDIDO pe
  JOIN CLIENTE c                ON c.Cpf_Cnpj = pe.Cpf_Cnpj
  JOIN ITEM_PEDIDO i            ON i.Id_Pedido = pe.Id_Pedido
  JOIN APARELHO a               ON a.Imei = i.Imei
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
 ORDER BY pe.Id_Pedido;

/* 4.3 Pedidos com o pagamento aprovado e o código da transação */
SELECT pe.Id_Pedido, c.Nome AS Cliente, pe.Forma_Pagamento, pg.Valor,
       pg.Codigo_Transacao, pg.Data_Confirmacao
  FROM PEDIDO pe
  JOIN CLIENTE c   ON c.Cpf_Cnpj = pe.Cpf_Cnpj
  JOIN PAGAMENTO pg ON pg.Id_Pedido = pe.Id_Pedido
 WHERE pg.Status = 'Aprovado'
 ORDER BY pg.Data_Confirmacao DESC;

/* 4.4 Todas as tentativas de pagamento de cada pedido
       (LEFT JOIN: pedido ainda sem cobrança aparece com pagamento NULL) */
SELECT pe.Id_Pedido, pe.Status_Pedido, pg.Id_Pagamento, pg.Data_Tentativa, pg.Status AS Status_Pagamento
  FROM PEDIDO pe
  LEFT JOIN PAGAMENTO pg ON pg.Id_Pedido = pe.Id_Pedido
 ORDER BY pe.Id_Pedido, pg.Data_Tentativa;

/* 4.5 Entregas com o pedido, o cliente e o endereço de entrega */
SELECT en.Codigo_Rastreio, en.Transportadora, en.Status_Entrega,
       pe.Id_Pedido, c.Nome AS Cliente,
       CONCAT(ed.Rua, ', ', ed.Numero, ' - ', ed.Bairro, ' - ', ed.Cidade) AS Endereco,
       IF(en.Codigo_Troca IS NULL, 'Venda', 'Reposição') AS Tipo_Entrega
  FROM ENTREGA en
  JOIN PEDIDO pe   ON pe.Id_Pedido = en.Id_Pedido
  JOIN CLIENTE c   ON c.Cpf_Cnpj = pe.Cpf_Cnpj
  LEFT JOIN ENDERECO ed ON ed.Cpf_Cnpj = c.Cpf_Cnpj
                       AND ed.Tipo_Endereco = 'Entrega'
 ORDER BY en.Data_Despacho DESC;


/* =====================================================================
   5. Pós-venda
   ===================================================================== */

/* 5.1 Solicitações de pós-venda com cliente, aparelho e a avaliação técnica
       (LEFT JOIN: a solicitação pode ainda não ter sido avaliada) */
SELECT pv.Id_PosVenda, pv.Tipo_Solicitacao, pv.Status, c.Nome AS Cliente,
       m.Nome_Modelo, pv.Imei, ad.Classificacao_Dano,
       IF(ad.Cobertura_Garantia = 1, 'Sim', 'Não') AS Coberto_Pela_Garantia,
       fu.Nome AS Tecnico
  FROM POS_VENDA pv
  JOIN PEDIDO pe                ON pe.Id_Pedido = pv.Id_Pedido
  JOIN CLIENTE c                ON c.Cpf_Cnpj = pe.Cpf_Cnpj
  JOIN APARELHO a               ON a.Imei = pv.Imei
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
  LEFT JOIN AVALIACAO_DANO ad   ON ad.Id_PosVenda = pv.Id_PosVenda
  LEFT JOIN FUNCIONARIO fu      ON fu.Codigo_Funcionario = ad.Codigo_Funcionario
 ORDER BY pv.Data_Abertura DESC;

/* 5.2 Trocas: aparelho devolvido x aparelho de reposição
       (self join: APARELHO usado duas vezes, com apelidos diferentes) */
SELECT t.Codigo_Troca, t.Data_Troca, t.Status, c.Nome AS Cliente,
       orig.Imei AS Imei_Devolvido,  mo.Nome_Modelo AS Modelo_Devolvido,
       rep.Imei  AS Imei_Reposicao,  mr.Nome_Modelo AS Modelo_Reposicao
  FROM TROCA t
  JOIN POS_VENDA pv              ON pv.Id_PosVenda = t.Id_PosVenda
  JOIN PEDIDO pe                 ON pe.Id_Pedido = pv.Id_Pedido
  JOIN CLIENTE c                 ON c.Cpf_Cnpj = pe.Cpf_Cnpj
  JOIN APARELHO orig             ON orig.Imei = pv.Imei
  JOIN ESPECIFICACAO_APARELHO eo ON eo.Id_Especificacao = orig.Id_Especificacao
  JOIN MODELO mo                 ON mo.Id_Modelo = eo.Id_Modelo
  JOIN APARELHO rep              ON rep.Imei = t.Imei_Reposicao
  JOIN ESPECIFICACAO_APARELHO er ON er.Id_Especificacao = rep.Id_Especificacao
  JOIN MODELO mr                 ON mr.Id_Modelo = er.Id_Modelo
 ORDER BY t.Data_Troca DESC;

/* 5.3 Devoluções com o cliente e o estorno gerado (LEFT JOIN: o estorno
       só é aberto depois da nota fiscal de devolução) */
SELECT d.Codigo_Devolucao, d.Data_Devolucao, d.Status AS Status_Devolucao,
       c.Nome AS Cliente, pv.Tipo_Solicitacao,
       es.Valor AS Valor_Estorno, es.Status AS Status_Estorno, es.Prazo_Limite
  FROM DEVOLUCAO d
  JOIN POS_VENDA pv     ON pv.Id_PosVenda = d.Id_PosVenda
  JOIN PEDIDO pe        ON pe.Id_Pedido = pv.Id_Pedido
  JOIN CLIENTE c        ON c.Cpf_Cnpj = pe.Cpf_Cnpj
  LEFT JOIN ESTORNO es  ON es.Codigo_Devolucao = d.Codigo_Devolucao
 ORDER BY d.Data_Devolucao DESC;

/* 5.4 Cancelamentos com o pedido, o cliente e o estorno */
SELECT ca.Codigo_Cancelamento, ca.Data_Solicitacao, ca.Motivo, ca.Status,
       pe.Id_Pedido, c.Nome AS Cliente, pe.Valor_Final,
       es.Valor AS Valor_Estorno, es.Status AS Status_Estorno
  FROM CANCELAMENTO ca
  JOIN PEDIDO pe       ON pe.Id_Pedido = ca.Id_Pedido
  JOIN CLIENTE c       ON c.Cpf_Cnpj = pe.Cpf_Cnpj
  LEFT JOIN ESTORNO es ON es.Codigo_Cancelamento = ca.Codigo_Cancelamento
 ORDER BY ca.Data_Solicitacao DESC;


/* =====================================================================
   6. Fiscal
   ===================================================================== */

/* 6.1 Notas de entrada e de reposição com a nota de venda que referenciam
       (self join: NOTA_FISCAL ligada a ela mesma) */
SELECT nf.Id_Nota, nf.Tipo_Nota, nf.Numero_Nota, nf.Status,
       ref.Numero_Nota AS Nota_Venda_Referenciada, ref.Id_Pedido AS Pedido
  FROM NOTA_FISCAL nf
  JOIN NOTA_FISCAL ref ON ref.Id_Nota = nf.Id_Nota_Referencia
 ORDER BY nf.Id_Nota;

/* 6.2 Itens das notas fiscais com o aparelho e o modelo */
SELECT nf.Id_Nota, nf.Tipo_Nota, nf.Numero_Nota, it.Imei, m.Nome_Modelo,
       e.Cor, e.Capacidade, it.Valor_Item
  FROM NOTA_FISCAL nf
  JOIN ITEM_NOTA_FISCAL it      ON it.Id_Nota = nf.Id_Nota
  JOIN APARELHO a               ON a.Imei = it.Imei
  JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
  JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
 ORDER BY nf.Id_Nota;

/* 6.3 Pedidos pagos que ainda não têm nota fiscal de venda emitida
       (LEFT JOIN com condição no ON) */
SELECT pe.Id_Pedido, c.Nome AS Cliente, pe.Data_Pedido, pe.Valor_Final
  FROM PEDIDO pe
  JOIN CLIENTE c          ON c.Cpf_Cnpj = pe.Cpf_Cnpj
  LEFT JOIN NOTA_FISCAL nf ON nf.Id_Pedido = pe.Id_Pedido
                          AND nf.Tipo_Nota = 'Venda'
                          AND nf.Status = 'Emitida'
 WHERE pe.Status_Pedido IN ('Pago', 'Finalizado')
   AND nf.Id_Nota IS NULL;
