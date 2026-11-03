USE cellgo;

-- Somente registros INVÁLIDOS, separados por TABELA e por TIPO DE ERRO esperado.
-- Todos devem ser barrados. Rode com: mysql --force -u root -p < arquivo.sql


-- ======================================================================
-- TABELA: PERFIL_ACESSO  (6 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (3) ----
-- PERFIL: nome fora da lista permitida
INSERT INTO PERFIL_ACESSO VALUES (90,'Estagiário',1);
-- PERFIL: Diretoria com nível 1 (deveria ser 2)
INSERT INTO PERFIL_ACESSO VALUES (90,'Diretoria',1);
-- PERFIL: perfil comum com nível 2 (deveria ser 1)
INSERT INTO PERFIL_ACESSO VALUES (90,'Vendas e Atendimento',2);

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- PERFIL: Nivel_Acesso NULL
INSERT INTO PERFIL_ACESSO VALUES (90,'Diretoria',NULL);

-- ---- Erro: 3. PK / UNIQUE duplicado (2) ----
-- PERFIL: nome duplicado (UNIQUE)
INSERT INTO PERFIL_ACESSO VALUES (90,'Diretoria',2);
-- PERFIL: PK duplicada
INSERT INTO PERFIL_ACESSO VALUES (1,'Diretoria',2);

-- ======================================================================
-- TABELA: FUNCIONARIO  (6 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (1) ----
-- FUNCIONARIO: Ativo = 2 (fora de 0/1)
INSERT INTO FUNCIONARIO VALUES (90,'Fulano','Vendedor','fulano',1,2);

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- FUNCIONARIO: Nome NULL
INSERT INTO FUNCIONARIO VALUES (90,NULL,'Vendedor','fulano',1,1);

-- ---- Erro: 3. PK / UNIQUE duplicado (2) ----
-- FUNCIONARIO: login duplicado
INSERT INTO FUNCIONARIO VALUES (90,'Outro Nome','Vendedor','ana.souza',1,1);
-- FUNCIONARIO: PK duplicada
INSERT INTO FUNCIONARIO VALUES (1,'Fulano','Vendedor','fulano',1,1);

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- FUNCIONARIO: perfil inexistente (FK)
INSERT INTO FUNCIONARIO VALUES (90,'Fulano','Vendedor','fulano',99,1);

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (1) ----
-- [LACUNA?] FUNCIONARIO: nome vazio (string em branco)
INSERT INTO FUNCIONARIO VALUES (91,'   ','Vendedor','vazio',1,1);

-- ======================================================================
-- TABELA: FORNECEDOR  (7 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (1) ----
-- FORNECEDOR: Tipo_Pessoa inválido
INSERT INTO FORNECEDOR VALUES ('99999999999','XX','Teste',NULL,NULL,'11999990000');

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- FORNECEDOR: telefone NULL
INSERT INTO FORNECEDOR VALUES ('99999999999','PF','Teste',NULL,NULL,NULL);

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- FORNECEDOR: PK duplicada
INSERT INTO FORNECEDOR VALUES ('12345678901','PF','Duplicado',NULL,NULL,'11999990000');

-- ---- Erro: 5. Tamanho excedido (VARCHAR/CHAR/DECIMAL) (1) ----
-- FORNECEDOR: CPF/CNPJ com 15 caracteres (excede VARCHAR(14))
INSERT INTO FORNECEDOR VALUES ('123456789012345','PJ','Teste',NULL,NULL,'11999990000');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (3) ----
-- [LACUNA?] FORNECEDOR: PF com documento de 14 dígitos (CNPJ)
INSERT INTO FORNECEDOR VALUES ('98765432000100','PF','PF com CNPJ',NULL,NULL,'11999990000');
-- [LACUNA?] FORNECEDOR: documento com letras
INSERT INTO FORNECEDOR VALUES ('ABCDEFGHIJK','PF','Doc inválido',NULL,NULL,'11999990000');
-- [LACUNA?] FORNECEDOR: telefone com letras/curto
INSERT INTO FORNECEDOR VALUES ('55555555555','PF','Tel inválido',NULL,NULL,'abc');

-- ======================================================================
-- TABELA: MODELO  (2 inserts inválidos)
-- ======================================================================

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- MODELO: Marca NULL
INSERT INTO MODELO VALUES (90,'Modelo X',NULL);

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- MODELO: nome duplicado (UNIQUE)
INSERT INTO MODELO VALUES (90,'iPhone 13','Apple');

-- ======================================================================
-- TABELA: ESPECIFICACAO_APARELHO  (8 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (6) ----
-- ESPECIFICACAO: capacidade 0
INSERT INTO ESPECIFICACAO_APARELHO VALUES (90,1,'Azul',0,3,30,60);
-- ESPECIFICACAO: capacidade negativa
INSERT INTO ESPECIFICACAO_APARELHO VALUES (90,1,'Azul',-64,3,30,60);
-- ESPECIFICACAO: estoque mínimo negativo
INSERT INTO ESPECIFICACAO_APARELHO VALUES (90,1,'Azul',128,-1,30,60);
-- ESPECIFICACAO: limite atenção negativo
INSERT INTO ESPECIFICACAO_APARELHO VALUES (90,1,'Azul',128,1,-1,60);
-- ESPECIFICACAO: limite crítico = atenção
INSERT INTO ESPECIFICACAO_APARELHO VALUES (90,1,'Azul',128,1,30,30);
-- ESPECIFICACAO: limite crítico < atenção
INSERT INTO ESPECIFICACAO_APARELHO VALUES (90,1,'Azul',128,1,30,10);

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- ESPECIFICACAO: combinação modelo+cor+capacidade repetida
INSERT INTO ESPECIFICACAO_APARELHO VALUES (90,1,'Preto',128,3,30,60);

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- ESPECIFICACAO: modelo inexistente (FK)
INSERT INTO ESPECIFICACAO_APARELHO VALUES (90,99,'Azul',128,1,30,60);

-- ======================================================================
-- TABELA: AQUISICAO  (9 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (3) ----
-- AQUISICAO: tipo de documento inválido
INSERT INTO AQUISICAO VALUES (90,1,'12345678000195','2026-10-01','Recibo','R-1',1,100.00,'Concluída');
-- AQUISICAO: status inválido
INSERT INTO AQUISICAO VALUES (90,1,'12345678000195','2026-10-01','Nota Fiscal','NF-9',1,100.00,'Pendente');
-- AQUISICAO: Data_Aquisicao inválida (30/02)
INSERT INTO AQUISICAO VALUES (90,1,'12345678000195','2026-02-30','Nota Fiscal','NF-9',1,100.00,'Concluída');

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- AQUISICAO: Valor_Total NULL
INSERT INTO AQUISICAO VALUES (90,1,'12345678000195','2026-10-01','Nota Fiscal','NF-9',1,NULL,'Concluída');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- AQUISICAO: fornecedor inexistente (FK)
INSERT INTO AQUISICAO VALUES (90,1,'00000000000000','2026-10-01','Nota Fiscal','NF-9',1,100.00,'Concluída');
-- AQUISICAO: funcionário inexistente (FK)
INSERT INTO AQUISICAO VALUES (90,99,'12345678000195','2026-10-01','Nota Fiscal','NF-9',1,100.00,'Concluída');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (3) ----
-- [LACUNA?] AQUISICAO: Valor_Total negativo
INSERT INTO AQUISICAO VALUES (91,1,'12345678000195','2026-10-01','Nota Fiscal','NF-NEG',1,-500.00,'Concluída');
-- [LACUNA?] AQUISICAO: concluída sem termo de responsabilidade aceito (NULL)
INSERT INTO AQUISICAO VALUES (92,1,'12345678901','2026-10-01','Termo de Compra e Venda','TCV-NULL',NULL,100.00,'Concluída');
-- [LACUNA?] AQUISICAO: data de aquisição no futuro
INSERT INTO AQUISICAO VALUES (93,1,'12345678000195','2030-01-01','Nota Fiscal','NF-FUT',1,100.00,'Concluída');

-- ======================================================================
-- TABELA: AVALIACAO_ENTRADA  (19 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (10) ----
-- AVALIACAO: resultado da consulta de IMEI inválido
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (90,3,1,'351234567890123','Anatel','Perdido','2026-10-01 10:00:00','Aprovado');
-- AVALIACAO: Resultado inválido
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (90,3,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00','Talvez');
-- AVALIACAO: Recusado sem motivo (NULL)
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (90,3,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00','Recusado');
-- AVALIACAO: Recusado com motivo só espaços
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado,Motivo_Recusa) VALUES (90,3,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00','Recusado','     ');
-- AVALIACAO: reconsulta anterior à consulta
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado,Data_Reconsulta_Imei,Resultado_Reconsulta_Imei) VALUES (90,3,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00','Aprovado','2026-09-01 10:00:00','Regular');
-- AVALIACAO: data de reconsulta sem resultado da reconsulta
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado,Data_Reconsulta_Imei) VALUES (90,3,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00','Aprovado','2026-10-02 10:00:00');
-- AVALIACAO: resultado da reconsulta sem data da reconsulta
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado,Resultado_Reconsulta_Imei) VALUES (90,3,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00','Aprovado','Regular');
-- AVALIACAO: resultado da reconsulta com valor inválido
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado,Data_Reconsulta_Imei,Resultado_Reconsulta_Imei) VALUES (90,3,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00','Aprovado','2026-10-02 10:00:00','Sumiu');
-- AVALIACAO: checklist com valor 2
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Checklist_Bateria,Resultado) VALUES (90,3,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00',2,'Aprovado');
-- AVALIACAO: Bloqueio_Conta com valor 5
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Bloqueio_Conta,Resultado) VALUES (90,3,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00',5,'Aprovado');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- AVALIACAO: aquisição inexistente (FK)
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (90,3,99,'351234567890123','Anatel','Regular','2026-10-01 10:00:00','Aprovado');
-- AVALIACAO: funcionário inexistente (FK)
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (90,99,1,'351234567890123','Anatel','Regular','2026-10-01 10:00:00','Aprovado');

-- ---- Erro: 5. Tamanho excedido (VARCHAR/CHAR/DECIMAL) (1) ----
-- AVALIACAO: IMEI com mais de 15 caracteres
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (90,3,1,'3512345678901234','Anatel','Regular','2026-10-01 10:00:00','Aprovado');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (6) ----
-- [LACUNA?] AVALIACAO: IMEI curto/com letras (ex.: ABC)
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (91,3,1,'ABC','Anatel','Regular','2026-10-01 10:00:00','Aprovado');
-- [LACUNA?] AVALIACAO: Aprovado com IMEI Roubado/Furtado
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (92,3,1,'351111111111111','Anatel','Roubado/Furtado','2026-10-01 10:00:00','Aprovado');
-- [LACUNA?] AVALIACAO: Aprovado com IMEI Bloqueado
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (93,3,1,'351111111111112','Anatel','Bloqueado','2026-10-01 10:00:00','Aprovado');
-- [LACUNA?] AVALIACAO: Aprovado com checklist reprovado (tela = 0)
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Checklist_Tela,Resultado) VALUES (94,3,1,'351111111111113','Anatel','Regular','2026-10-01 10:00:00',0,'Aprovado');
-- [LACUNA?] AVALIACAO: Aprovado com conta ainda bloqueada (Bloqueio_Conta=1)
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Bloqueio_Conta,Resultado) VALUES (95,3,1,'351111111111114','Anatel','Regular','2026-10-01 10:00:00',1,'Aprovado');
-- [LACUNA?] AVALIACAO: avaliação aprovada para aquisição já Recusada
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada,Codigo_Funcionario,Id_Aquisicao,Imei_Avaliado,Base_Consultada,Resultado_Consulta_Imei,Data_Consulta,Resultado) VALUES (96,3,3,'351111111111115','Anatel','Regular','2026-10-06 12:00:00','Aprovado');

-- ======================================================================
-- TABELA: APARELHO  (20 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (7) ----
-- APARELHO: Condicao inválida
INSERT INTO APARELHO VALUES ('354567890123456',1,5,2,'Usado',1000.00,500.00,'Disponível','2026-10-10',NULL,NULL,0);
-- APARELHO: Status inválido
INSERT INTO APARELHO VALUES ('354567890123456',1,5,2,'Novo',1000.00,500.00,'Roubado','2026-10-10',NULL,NULL,0);
-- APARELHO: preço de venda negativo
INSERT INTO APARELHO VALUES ('354567890123456',1,5,2,'Novo',-1.00,500.00,'Disponível','2026-10-10',NULL,NULL,0);
-- APARELHO: custo de aquisição negativo
INSERT INTO APARELHO VALUES ('354567890123456',1,5,2,'Novo',1000.00,-1.00,'Disponível','2026-10-10',NULL,NULL,0);
-- APARELHO: Data_Disponivel anterior à entrada
INSERT INTO APARELHO VALUES ('354567890123456',1,5,2,'Novo',1000.00,500.00,'Disponível','2026-10-10','2026-10-01',NULL,0);
-- APARELHO: Data_Fim_Quarentena anterior à entrada
INSERT INTO APARELHO VALUES ('354567890123456',1,5,2,'Novo',1000.00,500.00,'Em quarentena','2026-10-10',NULL,'2026-10-01',0);
-- APARELHO: Elegivel_Desconto_Pix = 2
INSERT INTO APARELHO VALUES ('354567890123456',1,5,2,'Novo',1000.00,500.00,'Disponível','2026-10-10',NULL,NULL,2);

-- ---- Erro: 3. PK / UNIQUE duplicado (2) ----
-- APARELHO: avaliação de entrada já usada por outro aparelho (UNIQUE)
INSERT INTO APARELHO VALUES ('359000000000010',1,1,2,'Novo',4500.00,3000.00,'Disponível','2026-10-01',NULL,NULL,0);
-- APARELHO: IMEI duplicado (PK)
INSERT INTO APARELHO VALUES ('351234567890123',1,5,2,'Novo',4500.00,3000.00,'Disponível','2026-10-01',NULL,NULL,0);

-- ---- Erro: 4. FK (chave estrangeira inexistente) (3) ----
-- APARELHO: especificação inexistente (FK)
INSERT INTO APARELHO VALUES ('354567890123456',99,5,2,'Novo',1000.00,500.00,'Disponível','2026-10-10',NULL,NULL,0);
-- APARELHO: avaliação inexistente (FK)
INSERT INTO APARELHO VALUES ('354567890123456',1,99,2,'Novo',1000.00,500.00,'Disponível','2026-10-10',NULL,NULL,0);
-- APARELHO: funcionário inexistente (FK)
INSERT INTO APARELHO VALUES ('354567890123456',1,5,99,'Novo',1000.00,500.00,'Disponível','2026-10-10',NULL,NULL,0);

-- ---- Erro: 5. Tamanho excedido (VARCHAR/CHAR/DECIMAL) (1) ----
-- APARELHO: IMEI maior que 15 caracteres
INSERT INTO APARELHO VALUES ('3545678901234567',1,5,2,'Novo',1000.00,500.00,'Disponível','2026-10-10',NULL,NULL,0);

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (7) ----
-- [LACUNA?] APARELHO: Seminovo marcado como elegível a desconto Pix (regra a confirmar)
INSERT INTO APARELHO VALUES ('359000000000011',2,5,2,'Seminovo',1000.00,500.00,'Disponível','2026-10-10',NULL,NULL,1);
-- [LACUNA?] APARELHO: preço de venda menor que o custo (prejuízo)
INSERT INTO APARELHO VALUES ('359000000000012',1,5,2,'Novo',100.00,500.00,'Disponível','2026-10-10',NULL,NULL,0);
-- [LACUNA?] APARELHO: Em quarentena sem Data_Fim_Quarentena
INSERT INTO APARELHO VALUES ('359000000000013',1,5,2,'Novo',1000.00,500.00,'Em quarentena','2026-10-10',NULL,NULL,0);
-- [LACUNA?] APARELHO: Disponível sem Data_Disponivel
INSERT INTO APARELHO VALUES ('359000000000014',1,5,2,'Novo',1000.00,500.00,'Disponível','2026-10-10',NULL,NULL,0);
-- [LACUNA?] APARELHO: IMEI com letras/curto
INSERT INTO APARELHO VALUES ('ABC',1,5,2,'Novo',1000.00,500.00,'Disponível','2026-10-10','2026-10-11',NULL,0);
-- [LACUNA?] APARELHO: vinculado a avaliação RECUSADA (avaliação 3)
INSERT INTO APARELHO VALUES ('353999999999999',1,3,2,'Novo',1000.00,500.00,'Disponível','2026-10-06','2026-10-07',NULL,0);
-- [LACUNA?] APARELHO: IMEI diferente do Imei_Avaliado da avaliação 5
INSERT INTO APARELHO VALUES ('359000000000099',1,5,2,'Novo',1000.00,500.00,'Disponível','2026-10-10','2026-10-11',NULL,0);

-- ======================================================================
-- TABELA: CLIENTE  (14 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (4) ----
-- CLIENTE: PF menor de idade (2015)
INSERT INTO CLIENTE VALUES ('55566677788','Menor','menor@email.com','2015-01-01','PF');
-- CLIENTE: PF sem data de nascimento
INSERT INTO CLIENTE VALUES ('66677788899','Sem Data','semdata@email.com',NULL,'PF');
-- CLIENTE: PF com data de nascimento no futuro
INSERT INTO CLIENTE VALUES ('77788899900','Futuro','futuro@email.com','2035-01-01','PF');
-- CLIENTE: Tipo_Pessoa inválido
INSERT INTO CLIENTE VALUES ('88899900011','Teste','t@email.com','1990-01-01','XX');

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- CLIENTE: Email NULL
INSERT INTO CLIENTE VALUES ('99900011133','Teste',NULL,NULL,'PJ');

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- CLIENTE: PK duplicada
INSERT INTO CLIENTE VALUES ('12345678909','Duplicada','dup@email.com','1990-01-01','PF');

-- ---- Erro: 5. Tamanho excedido (VARCHAR/CHAR/DECIMAL) (1) ----
-- CLIENTE: CPF/CNPJ com 15 caracteres
INSERT INTO CLIENTE VALUES ('123456789012345','Longo','l@email.com',NULL,'PJ');

-- ---- Erro: 6. TRIGGER (3) ----
-- CLIENTE: PF a 1 dia de completar 18 anos (trigger)
INSERT INTO CLIENTE VALUES ('44455566677','Quase Maior','quase@email.com',DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 18 YEAR), INTERVAL 1 DAY),'PF');
-- CLIENTE: UPDATE para menor de idade (trigger de update)
UPDATE CLIENTE SET Data_Nascimento = '2015-01-01' WHERE Cpf_Cnpj = '12345678909';
-- CLIENTE: UPDATE de PF para NULL na data de nascimento
UPDATE CLIENTE SET Data_Nascimento = NULL WHERE Cpf_Cnpj = '12345678909';

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (4) ----
-- [LACUNA?] CLIENTE: PJ com 11 dígitos / PF com 14 dígitos
INSERT INTO CLIENTE VALUES ('11222333000199','PF com CNPJ','pf14@email.com','1990-01-01','PF');
-- [LACUNA?] CLIENTE: e-mail em formato inválido
INSERT INTO CLIENTE VALUES ('10101010101','Email Ruim','isso nao e email','1990-01-01','PF');
-- [LACUNA?] CLIENTE: CPF com letras
INSERT INTO CLIENTE VALUES ('ABCDEFGHIJK','Doc Ruim','ruim@email.com','1990-01-01','PF');
-- [LACUNA?] CLIENTE: PF com mais de 120 anos
INSERT INTO CLIENTE VALUES ('20202020202','Muito Velho','velho@email.com','1850-01-01','PF');

-- ======================================================================
-- TABELA: ENDERECO  (7 inserts inválidos)
-- ======================================================================

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (2) ----
-- ENDERECO: CEP NULL
INSERT INTO ENDERECO VALUES (90,'12345678909','Rua A','Centro','São Paulo',NULL,'100',NULL,'Residencial');
-- ENDERECO: Rua NULL
INSERT INTO ENDERECO VALUES (90,'12345678909',NULL,'Centro','São Paulo','01001000','100',NULL,'Residencial');

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- ENDERECO: PK duplicada
INSERT INTO ENDERECO VALUES (1,'12345678909','Rua B','Centro','São Paulo','01001000','200',NULL,'Comercial');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- ENDERECO: cliente inexistente (FK)
INSERT INTO ENDERECO VALUES (90,'00000000000','Rua A','Centro','São Paulo','01001000','100',NULL,'Residencial');

-- ---- Erro: 5. Tamanho excedido (VARCHAR/CHAR/DECIMAL) (1) ----
-- ENDERECO: CEP com 9 caracteres (excede 8)
INSERT INTO ENDERECO VALUES (90,'12345678909','Rua A','Centro','São Paulo','01001-000','100',NULL,'Residencial');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (2) ----
-- [LACUNA?] ENDERECO: CEP com letras/curto
INSERT INTO ENDERECO VALUES (91,'12345678909','Rua A','Centro','São Paulo','abc','100',NULL,'Residencial');
-- [LACUNA?] ENDERECO: Tipo_endereco livre (sem lista permitida)
INSERT INTO ENDERECO VALUES (92,'12345678909','Rua A','Centro','São Paulo','01001000','100',NULL,'Qualquer Coisa');

-- ======================================================================
-- TABELA: TELEFONE  (6 inserts inválidos)
-- ======================================================================

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- TELEFONE: DDD NULL
INSERT INTO TELEFONE VALUES (NULL,'988880000','12345678909');

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- TELEFONE: PK duplicada (mesmo cliente/DDD/número)
INSERT INTO TELEFONE VALUES ('11','999990000','12345678909');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- TELEFONE: cliente inexistente (FK)
INSERT INTO TELEFONE VALUES ('11','988880000','00000000000');

-- ---- Erro: 5. Tamanho excedido (VARCHAR/CHAR/DECIMAL) (1) ----
-- TELEFONE: DDD com 3 dígitos
INSERT INTO TELEFONE VALUES ('011','988880000','12345678909');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (2) ----
-- [LACUNA?] TELEFONE: DDD com letras
INSERT INTO TELEFONE VALUES ('ab','988880001','12345678909');
-- [LACUNA?] TELEFONE: número com 1 dígito
INSERT INTO TELEFONE VALUES ('11','9','12345678909');

-- ======================================================================
-- TABELA: PEDIDO  (20 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (12) ----
-- PEDIDO: Status_Pedido inválido
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Perdido','Pix',1,100.00,NULL,NULL,NULL,100.00);
-- PEDIDO: forma de pagamento inválida (Boleto)
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Boleto',1,100.00,NULL,NULL,NULL,100.00);
-- PEDIDO: 0 parcelas
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Cartão de crédito',0,100.00,NULL,NULL,NULL,100.00);
-- PEDIDO: 13 parcelas
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Cartão de crédito',13,100.00,NULL,NULL,NULL,100.00);
-- PEDIDO: Pix parcelado em 3x
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Pix',3,100.00,NULL,NULL,NULL,100.00);
-- PEDIDO: desconto Pix em pedido de cartão
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Cartão de crédito',1,100.00,5,5.00,NULL,95.00);
-- PEDIDO: percentual Pix de 6% (só 5, 7 ou 10)
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,100.00,6,6.00,NULL,94.00);
-- PEDIDO: percentual Pix de 15%
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,100.00,15,15.00,NULL,85.00);
-- PEDIDO: Valor_Produtos negativo
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,-100.00,NULL,NULL,NULL,0.00);
-- PEDIDO: Valor_Desconto negativo
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,100.00,NULL,-5.00,NULL,100.00);
-- PEDIDO: Valor_Taxas negativo
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Cartão de crédito',1,100.00,NULL,NULL,-5.00,100.00);
-- PEDIDO: Valor_Final negativo
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,100.00,NULL,NULL,NULL,-100.00);

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- PEDIDO: cliente inexistente (FK)
INSERT INTO PEDIDO VALUES (90,'00000000000','2026-10-20 14:00:00','Aberto','Pix',1,100.00,NULL,NULL,NULL,100.00);

-- ---- Erro: 5. Tamanho excedido (VARCHAR/CHAR/DECIMAL) (1) ----
-- PEDIDO: valor acima de DECIMAL(10,2)
INSERT INTO PEDIDO VALUES (90,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,999999999.99,NULL,NULL,NULL,100.00);

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (6) ----
-- [LACUNA?] PEDIDO: Valor_Final diferente de produtos - desconto + taxas
INSERT INTO PEDIDO VALUES (91,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,1000.00,5,50.00,NULL,1.00);
-- [LACUNA?] PEDIDO: Pix com Valor_Desconto mas sem percentual
INSERT INTO PEDIDO VALUES (92,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,1000.00,NULL,200.00,NULL,800.00);
-- [LACUNA?] PEDIDO: percentual Pix sem Valor_Desconto
INSERT INTO PEDIDO VALUES (93,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,1000.00,10,NULL,NULL,1000.00);
-- [LACUNA?] PEDIDO: desconto maior que o valor dos produtos
INSERT INTO PEDIDO VALUES (94,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,100.00,10,500.00,NULL,0.00);
-- [LACUNA?] PEDIDO: data do pedido no futuro
INSERT INTO PEDIDO VALUES (95,'12345678909','2035-01-01 10:00:00','Aberto','Pix',1,100.00,NULL,NULL,NULL,100.00);
-- [LACUNA?] PEDIDO: taxas em pedido Pix (taxa é de cartão)
INSERT INTO PEDIDO VALUES (96,'12345678909','2026-10-20 14:00:00','Aberto','Pix',1,100.00,NULL,NULL,50.00,150.00);

-- ======================================================================
-- TABELA: IMAGEM_APARELHO  (3 inserts inválidos)
-- ======================================================================

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- IMAGEM: URL NULL
INSERT INTO IMAGEM_APARELHO VALUES (90,'351234567890123',NULL);

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- IMAGEM: IMEI inexistente (FK)
INSERT INTO IMAGEM_APARELHO VALUES (90,'000000000000000','https://img.cellgo.com/x.jpg');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (1) ----
-- [LACUNA?] IMAGEM: URL sem formato de link
INSERT INTO IMAGEM_APARELHO VALUES (91,'351234567890123','isso nao e url');

-- ======================================================================
-- TABELA: ITEM_PEDIDO  (12 inserts inválidos)
-- ======================================================================

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (2) ----
-- ITEM_PEDIDO: Data_Fim_Garantia_Loja NULL
INSERT INTO ITEM_PEDIDO VALUES ('353456789012345',4,3000.00,'2026-10-26',NULL,NULL);
-- ITEM_PEDIDO: Preco_Unitario NULL
INSERT INTO ITEM_PEDIDO VALUES ('353456789012345',4,NULL,'2026-10-26','2027-01-26',NULL);

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- ITEM_PEDIDO: PK duplicada (mesmo item no mesmo pedido)
INSERT INTO ITEM_PEDIDO VALUES ('351234567890123',1,4500.00,'2026-10-20','2027-01-20','2027-10-20');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- ITEM_PEDIDO: IMEI inexistente (FK)
INSERT INTO ITEM_PEDIDO VALUES ('000000000000000',4,100.00,'2026-10-26','2027-01-26',NULL);
-- ITEM_PEDIDO: pedido inexistente (FK)
INSERT INTO ITEM_PEDIDO VALUES ('353456789012345',99,100.00,'2026-10-26','2027-01-26',NULL);

-- ---- Erro: 6. TRIGGER (2) ----
-- ITEM_PEDIDO: Seminovo COM garantia de fabricante (trigger INSERT)
INSERT INTO ITEM_PEDIDO VALUES ('353456789012345',4,3000.00,'2026-10-26','2027-01-26','2027-10-26');
-- ITEM_PEDIDO: UPDATE colocando garantia de fabricante em Seminovo (trigger UPDATE)
UPDATE ITEM_PEDIDO SET Data_Fim_Garantia_Fabricante = '2027-10-21' WHERE Imei = '352345678901234' AND Id_Pedido = 2;

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (5) ----
-- [LACUNA?] ITEM_PEDIDO: fim da garantia da loja antes do início
INSERT INTO ITEM_PEDIDO VALUES ('353456789012345',5,3000.00,'2026-10-26','2020-01-01',NULL);
-- [LACUNA?] ITEM_PEDIDO: Preco_Unitario negativo
INSERT INTO ITEM_PEDIDO VALUES ('353456789012345',3,-10.00,'2026-10-25','2027-01-25',NULL);
-- [LACUNA?] ITEM_PEDIDO: mesmo aparelho (IMEI) vendido em DOIS pedidos
INSERT INTO ITEM_PEDIDO VALUES ('351234567890123',3,4500.00,'2026-10-25','2027-01-25','2027-10-25');
-- [LACUNA?] ITEM_PEDIDO: venda de aparelho com status Em quarentena
INSERT INTO ITEM_PEDIDO VALUES ('353456789012345',4,3000.00,'2026-10-26','2027-01-26',NULL);
-- [LACUNA?] ITEM_PEDIDO: garantia de fabricante anterior ao início da garantia
INSERT INTO ITEM_PEDIDO VALUES ('351234567890123',5,4500.00,'2026-10-26','2027-01-26','2020-01-01');

-- ======================================================================
-- TABELA: PAGAMENTO  (10 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (4) ----
-- PAGAMENTO: Aprovado sem Data_Confirmacao
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Comprovante) VALUES (90,3,'TX-X','2026-10-25 09:01:00',NULL,4500.00,'Aprovado',NULL);
-- PAGAMENTO: Status inválido
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Comprovante) VALUES (90,3,'TX-X','2026-10-25 09:01:00',NULL,4500.00,'Cancelado',NULL);
-- PAGAMENTO: confirmação anterior à tentativa
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Comprovante) VALUES (90,3,'TX-X','2026-10-25 09:01:00','2026-10-24 09:00:00',4500.00,'Pendente',NULL);
-- PAGAMENTO: valor negativo
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Comprovante) VALUES (90,3,'TX-X','2026-10-25 09:01:00',NULL,-1.00,'Pendente',NULL);

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- PAGAMENTO: 2º pagamento APROVADO para o mesmo pedido (UNIQUE gerado)
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Comprovante) VALUES (90,1,'TX-X','2026-10-20 15:00:00','2026-10-20 15:01:00',4275.00,'Aprovado',NULL);

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- PAGAMENTO: pedido inexistente (FK)
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Comprovante) VALUES (90,99,'TX-X','2026-10-25 09:01:00',NULL,100.00,'Pendente',NULL);

