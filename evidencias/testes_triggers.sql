/* =====================================================================
   CellGO — Testes das TRIGGERS (regras de negócio)
   SGBD: MySQL 8

   COMO EXECUTAR
   1. Rode tabelas.sql, trigger.sql e insert_validos.sql (banco cellgo pronto);
   2. Rode este arquivo. Quase todos os comandos terminam em ERRO: é isso
      que prova que a validação funciona. No MySQL Workbench, ative
      Query > 'Continue SQL Script Execution After Errors'; no terminal,
      use: mysql --force -u root cellgo < testes_triggers.sql

   Cada bloco é um comando que quebra uma regra de negócio. A trigger deve
   RECUSAR o comando com o erro 1644 (SQLSTATE 45000) e a mensagem escrita
   acima dele.

   O bloco marcado com ★ é a demonstração do slide 9 (venda dupla do mesmo
   aparelho: o pedido A é pago e o pagamento do pedido B é barrado).

   Os blocos com START TRANSACTION ... ROLLBACK montam um cenário de apoio
   (pedido, aquisição etc.) e o desfazem no fim, então os dados do
   insert_validos.sql não são alterados. Os Ids 100 a 103 são só de teste.
   Total: 71 testes. Todos foram executados e recusados como descrito.
   ===================================================================== */

SET NAMES utf8mb4;
USE cellgo;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   CLIENTE
   --------------------------------------------------------------------- */
-- [01] Pessoa física sem data de nascimento
-- Esperado : ERROR 1644 (45000): Informe a data de nascimento do cliente pessoa física.
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES ('11122233396', 'Sem Nascimento', 'sem.nasc@email.com', NULL, 'PF');

-- [02] Cliente menor de 18 anos
-- Esperado : ERROR 1644 (45000): O cliente pessoa física deve ter pelo menos 18 anos.
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES ('11122233396', 'Menor de Idade', 'menor@email.com', DATE_SUB(CURDATE(), INTERVAL 10 YEAR), 'PF');

-- [03] Alterar nascimento de cliente para menor de idade
-- Esperado : ERROR 1644 (45000): O cliente pessoa física deve ter pelo menos 18 anos.
UPDATE CLIENTE SET Data_Nascimento = DATE_SUB(CURDATE(), INTERVAL 10 YEAR) WHERE Cpf_Cnpj = '32165498700';


/* ---------------------------------------------------------------------
   ENDERECO
   --------------------------------------------------------------------- */
-- [04] Excluir o único endereço do cliente
-- Esperado : ERROR 1644 (45000): O cliente precisa ter pelo menos um endereço cadastrado.
DELETE FROM ENDERECO WHERE Id_Endereco = 1;


/* ---------------------------------------------------------------------
   TELEFONE
   --------------------------------------------------------------------- */
-- [05] Excluir o único telefone do cliente
-- Esperado : ERROR 1644 (45000): O cliente precisa ter pelo menos um telefone cadastrado.
DELETE FROM TELEFONE WHERE Cpf_Cnpj = '32165498700';


/* ---------------------------------------------------------------------
   ESPECIFICACAO_APARELHO
   --------------------------------------------------------------------- */
-- [06] Funcionário que não é da Diretoria altera estoque mínimo
-- Esperado : ERROR 1644 (45000): Somente a Diretoria pode alterar os parâmetros de estoque.
START TRANSACTION;
SET @cellgo_funcionario = 6;
UPDATE ESPECIFICACAO_APARELHO SET Estoque_Minimo = 10 WHERE Id_Especificacao = 1;
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   AQUISICAO
   --------------------------------------------------------------------- */
