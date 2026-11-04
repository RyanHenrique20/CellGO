/* =====================================================================
   CellGO — Comandos DELETE
   SGBD: MySQL 8
   Execute depois de tabelas.sql, trigger.sql e dos inserts.

   Política de exclusão do CellGO
   - Registros com valor histórico, fiscal ou de auditoria NÃO são
     excluídos: eles mudam de status.
       APARELHO     → Status = 'Inativo'
       PEDIDO       → Status_Pedido = 'Cancelado'
       FUNCIONARIO  → Ativo = 0
       NOTA_FISCAL, MOVIMENTACAO e AUDITORIA → nunca são excluídas (RN-23)
     As triggers *_bd e as chaves estrangeiras garantem essa regra.
   - O DELETE fica restrito a:
       • dados cadastrais complementares (fotos, telefones, endereços);
       • itens de operações ainda não concluídas (item de pedido Aberto);
       • cadastros feitos por engano que nunca foram usados.
   - Toda exclusão de dado cadastral é registrada antes na AUDITORIA,
     com o valor anterior em JSON (RN-23 / RNF-07).

   Organização
   1. IMAGEM_APARELHO      — fotos do anúncio
   2. TELEFONE e ENDERECO  — dados de contato do cliente
   3. ITEM_PEDIDO          — aparelho retirado de um pedido em aberto
   4. Cadastros sem uso    — FORNECEDOR, ESPECIFICACAO_APARELHO e MODELO
   5. Exclusões BLOQUEADAS pelo banco (demonstração das restrições)

   As seções 1 a 4 executam sem erro. A seção 5 gera erros DE PROPÓSITO:
   execute cada comando separadamente para ver a mensagem de cada regra.
   ===================================================================== */

USE cellgo;

/* O MySQL Workbench bloqueia DELETE sem chave no WHERE (safe updates).
   Algumas exclusões abaixo usam JOIN ou colunas que não são PK, por isso
   o modo é desligado aqui e religado no fim da seção 4. */
SET SQL_SAFE_UPDATES = 0;


/* =====================================================================
   1. IMAGEM_APARELHO
   Fotos podem ser excluídas: não são referenciadas por nenhuma outra
   tabela e não têm valor fiscal. A exclusão fica registrada na AUDITORIA.
   ===================================================================== */

/* Funcionário de Estoque e Logística responsável pelo anúncio */
SET @cellgo_funcionario = 2;

/* 1.1 Excluir uma foto específica cadastrada por engano
       (identificada pela chave única Imei + URL) */
START TRANSACTION;

INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                       Valor_Anterior, Valor_Novo, Descricao)
SELECT @cellgo_funcionario, 'DELETE', 'IMAGEM_APARELHO', CAST(Id_Imagem AS CHAR),
       JSON_OBJECT('Imei', Imei, 'URL', URL), NULL,
       'Foto cadastrada por engano removida do anúncio.'
  FROM IMAGEM_APARELHO
 WHERE Imei = '356938035643809'
   AND URL  = 'https://cellgo.com.br/imagens/aparelhos/356938035643809_traseira.jpg';

DELETE FROM IMAGEM_APARELHO
 WHERE Imei = '356938035643809'
   AND URL  = 'https://cellgo.com.br/imagens/aparelhos/356938035643809_traseira.jpg';

SELECT ROW_COUNT() AS Fotos_Excluidas;

COMMIT;

/* 1.2 Excluir as fotos de aparelhos Inativos, que saíram definitivamente
       do estoque e não são mais anunciados (DELETE com JOIN) */
START TRANSACTION;

INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                       Valor_Anterior, Valor_Novo, Descricao)
SELECT @cellgo_funcionario, 'DELETE', 'IMAGEM_APARELHO', CAST(i.Id_Imagem AS CHAR),
       JSON_OBJECT('Imei', i.Imei, 'URL', i.URL), NULL,
       'Foto removida: aparelho inativo, fora do catálogo.'
  FROM IMAGEM_APARELHO i
  JOIN APARELHO a ON a.Imei = i.Imei
 WHERE a.Status = 'Inativo';

DELETE i
  FROM IMAGEM_APARELHO i
  JOIN APARELHO a ON a.Imei = i.Imei
 WHERE a.Status = 'Inativo';

SELECT ROW_COUNT() AS Fotos_Excluidas;