-- ---- Erro: 7. Coluna gerada (não aceita valor manual) (1) ----
-- PAGAMENTO: tentativa de gravar na coluna gerada Pedido_Aprovado
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Pedido_Aprovado) VALUES (90,3,'TX-X','2026-10-25 09:01:00',NULL,100.00,'Pendente',3);

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (3) ----
-- [LACUNA?] PAGAMENTO: valor diferente do Valor_Final do pedido
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Comprovante) VALUES (91,5,'TX-V','2026-10-26 09:31:00','2026-10-26 09:32:00',1.00,'Aprovado','c.pdf');
-- [LACUNA?] PAGAMENTO: Codigo_Transacao repetido em outro pagamento
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Comprovante) VALUES (92,4,'TX-0001','2026-10-26 09:31:00',NULL,930.00,'Pendente',NULL);
-- [LACUNA?] PAGAMENTO: Pendente já com Data_Confirmacao preenchida
INSERT INTO PAGAMENTO (Id_Pagamento,Id_Pedido,Codigo_Transacao,Data_Tentativa,Data_Confirmacao,Valor,Status,Comprovante) VALUES (93,4,'TX-P','2026-10-26 09:31:00','2026-10-26 09:35:00',930.00,'Pendente',NULL);

-- ======================================================================
-- TABELA: CANCELAMENTO  (5 inserts inválidos)
-- ======================================================================

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- CANCELAMENTO: Motivo NULL
INSERT INTO CANCELAMENTO VALUES (90,4,'2026-10-27 11:00:00',NULL,'Aprovado');

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- CANCELAMENTO: segundo cancelamento do mesmo pedido (UNIQUE)
INSERT INTO CANCELAMENTO VALUES (90,3,'2026-10-27 11:00:00','Outro motivo','Aprovado');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- CANCELAMENTO: pedido inexistente (FK)
INSERT INTO CANCELAMENTO VALUES (90,99,'2026-10-27 11:00:00','Motivo','Aprovado');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (2) ----
-- [LACUNA?] CANCELAMENTO: Status sem lista de valores permitidos
INSERT INTO CANCELAMENTO VALUES (91,4,'2026-10-27 11:00:00','Motivo','Qualquer Status');
-- [LACUNA?] CANCELAMENTO: de pedido já Finalizado (pedido 2)
INSERT INTO CANCELAMENTO VALUES (92,2,'2026-10-27 11:00:00','Motivo','Pendente');