-- [07] Aquisição registrada por funcionário de Vendas
-- Esperado : ERROR 1644 (45000): A aquisição deve ser registrada por funcionário ativo de Estoque e Logística.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (6, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-T1');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [08] Aquisição registrada por funcionário inativo
-- Esperado : ERROR 1644 (45000): A aquisição deve ser registrada por funcionário ativo de Estoque e Logística.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (4, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-T2');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [09] Compra de pessoa física sem termo de compra e venda
-- Esperado : ERROR 1644 (45000): Compra de pessoa física exige o termo de compra e venda.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (2, '12345678909', CURDATE(), 'Nota fiscal do fornecedor', 'NF-T3');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [10] Fornecedor pessoa física não aceitou o termo de responsabilidade
-- Esperado : ERROR 1644 (45000): O fornecedor pessoa física deve aceitar o termo de responsabilidade.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra, Termo_Responsabilidade_Aceito) VALUES (2, '12345678909', CURDATE(), 'Termo de compra e venda', 'TCV-T4', 0);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [11] Compra de pessoa jurídica com termo em vez de nota fiscal
-- Esperado : ERROR 1644 (45000): Compra de pessoa jurídica exige a nota fiscal do fornecedor.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (2, '11222333000181', CURDATE(), 'Termo de compra e venda', 'TCV-T5');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [12] Nova aquisição já começando como Concluída
-- Esperado : ERROR 1644 (45000): Uma nova aquisição começa com status Em avaliação.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra, Status) VALUES (2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-T6', 'Concluída');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [13] Reabrir aquisição já concluída
-- Esperado : ERROR 1644 (45000): Aquisição concluída ou recusada não pode mudar de status.
START TRANSACTION;
SET @cellgo_funcionario = 2;
UPDATE AQUISICAO SET Status = 'Em avaliação' WHERE Id_Aquisicao = 1;
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   AVALIACAO_ENTRADA
   --------------------------------------------------------------------- */
-- [14] Avaliação feita por funcionário de Estoque (não é da Assistência Técnica)
-- Esperado : ERROR 1644 (45000): A avaliação de entrada deve ser feita por funcionário ativo da Assistência Técnica.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Resultado, Motivo_Recusa) VALUES (2, 100, '222222222222227', 'CEIR/Anatel', 'Bloqueado', NOW(), 'Recusado', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [15] Avaliar aparelho de aquisição já concluída
-- Esperado : ERROR 1644 (45000): Só é possível avaliar aparelhos de uma aquisição Em avaliação.
START TRANSACTION;
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Resultado, Motivo_Recusa) VALUES (3, 1, '222222222222227', 'CEIR/Anatel', 'Bloqueado', NOW(), 'Recusado', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [16] Consulta do IMEI anterior à data da aquisição
-- Esperado : ERROR 1644 (45000): A consulta do IMEI não pode ser anterior à data da aquisição.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Resultado, Motivo_Recusa) VALUES (3, 100, '222222222222227', 'CEIR/Anatel', 'Bloqueado', DATE_SUB(NOW(), INTERVAL 30 DAY), 'Recusado', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [17] IMEI que já está cadastrado no estoque
-- Esperado : ERROR 1644 (45000): Este IMEI já está cadastrado no estoque.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Resultado, Motivo_Recusa) VALUES (3, 100, '356938035643809', 'CEIR/Anatel', 'Bloqueado', NOW(), 'Recusado', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [18] Quarto aparelho no mesmo dia para o mesmo CPF (limite de 3)
-- Esperado : ERROR 1644 (45000): Limite atingido: um mesmo CPF pode vender no máximo 3 aparelhos por dia.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra, Termo_Responsabilidade_Aceito) VALUES (100, 2, '12345678909', CURDATE(), 'Termo de compra e venda', 'TCV-TESTE-100', 1);
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (101, 3, 100, '111111111111119', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (102, 3, 100, '222222222222227', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (103, 3, 100, '333333333333335', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (3, 100, '444444444444441', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   APARELHO
   --------------------------------------------------------------------- */
-- [19] Cadastrar aparelho com avaliação de entrada Recusada
-- Esperado : ERROR 1644 (45000): Só é possível cadastrar aparelho com avaliação de entrada Aprovada.
START TRANSACTION;
SET @cellgo_funcionario = 3;
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada, Data_Disponivel) VALUES ('867530902314556', 1, 4, 3, 'Novo', 1000.00, 500.00, 'Disponível', CURDATE(), CURDATE());
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [20] IMEI diferente do IMEI da avaliação
-- Esperado : ERROR 1644 (45000): O IMEI do aparelho deve ser o mesmo IMEI da avaliação de entrada.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (100, 3, 100, '111111111111119', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada, Data_Disponivel) VALUES ('999999999999994', 1, 100, 3, 'Novo', 1000.00, 500.00, 'Disponível', CURDATE(), CURDATE());
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [21] Entrada do aparelho já como Vendido
-- Esperado : ERROR 1644 (45000): Um aparelho novo no estoque entra Em quarentena ou Disponível.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (100, 3, 100, '111111111111119', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada, Data_Disponivel) VALUES ('111111111111119', 1, 100, 3, 'Novo', 1000.00, 500.00, 'Vendido', CURDATE(), CURDATE());
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [22] Mudar status de Vendido direto para Inativo
-- Esperado : ERROR 1644 (45000): Mudança de status do aparelho não permitida.
START TRANSACTION;
SET @cellgo_funcionario = 3;
UPDATE APARELHO SET Status = 'Inativo' WHERE Imei = '351756051523999';
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [23] Funcionário que não é da Diretoria altera o preço de venda
-- Esperado : ERROR 1644 (45000): Somente a Diretoria pode alterar o preço ou a elegibilidade ao desconto Pix.
START TRANSACTION;
SET @cellgo_funcionario = 6;
UPDATE APARELHO SET Preco_Venda = 100.00 WHERE Imei = '353879234252633';
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [24] Excluir aparelho do estoque
-- Esperado : ERROR 1644 (45000): Aparelho não pode ser excluído; use o status Inativo.
DELETE FROM APARELHO WHERE Imei = '353879234252633';


/* ---------------------------------------------------------------------
   REQUISICAO_COMPRA
   --------------------------------------------------------------------- */
-- [25] Segunda requisição em aberto para a mesma especificação
-- Esperado : ERROR 1644 (45000): Já existe uma requisição de compra em aberto para esta especificação.
START TRANSACTION;
SET @cellgo_funcionario = 1;
INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida) VALUES (1, 3, 5, CURDATE(), 10);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [26] Requisição nascendo já Aprovada
-- Esperado : ERROR 1644 (45000): A requisição de compra começa com status Aguardando Análise Financeira.
START TRANSACTION;
SET @cellgo_funcionario = 1;
INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida, Status, Codigo_Funcionario, Data_Decisao, Parecer_Financeiro) VALUES (1, 3, 5, CURDATE(), 10, 'Aprovada', 1, CURDATE(), 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [27] Pular a análise financeira (Aguardando Análise → Aprovada)
-- Esperado : ERROR 1644 (45000): Mudança de status da requisição não permitida.
START TRANSACTION;
SET @cellgo_funcionario = 1;
UPDATE REQUISICAO_COMPRA SET Status = 'Aprovada', Codigo_Funcionario = 1, Data_Decisao = CURDATE(), Parecer_Financeiro = 'Teste' WHERE Id_Requisicao = 1;
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [28] Aprovação feita por quem não é da Diretoria
-- Esperado : ERROR 1644 (45000): A requisição só pode ser aprovada ou recusada pela Diretoria.
START TRANSACTION;
SET @cellgo_funcionario = 7;
UPDATE REQUISICAO_COMPRA SET Status = 'Aprovada', Codigo_Funcionario = 7, Data_Decisao = CURDATE() WHERE Id_Requisicao = 2;
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [29] Alterar requisição já decidida
-- Esperado : ERROR 1644 (45000): Requisição já decidida não pode ser alterada.
START TRANSACTION;
SET @cellgo_funcionario = 1;
UPDATE REQUISICAO_COMPRA SET Parecer_Financeiro = 'Alterado depois da decisão' WHERE Id_Requisicao = 3;
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   PEDIDO
   --------------------------------------------------------------------- */
-- [30] Pedido nascendo já como Pago
-- Esperado : ERROR 1644 (45000): Um novo pedido começa com status Aberto.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas, Status_Pedido) VALUES ('32165498700', 'Pix', 1, 'Pago');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [31] Pedido Aberto direto para Pago (sem pagamento)
-- Esperado : ERROR 1644 (45000): Mudança de status do pedido não permitida.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Pago' WHERE Id_Pedido = 100;
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [32] Aguardando pagamento sem nenhum aparelho no pedido
-- Esperado : ERROR 1644 (45000): O pedido precisa ter pelo menos um aparelho.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [33] Trocar o cliente de um pedido
-- Esperado : ERROR 1644 (45000): Cliente e data do pedido não podem ser alterados.
START TRANSACTION;
SET @cellgo_funcionario = 6;
UPDATE PEDIDO SET Cpf_Cnpj = '74185296300' WHERE Id_Pedido = 1;
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [34] Excluir pedido
-- Esperado : ERROR 1644 (45000): Pedido não pode ser excluído; use o status Cancelado.
DELETE FROM PEDIDO WHERE Id_Pedido = 1;


/* ---------------------------------------------------------------------
   ITEM_PEDIDO
   --------------------------------------------------------------------- */
-- [35] Incluir aparelho já Vendido no pedido
-- Esperado : ERROR 1644 (45000): Aparelho indisponível: só aparelhos com status Disponível podem ser vendidos.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('351756051523999', 100);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [36] Incluir aparelho Em manutenção no pedido
-- Esperado : ERROR 1644 (45000): Aparelho indisponível: só aparelhos com status Disponível podem ser vendidos.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('356938035643809', 100);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [37] Incluir item em pedido já Finalizado
-- Esperado : ERROR 1644 (45000): Só é possível incluir itens em pedido Aberto ou Aguardando pagamento.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 1);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [38] Alterar manualmente o preço do item
-- Esperado : ERROR 1644 (45000): O preço do item vem do aparelho e não pode ser alterado manualmente.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE ITEM_PEDIDO SET Preco_Unitario = 1.00 WHERE Id_Pedido = 100;
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   PAGAMENTO
   --------------------------------------------------------------------- */
