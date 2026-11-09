/* =====================================================================
   CellGO — Testes das validações das TABELAS (CHECK, NOT NULL, UNIQUE, FK, ENUM)
   SGBD: MySQL 8

   COMO EXECUTAR
   1. Rode tabelas.sql, trigger.sql e insert_validos.sql (banco cellgo pronto);
   2. Rode este arquivo. Quase todos os comandos terminam em ERRO: é isso
      que prova que a validação funciona. No MySQL Workbench, ative
      Query > 'Continue SQL Script Execution After Errors'; no terminal,
      use: mysql --force -u root cellgo < testes_tabelas.sql

   Cada bloco é um INSERT com dado errado de propósito. O banco deve RECUSAR
   o comando, e o erro esperado vem escrito acima dele.

   Tipos de validação testados:
     CHECK     → regra da tabela (formato, faixa, campo condicional)
     NOT NULL  → campo obrigatório vazio
     UNIQUE    → chave primária ou campo único repetido
     FK        → chave estrangeira apontando para registro inexistente
     ENUM      → valor fora da lista permitida

   Os blocos com START TRANSACTION ... ROLLBACK montam um cenário de apoio
   (pedido, aquisição etc.) e o desfazem no fim, então os dados do
   insert_validos.sql não são alterados. Os Ids 100 a 103 são só de teste.
   Total: 66 testes. Todos foram executados e recusados como descrito.
   ===================================================================== */

SET NAMES utf8mb4;
USE cellgo;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   PERFIL_ACESSO
   --------------------------------------------------------------------- */
-- [01] Nome de perfil que não existe na lista
-- Validação: CHECK  (chk_perfil_nome)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_perfil_nome' is violated.
INSERT INTO PERFIL_ACESSO (Id_Perfil, Nome_Perfil, Nivel_Acesso) VALUES (90, 'Estagiário', 1);

-- [02] Diretoria com nível operacional (1)
-- Validação: CHECK  (chk_perfil_nivel)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_perfil_nivel' is violated.
INSERT INTO PERFIL_ACESSO (Id_Perfil, Nome_Perfil, Nivel_Acesso) VALUES (90, 'Diretoria', 1);

-- [03] Nome de perfil repetido
-- Validação: UNIQUE  (uq_perfil_nome)
-- Esperado : ERROR 1062 (23000): Duplicate entry 'Diretoria' for key 'PERFIL_ACESSO.uq_perfil_nome'
INSERT INTO PERFIL_ACESSO (Id_Perfil, Nome_Perfil, Nivel_Acesso) VALUES (90, 'Diretoria', 2);

-- [04] Nível de acesso vazio
-- Validação: NOT NULL  (PERFIL_ACESSO)
-- Esperado : ERROR 1048 (23000): Column 'Nivel_Acesso' cannot be null
INSERT INTO PERFIL_ACESSO (Id_Perfil, Nome_Perfil, Nivel_Acesso) VALUES (90, 'Vendas e Atendimento', NULL);


/* ---------------------------------------------------------------------
   FUNCIONARIO
   --------------------------------------------------------------------- */
-- [05] Login com espaço
-- Validação: CHECK  (chk_funcionario_login)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_funcionario_login' is violated.
INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('Teste', 'Analista', 'login com espaco', 1);

-- [06] Nome em branco
-- Validação: CHECK  (chk_funcionario_nome)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_funcionario_nome' is violated.
INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('   ', 'Analista', 'teste.nome', 1);

-- [07] Perfil que não existe
-- Validação: FK  (fk_funcionario_perfil)
-- Esperado : ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`cellgo`.`FUNCIONARIO`, CONSTRAINT `fk_funcionario_perfil` FOREIGN KEY (`Id_Perfil`) REFERENCES `PERFIL_ACESSO` (`Id_Perfil`))
INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('Teste', 'Analista', 'teste.perfil', 99);

-- [08] Login repetido
-- Validação: UNIQUE  (uq_funcionario_login)
-- Esperado : ERROR 1062 (23000): Duplicate entry 'carlos.silva' for key 'FUNCIONARIO.uq_funcionario_login'
INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('Teste', 'Analista', 'carlos.silva', 1);


