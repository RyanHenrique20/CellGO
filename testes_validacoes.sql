/* =====================================================================
   CellGO — Testes das validações (dados preenchidos incorretamente)
   SGBD: MySQL 8

   Objetivo: provar que o banco recusa dados preenchidos de forma
   errada: formato inválido, valor fora da faixa, campo obrigatório
   vazio, chave que não existe, valor duplicado e tipo inválido.

   Como executar:
   1. Rode tabelas.sql e trigger.sql (banco cellgo criado);
   2. Rode este arquivo inteiro. No fim aparece o relatório.
      O ideal é usar um banco de teste: os dados de apoio (todos com
      "Teste" no nome e códigos 8xx) ficam gravados.
   Este arquivo é independente do testes_triggers.sql: os dois podem
   ser rodados no mesmo banco, em qualquer ordem.

   Cada teste informa QUAL validação deve barrar o dado:
     CHECK    → restrição CHECK da tabela (formato, faixa, regras);
     NOT NULL → campo obrigatório deixado vazio;
     FK       → chave estrangeira apontando para registro inexistente;
     UNIQUE   → chave primária ou campo único repetido;
     TIPO     → valor fora do ENUM, data inválida, texto longo demais
                ou JSON inválido;
     TRIGGER  → regra validada por trigger (quando é ela que barra);
     ACEITAR  → dado correto, que deve passar (controle).
   O relatório mostra OK quando o dado foi barrado pela validação
   esperada, ATENÇÃO quando foi barrado por outra regra e FALHOU quando
   o banco aceitou um dado errado (ou recusou um dado correto).
   Cada tentativa é desfeita (ROLLBACK), então um teste não afeta o outro.

   Os comandos testados ficam entre aspas duplas para poder usar aspas
   simples dentro deles (padrão do MySQL, sem o modo ANSI_QUOTES).
   ===================================================================== */

SET NAMES utf8mb4;
USE cellgo;


/* =====================================================================
   PROCEDIMENTO DE TESTE E TABELA DE RESULTADOS
   (o mesmo do testes_triggers.sql)
   ===================================================================== */

DROP PROCEDURE IF EXISTS cellgo_testar;

DELIMITER $$
CREATE PROCEDURE cellgo_testar(IN p_grupo    VARCHAR(40),
                               IN p_teste    VARCHAR(200),
                               IN p_esperado VARCHAR(10),
                               IN p_comando  TEXT)
BEGIN
    DECLARE v_codigo   INT DEFAULT 0;
    DECLARE v_mensagem VARCHAR(512) DEFAULT NULL;
    DECLARE v_cod_tmp  INT;
    DECLARE v_msg_tmp  VARCHAR(512);
    DECLARE v_regra    VARCHAR(15);

    /* captura o primeiro erro do comando sem interromper o script
       (SQLWARNING entra porque, no modo estrito, valor fora do ENUM ou
       texto longo demais é erro, mas usa um SQLSTATE da classe 01) */
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLWARNING
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_cod_tmp = MYSQL_ERRNO, v_msg_tmp = MESSAGE_TEXT;
        IF v_mensagem IS NULL THEN
            SET v_codigo = v_cod_tmp, v_mensagem = v_msg_tmp;
        END IF;
    END;

    SET @cellgo_comando = p_comando;
    START TRANSACTION;
    PREPARE cmd FROM @cellgo_comando;
    EXECUTE cmd;
    DEALLOCATE PREPARE cmd;
    ROLLBACK;              /* desfaz a tentativa, mesmo quando ela passa */

    /* qual regra barrou, pelo código de erro do MySQL */
    SET v_regra = CASE
        WHEN v_mensagem IS NULL                    THEN NULL
        WHEN v_codigo = 1644                       THEN 'TRIGGER'
        WHEN v_codigo = 3819                       THEN 'CHECK'
        WHEN v_codigo IN (1048, 1364)              THEN 'NOT NULL'
        WHEN v_codigo IN (1451, 1452)              THEN 'FK'
        WHEN v_codigo = 1062                       THEN 'UNIQUE'
        WHEN v_codigo IN (1264, 1265, 1292, 1366, 1406, 3140) THEN 'TIPO'
        ELSE 'ERRO NO TESTE'
    END;

    INSERT INTO resultado_teste (Grupo, Teste, Esperado, Barrado_Por, Resultado, Mensagem)
    VALUES (p_grupo, p_teste, p_esperado, COALESCE(v_regra, '(aceito)'),
            CASE
                WHEN v_regra = 'ERRO NO TESTE'                 THEN 'ERRO NO TESTE'
                WHEN p_esperado = 'ACEITAR' AND v_regra IS NULL THEN 'OK'
                WHEN p_esperado = 'ACEITAR'                     THEN 'FALHOU'
                WHEN v_regra IS NULL                            THEN 'FALHOU'
                WHEN v_regra = p_esperado                       THEN 'OK'
                ELSE 'ATENÇÃO'
            END,
            COALESCE(v_mensagem, IF(p_esperado = 'ACEITAR',
                                    'Dado correto aceito.',
                                    'O banco ACEITOU um dado que deveria ser barrado.')));
END$$
DELIMITER ;

DROP TEMPORARY TABLE IF EXISTS resultado_teste;
CREATE TEMPORARY TABLE resultado_teste (
    Ordem       INT AUTO_INCREMENT PRIMARY KEY,
    Grupo       VARCHAR(40),
    Teste       VARCHAR(200),
    Esperado    VARCHAR(10),
    Barrado_Por VARCHAR(15),
    Resultado   VARCHAR(15),
    Mensagem    VARCHAR(512)
);


/* =====================================================================
   PARTE 1 — DADOS VÁLIDOS DE APOIO
   ===================================================================== */

SET @cellgo_funcionario = 801;

INSERT IGNORE INTO PERFIL_ACESSO (Nome_Perfil, Nivel_Acesso) VALUES
    ('Vendas e Atendimento', 1), ('Estoque e Logística', 1), ('Assistência Técnica', 1),
    ('Financeiro/Administrativo', 1), ('Diretoria', 2);