-- ======================================================================
-- TABELA: POS_VENDA  (8 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (2) ----
-- POS_VENDA: tipo de solicitação inválido
INSERT INTO POS_VENDA VALUES (90,'351234567890123',1,'Elogio','2026-11-01 09:00:00','Teste','Aberto');
-- POS_VENDA: Status NULL
INSERT INTO POS_VENDA VALUES (90,'351234567890123',1,'Defeito','2026-11-01 09:00:00','Teste',NULL);

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- POS_VENDA: Descricao NULL
INSERT INTO POS_VENDA VALUES (90,'351234567890123',1,'Defeito','2026-11-01 09:00:00',NULL,'Aberto');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- POS_VENDA: IMEI que não pertence ao pedido informado (FK composta)
INSERT INTO POS_VENDA VALUES (90,'351234567890123',2,'Defeito','2026-11-01 09:00:00','Teste','Aberto');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (4) ----
-- [LACUNA?] POS_VENDA: Status sem lista de valores permitidos
INSERT INTO POS_VENDA VALUES (91,'351234567890123',1,'Defeito','2026-11-01 09:00:00','Teste','Qualquer Status');
-- [LACUNA?] POS_VENDA: Garantia solicitada depois do fim da garantia (ano 2035)
INSERT INTO POS_VENDA VALUES (92,'351234567890123',1,'Garantia','2035-01-01 09:00:00','Fora da garantia','Aberto');
-- [LACUNA?] POS_VENDA: Arrependimento após 7 dias da compra (CDC)
INSERT INTO POS_VENDA VALUES (93,'352345678901234',2,'Arrependimento','2026-12-31 09:00:00','Fora do prazo','Aberto');
-- [LACUNA?] POS_VENDA: abertura anterior à data do pedido
INSERT INTO POS_VENDA VALUES (94,'351234567890123',1,'Defeito','2020-01-01 09:00:00','Antes da compra','Aberto');

-- ======================================================================
-- TABELA: DEVOLUCAO  (5 inserts inválidos)
-- ======================================================================

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- DEVOLUCAO: Motivo NULL
INSERT INTO DEVOLUCAO VALUES (90,2,'2026-10-26 10:00:00',NULL,'Concluída');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- DEVOLUCAO: pós-venda inexistente (FK)
INSERT INTO DEVOLUCAO VALUES (90,99,'2026-10-26 10:00:00','Motivo','Concluída');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (3) ----
-- [LACUNA?] DEVOLUCAO: Status sem lista de valores permitidos
INSERT INTO DEVOLUCAO VALUES (91,2,'2026-10-26 10:00:00','Motivo','Qualquer Status');
-- [LACUNA?] DEVOLUCAO: segunda devolução para o mesmo pós-venda
INSERT INTO DEVOLUCAO VALUES (92,2,'2026-10-27 10:00:00','Duplicada','Concluída');
-- [LACUNA?] DEVOLUCAO: data anterior à abertura do pós-venda
INSERT INTO DEVOLUCAO VALUES (93,1,'2020-01-01 10:00:00','Antes da abertura','Pendente');

-- ======================================================================
-- TABELA: AVALIACAO_DANO  (10 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (3) ----
-- AVALIACAO_DANO: classificação inválida
INSERT INTO AVALIACAO_DANO VALUES (90,1,3,'Queda','Teste',1,'Em manutenção','2026-11-02');
-- AVALIACAO_DANO: destino inválido (Vendido)
INSERT INTO AVALIACAO_DANO VALUES (90,1,3,'Mau uso','Teste',0,'Vendido','2026-11-02');
-- AVALIACAO_DANO: Cobertura_Garantia = 2
INSERT INTO AVALIACAO_DANO VALUES (90,1,3,'Mau uso','Teste',2,'Inativo','2026-11-02');

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- AVALIACAO_DANO: Descricao_Dano NULL
INSERT INTO AVALIACAO_DANO VALUES (90,1,3,'Mau uso',NULL,0,'Inativo','2026-11-02');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- AVALIACAO_DANO: funcionário inexistente (FK)
INSERT INTO AVALIACAO_DANO VALUES (90,1,99,'Mau uso','Teste',0,'Inativo','2026-11-02');
-- AVALIACAO_DANO: pós-venda inexistente (FK)
INSERT INTO AVALIACAO_DANO VALUES (90,99,3,'Mau uso','Teste',0,'Inativo','2026-11-02');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (4) ----
-- [LACUNA?] AVALIACAO_DANO: Mau uso com cobertura de garantia
INSERT INTO AVALIACAO_DANO VALUES (91,1,3,'Mau uso','Cliente molhou o aparelho',1,'Em manutenção','2026-11-02');
-- [LACUNA?] AVALIACAO_DANO: defeito de fabricação SEM cobertura de garantia
INSERT INTO AVALIACAO_DANO VALUES (92,1,3,'Defeito de fabricação','Defeito de fábrica',0,'Em manutenção','2026-11-02');
-- [LACUNA?] AVALIACAO_DANO: avaliador de perfil sem Assistência Técnica (vendedora)
INSERT INTO AVALIACAO_DANO VALUES (93,1,1,'Outros','Avaliado por vendedor',0,'Disponível','2026-11-02');
-- [LACUNA?] AVALIACAO_DANO: usa funcionário INATIVO (4)
INSERT INTO AVALIACAO_DANO VALUES (94,1,4,'Outros','Func inativo',0,'Disponível','2026-11-02');

-- ======================================================================
-- TABELA: TROCA  (7 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (1) ----
-- TROCA: status inválido
INSERT INTO TROCA VALUES (90,1,'353456789012345','2026-11-03','Atrasada');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- TROCA: IMEI de reposição inexistente (FK)
INSERT INTO TROCA VALUES (90,1,'000000000000000','2026-11-03','Pendente');
-- TROCA: pós-venda inexistente (FK)
INSERT INTO TROCA VALUES (90,99,'353456789012345','2026-11-03','Pendente');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (4) ----
-- [LACUNA?] TROCA: reposição com o MESMO IMEI do aparelho original
INSERT INTO TROCA VALUES (91,1,'351234567890123','2026-11-03','Pendente');
-- [LACUNA?] TROCA: mesmo aparelho de reposição usado em duas trocas
INSERT INTO TROCA VALUES (92,2,'353456789012345','2026-11-03','Pendente');
-- [LACUNA?] TROCA: reposição com aparelho Vendido/Em quarentena (aparelho 3 está em quarentena)
INSERT INTO TROCA VALUES (93,1,'353456789012345','2026-11-04','Pendente');
-- [LACUNA?] TROCA: troca para pós-venda do tipo Arrependimento (pós-venda 2)
INSERT INTO TROCA VALUES (94,2,'352345678901234','2026-11-04','Pendente');

-- ======================================================================
-- TABELA: NOTA_FISCAL  (21 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (11) ----
-- NOTA_FISCAL: sem nenhuma origem (pedido/cancelamento/pós-venda todos NULL)
INSERT INTO NOTA_FISCAL VALUES (90,NULL,NULL,NULL,NULL,NULL,NULL,'Venda','Venda','Pendente',NULL);
-- NOTA_FISCAL: duas origens (pedido E pós-venda)
INSERT INTO NOTA_FISCAL VALUES (90,NULL,1,NULL,NULL,4,NULL,'Venda','Venda','Pendente',NULL);
-- NOTA_FISCAL: três origens
INSERT INTO NOTA_FISCAL VALUES (90,NULL,1,NULL,1,4,NULL,'Venda','Venda','Pendente',NULL);
-- NOTA_FISCAL: Numero_Nota = 0
INSERT INTO NOTA_FISCAL VALUES (90,0,NULL,NULL,NULL,4,NULL,'Venda','Venda','Pendente',NULL);
-- NOTA_FISCAL: Numero_Nota negativo
INSERT INTO NOTA_FISCAL VALUES (90,-5,NULL,NULL,NULL,4,NULL,'Venda','Venda','Pendente',NULL);
-- NOTA_FISCAL: referência para ela mesma
INSERT INTO NOTA_FISCAL VALUES (90,NULL,NULL,90,NULL,4,NULL,'Venda','Venda','Pendente',NULL);
-- NOTA_FISCAL: Emitida sem Chave_Acesso
INSERT INTO NOTA_FISCAL VALUES (90,2001,NULL,NULL,NULL,4,NULL,'Venda','Venda','Emitida','2026-10-26 10:00:00');
-- NOTA_FISCAL: Emitida sem Numero_Nota
INSERT INTO NOTA_FISCAL VALUES (90,NULL,NULL,NULL,NULL,4,'32345678901234567890123456789012345678901234','Venda','Venda','Emitida','2026-10-26 10:00:00');
-- NOTA_FISCAL: Emitida sem Data_Emissao
INSERT INTO NOTA_FISCAL VALUES (90,2001,NULL,NULL,NULL,4,'32345678901234567890123456789012345678901234','Venda','Venda','Emitida',NULL);
-- NOTA_FISCAL: Tipo_Nota inválido
INSERT INTO NOTA_FISCAL VALUES (90,NULL,NULL,NULL,NULL,4,NULL,'Serviço','Venda','Pendente',NULL);
-- NOTA_FISCAL: Status inválido
INSERT INTO NOTA_FISCAL VALUES (90,NULL,NULL,NULL,NULL,4,NULL,'Venda','Venda','Rascunho',NULL);

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- NOTA_FISCAL: Chave_Acesso duplicada (UNIQUE)
INSERT INTO NOTA_FISCAL VALUES (90,3001,NULL,NULL,NULL,4,'12345678901234567890123456789012345678901234','Venda','Venda','Emitida','2026-10-26 10:00:00');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- NOTA_FISCAL: pedido inexistente (FK)
INSERT INTO NOTA_FISCAL VALUES (90,NULL,NULL,NULL,NULL,99,NULL,'Venda','Venda','Pendente',NULL);
-- NOTA_FISCAL: nota de referência inexistente (FK)
INSERT INTO NOTA_FISCAL VALUES (90,NULL,2,99,NULL,NULL,NULL,'Entrada (Devolução)','Devolução','Pendente',NULL);

-- ---- Erro: 5. Tamanho excedido (VARCHAR/CHAR/DECIMAL) (1) ----
-- NOTA_FISCAL: Chave_Acesso com 45 caracteres
INSERT INTO NOTA_FISCAL VALUES (90,3001,NULL,NULL,NULL,4,'123456789012345678901234567890123456789012345','Venda','Venda','Emitida','2026-10-26 10:00:00');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (6) ----
-- [LACUNA?] NOTA_FISCAL: Chave_Acesso com poucos caracteres (ex.: 10)
INSERT INTO NOTA_FISCAL VALUES (91,4001,NULL,NULL,NULL,4,'1234567890','Venda','Venda','Emitida','2026-10-26 10:00:00');
-- [LACUNA?] NOTA_FISCAL: Pendente/Aguardando já com Chave_Acesso e data de emissão
INSERT INTO NOTA_FISCAL VALUES (92,NULL,NULL,NULL,NULL,5,'42345678901234567890123456789012345678901234','Venda','Venda','Aguardando emissão','2026-10-26 10:00:00');
-- [LACUNA?] NOTA_FISCAL: nota de Venda com Id_Nota_Referencia preenchido
INSERT INTO NOTA_FISCAL VALUES (93,NULL,NULL,1,NULL,5,NULL,'Venda','Venda','Pendente',NULL);
-- [LACUNA?] NOTA_FISCAL: Numero_Nota repetido em outra nota
INSERT INTO NOTA_FISCAL VALUES (94,1001,NULL,NULL,NULL,5,'52345678901234567890123456789012345678901234','Venda','Venda','Emitida','2026-10-26 10:00:00');
-- [LACUNA?] NOTA_FISCAL: duas notas de Venda para o mesmo pedido
INSERT INTO NOTA_FISCAL VALUES (95,5001,NULL,NULL,NULL,1,'62345678901234567890123456789012345678901234','Venda','Venda','Emitida','2026-10-26 10:00:00');
-- [LACUNA?] NOTA_FISCAL: Data_Emissao no futuro
INSERT INTO NOTA_FISCAL VALUES (96,6001,NULL,NULL,NULL,5,'72345678901234567890123456789012345678901234','Venda','Venda','Emitida','2035-01-01 10:00:00');

-- ======================================================================
-- TABELA: ESTORNO  (16 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (8) ----
-- ESTORNO: devolução E cancelamento ao mesmo tempo
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (90,3,1,1,100.00,'2026-10-26 12:00:00','Pendente');
-- ESTORNO: sem devolução e sem cancelamento
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (90,3,NULL,NULL,100.00,'2026-10-26 12:00:00','Pendente');
-- ESTORNO: valor 0
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (90,3,1,NULL,0.00,'2026-10-26 12:00:00','Pendente');
-- ESTORNO: valor negativo
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (90,3,1,NULL,-10.00,'2026-10-26 12:00:00','Pendente');
-- ESTORNO: status inválido
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (90,3,1,NULL,10.00,'2026-10-26 12:00:00','Cancelado');
-- ESTORNO: conclusão anterior à abertura
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Data_Conclusao,Status) VALUES (90,3,1,NULL,10.00,'2026-10-26 12:00:00','2026-10-01 12:00:00','Processado');
-- ESTORNO: Processado sem Data_Conclusao
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (90,3,1,NULL,10.00,'2026-10-26 12:00:00','Processado');
-- ESTORNO: Tipo_Conta inválido
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Tipo_Conta,Data_Abertura,Status) VALUES (90,3,1,NULL,10.00,'Salário','2026-10-26 12:00:00','Pendente');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- ESTORNO: pagamento inexistente (FK)
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (90,99,1,NULL,10.00,'2026-10-26 12:00:00','Pendente');
-- ESTORNO: devolução inexistente (FK)
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (90,3,99,NULL,10.00,'2026-10-26 12:00:00','Pendente');

-- ---- Erro: 7. Coluna gerada (não aceita valor manual) (1) ----
-- ESTORNO: gravar manualmente na coluna gerada Prazo_Limite
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Prazo_Limite,Status) VALUES (90,3,1,NULL,10.00,'2026-10-26 12:00:00','2030-01-01 00:00:00','Pendente');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (5) ----
-- [LACUNA?] ESTORNO: valor maior que o valor do pagamento (3 = 2310)
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (91,3,1,NULL,99999.00,'2026-10-26 12:00:00','Pendente');
-- [LACUNA?] ESTORNO: de pagamento NÃO aprovado (pagamento 2 = Recusado)
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (92,2,1,NULL,100.00,'2026-10-26 12:00:00','Pendente');
-- [LACUNA?] ESTORNO: pagamento de pedido diferente do da devolução/cancelamento
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (93,1,NULL,1,100.00,'2026-10-26 12:00:00','Pendente');
-- [LACUNA?] ESTORNO: dois estornos para a mesma devolução
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Data_Abertura,Status) VALUES (94,3,1,NULL,10.00,'2026-10-27 12:00:00','Pendente');
-- [LACUNA?] ESTORNO: dados bancários incompletos (banco sem conta)
INSERT INTO ESTORNO (Id_Estorno,Id_Pagamento,Codigo_Devolucao,Codigo_Cancelamento,Valor,Banco,Data_Abertura,Status) VALUES (95,4,NULL,1,10.00,'Banco X','2026-10-27 12:00:00','Pendente');

-- ======================================================================
-- TABELA: ENTREGA  (16 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (7) ----
-- ENTREGA: status inválido
INSERT INTO ENTREGA VALUES ('BR000000001',NULL,1,'Correios','Perdida',NULL,NULL,'Manual');
-- ENTREGA: origem da atualização inválida
INSERT INTO ENTREGA VALUES ('BR000000001',NULL,1,'Correios','Aguardando envio',NULL,NULL,'Robô');
-- ENTREGA: entrega anterior ao despacho
INSERT INTO ENTREGA VALUES ('BR000000001',NULL,1,'Correios','Entregue','2026-10-24 08:00:00','2026-10-21 08:00:00','Manual');
-- ENTREGA: Em transporte sem Data_Despacho
INSERT INTO ENTREGA VALUES ('BR000000001',NULL,1,'Correios','Em transporte',NULL,NULL,'Manual');
-- ENTREGA: Entregue sem Data_Despacho
INSERT INTO ENTREGA VALUES ('BR000000001',NULL,1,'Correios','Entregue',NULL,'2026-10-24 08:00:00','Manual');
-- ENTREGA: Entregue sem Data_Entrega
INSERT INTO ENTREGA VALUES ('BR000000001',NULL,1,'Correios','Entregue','2026-10-21 08:00:00',NULL,'Manual');
-- ENTREGA: Data_Entrega preenchida sem Data_Despacho
INSERT INTO ENTREGA VALUES ('BR000000001',NULL,1,'Correios','Aguardando envio',NULL,'2026-10-24 08:00:00','Manual');

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- ENTREGA: transportadora NULL
INSERT INTO ENTREGA VALUES ('BR000000001',NULL,1,NULL,'Aguardando envio',NULL,NULL,'Manual');

-- ---- Erro: 3. PK / UNIQUE duplicado (1) ----
-- ENTREGA: código de rastreio duplicado (PK)
INSERT INTO ENTREGA VALUES ('BR123456789',NULL,1,'Correios','Aguardando envio',NULL,NULL,'Manual');

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- ENTREGA: troca inexistente (FK)
INSERT INTO ENTREGA VALUES ('BR000000001',99,1,'Correios','Aguardando envio',NULL,NULL,'Manual');
-- ENTREGA: pedido inexistente (FK)
INSERT INTO ENTREGA VALUES ('BR000000001',NULL,99,'Correios','Aguardando envio',NULL,NULL,'Manual');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (5) ----
-- [LACUNA?] ENTREGA: Aguardando envio já com Data_Despacho
INSERT INTO ENTREGA VALUES ('BR000000099',NULL,1,'Correios','Aguardando envio','2026-10-21 08:00:00',NULL,'Manual');
-- [LACUNA?] ENTREGA: Em transporte já com Data_Entrega
INSERT INTO ENTREGA VALUES ('BR000000098',NULL,1,'Correios','Em transporte','2026-10-21 08:00:00','2026-10-22 08:00:00','Manual');
-- [LACUNA?] ENTREGA: despacho anterior à data do pedido
INSERT INTO ENTREGA VALUES ('BR000000097',NULL,1,'Correios','Em transporte','2020-01-01 08:00:00',NULL,'Manual');
-- [LACUNA?] ENTREGA: pedido Cancelado (pedido 3) recebendo entrega
INSERT INTO ENTREGA VALUES ('BR000000096',NULL,3,'Correios','Aguardando envio',NULL,NULL,'Manual');
-- [LACUNA?] ENTREGA: pedido ainda Aberto (pedido 4, não pago) com entrega despachada
INSERT INTO ENTREGA VALUES ('BR000000095',NULL,4,'Correios','Em transporte','2026-10-27 08:00:00',NULL,'Manual');

-- ======================================================================
-- TABELA: REQUISICAO_COMPRA  (12 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (2) ----
-- REQUISICAO: status inválido
INSERT INTO REQUISICAO_COMPRA VALUES (90,2,1,1,3,NULL,'2026-11-01',NULL,NULL,'Pendente',5);
-- REQUISICAO: Recusada sem motivo
INSERT INTO REQUISICAO_COMPRA VALUES (90,2,1,1,3,NULL,'2026-11-01','2026-11-02',NULL,'Recusada',5);

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (1) ----
-- REQUISICAO: Qtd_Sugerida NULL
INSERT INTO REQUISICAO_COMPRA VALUES (90,2,1,1,3,NULL,'2026-11-01',NULL,NULL,'Aprovada',NULL);

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- REQUISICAO: especificação inexistente (FK)
INSERT INTO REQUISICAO_COMPRA VALUES (90,2,99,1,3,NULL,'2026-11-01',NULL,NULL,'Aprovada',5);
-- REQUISICAO: funcionário inexistente (FK)
INSERT INTO REQUISICAO_COMPRA VALUES (90,99,1,1,3,NULL,'2026-11-01',NULL,NULL,'Aprovada',5);

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (7) ----
-- [LACUNA?] REQUISICAO: Qtd_Atual_Estoque negativa
INSERT INTO REQUISICAO_COMPRA VALUES (91,2,1,-5,3,NULL,'2026-11-01',NULL,NULL,'Aguardando Análise Financeira',5);
-- [LACUNA?] REQUISICAO: Qtd_Sugerida zero ou negativa
INSERT INTO REQUISICAO_COMPRA VALUES (92,2,1,1,3,NULL,'2026-11-01',NULL,NULL,'Aguardando Análise Financeira',-3);
-- [LACUNA?] REQUISICAO: Data_Decisao anterior à Data_Abertura
INSERT INTO REQUISICAO_COMPRA VALUES (93,2,1,1,3,NULL,'2026-11-01','2026-01-01',NULL,'Aprovada',5);
-- [LACUNA?] REQUISICAO: Aprovada sem Data_Decisao e sem parecer
INSERT INTO REQUISICAO_COMPRA VALUES (94,2,1,1,3,NULL,'2026-11-01',NULL,NULL,'Aprovada',5);
-- [LACUNA?] REQUISICAO: Estoque_Minimo divergente da especificação (spec 1 = 3)
INSERT INTO REQUISICAO_COMPRA VALUES (95,2,1,1,99,NULL,'2026-11-01',NULL,NULL,'Aguardando Análise Financeira',5);
-- [LACUNA?] REQUISICAO: estoque atual acima do mínimo (não precisaria comprar)
INSERT INTO REQUISICAO_COMPRA VALUES (96,2,1,50,3,NULL,'2026-11-01',NULL,NULL,'Aguardando Análise Financeira',5);
-- [LACUNA?] REQUISICAO: Recusada com Data_Decisao NULL
INSERT INTO REQUISICAO_COMPRA VALUES (97,2,1,1,3,NULL,'2026-11-01',NULL,'Sem verba','Recusada',5);

-- ======================================================================
-- TABELA: MOVIMENTACAO  (10 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (2) ----
-- MOVIMENTACAO: tipo de movimento inválido
INSERT INTO MOVIMENTACAO VALUES (90,2,'351234567890123','Roubo','Disponível','Inativo','2026-10-20 14:10:00');
-- MOVIMENTACAO: Status_Novo inválido
INSERT INTO MOVIMENTACAO VALUES (90,2,'351234567890123','Venda','Disponível','Perdido','2026-10-20 14:10:00');

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (2) ----
-- MOVIMENTACAO: Status_Novo NULL
INSERT INTO MOVIMENTACAO VALUES (90,2,'351234567890123','Venda','Disponível',NULL,'2026-10-20 14:10:00');
-- MOVIMENTACAO: Data_Hora NULL
INSERT INTO MOVIMENTACAO VALUES (90,2,'351234567890123','Venda','Disponível','Vendido',NULL);

-- ---- Erro: 4. FK (chave estrangeira inexistente) (1) ----
-- MOVIMENTACAO: IMEI inexistente (FK)
INSERT INTO MOVIMENTACAO VALUES (90,2,'000000000000000','Venda','Disponível','Vendido','2026-10-20 14:10:00');

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (5) ----
-- [LACUNA?] MOVIMENTACAO: Status_Anterior igual ao Status_Novo
INSERT INTO MOVIMENTACAO VALUES (91,2,'351234567890123','Manutenção','Disponível','Disponível','2026-10-21 10:00:00');
-- [LACUNA?] MOVIMENTACAO: Venda que termina em Disponível
INSERT INTO MOVIMENTACAO VALUES (92,2,'351234567890123','Venda','Disponível','Disponível','2026-10-21 10:00:00');
-- [LACUNA?] MOVIMENTACAO: Status_Anterior NULL fora de Entrada
INSERT INTO MOVIMENTACAO VALUES (93,2,'351234567890123','Venda',NULL,'Vendido','2026-10-21 10:00:00');
-- [LACUNA?] MOVIMENTACAO: Status_Anterior diferente do status atual do aparelho
INSERT INTO MOVIMENTACAO VALUES (94,2,'351234567890123','Manutenção','Em avaliação','Em manutenção','2026-10-21 10:00:00');
-- [LACUNA?] MOVIMENTACAO: data no futuro
INSERT INTO MOVIMENTACAO VALUES (95,2,'351234567890123','Manutenção','Disponível','Em manutenção','2035-01-01 10:00:00');

-- ======================================================================
-- TABELA: AUDITORIA  (9 inserts inválidos)
-- ======================================================================

-- ---- Erro: 1. CHECK / ENUM / valor inválido (1) ----
-- AUDITORIA: JSON inválido em Valor_Anterior
INSERT INTO AUDITORIA VALUES (90,1,5,'UPDATE','APARELHO','351234567890123','{abc',NULL,'2026-10-15 10:00:00',NULL);

-- ---- Erro: 2. NOT NULL (campo obrigatório vazio) (2) ----
-- AUDITORIA: Acao NULL
INSERT INTO AUDITORIA VALUES (90,1,5,NULL,'APARELHO','351234567890123',NULL,NULL,'2026-10-15 10:00:00',NULL);
-- AUDITORIA: Tabela_Afetada NULL
INSERT INTO AUDITORIA VALUES (90,1,5,'UPDATE',NULL,'351234567890123',NULL,NULL,'2026-10-15 10:00:00',NULL);

-- ---- Erro: 4. FK (chave estrangeira inexistente) (2) ----
-- AUDITORIA: autorizador inexistente (FK)
INSERT INTO AUDITORIA VALUES (90,1,99,'UPDATE','APARELHO','351234567890123',NULL,NULL,'2026-10-15 10:00:00',NULL);
-- AUDITORIA: funcionário inexistente (FK)
INSERT INTO AUDITORIA VALUES (90,99,5,'UPDATE','APARELHO','351234567890123',NULL,NULL,'2026-10-15 10:00:00',NULL);

-- ---- Erro: 8. [LACUNA?] Regra de negócio possivelmente SEM proteção (4) ----
-- [LACUNA?] AUDITORIA: funcionário autorizando a própria ação
INSERT INTO AUDITORIA VALUES (91,1,1,'UPDATE','APARELHO','351234567890123',NULL,NULL,'2026-10-15 10:00:00',NULL);
-- [LACUNA?] AUDITORIA: autorizador sem perfil Diretoria (vendedora)
INSERT INTO AUDITORIA VALUES (92,2,1,'UPDATE','APARELHO','351234567890123',NULL,NULL,'2026-10-15 10:00:00',NULL);
-- [LACUNA?] AUDITORIA: Tabela_Afetada com nome de tabela que não existe
INSERT INTO AUDITORIA VALUES (93,1,5,'UPDATE','TABELA_FANTASMA','1',NULL,NULL,'2026-10-15 10:00:00',NULL);
-- [LACUNA?] AUDITORIA: Acao fora de lista (INSERT/UPDATE/DELETE)
INSERT INTO AUDITORIA VALUES (94,1,5,'XYZ','APARELHO','351234567890123',NULL,NULL,'2026-10-15 10:00:00',NULL);