/* ---------------------------------------------------------------------
   FORNECEDOR
   --------------------------------------------------------------------- */
-- [09] Pessoa física com CNPJ de 14 dígitos
-- Validação: CHECK  (chk_fornecedor_documento)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_fornecedor_documento' is violated.
INSERT INTO FORNECEDOR (Cpf_Cnpj_Fornecedor, Tipo_Pessoa, Nome, Tipo_Documento, Numero_Documento, Telefone_Contato) VALUES ('12345678000199', 'PF', 'Fornecedor Teste', 'RG', '123456', '11987654321');

-- [10] Pessoa física sem RG/CNH
-- Validação: CHECK  (chk_fornecedor_doc_foto)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_fornecedor_doc_foto' is violated.
INSERT INTO FORNECEDOR (Cpf_Cnpj_Fornecedor, Tipo_Pessoa, Nome, Tipo_Documento, Numero_Documento, Telefone_Contato) VALUES ('11122233396', 'PF', 'Fornecedor Teste', NULL, NULL, '11987654321');

-- [11] Telefone de contato curto demais
-- Validação: CHECK  (chk_fornecedor_telefone)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_fornecedor_telefone' is violated.
INSERT INTO FORNECEDOR (Cpf_Cnpj_Fornecedor, Tipo_Pessoa, Nome, Tipo_Documento, Numero_Documento, Telefone_Contato) VALUES ('11122233000144', 'PJ', 'Fornecedor Teste', NULL, NULL, '12345');

-- [12] CPF/CNPJ de fornecedor repetido
-- Validação: UNIQUE  (PRIMARY)
-- Esperado : ERROR 1062 (23000): Duplicate entry '11222333000181' for key 'FORNECEDOR.PRIMARY'
INSERT INTO FORNECEDOR (Cpf_Cnpj_Fornecedor, Tipo_Pessoa, Nome, Tipo_Documento, Numero_Documento, Telefone_Contato) VALUES ('11222333000181', 'PJ', 'Outro Nome', NULL, NULL, '1133445566');


/* ---------------------------------------------------------------------
   MODELO
   --------------------------------------------------------------------- */
-- [13] Nome de modelo repetido
-- Validação: UNIQUE  (uq_modelo_nome)
-- Esperado : ERROR 1062 (23000): Duplicate entry 'Galaxy S23' for key 'MODELO.uq_modelo_nome'
INSERT INTO MODELO (Nome_Modelo, Marca) VALUES ('Galaxy S23', 'Samsung');

-- [14] Marca em branco
-- Validação: CHECK  (chk_modelo_marca)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_modelo_marca' is violated.
INSERT INTO MODELO (Nome_Modelo, Marca) VALUES ('Modelo Teste', '  ');


/* ---------------------------------------------------------------------
   ESPECIFICACAO_APARELHO
   --------------------------------------------------------------------- */
-- [15] Capacidade zero
-- Validação: CHECK  (chk_especificacao_capacidade)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_especificacao_capacidade' is violated.
INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade) VALUES (1, 'Rosa', 0);

-- [16] Limite crítico menor ou igual ao de atenção
-- Validação: CHECK  (chk_especificacao_critico)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_especificacao_critico' is violated.
INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade, Limite_Dias_Atencao, Limite_Dias_Critico) VALUES (1, 'Rosa', 64, 50, 40);

-- [17] Modelo que não existe
-- Validação: FK  (fk_especificacao_modelo)
-- Esperado : ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`cellgo`.`ESPECIFICACAO_APARELHO`, CONSTRAINT `fk_especificacao_modelo` FOREIGN KEY (`Id_Modelo`) REFERENCES `MODELO` (`Id_Modelo`))
INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade) VALUES (99, 'Rosa', 64);

-- [18] Mesmo modelo + cor + capacidade
-- Validação: UNIQUE  (uq_especificacao)
-- Esperado : ERROR 1062 (23000): Duplicate entry '1-Preto-128' for key 'ESPECIFICACAO_APARELHO.uq_especificacao'
INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade) VALUES (1, 'Preto', 128);


/* ---------------------------------------------------------------------
   CLIENTE
   --------------------------------------------------------------------- */