COMMIT;


/* =====================================================================
   2. TELEFONE e ENDERECO
   O cliente precisa manter pelo menos um telefone e um endereço
   (cardinalidade 1,n — RN-01; triggers trg_telefone_bd e
   trg_endereco_bd). Por isso a troca é feita em duas etapas: primeiro
   o dado novo é cadastrado, depois o antigo é excluído.
   ===================================================================== */

/* Funcionário de Vendas e Atendimento que atendeu o cliente */
SET @cellgo_funcionario = 1;

/* 2.1 A cliente Ana Beatriz trocou de número de celular */
START TRANSACTION;

INSERT INTO TELEFONE (Cpf_Cnpj, DDD, Numero_Telefone)
VALUES ('32165498700', 11, 912345678);

INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                       Valor_Anterior, Valor_Novo, Descricao)
SELECT @cellgo_funcionario, 'DELETE', 'TELEFONE',
       CONCAT(Cpf_Cnpj, '-', DDD, '-', Numero_Telefone),
       JSON_OBJECT('Cpf_Cnpj', Cpf_Cnpj, 'DDD', DDD, 'Numero_Telefone', Numero_Telefone), NULL,
       'Número antigo removido a pedido da cliente (novo número já cadastrado).'
  FROM TELEFONE
 WHERE Cpf_Cnpj = '32165498700' AND DDD = 11 AND Numero_Telefone = 987654321;

DELETE FROM TELEFONE
 WHERE Cpf_Cnpj = '32165498700'
   AND DDD = 11
   AND Numero_Telefone = 987654321;

COMMIT;

/* Conferência: a cliente continua com um telefone */
SELECT Cpf_Cnpj, DDD, Numero_Telefone
  FROM TELEFONE
 WHERE Cpf_Cnpj = '32165498700';

/* 2.2 O cliente Ricardo mudou de endereço */
START TRANSACTION;

INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Complemento, Tipo_Endereco)
VALUES ('74185296300', 'Rua Itapura', 'Tatuapé', 'São Paulo', '03310000', '1200', 'Apartamento 41', 'Residencial');

INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                       Valor_Anterior, Valor_Novo, Descricao)
SELECT @cellgo_funcionario, 'DELETE', 'ENDERECO', CAST(Id_Endereco AS CHAR),
       JSON_OBJECT('Cpf_Cnpj', Cpf_Cnpj, 'Rua', Rua, 'Numero', Numero, 'Bairro', Bairro,
                   'Cidade', Cidade, 'CEP', CEP, 'Tipo_Endereco', Tipo_Endereco), NULL,
       'Endereço antigo removido após mudança do cliente (novo endereço já cadastrado).'
  FROM ENDERECO
 WHERE Cpf_Cnpj = '74185296300' AND CEP = '03065000' AND Numero = '250';

DELETE FROM ENDERECO
 WHERE Cpf_Cnpj = '74185296300'
   AND CEP = '03065000'
   AND Numero = '250';

COMMIT;

/* Conferência: o cliente continua com um endereço */
SELECT Id_Endereco, Rua, Numero, Bairro, Cidade, CEP, Tipo_Endereco
  FROM ENDERECO
 WHERE Cpf_Cnpj = '74185296300';


/* =====================================================================
   3. ITEM_PEDIDO
   Um item só pode ser retirado enquanto o pedido está Aberto ou
   Aguardando pagamento (trigger trg_item_pedido_bd). Depois da exclusão,
   a trigger trg_item_pedido_ad recalcula o pedido (Valor_Produtos,
   desconto Pix e Valor_Final — RN-09/RN-10).
   ===================================================================== */

/* 3.1 A cliente Juliana coloca um aparelho no pedido e desiste dele */

/* Cenário: novo pedido no Pix com o aparelho Disponível há mais tempo */
INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento)
VALUES ('15935748600', 'Pix');

SET @pedido = LAST_INSERT_ID();
SET @imei   = (SELECT Imei FROM APARELHO
                WHERE Status = 'Disponível'
                ORDER BY Data_Disponivel
                LIMIT 1);
SET @preco  = (SELECT Preco_Venda FROM APARELHO WHERE Imei = @imei);