-- [39] Valor diferente do valor final do pedido
-- Esperado : ERROR 1644 (45000): O valor do pagamento deve ser igual ao Valor_Final do pedido.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (100, 1.00);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [40] Cobrança para pedido que não está Aguardando pagamento
-- Esperado : ERROR 1644 (45000): Só é possível gerar cobrança para pedido Aguardando pagamento.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (5, 1766.07);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [41] Pagamento registrado já como Estornado
-- Esperado : ERROR 1644 (45000): Um pagamento não pode ser registrado já como Estornado.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Data_Confirmacao, Valor, Status) VALUES (100, 'TX-T-EST', NOW(), @valor, 'Estornado');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [42] Segunda cobrança Pendente para o mesmo pedido
-- Esperado : ERROR 1644 (45000): Já existe uma cobrança Pendente para este pedido.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (100, @valor);
INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (100, @valor);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [43] ★ DEMO DO SLIDE: venda dupla do mesmo aparelho (pedido B)
-- Esperado : ERROR 1644 (45000): Pagamento não aprovado: há aparelho do pedido que não está mais Disponível.
START TRANSACTION;
SET @cellgo_funcionario = 6;
SET @cpf = '32165498700';
SET @imei = '353879234252633';
INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (@cpf, 'Pix', 1);
SET @pedido_a = LAST_INSERT_ID();
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES (@imei, @pedido_a);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = @pedido_a;
SET @valor_a = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = @pedido_a);
INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (@cpf, 'Pix', 1);
SET @pedido_b = LAST_INSERT_ID();
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES (@imei, @pedido_b);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = @pedido_b;
SET @valor_b = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = @pedido_b);
INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Data_Confirmacao, Valor, Status) VALUES (@pedido_a, 'TX-DEMO-A', NOW(), @valor_a, 'Aprovado');
INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Data_Confirmacao, Valor, Status) VALUES (@pedido_b, 'TX-DEMO-B', NOW(), @valor_b, 'Aprovado');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [44] Alterar o valor de um pagamento já registrado
-- Esperado : ERROR 1644 (45000): Pedido, valor e data da tentativa não podem ser alterados.
START TRANSACTION;
SET @cellgo_funcionario = 7;
UPDATE PAGAMENTO SET Valor = 1.00 WHERE Id_Pagamento = 2;
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [45] Alterar pagamento já encerrado (Recusado → Aprovado)
-- Esperado : ERROR 1644 (45000): Mudança de status do pagamento não permitida.
START TRANSACTION;
SET @cellgo_funcionario = 7;
UPDATE PAGAMENTO SET Status = 'Aprovado', Data_Confirmacao = NOW() WHERE Id_Pagamento = 1;
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   CANCELAMENTO
   --------------------------------------------------------------------- */