-- [19] CPF com letra
-- Validação: CHECK  (chk_cliente_documento)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_cliente_documento' is violated.
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES ('1234567890A', 'Cliente Teste', 'teste1@email.com', '1990-01-01', 'PF');

-- [20] E-mail sem @
-- Validação: CHECK  (chk_cliente_email)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_cliente_email' is violated.
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES ('11122233396', 'Cliente Teste', 'email-sem-arroba', '1990-01-01', 'PF');

-- [21] Pessoa jurídica com data de nascimento
-- Validação: CHECK  (chk_cliente_nascimento)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_cliente_nascimento' is violated.
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES ('11222333000144', 'Empresa Teste', 'empresa.teste@email.com', '1990-01-01', 'PJ');

-- [22] E-mail repetido
-- Validação: UNIQUE  (uq_cliente_email)
-- Esperado : ERROR 1062 (23000): Duplicate entry 'ana.carvalho@email.com' for key 'CLIENTE.uq_cliente_email'
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES ('11122233396', 'Cliente Teste', 'ana.carvalho@email.com', '1990-01-01', 'PF');

-- [23] CPF repetido
-- Validação: UNIQUE  (PRIMARY)
-- Esperado : ERROR 1062 (23000): Duplicate entry '32165498700' for key 'CLIENTE.PRIMARY'
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES ('32165498700', 'Cliente Teste', 'outro@email.com', '1990-01-01', 'PF');

-- [24] Nome vazio (NULL)
-- Validação: NOT NULL  (CLIENTE)
-- Esperado : ERROR 1048 (23000): Column 'Nome' cannot be null
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES ('11122233396', NULL, 'teste2@email.com', '1990-01-01', 'PF');

-- [25] Tipo de pessoa fora do ENUM
-- Validação: ENUM  (CLIENTE)
-- Esperado : ERROR 1265 (01000): Data truncated for column 'Tipo_Pessoa' at row 1
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES ('11122233396', 'Cliente Teste', 'teste3@email.com', '1990-01-01', 'XX');


/* ---------------------------------------------------------------------
   ENDERECO
   --------------------------------------------------------------------- */
-- [26] Cliente que não existe
-- Validação: FK  (fk_endereco_cliente)
-- Esperado : ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`cellgo`.`ENDERECO`, CONSTRAINT `fk_endereco_cliente` FOREIGN KEY (`Cpf_Cnpj`) REFERENCES `CLIENTE` (`Cpf_Cnpj`))
INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES ('99999999999', 'Rua Teste', 'Centro', 'São Paulo', '01001000', '10', 'Residencial');

-- [27] CEP com 7 dígitos
-- Validação: CHECK  (chk_endereco_cep)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_endereco_cep' is violated.
INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES ('32165498700', 'Rua Teste', 'Centro', 'São Paulo', '0100100', '10', 'Residencial');

-- [28] Tipo de endereço inválido
-- Validação: CHECK  (chk_endereco_tipo)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_endereco_tipo' is violated.
INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES ('32165498700', 'Rua Teste', 'Centro', 'São Paulo', '01001000', '10', 'Escritório');


/* ---------------------------------------------------------------------
   TELEFONE
   --------------------------------------------------------------------- */
-- [29] DDD com um dígito
-- Validação: CHECK  (chk_telefone_ddd)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_telefone_ddd' is violated.
INSERT INTO TELEFONE (Cpf_Cnpj, DDD, Numero_Telefone) VALUES ('32165498700', 5, 987654322);

-- [30] Número fora do padrão de fixo/celular
-- Validação: CHECK  (chk_telefone_numero)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_telefone_numero' is violated.
INSERT INTO TELEFONE (Cpf_Cnpj, DDD, Numero_Telefone) VALUES ('32165498700', 11, 12345678);

-- [31] Telefone repetido para o mesmo cliente
-- Validação: UNIQUE  (PRIMARY)
-- Esperado : ERROR 1062 (23000): Duplicate entry '32165498700-11-987654321' for key 'TELEFONE.PRIMARY'
INSERT INTO TELEFONE (Cpf_Cnpj, DDD, Numero_Telefone) VALUES ('32165498700', 11, 987654321);


/* ---------------------------------------------------------------------
   AQUISICAO
   --------------------------------------------------------------------- */