INSERT INTO FUNCIONARIO (Codigo_Funcionario, Nome, Cargo, Login, Id_Perfil, Ativo) VALUES
    (801, 'Teste Val Diretor',    'Diretor',    'teste.val.diretor',  (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Diretoria'), 1),
    (802, 'Teste Val Estoquista', 'Estoquista', 'teste.val.estoque',  (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Estoque e Logística'), 1),
    (803, 'Teste Val Técnico',    'Técnico',    'teste.val.tecnico',  (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Assistência Técnica'), 1),
    (804, 'Teste Val Vendedor',   'Vendedor',   'teste.val.vendedor', (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Vendas e Atendimento'), 1);

INSERT INTO FORNECEDOR (Cpf_Cnpj_Fornecedor, Tipo_Pessoa, Nome, Tipo_Documento, Numero_Documento, Telefone_Contato) VALUES
    ('80000000001',    'PF', 'Fornecedor Val PF',      'CNH', '80000000001', '11980000001'),
    ('80000000000001', 'PJ', 'Fornecedor Val PJ Ltda', NULL,  NULL,          '1120000001');

INSERT INTO MODELO (Id_Modelo, Nome_Modelo, Marca) VALUES
    (801, 'Teste Validação A', 'Marca Val'),
    (802, 'Teste Validação B', 'Marca Val');

INSERT INTO ESPECIFICACAO_APARELHO (Id_Especificacao, Id_Modelo, Cor, Capacidade, Estoque_Minimo) VALUES
    (801, 801, 'Preto', 128, 0),
    (802, 802, 'Azul',  256, 0),
    (803, 801, 'Verde',  64, 0);

/* Aquisição 801 fica Em avaliação para os testes de avaliação de entrada */
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao,
                       Tipo_Documento_Compra, Numero_Documento_Compra)
VALUES (801, 802, '80000000000001', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Nota fiscal do fornecedor', 'NF-VAL-801');

INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado,
                               Base_Consultada, Resultado_Consulta_Imei, Data_Consulta,
                               Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado) VALUES
    (801, 803, 801, '800000000000001', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 5 DAY), 0, 1, 'Aprovado'),
    (802, 803, 801, '800000000000002', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 5 DAY), 0, 1, 'Aprovado'),
    (803, 803, 801, '800000000000003', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 5 DAY), 0, 1, 'Aprovado'),
    (804, 803, 801, '800000000000004', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 5 DAY), 0, 1, 'Aprovado');

/* A avaliação 803 fica sem aparelho, para os testes da tabela APARELHO */
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao,
                      Preco_Venda, Custo_Aquisicao, Status, Data_Entrada, Elegivel_Desconto_Pix) VALUES
    ('800000000000001', 801, 801, 802, 'Novo', 1000.00, 700.00, 'Disponível', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 1),
    ('800000000000002', 801, 802, 802, 'Novo', 1200.00, 800.00, 'Disponível', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 0),
    ('800000000000004', 801, 804, 802, 'Novo',  900.00, 600.00, 'Disponível', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 0);

INSERT INTO IMAGEM_APARELHO (Imei, URL) VALUES ('800000000000001', 'https://cellgo.test/img/800000000000001.jpg');

INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES
    ('80000000091',    'Cliente Val PF',      'val.pf@cellgo.test', '1985-01-01', 'PF'),
    ('80000000000091', 'Cliente Val PJ Ltda', 'val.pj@cellgo.test', NULL,         'PJ');

INSERT INTO ENDERECO (Id_Endereco, Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES
    (801, '80000000091',    'Rua Validação', 'Tatuapé', 'São Paulo', '03001000', '50', 'Residencial'),
    (802, '80000000000091', 'Rua Empresa',   'Centro',  'São Paulo', '01001000', '10', 'Comercial');

INSERT INTO TELEFONE (Cpf_Cnpj, DDD, Numero_Telefone) VALUES
    ('80000000091',    11, 980000091),
    ('80000000000091', 11, 20000091);

/* Pedido 801: Pix, pago (com nota de venda aguardando emissão) */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (801, '80000000091', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('800000000000001', 801);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 801;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 801);
INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status)
VALUES (801, 801, 'TX-VAL-801', NOW(), NOW(), @valor, 'Aprovado');
INSERT INTO NOTA_FISCAL (Id_Nota, Id_Pedido, Tipo_Nota, Natureza) VALUES (801, 801, 'Venda', 'Venda de mercadoria');

/* Pedido 802: cartão, aguardando pagamento */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (802, '80000000091', 'Cartão de crédito', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('800000000000004', 802);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 802;

/* Pedido 803: Pix, pago e cancelado (origem dos testes de estorno) */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (803, '80000000000091', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('800000000000002', 803);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 803;
INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status)
VALUES (803, 803, 'TX-VAL-803', NOW(), NOW(), 1200.00, 'Aprovado');
INSERT INTO CANCELAMENTO (Codigo_Cancelamento, Id_Pedido, Motivo, Status) VALUES (801, 803, 'Teste: desistência', 'Concluído');

/* Pós-venda 801: defeito no aparelho do pedido 801, avaliado com garantia */
INSERT INTO POS_VENDA (Id_PosVenda, Imei, Id_Pedido, Tipo_Solicitacao, Descricao)
VALUES (801, '800000000000001', 801, 'Defeito', 'Teste: não carrega');
INSERT INTO AVALIACAO_DANO (Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano,
                            Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
VALUES (801, 803, 'Defeito de fabricação', 'Conector de carga com defeito', 1, 'Em manutenção', CURDATE());

/* Requisições: 801 em análise financeira; 802 aguardando a Diretoria */
INSERT INTO REQUISICAO_COMPRA (Id_Requisicao, Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida)
VALUES (801, 801, 0, 2, CURDATE(), 4),
       (802, 802, 0, 2, CURDATE(), 4);
UPDATE REQUISICAO_COMPRA
   SET Status = 'Aguardando Aprovação da Diretoria', Parecer_Financeiro = 'Teste: aprovado pelo financeiro'
 WHERE Id_Requisicao = 802;


/* =====================================================================
   PARTE 2 — DADOS PREENCHIDOS DE FORMA INCORRETA
   ===================================================================== */

/* ---------- PERFIL_ACESSO ---------- */
CALL cellgo_testar('PERFIL_ACESSO', 'Nome de perfil fora da lista permitida', 'CHECK',
    "INSERT INTO PERFIL_ACESSO (Nome_Perfil, Nivel_Acesso) VALUES ('Estagiário', 1)");
CALL cellgo_testar('PERFIL_ACESSO', 'Perfil operacional com nível estratégico (2)', 'CHECK',
    "UPDATE PERFIL_ACESSO SET Nivel_Acesso = 2 WHERE Nome_Perfil = 'Vendas e Atendimento'");
CALL cellgo_testar('PERFIL_ACESSO', 'Nível de acesso vazio', 'NOT NULL',
    "UPDATE PERFIL_ACESSO SET Nivel_Acesso = NULL WHERE Nome_Perfil = 'Diretoria'");
CALL cellgo_testar('PERFIL_ACESSO', 'Nome de perfil repetido', 'UNIQUE',
    "INSERT INTO PERFIL_ACESSO (Nome_Perfil, Nivel_Acesso) VALUES ('Diretoria', 2)");

/* ---------- FUNCIONARIO ---------- */
CALL cellgo_testar('FUNCIONARIO', 'Login com espaço', 'CHECK',
    "INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('Fulano', 'Vendedor', 'fulano silva', (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Diretoria'))");
CALL cellgo_testar('FUNCIONARIO', 'Login com menos de 3 caracteres', 'CHECK',
    "INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('Fulano', 'Vendedor', 'fs', (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Diretoria'))");
CALL cellgo_testar('FUNCIONARIO', 'Login repetido', 'UNIQUE',
    "INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('Fulano', 'Vendedor', 'teste.val.vendedor', (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Diretoria'))");
CALL cellgo_testar('FUNCIONARIO', 'Nome só com espaços', 'CHECK',
    "INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('   ', 'Vendedor', 'teste.val.x1', (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Diretoria'))");
CALL cellgo_testar('FUNCIONARIO', 'Cargo vazio', 'NOT NULL',
    "INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('Fulano', NULL, 'teste.val.x2', (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Diretoria'))");
CALL cellgo_testar('FUNCIONARIO', 'Perfil de acesso que não existe', 'FK',
    "INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('Fulano', 'Vendedor', 'teste.val.x3', 99999)");
CALL cellgo_testar('FUNCIONARIO', 'Campo Ativo com valor diferente de 0 ou 1', 'CHECK',
    "INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil, Ativo) VALUES ('Fulano', 'Vendedor', 'teste.val.x4', (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Diretoria'), 2)");
CALL cellgo_testar('FUNCIONARIO', 'Funcionário preenchido corretamente (deve passar)', 'ACEITAR',
    "INSERT INTO FUNCIONARIO (Nome, Cargo, Login, Id_Perfil) VALUES ('Fulano de Tal', 'Vendedor', 'teste.val.ok', (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Vendas e Atendimento'))");

/* ---------- FORNECEDOR ---------- */
CALL cellgo_testar('FORNECEDOR', 'CPF com 10 dígitos', 'CHECK',
    "INSERT INTO FORNECEDOR VALUES ('8000000002', 'PF', 'Fulano', 'RG', '123', '11980000002')");
CALL cellgo_testar('FORNECEDOR', 'CPF com pontuação (só números são aceitos)', 'CHECK',
    "INSERT INTO FORNECEDOR VALUES ('800.000.000-03', 'PF', 'Fulano', 'RG', '123', '11980000003')");
CALL cellgo_testar('FORNECEDOR', 'Pessoa jurídica com CNPJ de 11 dígitos', 'CHECK',
    "INSERT INTO FORNECEDOR VALUES ('80000000004', 'PJ', 'Empresa X', NULL, NULL, '1120000004')");
CALL cellgo_testar('FORNECEDOR', 'Pessoa física sem documento com foto', 'CHECK',
    "INSERT INTO FORNECEDOR VALUES ('80000000005', 'PF', 'Fulano', NULL, NULL, '11980000005')");
CALL cellgo_testar('FORNECEDOR', 'Documento com foto de tipo inválido (CPF)', 'CHECK',
    "INSERT INTO FORNECEDOR VALUES ('80000000006', 'PF', 'Fulano', 'CPF', '123', '11980000006')");
CALL cellgo_testar('FORNECEDOR', 'Telefone sem DDD (8 dígitos)', 'CHECK',
    "INSERT INTO FORNECEDOR VALUES ('80000000007', 'PF', 'Fulano', 'RG', '123', '98000007')");
CALL cellgo_testar('FORNECEDOR', 'Tipo de pessoa inválido', 'TIPO',
    "INSERT INTO FORNECEDOR VALUES ('80000000008', 'PX', 'Fulano', 'RG', '123', '11980000008')");
CALL cellgo_testar('FORNECEDOR', 'CPF de fornecedor repetido', 'UNIQUE',
    "INSERT INTO FORNECEDOR VALUES ('80000000001', 'PF', 'Outro', 'RG', '999', '11980000009')");
CALL cellgo_testar('FORNECEDOR', 'Fornecedor pessoa jurídica correto (deve passar)', 'ACEITAR',
    "INSERT INTO FORNECEDOR VALUES ('80000000000010', 'PJ', 'Distribuidora Val Ltda', NULL, NULL, '1120000010')");

/* ---------- MODELO e ESPECIFICACAO_APARELHO ---------- */
CALL cellgo_testar('MODELO', 'Nome de modelo repetido', 'UNIQUE',
    "INSERT INTO MODELO (Nome_Modelo, Marca) VALUES ('Teste Validação A', 'Outra')");
CALL cellgo_testar('MODELO', 'Marca em branco', 'CHECK',
    "INSERT INTO MODELO (Nome_Modelo, Marca) VALUES ('Teste Validação C', '')");
CALL cellgo_testar('MODELO', 'Nome do modelo vazio', 'NOT NULL',
    "INSERT INTO MODELO (Nome_Modelo, Marca) VALUES (NULL, 'Marca Val')");
CALL cellgo_testar('ESPECIFICACAO', 'Capacidade igual a zero', 'CHECK',
    "INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade) VALUES (801, 'Rosa', 0)");
CALL cellgo_testar('ESPECIFICACAO', 'Estoque mínimo negativo', 'CHECK',
    "INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade, Estoque_Minimo) VALUES (801, 'Rosa', 128, -1)");
CALL cellgo_testar('ESPECIFICACAO', 'Limite crítico menor que o limite de atenção', 'CHECK',
    "INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade, Limite_Dias_Atencao, Limite_Dias_Critico) VALUES (801, 'Rosa', 128, 60, 30)");
CALL cellgo_testar('ESPECIFICACAO', 'Cor em branco', 'CHECK',
    "INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade) VALUES (801, '  ', 128)");
CALL cellgo_testar('ESPECIFICACAO', 'Mesmo modelo, cor e capacidade já cadastrados', 'UNIQUE',
    "INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade) VALUES (801, 'Preto', 128)");
CALL cellgo_testar('ESPECIFICACAO', 'Modelo que não existe', 'FK',
    "INSERT INTO ESPECIFICACAO_APARELHO (Id_Modelo, Cor, Capacidade) VALUES (99999, 'Rosa', 128)");

/* ---------- AQUISICAO ---------- */
CALL cellgo_testar('AQUISICAO', 'Número do documento de compra em branco', 'CHECK',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra)
     VALUES (802, '80000000000001', CURDATE(), 'Nota fiscal do fornecedor', ' ')");
CALL cellgo_testar('AQUISICAO', 'Data da aquisição vazia', 'NOT NULL',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra)
     VALUES (802, '80000000000001', NULL, 'Nota fiscal do fornecedor', 'NF-1')");
CALL cellgo_testar('AQUISICAO', 'Data da aquisição inválida (31/02)', 'TIPO',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra)
     VALUES (802, '80000000000001', '2026-02-31', 'Nota fiscal do fornecedor', 'NF-2')");
CALL cellgo_testar('AQUISICAO', 'Fornecedor que não existe', 'FK',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra)
     VALUES (802, '99999999999999', CURDATE(), 'Nota fiscal do fornecedor', 'NF-3')");
CALL cellgo_testar('AQUISICAO', 'Tipo de documento de compra fora da lista', 'TRIGGER',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra)
     VALUES (802, '80000000000001', CURDATE(), 'Recibo', 'R-1')");

/* ---------- AVALIACAO_ENTRADA ---------- */
CALL cellgo_testar('AVALIACAO_ENTRADA', 'IMEI com 14 dígitos', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '80000000000005', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'IMEI com letras', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '80000000000ABCD', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Resultado da consulta do IMEI fora da lista', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Desconhecido', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Resultado da avaliação fora da lista', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Talvez')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Aparelho recusado sem motivo da recusa', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Resultado)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Bloqueado', NOW(), 'Recusado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Aprovado com IMEI roubado/furtado', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Roubado/Furtado', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Aprovado com a tela reprovada no checklist', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Tela, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Regular', NOW(), 0, 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Aprovado com bloqueio de conta', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Regular', NOW(), 1, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Aprovado sem o reset de fábrica', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Regular', NOW(), 0, 0, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Recusado com reset de fábrica preenchido', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Reset_Fabrica_Realizado, Resultado, Motivo_Recusa)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Bloqueado', NOW(), 1, 'Recusado', 'IMEI bloqueado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Item do checklist com valor diferente de 0 ou 1', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Som, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Regular', NOW(), 5, 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Base consultada em branco', 'CHECK',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '800000000000005', '', 'Regular', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Reconsulta com data, mas sem resultado', 'CHECK',
    "UPDATE AVALIACAO_ENTRADA SET Data_Reconsulta_Imei = NOW() WHERE Id_Avaliacao_Entrada = 801");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Reconsulta anterior à primeira consulta', 'CHECK',
    "UPDATE AVALIACAO_ENTRADA SET Data_Reconsulta_Imei = DATE_SUB(NOW(), INTERVAL 30 DAY), Resultado_Reconsulta_Imei = 'Regular'
     WHERE Id_Avaliacao_Entrada = 801");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Avaliação aprovada preenchida corretamente (deve passar)', 'ACEITAR',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (803, 801, '800000000000005', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado')");

/* ---------- APARELHO (usa a avaliação aprovada 803, ainda sem aparelho) ---------- */
CALL cellgo_testar('APARELHO', 'Preço de venda igual a zero', 'CHECK',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('800000000000003', 801, 803, 802, 'Novo', 0.00, 500.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'Custo de aquisição negativo', 'CHECK',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('800000000000003', 801, 803, 802, 'Novo', 1000.00, -10.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'Condição fora da lista (Usado)', 'TIPO',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('800000000000003', 801, 803, 802, 'Usado', 1000.00, 500.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'Status fora da lista', 'TIPO',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('800000000000003', 801, 803, 802, 'Novo', 1000.00, 500.00, 'Reservado', CURDATE())");
CALL cellgo_testar('APARELHO', 'Especificação que não existe', 'FK',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('800000000000003', 99999, 803, 802, 'Novo', 1000.00, 500.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'Elegibilidade ao Pix com valor diferente de 0 ou 1', 'CHECK',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada, Elegivel_Desconto_Pix)
     VALUES ('800000000000003', 801, 803, 802, 'Novo', 1000.00, 500.00, 'Disponível', CURDATE(), 3)");
CALL cellgo_testar('APARELHO', 'Data de entrada vazia', 'NOT NULL',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('800000000000003', 801, 803, 802, 'Novo', 1000.00, 500.00, 'Disponível', NULL)");
CALL cellgo_testar('APARELHO', 'Mesmo IMEI cadastrado duas vezes', 'UNIQUE',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('800000000000001', 801, 801, 802, 'Novo', 1000.00, 500.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'Preço com mais dígitos do que o campo comporta', 'TIPO',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('800000000000003', 801, 803, 802, 'Novo', 123456789012.00, 500.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'Aparelho preenchido corretamente (deve passar)', 'ACEITAR',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('800000000000003', 801, 803, 802, 'Novo', 1000.00, 500.00, 'Disponível', CURDATE())");

/* ---------- IMAGEM_APARELHO ---------- */
CALL cellgo_testar('IMAGEM_APARELHO', 'URL sem http:// ou https://', 'CHECK',
    "INSERT INTO IMAGEM_APARELHO (Imei, URL) VALUES ('800000000000001', 'cellgo.test/img/foto.jpg')");
CALL cellgo_testar('IMAGEM_APARELHO', 'URL com espaço', 'CHECK',
    "INSERT INTO IMAGEM_APARELHO (Imei, URL) VALUES ('800000000000001', 'https://cellgo.test/img/minha foto.jpg')");
CALL cellgo_testar('IMAGEM_APARELHO', 'Mesma imagem repetida para o aparelho', 'UNIQUE',
    "INSERT INTO IMAGEM_APARELHO (Imei, URL) VALUES ('800000000000001', 'https://cellgo.test/img/800000000000001.jpg')");
CALL cellgo_testar('IMAGEM_APARELHO', 'Imagem de aparelho que não existe', 'FK',
    "INSERT INTO IMAGEM_APARELHO (Imei, URL) VALUES ('899999999999999', 'https://cellgo.test/img/x.jpg')");

/* ---------- CLIENTE ---------- */
CALL cellgo_testar('CLIENTE', 'CPF com 10 dígitos', 'CHECK',
    "INSERT INTO CLIENTE VALUES ('8000000092', 'Fulano', 'fulano92@cellgo.test', '1990-01-01', 'PF')");
CALL cellgo_testar('CLIENTE', 'Pessoa jurídica com CNPJ de 13 dígitos', 'CHECK',
    "INSERT INTO CLIENTE VALUES ('8000000000093', 'Empresa X', 'empresa93@cellgo.test', NULL, 'PJ')");
CALL cellgo_testar('CLIENTE', 'Pessoa jurídica com data de nascimento', 'CHECK',
    "INSERT INTO CLIENTE VALUES ('80000000000094', 'Empresa Y', 'empresa94@cellgo.test', '1990-01-01', 'PJ')");
CALL cellgo_testar('CLIENTE', 'E-mail sem @', 'CHECK',
    "INSERT INTO CLIENTE VALUES ('80000000095', 'Fulano', 'fulano.cellgo.test', '1990-01-01', 'PF')");
CALL cellgo_testar('CLIENTE', 'E-mail sem domínio (fulano@cellgo)', 'CHECK',
    "INSERT INTO CLIENTE VALUES ('80000000096', 'Fulano', 'fulano@cellgo', '1990-01-01', 'PF')");
CALL cellgo_testar('CLIENTE', 'E-mail já usado por outro cliente', 'UNIQUE',
    "INSERT INTO CLIENTE VALUES ('80000000097', 'Fulano', 'val.pf@cellgo.test', '1990-01-01', 'PF')");
CALL cellgo_testar('CLIENTE', 'E-mail vazio', 'NOT NULL',
    "INSERT INTO CLIENTE VALUES ('80000000098', 'Fulano', NULL, '1990-01-01', 'PF')");
CALL cellgo_testar('CLIENTE', 'Data de nascimento anterior a 1900', 'CHECK',
    "INSERT INTO CLIENTE VALUES ('80000000099', 'Fulano', 'fulano99@cellgo.test', '1850-01-01', 'PF')");
CALL cellgo_testar('CLIENTE', 'Nome em branco', 'CHECK',
    "INSERT INTO CLIENTE VALUES ('80000000100', '', 'fulano100@cellgo.test', '1990-01-01', 'PF')");
CALL cellgo_testar('CLIENTE', 'CPF de cliente repetido', 'UNIQUE',
    "INSERT INTO CLIENTE VALUES ('80000000091', 'Outro', 'outro@cellgo.test', '1990-01-01', 'PF')");
CALL cellgo_testar('CLIENTE', 'Cliente pessoa física correto (deve passar)', 'ACEITAR',
    "INSERT INTO CLIENTE VALUES ('80000000101', 'Maria da Silva', 'maria.silva@cellgo.test', '1995-07-20', 'PF')");

/* ---------- ENDERECO e TELEFONE ---------- */
CALL cellgo_testar('ENDERECO', 'CEP com 7 dígitos', 'CHECK',
    "INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES ('80000000091', 'Rua A', 'Centro', 'São Paulo', '0300100', '1', 'Entrega')");
CALL cellgo_testar('ENDERECO', 'CEP com hífen (só números são aceitos)', 'CHECK',
    "INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES ('80000000091', 'Rua A', 'Centro', 'São Paulo', '0300-100', '1', 'Entrega')");
CALL cellgo_testar('ENDERECO', 'Tipo de endereço fora da lista', 'CHECK',
    "INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES ('80000000091', 'Rua A', 'Centro', 'São Paulo', '03001000', '1', 'Casa de praia')");
CALL cellgo_testar('ENDERECO', 'Rua em branco', 'CHECK',
    "INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES ('80000000091', ' ', 'Centro', 'São Paulo', '03001000', '1', 'Entrega')");
CALL cellgo_testar('ENDERECO', 'Número do endereço vazio', 'NOT NULL',
    "INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES ('80000000091', 'Rua A', 'Centro', 'São Paulo', '03001000', NULL, 'Entrega')");
CALL cellgo_testar('ENDERECO', 'Endereço de cliente que não existe', 'FK',
    "INSERT INTO ENDERECO (Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Tipo_Endereco) VALUES ('89999999999', 'Rua A', 'Centro', 'São Paulo', '03001000', '1', 'Entrega')");
CALL cellgo_testar('TELEFONE', 'DDD com um dígito', 'CHECK',
    "INSERT INTO TELEFONE VALUES ('80000000091', 5, 980000092)");
CALL cellgo_testar('TELEFONE', 'Número com 7 dígitos', 'CHECK',
    "INSERT INTO TELEFONE VALUES ('80000000091', 11, 9800001)");
CALL cellgo_testar('TELEFONE', 'Celular de 9 dígitos que não começa com 9', 'CHECK',
    "INSERT INTO TELEFONE VALUES ('80000000091', 11, 880000092)");
CALL cellgo_testar('TELEFONE', 'Telefone repetido para o mesmo cliente', 'UNIQUE',
    "INSERT INTO TELEFONE VALUES ('80000000091', 11, 980000091)");
CALL cellgo_testar('TELEFONE', 'Telefone de cliente que não existe', 'FK',
    "INSERT INTO TELEFONE VALUES ('89999999999', 11, 980000093)");
CALL cellgo_testar('TELEFONE', 'Celular correto (deve passar)', 'ACEITAR',
    "INSERT INTO TELEFONE VALUES ('80000000091', 21, 987654321)");

/* ---------- PEDIDO ---------- */
CALL cellgo_testar('PEDIDO', 'Pix parcelado em 3 vezes', 'CHECK',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('80000000091', 'Pix', 3)");
CALL cellgo_testar('PEDIDO', 'Cartão em 13 parcelas', 'CHECK',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('80000000091', 'Cartão de crédito', 13)");
CALL cellgo_testar('PEDIDO', 'Cartão com 0 parcelas', 'CHECK',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('80000000091', 'Cartão de crédito', 0)");
CALL cellgo_testar('PEDIDO', 'Forma de pagamento Boleto (não aceita)', 'TIPO',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('80000000091', 'Boleto', 1)");
CALL cellgo_testar('PEDIDO', 'Forma de pagamento Débito (não aceita)', 'TIPO',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('80000000091', 'Débito', 1)");
CALL cellgo_testar('PEDIDO', 'Pix com taxa de juros', 'CHECK',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas, Valor_Taxas) VALUES ('80000000091', 'Pix', 1, 10.00)");
CALL cellgo_testar('PEDIDO', 'Cartão com taxa igual a zero (sem juros deve ficar vazia)', 'CHECK',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas, Valor_Taxas) VALUES ('80000000091', 'Cartão de crédito', 1, 0.00)");
CALL cellgo_testar('PEDIDO', 'Pedido de cliente que não existe', 'FK',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('89999999999', 'Pix', 1)");
CALL cellgo_testar('PEDIDO', 'Forma de pagamento vazia', 'NOT NULL',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES ('80000000091', NULL, 1)");
CALL cellgo_testar('PEDIDO', 'Alterar pedido no cartão para 15 parcelas', 'CHECK',
    "UPDATE PEDIDO SET Numero_Parcelas = 15 WHERE Id_Pedido = 802");
CALL cellgo_testar('PEDIDO', 'Pedido no cartão em 10 vezes com juros (deve passar)', 'ACEITAR',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas, Valor_Taxas) VALUES ('80000000091', 'Cartão de crédito', 10, 89.90)");

/* ---------- ITEM_PEDIDO (pedido 802, aguardando pagamento) ---------- */
CALL cellgo_testar('ITEM_PEDIDO', 'Fim da garantia do fabricante antes do início da garantia', 'CHECK',
    "INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido, Data_Fim_Garantia_Fabricante) VALUES ('800000000000002', 802, DATE_SUB(CURDATE(), INTERVAL 1 DAY))");
CALL cellgo_testar('ITEM_PEDIDO', 'Mesmo aparelho duas vezes no mesmo pedido', 'UNIQUE',
    "INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('800000000000004', 802)");
CALL cellgo_testar('ITEM_PEDIDO', 'Item em pedido que não existe', 'FK',
    "INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('800000000000002', 99999)");

/* ---------- PAGAMENTO (pedido 802, valor R$ 900,00) ---------- */
CALL cellgo_testar('PAGAMENTO', 'Status de pagamento fora da lista', 'CHECK',
    "INSERT INTO PAGAMENTO (Id_Pedido, Valor, Status) VALUES (802, 900.00, 'Pago')");
CALL cellgo_testar('PAGAMENTO', 'Pagamento aprovado sem código da transação', 'CHECK',
    "INSERT INTO PAGAMENTO (Id_Pedido, Data_Confirmacao, Valor, Status) VALUES (802, NOW(), 900.00, 'Aprovado')");
CALL cellgo_testar('PAGAMENTO', 'Pagamento aprovado sem data de confirmação', 'CHECK',
    "INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Valor, Status) VALUES (802, 'TX-VAL-X1', 900.00, 'Aprovado')");
CALL cellgo_testar('PAGAMENTO', 'Pagamento pendente com data de confirmação', 'CHECK',
    "INSERT INTO PAGAMENTO (Id_Pedido, Data_Confirmacao, Valor) VALUES (802, NOW(), 900.00)");
CALL cellgo_testar('PAGAMENTO', 'Confirmação anterior à tentativa de pagamento', 'CHECK',
    "INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status)
     VALUES (802, 'TX-VAL-X2', NOW(), DATE_SUB(NOW(), INTERVAL 1 HOUR), 900.00, 'Aprovado')");
CALL cellgo_testar('PAGAMENTO', 'Código de transação repetido', 'UNIQUE',
    "INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Valor) VALUES (802, 'TX-VAL-801', 900.00)");
CALL cellgo_testar('PAGAMENTO', 'Valor do pagamento vazio', 'NOT NULL',
    "INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (802, NULL)");
CALL cellgo_testar('PAGAMENTO', 'Cobrança pendente correta (deve passar)', 'ACEITAR',
    "INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (802, 900.00)");

/* ---------- CANCELAMENTO (pedido 801, pago e não enviado) ---------- */
CALL cellgo_testar('CANCELAMENTO', 'Motivo do cancelamento em branco', 'CHECK',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Motivo) VALUES (801, '  ')");
CALL cellgo_testar('CANCELAMENTO', 'Motivo do cancelamento vazio', 'NOT NULL',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Motivo) VALUES (801, NULL)");
CALL cellgo_testar('CANCELAMENTO', 'Status de cancelamento fora da lista', 'CHECK',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Motivo, Status) VALUES (801, 'Desistência', 'Em análise')");
CALL cellgo_testar('CANCELAMENTO', 'Motivo maior que 255 caracteres', 'TIPO',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Motivo) VALUES (801, REPEAT('x', 300))");

/* ---------- AVALIACAO_DANO (pós-venda 801, aberta) ---------- */
CALL cellgo_testar('AVALIACAO_DANO', 'Mau uso marcado como coberto pela garantia', 'CHECK',
    "INSERT INTO AVALIACAO_DANO (Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
     VALUES (801, 803, 'Mau uso', 'Tela quebrada por queda', 1, 'Em manutenção', CURDATE())");
CALL cellgo_testar('AVALIACAO_DANO', 'Dano acidental marcado como coberto pela garantia', 'CHECK',
    "INSERT INTO AVALIACAO_DANO (Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
     VALUES (801, 803, 'Dano acidental', 'Contato com água', 1, 'Em manutenção', CURDATE())");
CALL cellgo_testar('AVALIACAO_DANO', 'Classificação do dano fora da lista', 'TIPO',
    "INSERT INTO AVALIACAO_DANO (Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
     VALUES (801, 803, 'Queda', 'Teste', 0, 'Em manutenção', CURDATE())");
CALL cellgo_testar('AVALIACAO_DANO', 'Destino do aparelho fora da lista', 'TIPO',
    "INSERT INTO AVALIACAO_DANO (Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
     VALUES (801, 803, 'Outros', 'Teste', 0, 'Vendido', CURDATE())");
CALL cellgo_testar('AVALIACAO_DANO', 'Descrição do dano em branco', 'CHECK',
    "INSERT INTO AVALIACAO_DANO (Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
     VALUES (801, 803, 'Outros', ' ', 0, 'Em manutenção', CURDATE())");
CALL cellgo_testar('AVALIACAO_DANO', 'Cobertura da garantia com valor diferente de 0 ou 1', 'CHECK',
    "INSERT INTO AVALIACAO_DANO (Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
     VALUES (801, 803, 'Outros', 'Teste', 7, 'Em manutenção', CURDATE())");

/* ---------- TROCA (pós-venda 801, avaliada com garantia) ---------- */
CALL cellgo_testar('TROCA', 'Status da troca fora da lista', 'TIPO',
    "INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca, Status) VALUES (801, '800000000000002', CURDATE(), 'Feita')");
CALL cellgo_testar('TROCA', 'Data da troca vazia', 'NOT NULL',
    "INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca) VALUES (801, '800000000000002', NULL)");
CALL cellgo_testar('TROCA', 'Aparelho de reposição que não existe', 'FK',
    "INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca) VALUES (801, '899999999999999', CURDATE())");

/* A partir daqui a solicitação 801 é encerrada, para liberar novas
   solicitações para o mesmo aparelho nos testes de POS_VENDA */
UPDATE POS_VENDA SET Status = 'Concluída' WHERE Id_PosVenda = 801;

/* ---------- POS_VENDA ---------- */
CALL cellgo_testar('POS_VENDA', 'Tipo de solicitação fora da lista', 'CHECK',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Descricao) VALUES ('800000000000001', 801, 'Reclamação', 'Teste')");
CALL cellgo_testar('POS_VENDA', 'Descrição em branco', 'CHECK',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Descricao) VALUES ('800000000000001', 801, 'Defeito', '')");
CALL cellgo_testar('POS_VENDA', 'Status da solicitação fora da lista', 'CHECK',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Descricao, Status) VALUES ('800000000000001', 801, 'Defeito', 'Teste', 'Pendente')");
CALL cellgo_testar('POS_VENDA', 'Aparelho que não pertence ao pedido', 'FK',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Descricao) VALUES ('800000000000004', 801, 'Defeito', 'Teste')");

/* ---------- NOTA_FISCAL e ITEM_NOTA_FISCAL (nota 801 aguardando emissão) ---------- */
CALL cellgo_testar('NOTA_FISCAL', 'Nota emitida sem número, chave e data', 'CHECK',
    "UPDATE NOTA_FISCAL SET Status = 'Emitida' WHERE Id_Nota = 801");
CALL cellgo_testar('NOTA_FISCAL', 'Chave de acesso com 43 dígitos', 'CHECK',
    "UPDATE NOTA_FISCAL SET Status = 'Emitida', Numero_Nota = 800001, Chave_Acesso = REPEAT('8', 43), Data_Emissao = NOW() WHERE Id_Nota = 801");
CALL cellgo_testar('NOTA_FISCAL', 'Número da nota igual a zero', 'CHECK',
    "UPDATE NOTA_FISCAL SET Status = 'Emitida', Numero_Nota = 0, Chave_Acesso = REPEAT('8', 44), Data_Emissao = NOW() WHERE Id_Nota = 801");
CALL cellgo_testar('NOTA_FISCAL', 'Nota ainda não emitida com número preenchido', 'CHECK',
    "UPDATE NOTA_FISCAL SET Numero_Nota = 800002 WHERE Id_Nota = 801");
CALL cellgo_testar('NOTA_FISCAL', 'Tipo de nota fora da lista', 'CHECK',
    "INSERT INTO NOTA_FISCAL (Id_PosVenda, Id_Nota_Referencia, Tipo_Nota, Natureza) VALUES (801, 801, 'Serviço', 'Teste')");
CALL cellgo_testar('NOTA_FISCAL', 'Natureza da operação em branco', 'CHECK',
    "INSERT INTO NOTA_FISCAL (Id_PosVenda, Id_Nota_Referencia, Tipo_Nota, Natureza) VALUES (801, 801, 'Entrada (Devolução)', ' ')");
CALL cellgo_testar('NOTA_FISCAL', 'Nota emitida corretamente (deve passar)', 'ACEITAR',
    "UPDATE NOTA_FISCAL SET Status = 'Emitida', Numero_Nota = 800001, Chave_Acesso = REPEAT('8', 44), Data_Emissao = NOW() WHERE Id_Nota = 801");
CALL cellgo_testar('ITEM_NOTA_FISCAL', 'Valor do item igual a zero', 'CHECK',
    "INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES ('800000000000001', 801, 0.00)");
CALL cellgo_testar('ITEM_NOTA_FISCAL', 'Valor do item vazio', 'NOT NULL',
    "INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES ('800000000000001', 801, NULL)");

/* ---------- ESTORNO (pagamento 803, pedido 803 cancelado) ---------- */
CALL cellgo_testar('ESTORNO', 'Valor do estorno igual a zero', 'CHECK',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor) VALUES (803, 801, 0.00)");
CALL cellgo_testar('ESTORNO', 'Valor do estorno negativo', 'CHECK',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor) VALUES (803, 801, -50.00)");
CALL cellgo_testar('ESTORNO', 'Status do estorno fora da lista', 'CHECK',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor, Status) VALUES (803, 801, 1200.00, 'Feito')");
CALL cellgo_testar('ESTORNO', 'Estorno pendente com data de conclusão', 'CHECK',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor, Data_Conclusao) VALUES (803, 801, 1200.00, NOW())");
CALL cellgo_testar('ESTORNO', 'Estorno processado sem data de conclusão', 'CHECK',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor, Status) VALUES (803, 801, 1200.00, 'Processado')");
CALL cellgo_testar('ESTORNO', 'Conclusão anterior à abertura do estorno', 'CHECK',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor, Status, Data_Conclusao) VALUES (803, 801, 1200.00, 'Processado', DATE_SUB(NOW(), INTERVAL 1 DAY))");
CALL cellgo_testar('ESTORNO', 'Estorno de pagamento que não existe', 'FK',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor) VALUES (99999, 801, 100.00)");
CALL cellgo_testar('ESTORNO', 'Estorno correto pelo valor pago (deve passar)', 'ACEITAR',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor) VALUES (803, 801, 1200.00)");

/* ---------- ENTREGA (pedido 801, pago) ---------- */
CALL cellgo_testar('ENTREGA', 'Código de rastreio muito curto', 'CHECK',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('AB12', 801, 'Transportadora Val')");
CALL cellgo_testar('ENTREGA', 'Código de rastreio com espaço', 'CHECK',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BR 12345678', 801, 'Transportadora Val')");
CALL cellgo_testar('ENTREGA', 'Status da entrega fora da lista', 'CHECK',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora, Status_Entrega) VALUES ('BRVAL0001', 801, 'Transportadora Val', 'Extraviada')");
CALL cellgo_testar('ENTREGA', 'Em transporte sem data de despacho', 'CHECK',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora, Status_Entrega) VALUES ('BRVAL0002', 801, 'Transportadora Val', 'Em transporte')");
CALL cellgo_testar('ENTREGA', 'Entregue sem data de entrega', 'CHECK',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora, Status_Entrega, Data_Despacho) VALUES ('BRVAL0003', 801, 'Transportadora Val', 'Entregue', NOW())");
CALL cellgo_testar('ENTREGA', 'Data de entrega anterior ao despacho', 'CHECK',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora, Status_Entrega, Data_Despacho, Data_Entrega)
     VALUES ('BRVAL0004', 801, 'Transportadora Val', 'Entregue', NOW(), DATE_SUB(NOW(), INTERVAL 2 DAY))");
CALL cellgo_testar('ENTREGA', 'Origem da atualização fora da lista', 'CHECK',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora, Origem_Atualizacao) VALUES ('BRVAL0005', 801, 'Transportadora Val', 'Robô')");
CALL cellgo_testar('ENTREGA', 'Transportadora em branco', 'CHECK',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BRVAL0006', 801, '')");
CALL cellgo_testar('ENTREGA', 'Entrega cadastrada corretamente (deve passar)', 'ACEITAR',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BRVAL0007', 801, 'Transportadora Val')");

/* ---------- REQUISICAO_COMPRA ---------- */
CALL cellgo_testar('REQUISICAO_COMPRA', 'Quantidade sugerida igual a zero', 'CHECK',
    "INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida) VALUES (803, 0, 2, CURDATE(), 0)");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Quantidade em estoque negativa', 'CHECK',
    "INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida) VALUES (803, -1, 2, CURDATE(), 3)");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Requisição em aberto com motivo de recusa', 'CHECK',
    "INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida, Motivo_Recusa) VALUES (803, 0, 2, CURDATE(), 3, 'Sem verba')");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Data de abertura vazia', 'NOT NULL',
    "INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida) VALUES (803, 0, 2, NULL, 3)");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Especificação que não existe', 'FK',
    "INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida) VALUES (99999, 0, 2, CURDATE(), 3)");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Enviar para a Diretoria sem o parecer financeiro', 'CHECK',
    "UPDATE REQUISICAO_COMPRA SET Status = 'Aguardando Aprovação da Diretoria' WHERE Id_Requisicao = 801");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Recusar sem informar o motivo', 'CHECK',
    "UPDATE REQUISICAO_COMPRA SET Status = 'Recusada', Codigo_Funcionario = 801, Data_Decisao = CURDATE() WHERE Id_Requisicao = 802");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Aprovar sem a data da decisão', 'CHECK',
    "UPDATE REQUISICAO_COMPRA SET Status = 'Aprovada', Codigo_Funcionario = 801 WHERE Id_Requisicao = 802");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Data da decisão anterior à abertura', 'CHECK',
    "UPDATE REQUISICAO_COMPRA SET Status = 'Aprovada', Codigo_Funcionario = 801, Data_Decisao = DATE_SUB(CURDATE(), INTERVAL 5 DAY) WHERE Id_Requisicao = 802");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Requisição aberta corretamente (deve passar)', 'ACEITAR',
    "INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida) VALUES (803, 0, 2, CURDATE(), 4)");

/* ---------- MOVIMENTACAO (aparelho 800000000000004, Disponível) ---------- */
CALL cellgo_testar('MOVIMENTACAO', 'Entrada no estoque com status anterior preenchido', 'CHECK',
    "INSERT INTO MOVIMENTACAO (Codigo_Funcionario, Imei, Tipo_Movimento, Status_Anterior, Status_Novo)
     VALUES (802, '800000000000004', 'Entrada', 'Em avaliação', 'Disponível')");
CALL cellgo_testar('MOVIMENTACAO', 'Movimentação sem mudança de status', 'CHECK',
    "INSERT INTO MOVIMENTACAO (Codigo_Funcionario, Imei, Tipo_Movimento, Status_Anterior, Status_Novo)
     VALUES (802, '800000000000004', 'Retorno ao estoque', 'Disponível', 'Disponível')");
CALL cellgo_testar('MOVIMENTACAO', 'Tipo de movimento fora da lista', 'TIPO',
    "INSERT INTO MOVIMENTACAO (Codigo_Funcionario, Imei, Tipo_Movimento, Status_Anterior, Status_Novo)
     VALUES (802, '800000000000004', 'Empréstimo', 'Em avaliação', 'Disponível')");
CALL cellgo_testar('MOVIMENTACAO', 'Movimentação de aparelho que não existe', 'FK',
    "INSERT INTO MOVIMENTACAO (Codigo_Funcionario, Imei, Tipo_Movimento, Status_Anterior, Status_Novo)
     VALUES (802, '899999999999999', 'Retorno ao estoque', 'Em avaliação', 'Disponível')");

/* ---------- AUDITORIA ---------- */
CALL cellgo_testar('AUDITORIA', 'Tabela afetada que não existe no sistema', 'CHECK',
    "INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id, Valor_Novo) VALUES (801, 'Teste', 'USUARIO', '1', JSON_OBJECT('x', 1))");
CALL cellgo_testar('AUDITORIA', 'Registro sem valor anterior e sem valor novo', 'CHECK',
    "INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id) VALUES (801, 'Teste', 'APARELHO', '1')");
CALL cellgo_testar('AUDITORIA', 'Ação em branco', 'CHECK',
    "INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id, Valor_Novo) VALUES (801, ' ', 'APARELHO', '1', JSON_OBJECT('x', 1))");
CALL cellgo_testar('AUDITORIA', 'Valor novo com JSON inválido', 'TIPO',
    "INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id, Valor_Novo) VALUES (801, 'Teste', 'APARELHO', '1', '{abc')");
CALL cellgo_testar('AUDITORIA', 'Funcionário que não existe', 'FK',
    "INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id, Valor_Novo) VALUES (99999, 'Teste', 'APARELHO', '1', JSON_OBJECT('x', 1))");


/* =====================================================================
   PARTE 3 — RELATÓRIO
   ===================================================================== */

/* Resumo: o esperado é que tudo esteja em OK */
SELECT Resultado, COUNT(*) AS Quantidade
  FROM resultado_teste
 GROUP BY Resultado
 ORDER BY FIELD(Resultado, 'FALHOU', 'ERRO NO TESTE', 'ATENÇÃO', 'OK');

/* Quantidade de testes por tipo de validação */
SELECT Esperado AS Validacao, COUNT(*) AS Testes, SUM(Resultado = 'OK') AS Ok
  FROM resultado_teste
 GROUP BY Esperado
 ORDER BY Testes DESC;

/* Detalhe de cada teste, com a mensagem devolvida pelo banco */
SELECT Ordem, Grupo, Teste, Esperado, Barrado_Por, Resultado, Mensagem
  FROM resultado_teste
 ORDER BY Ordem;

SET @cellgo_funcionario = NULL;
DROP PROCEDURE IF EXISTS cellgo_testar;