-- [46] Cancelar pedido Finalizado
-- Esperado : ERROR 1644 (45000): Só é possível cancelar pedido Aguardando pagamento ou Pago.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO CANCELAMENTO (Id_Pedido, Motivo) VALUES (1, 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [47] Cancelamento fora do prazo de 7 dias
-- Esperado : ERROR 1644 (45000): Prazo de cancelamento vencido: o limite é de 7 dias corridos da compra.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO CANCELAMENTO (Id_Pedido, Data_Solicitacao, Motivo) VALUES (3, '2026-11-09 00:00:00', 'Cliente desistiu');
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   POS_VENDA
   --------------------------------------------------------------------- */
-- [48] Pós-venda para pedido que não foi pago
-- Esperado : ERROR 1644 (45000): Solicitação de pós-venda só para pedido Pago ou Finalizado.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Descricao) VALUES ('353879234252633', 100, 'Defeito', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [49] Arrependimento antes de o aparelho ser entregue
-- Esperado : ERROR 1644 (45000): Arrependimento só depois que o aparelho for entregue.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Descricao) VALUES ('351756051523999', 3, 'Arrependimento', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [50] Defeito fora do prazo de 30 dias da compra
-- Esperado : ERROR 1644 (45000): Fora do prazo: troca ou devolução por defeito é aceita em até 30 dias da compra.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Data_Abertura, Descricao) VALUES ('356938035643809', 1, 'Defeito', '2026-11-09 00:00:00', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [51] Segunda solicitação em aberto para o mesmo aparelho
-- Esperado : ERROR 1644 (45000): Já existe uma solicitação de pós-venda em aberto para este aparelho.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Data_Abertura, Descricao) VALUES ('490154203237518', 2, 'Garantia', '2026-11-05 00:00:00', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   DEVOLUCAO
   --------------------------------------------------------------------- */
-- [52] Devolução para solicitação do tipo Garantia
-- Esperado : ERROR 1644 (45000): Devolução só para solicitação de Arrependimento ou Defeito.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO DEVOLUCAO (Id_PosVenda, Motivo) VALUES (3, 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   TROCA
   --------------------------------------------------------------------- */
-- [53] Aparelho de reposição igual ao aparelho trocado
-- Esperado : ERROR 1644 (45000): O aparelho de reposição deve ser diferente do aparelho trocado.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca) VALUES (3, '490154203237518', CURDATE());
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [54] Troca para solicitação de Arrependimento
-- Esperado : ERROR 1644 (45000): Troca só para solicitação de Defeito ou Garantia.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca) VALUES (4, '353879234252633', CURDATE());
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   NOTA_FISCAL
   --------------------------------------------------------------------- */