-- [32] Número do documento de compra em branco
-- Validação: CHECK  (chk_aquisicao_num_doc)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_aquisicao_num_doc' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', '   ');
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   AVALIACAO_ENTRADA
   --------------------------------------------------------------------- */
-- [33] IMEI com 14 dígitos
-- Validação: CHECK  (chk_aval_entrada_imei)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_aval_entrada_imei' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Resultado, Motivo_Recusa) VALUES (3, 100, '12345678901234', 'CEIR/Anatel', 'Regular', NOW(), 'Recusado', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [34] Aprovada com IMEI Bloqueado
-- Validação: CHECK  (chk_aval_entrada_aprovado)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_aval_entrada_aprovado' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Reset_Fabrica_Realizado, Resultado) VALUES (3, 100, '222222222222227', 'CEIR/Anatel', 'Bloqueado', NOW(), 1, 1, 'Aprovado');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [35] Recusada sem motivo
-- Validação: CHECK  (chk_aval_entrada_motivo)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_aval_entrada_motivo' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Resultado) VALUES (3, 100, '222222222222227', 'CEIR/Anatel', 'Bloqueado', NOW(), 'Recusado');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [36] Resultado da consulta fora da lista
-- Validação: CHECK  (chk_aval_entrada_consulta)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_aval_entrada_consulta' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Resultado, Motivo_Recusa) VALUES (3, 100, '222222222222227', 'CEIR/Anatel', 'Duvidoso', NOW(), 'Recusado', 'Teste');
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   APARELHO
   --------------------------------------------------------------------- */
-- [37] Preço de venda zero
-- Validação: CHECK  (chk_aparelho_preco)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_aparelho_preco' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (100, 3, 100, '111111111111119', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada) VALUES ('111111111111119', 1, 100, 3, 'Novo', 0.00, 100.00, 'Disponível', CURDATE());
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [38] Custo de aquisição negativo
-- Validação: CHECK  (chk_aparelho_custo)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_aparelho_custo' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (100, 3, 100, '111111111111119', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada) VALUES ('111111111111119', 1, 100, 3, 'Novo', 1000.00, -5.00, 'Disponível', CURDATE());
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [39] Condição fora do ENUM
-- Validação: ENUM  (APARELHO)
-- Esperado : ERROR 1265 (01000): Data truncated for column 'Condicao' at row 1
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (100, 3, 100, '111111111111119', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada) VALUES ('111111111111119', 1, 100, 3, 'Quebrado', 1000.00, 500.00, 'Disponível', CURDATE());
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [40] Especificação que não existe
-- Validação: FK  (fk_aparelho_especificacao)
-- Esperado : ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`cellgo`.`APARELHO`, CONSTRAINT `fk_aparelho_especificacao` FOREIGN KEY (`Id_Especificacao`) REFERENCES `ESPECIFICACAO_APARELHO` (`Id_Especificacao`))
START TRANSACTION;
SET @cellgo_funcionario = 2;
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra) VALUES (100, 2, '11222333000181', CURDATE(), 'Nota fiscal do fornecedor', 'NF-TESTE-100');
SET @cellgo_funcionario = 3;
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES (100, 3, 100, '111111111111119', 'CEIR/Anatel', 'Regular', NOW(), 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado');
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada) VALUES ('111111111111119', 99, 100, 3, 'Novo', 1000.00, 500.00, 'Disponível', CURDATE());
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   IMAGEM_APARELHO
   --------------------------------------------------------------------- */
-- [41] URL sem http/https
-- Validação: CHECK  (chk_imagem_url)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_imagem_url' is violated.
INSERT INTO IMAGEM_APARELHO (Imei, URL) VALUES ('356938035643809', 'imagem-local.jpg');

-- [42] Aparelho que não existe
-- Validação: FK  (fk_imagem_aparelho)
-- Esperado : ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`cellgo`.`IMAGEM_APARELHO`, CONSTRAINT `fk_imagem_aparelho` FOREIGN KEY (`Imei`) REFERENCES `APARELHO` (`Imei`))
INSERT INTO IMAGEM_APARELHO (Imei, URL) VALUES ('000000000000000', 'https://cellgo.com.br/img/x.jpg');