/* Preço e datas de garantia são recalculados pela trigger trg_item_pedido_bi */
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido, Preco_Unitario, Data_Inicio_Garantia, Data_Fim_Garantia_Loja)
VALUES (@imei, @pedido, @preco, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY));

/* Antes da exclusão: pedido com o aparelho e o desconto Pix calculado */
SELECT Id_Pedido, Status_Pedido, Valor_Produtos, Percentual_Desconto_Pix,
       Valor_Desconto, Valor_Final
  FROM PEDIDO
 WHERE Id_Pedido = @pedido;

/* Exclusão do item */
DELETE FROM ITEM_PEDIDO
 WHERE Id_Pedido = @pedido
   AND Imei = @imei;

/* Depois da exclusão: valores zerados e desconto removido automaticamente */
SELECT Id_Pedido, Status_Pedido, Valor_Produtos, Percentual_Desconto_Pix,
       Valor_Desconto, Valor_Final
  FROM PEDIDO
 WHERE Id_Pedido = @pedido;

/* O aparelho continua Disponível: ele só muda para Vendido na aprovação
   do pagamento (RN-04) */
SELECT Imei, Status FROM APARELHO WHERE Imei = @imei;

/* O pedido vazio não é excluído (trg_pedido_bd): ele é cancelado */
UPDATE PEDIDO
   SET Status_Pedido = 'Cancelado'
 WHERE Id_Pedido = @pedido;


/* =====================================================================
   4. Cadastros sem uso
   Um cadastro só pode ser excluído se nenhum registro depender dele.
   As chaves estrangeiras impedem a exclusão de qualquer cadastro em uso,
   e o LEFT JOIN ... IS NULL seleciona apenas os que nunca foram usados.
   Antes de cada exclusão há um SELECT de conferência com o mesmo filtro.
   ===================================================================== */

SET @cellgo_funcionario = 2;

/* Cenário: cadastros feitos durante uma negociação que não avançou */
INSERT INTO FORNECEDOR (Cpf_Cnpj_Fornecedor, Tipo_Pessoa, Nome, Tipo_Documento,
                        Numero_Documento, Telefone_Contato)
VALUES ('22333444000105', 'PJ', 'Mega Celulares Atacado Ltda', NULL, NULL, '1132221100');

INSERT INTO MODELO (Nome_Modelo, Marca)
VALUES ('Galaxy A55', 'Samsung');

INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade)
VALUES (LAST_INSERT_ID(), 'Azul', 128);

/* 4.1 Fornecedores sem nenhuma aquisição
       (sem aquisição não há procedência a preservar — RN-25) */
SELECT f.Cpf_Cnpj_Fornecedor, f.Nome
  FROM FORNECEDOR f
  LEFT JOIN AQUISICAO aq ON aq.Cpf_Cnpj_Fornecedor = f.Cpf_Cnpj_Fornecedor
 WHERE aq.Id_Aquisicao IS NULL;

DELETE f
  FROM FORNECEDOR f
  LEFT JOIN AQUISICAO aq ON aq.Cpf_Cnpj_Fornecedor = f.Cpf_Cnpj_Fornecedor
 WHERE aq.Id_Aquisicao IS NULL;

SELECT ROW_COUNT() AS Fornecedores_Excluidos;

/* 4.2 Especificações sem nenhum aparelho e sem requisição de compra */
SELECT e.Id_Especificacao, m.Nome_Modelo, e.Cor, e.Capacidade
  FROM ESPECIFICACAO_APARELHO e
  JOIN MODELO m               ON m.Id_Modelo = e.Id_Modelo
  LEFT JOIN APARELHO a        ON a.Id_Especificacao = e.Id_Especificacao
  LEFT JOIN REQUISICAO_COMPRA r ON r.Id_Especificacao = e.Id_Especificacao
 WHERE a.Imei IS NULL
   AND r.Id_Requisicao IS NULL;

DELETE e
  FROM ESPECIFICACAO_APARELHO e
  LEFT JOIN APARELHO a          ON a.Id_Especificacao = e.Id_Especificacao
  LEFT JOIN REQUISICAO_COMPRA r ON r.Id_Especificacao = e.Id_Especificacao
 WHERE a.Imei IS NULL
   AND r.Id_Requisicao IS NULL;

SELECT ROW_COUNT() AS Especificacoes_Excluidas;

/* 4.3 Modelos que ficaram sem nenhuma especificação
       (precisa rodar depois do 4.2) */