-- [55] Segunda nota de venda para o mesmo pedido
-- Esperado : ERROR 1644 (45000): Este pedido já possui nota fiscal de venda ativa.
START TRANSACTION;
SET @cellgo_funcionario = 7;
INSERT INTO NOTA_FISCAL (Id_Pedido, Tipo_Nota, Natureza) VALUES (1, 'Venda', 'Venda de mercadoria');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [56] Nota de venda para pedido ainda sem pagamento aprovado
-- Esperado : ERROR 1644 (45000): A nota fiscal de venda só é emitida depois do pagamento aprovado.
START TRANSACTION;
SET @cellgo_funcionario = 7;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
INSERT INTO NOTA_FISCAL (Id_Pedido, Tipo_Nota, Natureza) VALUES (100, 'Venda', 'Venda de mercadoria');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [57] Alterar o número de uma nota já emitida
-- Esperado : ERROR 1644 (45000): Número, chave e data de uma nota emitida não podem ser alterados.
START TRANSACTION;
SET @cellgo_funcionario = 7;
UPDATE NOTA_FISCAL SET Numero_Nota = 9999 WHERE Id_Nota = 1;
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [58] Excluir nota fiscal
-- Esperado : ERROR 1644 (45000): Nota fiscal não pode ser excluída.
DELETE FROM NOTA_FISCAL WHERE Id_Nota = 8;