-- [43] Mesma imagem repetida para o aparelho
-- Validação: UNIQUE  (uq_imagem_url)
-- Esperado : ERROR 1062 (23000): Duplicate entry '356938035643809-https://cellgo.com.br/imagens/aparelhos/35693803' for key 'IMAGEM_APARELHO.uq_imagem_url'
INSERT INTO IMAGEM_APARELHO (Imei, URL) VALUES ('356938035643809', 'https://cellgo.com.br/imagens/aparelhos/356938035643809_frente.jpg');


/* ---------------------------------------------------------------------
   PEDIDO
   --------------------------------------------------------------------- */
-- [44] Cliente que não existe (erro 1452)
-- Validação: FK  (fk_pedido_cliente)
-- Esperado : ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`cellgo`.`PEDIDO`, CONSTRAINT `fk_pedido_cliente` FOREIGN KEY (`Cpf_Cnpj`) REFERENCES `CLIENTE` (`Cpf_Cnpj`))
INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('99999999999', 'Pix', 1);

-- [45] Pix parcelado em 3x
-- Validação: CHECK  (chk_pedido_parcelas)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_pedido_parcelas' is violated.
INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('32165498700', 'Pix', 3);

-- [46] Cartão em 13 parcelas
-- Validação: CHECK  (chk_pedido_parcelas)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_pedido_parcelas' is violated.
INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('32165498700', 'Cartão de crédito', 13);

-- [47] Taxa informada em pedido Pix
-- Validação: CHECK  (chk_pedido_taxas)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_pedido_taxas' is violated.
INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas, Valor_Taxas) VALUES ('32165498700', 'Pix', 1, 10.00);

-- [48] Forma de pagamento fora do ENUM (Boleto)
-- Validação: ENUM  (PEDIDO)
-- Esperado : ERROR 1265 (01000): Data truncated for column 'Forma_Pagamento' at row 1
INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('32165498700', 'Boleto', 1);


/* ---------------------------------------------------------------------
   ITEM_PEDIDO
   --------------------------------------------------------------------- */
-- [49] Pedido que não existe
-- Validação: FK  (fk_item_pedido_pedido)
-- Esperado : ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`cellgo`.`ITEM_PEDIDO`, CONSTRAINT `fk_item_pedido_pedido` FOREIGN KEY (`Id_Pedido`) REFERENCES `PEDIDO` (`Id_Pedido`))
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 9999);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [50] Mesmo aparelho duas vezes no mesmo pedido
-- Validação: UNIQUE  (PRIMARY)
-- Esperado : ERROR 1062 (23000): Duplicate entry '100-353879234252633' for key 'ITEM_PEDIDO.PRIMARY'
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   PAGAMENTO
   --------------------------------------------------------------------- */
-- [51] Aprovado sem código de transação
-- Validação: CHECK  (chk_pagamento_aprovado)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_pagamento_aprovado' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Data_Confirmacao, Valor, Status) VALUES (100, NOW(), @valor, 'Aprovado');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [52] Aprovado sem data de confirmação
-- Validação: CHECK  (chk_pagamento_aprovado)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_pagamento_aprovado' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Valor, Status) VALUES (100, 'TX-TESTE-X1', @valor, 'Aprovado');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [53] Pendente com data de confirmação
-- Validação: CHECK  (chk_pagamento_nao_aprovado)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_pagamento_nao_aprovado' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Data_Confirmacao, Valor) VALUES (100, NOW(), @valor);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [54] Confirmação anterior à tentativa
-- Validação: CHECK  (chk_pagamento_datas)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_pagamento_datas' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status) VALUES (100, 'TX-TESTE-X2', NOW(), DATE_SUB(NOW(), INTERVAL 1 HOUR), @valor, 'Aprovado');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [55] Status de pagamento inválido (Pago)
-- Validação: CHECK  (chk_pagamento_status)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_pagamento_status' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Valor, Status) VALUES (100, @valor, 'Pago');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [56] Código de transação repetido
-- Validação: UNIQUE  (uq_pagamento_transacao)
-- Esperado : ERROR 1062 (23000): Duplicate entry 'TESTE-TRANSACAO-002' for key 'PAGAMENTO.uq_pagamento_transacao'
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Valor) VALUES (100, 'TESTE-TRANSACAO-002', @valor);
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [57] Valor vazio (NULL)
-- Validação: NOT NULL  (PAGAMENTO)
-- Esperado : ERROR 1048 (23000): Column 'Valor' cannot be null
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (100, NULL);
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   CANCELAMENTO
   --------------------------------------------------------------------- */