SELECT m.Id_Modelo, m.Marca, m.Nome_Modelo
  FROM MODELO m
  LEFT JOIN ESPECIFICACAO_APARELHO e ON e.Id_Modelo = m.Id_Modelo
 WHERE e.Id_Especificacao IS NULL;

DELETE m
  FROM MODELO m
  LEFT JOIN ESPECIFICACAO_APARELHO e ON e.Id_Modelo = m.Id_Modelo
 WHERE e.Id_Especificacao IS NULL;

SELECT ROW_COUNT() AS Modelos_Excluidos;

SET SQL_SAFE_UPDATES = 1;


/* =====================================================================
   5. Exclusões BLOQUEADAS pelo banco
   Cada comando abaixo DEVE falhar. Eles demonstram as regras que o
   banco protege. Execute um por vez para ver a mensagem de cada um.
   Os registros alvo são escolhidos por variáveis, para não depender de
   IDs fixos da massa de dados.
   ===================================================================== */

SET @imei_vendido       = (SELECT Imei FROM APARELHO WHERE Status = 'Vendido' LIMIT 1);
SET @pedido_finalizado  = (SELECT Id_Pedido FROM PEDIDO
                            WHERE Status_Pedido IN ('Pago', 'Finalizado') LIMIT 1);
SET @cliente_com_pedido = (SELECT Cpf_Cnpj FROM PEDIDO LIMIT 1);
SET @tecnico            = (SELECT Codigo_Funcionario FROM AVALIACAO_ENTRADA LIMIT 1);
SET @nota               = (SELECT MIN(Id_Nota) FROM NOTA_FISCAL);
SET @movimentacao       = (SELECT MIN(Numero_Movimentacao) FROM MOVIMENTACAO);
SET @auditoria          = (SELECT MIN(Id_Auditoria) FROM AUDITORIA);

/* 5.1 Aparelho não é excluído: perde-se o histórico por IMEI (RN-03).
       Esperado: 'Aparelho não pode ser excluído; use o status Inativo.' */
DELETE FROM APARELHO WHERE Imei = @imei_vendido;

/* 5.2 Pedido não é excluído: a venda fica no histórico do cliente (RN-13/RN-22).
       Esperado: 'Pedido não pode ser excluído; use o status Cancelado.' */
DELETE FROM PEDIDO WHERE Id_Pedido = @pedido_finalizado;

/* 5.3 Item de pedido já pago não pode ser retirado.
       Esperado: 'Só é possível remover itens de pedido Aberto ou Aguardando pagamento.' */
DELETE FROM ITEM_PEDIDO WHERE Id_Pedido = @pedido_finalizado;

/* 5.4 Último telefone do cliente (RN-01, cardinalidade 1,n).
       Esperado: 'O cliente precisa ter pelo menos um telefone cadastrado.' */
DELETE FROM TELEFONE
 WHERE Cpf_Cnpj = '32165498700' AND DDD = 11 AND Numero_Telefone = 912345678;

/* 5.5 Cliente com pedidos (integridade referencial: fk_pedido_cliente).
       Esperado: erro 1451 — Cannot delete or update a parent row. */
DELETE FROM CLIENTE WHERE Cpf_Cnpj = @cliente_com_pedido;

/* 5.6 Funcionário com operações registradas (fk_aval_entrada_funcionario).
       O desligamento é feito com Ativo = 0.
       Esperado: erro 1451 — Cannot delete or update a parent row. */
DELETE FROM FUNCIONARIO WHERE Codigo_Funcionario = @tecnico;

/* 5.7 Nota fiscal não é excluída (RN-20; cancelamento é por status).
       Esperado: 'Nota fiscal não pode ser excluída.' */
DELETE FROM NOTA_FISCAL WHERE Id_Nota = @nota;

/* 5.8 Histórico de movimentações é imutável (RN-03/RN-23).
       Esperado: 'O histórico de movimentações não pode ser excluído.' */
DELETE FROM MOVIMENTACAO WHERE Numero_Movimentacao = @movimentacao;

/* 5.9 Auditoria é imutável, nem a Diretoria exclui (RN-23/RNF-07).
       Esperado: 'Registros de auditoria não podem ser excluídos.' */
DELETE FROM AUDITORIA WHERE Id_Auditoria = @auditoria;