/* ---------------------------------------------------------------------
   ITEM_NOTA_FISCAL
   --------------------------------------------------------------------- */
-- [59] Incluir item em nota já emitida
-- Esperado : ERROR 1644 (45000): Itens só podem ser incluídos antes da emissão da nota.
START TRANSACTION;
SET @cellgo_funcionario = 7;
INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES ('353879234252633', 1, 100.00);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [60] Aparelho que não é o de reposição da troca
-- Esperado : ERROR 1644 (45000): O aparelho não é o aparelho de reposição da troca.
START TRANSACTION;
SET @cellgo_funcionario = 7;
INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES ('353879234252633', 8, 100.00);
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   ESTORNO
   --------------------------------------------------------------------- */
-- [61] Estornar pagamento que não foi aprovado (Recusado)
-- Esperado : ERROR 1644 (45000): Só é possível estornar um pagamento Aprovado.
START TRANSACTION;
SET @cellgo_funcionario = 7;
INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor) VALUES (1, 1, 100.00);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [62] Valor do estorno maior que o valor pago
-- Esperado : ERROR 1644 (45000): O valor do estorno não pode ser maior que o valor pago.
START TRANSACTION;
SET @cellgo_funcionario = 7;
INSERT INTO ESTORNO (Id_Pagamento, Codigo_Devolucao, Valor) VALUES (2, 1, 99999.00);
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   ENTREGA
   --------------------------------------------------------------------- */
-- [63] Entrega de venda para pedido que não está Pago
-- Esperado : ERROR 1644 (45000): A entrega de venda só é criada para pedido Pago.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BRTESTE0002', 100, 'Correios');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [64] Segunda entrega de venda para o mesmo pedido
-- Esperado : ERROR 1644 (45000): Este pedido já possui entrega de venda.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BRTESTE0003', 3, 'Correios');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [65] Voltar o status da entrega (Entregue → Em transporte)
-- Esperado : ERROR 1644 (45000): O status da entrega não pode voltar para uma etapa anterior.
START TRANSACTION;
SET @cellgo_funcionario = 6;
UPDATE ENTREGA SET Status_Entrega = 'Em transporte', Data_Entrega = NULL WHERE Codigo_Rastreio = 'BR123456789SP';
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   MOVIMENTACAO
   --------------------------------------------------------------------- */
-- [66] Registrar movimentação com status novo diferente do status atual
-- Esperado : ERROR 1644 (45000): O status novo da movimentação deve ser o status atual do aparelho.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO MOVIMENTACAO (Imei, Tipo_Movimento, Status_Anterior, Status_Novo) VALUES ('353879234252633', 'Venda', 'Disponível', 'Vendido');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [67] Alterar histórico de movimentação
-- Esperado : ERROR 1644 (45000): O histórico de movimentações não pode ser alterado.
UPDATE MOVIMENTACAO SET Status_Novo = 'Inativo' WHERE Numero_Movimentacao = 1;

-- [68] Excluir histórico de movimentação
-- Esperado : ERROR 1644 (45000): O histórico de movimentações não pode ser excluído.
DELETE FROM MOVIMENTACAO WHERE Numero_Movimentacao = 1;


/* ---------------------------------------------------------------------
   AUDITORIA
   --------------------------------------------------------------------- */
-- [69] Autorizador que não é da Diretoria
-- Esperado : ERROR 1644 (45000): O autorizador registrado na auditoria deve ser da Diretoria.
INSERT INTO AUDITORIA (Codigo_Funcionario, Codigo_Autorizador, Acao, Tabela_Afetada, Registro_Id, Valor_Novo) VALUES (2, 3, 'UPDATE', 'CLIENTE', '1', '{"a": 1}');

-- [70] Alterar registro de auditoria
-- Esperado : ERROR 1644 (45000): Registros de auditoria não podem ser alterados.
UPDATE AUDITORIA SET Acao = 'ALTERADO' WHERE Id_Auditoria = 1;

-- [71] Excluir registro de auditoria
-- Esperado : ERROR 1644 (45000): Registros de auditoria não podem ser excluídos.
DELETE FROM AUDITORIA WHERE Id_Auditoria = 1;