-- [58] Motivo em branco
-- Validação: CHECK  (chk_cancelamento_motivo)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_cancelamento_motivo' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
INSERT INTO CANCELAMENTO (Id_Pedido, Motivo) VALUES (100, '   ');
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   ENTREGA
   --------------------------------------------------------------------- */
-- [59] Código de rastreio curto demais
-- Validação: CHECK  (chk_entrega_rastreio)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_entrega_rastreio' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Data_Confirmacao, Valor, Status) VALUES (100, 'TX-SETUP-100', NOW(), @valor, 'Aprovado');
INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('ABC', 100, 'Correios');
ROLLBACK;
SET @cellgo_funcionario = NULL;

-- [60] Entregue sem data de despacho
-- Validação: CHECK  (chk_entrega_entregue)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_entrega_entregue' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 6;
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (100, '32165498700', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('353879234252633', 100);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 100;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 100);
INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Data_Confirmacao, Valor, Status) VALUES (100, 'TX-SETUP-100', NOW(), @valor, 'Aprovado');
INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora, Status_Entrega, Data_Entrega) VALUES ('BRTESTE0001', 100, 'Correios', 'Entregue', NOW());
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   REQUISICAO_COMPRA
   --------------------------------------------------------------------- */
-- [61] Quantidade sugerida zero
-- Validação: CHECK  (chk_requisicao_qtd)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_requisicao_qtd' is violated.
START TRANSACTION;
SET @cellgo_funcionario = 1;
INSERT INTO ESPECIFICACAO_APARELHO (Id_Especificacao, Id_Modelo, Cor, Capacidade) VALUES (100, 1, 'Rosa', 64);
INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida) VALUES (100, 0, 5, CURDATE(), 0);
ROLLBACK;
SET @cellgo_funcionario = NULL;


/* ---------------------------------------------------------------------
   AUDITORIA
   --------------------------------------------------------------------- */
-- [62] Tabela afetada que não existe no sistema
-- Validação: CHECK  (chk_auditoria_tabela)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_auditoria_tabela' is violated.
INSERT INTO AUDITORIA (Acao, Tabela_Afetada, Registro_Id, Valor_Novo) VALUES ('INSERT', 'TABELA_FANTASMA', '1', '{"a": 1}');

-- [63] Sem valor anterior nem valor novo
-- Validação: CHECK  (chk_auditoria_valores)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_auditoria_valores' is violated.
INSERT INTO AUDITORIA (Acao, Tabela_Afetada, Registro_Id) VALUES ('INSERT', 'CLIENTE', '1');

-- [64] JSON inválido no valor novo
-- Validação: ENUM  (AUDITORIA)
-- Esperado : ERROR 3140 (22032): Invalid JSON text: "Invalid value." at position 0 in value for column 'AUDITORIA.Valor_Novo'.
INSERT INTO AUDITORIA (Acao, Tabela_Afetada, Registro_Id, Valor_Novo) VALUES ('INSERT', 'CLIENTE', '1', 'isto não é json');


/* ---------------------------------------------------------------------
   NOTA_FISCAL
   --------------------------------------------------------------------- */
-- [65] Nota sem nenhuma origem (pedido, cancelamento ou pós-venda)
-- Validação: CHECK  (chk_nota_origem)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_nota_origem' is violated.
INSERT INTO NOTA_FISCAL (Tipo_Nota, Natureza) VALUES ('Venda', 'Venda de mercadoria');

-- [66] Chave de acesso com tamanho errado
-- Validação: CHECK  (chk_nota_chave)
-- Esperado : ERROR 3819 (HY000): Check constraint 'chk_nota_chave' is violated.
INSERT INTO NOTA_FISCAL (Id_Pedido, Tipo_Nota, Natureza, Chave_Acesso) VALUES (3, 'Venda', 'Venda de mercadoria', '123');
