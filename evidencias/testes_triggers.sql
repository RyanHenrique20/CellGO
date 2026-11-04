/* =====================================================================
   CellGO — Testes das triggers (regras de negócio)
   SGBD: MySQL 8

   Objetivo: provar que as triggers barram as operações que quebram as
   regras de negócio e deixam passar as operações corretas.

   Como executar:
   1. Rode tabelas.sql e trigger.sql (banco cellgo criado);
   2. Rode este arquivo inteiro. No fim aparece o relatório.
      O ideal é usar um banco de teste: os dados de apoio (todos com
      "Teste" no nome e códigos 9xx) ficam gravados, porque as próprias
      triggers proíbem excluir aparelhos, pedidos e notas.

   Como funciona:
   - Parte 1 cria dados VÁLIDOS de apoio. Se algum deles der erro, o
     script para ali: é sinal de que uma regra está barrando dado certo.
   - Parte 2 chama o procedimento cellgo_testar(grupo, teste, esperado,
     comando) para cada tentativa. Ele executa o comando, anota se o
     banco barrou ou aceitou, qual regra barrou e a mensagem de erro, e
     desfaz a tentativa (ROLLBACK). Assim um teste não afeta o outro.
       esperado = 'TRIGGER'  → deve ser barrado por uma trigger;
       esperado = 'ACEITAR'  → é uma operação correta e deve passar.
   - Parte 3 confere os valores que as triggers calculam sozinhas
     (desconto Pix, garantias, quarentena, valor total etc.).
   - Parte 4 mostra o relatório: OK, FALHOU ou ATENÇÃO
     (ATENÇÃO = barrou, mas por outra regra diferente da esperada).

   Os comandos testados ficam entre aspas duplas para poder usar aspas
   simples dentro deles (padrão do MySQL, sem o modo ANSI_QUOTES).
   ===================================================================== */

SET NAMES utf8mb4;
USE cellgo;


/* =====================================================================
   PROCEDIMENTO DE TESTE E TABELA DE RESULTADOS
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
                                    'Operação correta aceita.',
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

/* As ações de Diretoria leem esta variável (ver trigger.sql) */
SET @cellgo_funcionario = 901;

/* Perfis: os 5 perfis possíveis (ignora os que já existirem) */
INSERT IGNORE INTO PERFIL_ACESSO (Nome_Perfil, Nivel_Acesso) VALUES
    ('Vendas e Atendimento', 1), ('Estoque e Logística', 1), ('Assistência Técnica', 1),
    ('Financeiro/Administrativo', 1), ('Diretoria', 2);

INSERT INTO FUNCIONARIO (Codigo_Funcionario, Nome, Cargo, Login, Id_Perfil, Ativo) VALUES
    (901, 'Teste Diretor',         'Diretor',    'teste.trg.diretor',    (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Diretoria'), 1),
    (902, 'Teste Estoquista',      'Estoquista', 'teste.trg.estoque',    (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Estoque e Logística'), 1),
    (903, 'Teste Técnico',         'Técnico',    'teste.trg.tecnico',    (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Assistência Técnica'), 1),
    (904, 'Teste Vendedor',        'Vendedor',   'teste.trg.vendedor',   (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Vendas e Atendimento'), 1),
    (905, 'Teste Técnico Inativo', 'Técnico',    'teste.trg.inativo',    (SELECT Id_Perfil FROM PERFIL_ACESSO WHERE Nome_Perfil = 'Assistência Técnica'), 0);

INSERT INTO FORNECEDOR (Cpf_Cnpj_Fornecedor, Tipo_Pessoa, Nome, Tipo_Documento, Numero_Documento, Telefone_Contato) VALUES
    ('90000000001',    'PF', 'Fornecedor Teste PF',      'RG', '900000001', '11990000001'),
    ('90000000000001', 'PJ', 'Fornecedor Teste PJ Ltda', NULL, NULL,        '1130000001');

INSERT INTO MODELO (Id_Modelo, Nome_Modelo, Marca) VALUES
    (901, 'Teste Modelo A', 'Marca Teste'),
    (902, 'Teste Modelo B', 'Marca Teste');

/* estoque mínimo 0 nas especificações 901 e 902 para não abrir
   requisição automática durante os testes; a 903 é usada nos testes
   de requisição de compra */
INSERT INTO ESPECIFICACAO_APARELHO (Id_Especificacao, Id_Modelo, Cor, Capacidade, Estoque_Minimo) VALUES
    (901, 901, 'Preto',  128, 0),
    (902, 902, 'Azul',   256, 0),
    (903, 901, 'Branco', 256, 5);

/* Aquisições
   901: pessoa jurídica, há 30 dias
   902: pessoa física, há 30 dias (aparelhos em quarentena)
   903: pessoa física, hoje (limite de 3 aparelhos por CPF no dia)
   904: pessoa jurídica, há 10 dias, sem aparelho aprovado */
INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao,
                       Tipo_Documento_Compra, Numero_Documento_Compra, Termo_Responsabilidade_Aceito) VALUES
    (901, 902, '90000000000001', DATE_SUB(CURDATE(), INTERVAL 30 DAY), 'Nota fiscal do fornecedor', 'NF-TESTE-901',  NULL),
    (902, 902, '90000000001',    DATE_SUB(CURDATE(), INTERVAL 30 DAY), 'Termo de compra e venda',   'TCV-TESTE-902', 1),
    (903, 902, '90000000001',    CURDATE(),                            'Termo de compra e venda',   'TCV-TESTE-903', 1),
    (904, 902, '90000000000001', DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Nota fiscal do fornecedor', 'NF-TESTE-904',  NULL);

/* Avaliações de entrada (técnico 903). Aprovado = IMEI regular, checklist
   sem reprovação, sem bloqueio de conta e com reset de fábrica */
INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado,
                               Base_Consultada, Resultado_Consulta_Imei, Data_Consulta,
                               Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado, Motivo_Recusa) VALUES
    (901, 903, 901, '900000000000001', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (902, 903, 901, '900000000000002', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (903, 903, 901, '900000000000003', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (909, 903, 901, '900000000000009', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (912, 903, 901, '900000000000012', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (913, 903, 901, '900000000000013', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (914, 903, 901, '900000000000014', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (904, 903, 902, '900000000000004', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (905, 903, 902, '900000000000005', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (911, 903, 902, '900000000000011', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 1, 'Aprovado', NULL),
    (906, 903, 903, '900000000000006', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado', NULL),
    (907, 903, 903, '900000000000007', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado', NULL),
    (908, 903, 903, '900000000000008', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado', NULL),
    (910, 903, 904, '900000000000010', 'Celular Seguro', 'Bloqueado', NOW(), 0, NULL, 'Recusado', 'IMEI bloqueado na consulta');

/* Reconsulta Regular ao fim da quarentena para as avaliações 905 e 911 */
UPDATE AVALIACAO_ENTRADA
   SET Data_Reconsulta_Imei = NOW(), Resultado_Reconsulta_Imei = 'Regular'
 WHERE Id_Avaliacao_Entrada IN (905, 911);

/* Aparelhos (o status inicial e a quarentena são definidos pela trigger)
   A1 001 Novo     1000 Pix   → será vendido no pedido 901
   A2 002 Novo     2000       → no pedido 902 (aguardando pagamento)
   A3 003 Seminovo 1500 Pix   → livre no estoque
   A4 004 Seminovo PF, entrada há 30 dias, sem reconsulta → quarentena
   A5 005 Seminovo PF, entrada hoje → quarentena até daqui 15 dias
   A6 009 Novo     1000       → vendido no pedido 904
   A8 011 Seminovo PF, entrada há 30 dias, reconsulta Regular
   A9 012 Seminovo  900       → no pedido 905, depois vai para manutenção
   A10 013 Seminovo 500       → livre (aparelho de valor menor)
   A11 014 Seminovo 800 Pix   → pedido 906, cancelado */
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao,
                      Preco_Venda, Custo_Aquisicao, Status, Data_Entrada, Elegivel_Desconto_Pix) VALUES
    ('900000000000001', 901, 901, 902, 'Novo',     1000.00,  700.00, 'Disponível',    DATE_SUB(CURDATE(), INTERVAL 30 DAY), 1),
    ('900000000000002', 901, 902, 902, 'Novo',     2000.00, 1500.00, 'Disponível',    DATE_SUB(CURDATE(), INTERVAL 30 DAY), 0),
    ('900000000000003', 902, 903, 902, 'Seminovo', 1500.00,  900.00, 'Disponível',    DATE_SUB(CURDATE(), INTERVAL 30 DAY), 1),
    ('900000000000004', 902, 904, 902, 'Seminovo', 1200.00,  800.00, 'Em quarentena', DATE_SUB(CURDATE(), INTERVAL 30 DAY), 1),
    ('900000000000005', 902, 905, 902, 'Seminovo', 1300.00,  850.00, 'Em quarentena', CURDATE(),                            1),
    ('900000000000009', 901, 909, 902, 'Novo',     1000.00,  700.00, 'Disponível',    DATE_SUB(CURDATE(), INTERVAL 30 DAY), 0),
    ('900000000000011', 902, 911, 902, 'Seminovo', 1100.00,  700.00, 'Em quarentena', DATE_SUB(CURDATE(), INTERVAL 30 DAY), 1),
    ('900000000000012', 902, 912, 902, 'Seminovo',  900.00,  600.00, 'Disponível',    DATE_SUB(CURDATE(), INTERVAL 30 DAY), 0),
    ('900000000000013', 902, 913, 902, 'Seminovo',  500.00,  300.00, 'Disponível',    DATE_SUB(CURDATE(), INTERVAL 30 DAY), 0),
    ('900000000000014', 902, 914, 902, 'Seminovo',  800.00,  500.00, 'Disponível',    DATE_SUB(CURDATE(), INTERVAL 30 DAY), 1);

UPDATE AQUISICAO SET Status = 'Concluída' WHERE Id_Aquisicao = 901;

/* Clientes: PF com 1 endereço e 1 telefone; PJ com 2 endereços */
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES
    ('90000000091',    'Cliente Teste PF',      'cliente.teste.pf@cellgo.test', '1990-05-10', 'PF'),
    ('90000000000091', 'Cliente Teste PJ Ltda', 'cliente.teste.pj@cellgo.test', NULL,         'PJ');

INSERT INTO ENDERECO (Id_Endereco, Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Complemento, Tipo_Endereco) VALUES
    (901, '90000000091',    'Rua Teste',     'Tatuapé', 'São Paulo', '03000000', '10',  NULL,      'Entrega'),
    (902, '90000000000091', 'Avenida Teste', 'Centro',  'São Paulo', '01000000', '100', 'Sala 1',  'Comercial'),
    (903, '90000000000091', 'Rua Depósito',  'Mooca',   'São Paulo', '03100000', '200', NULL,      'Entrega');

INSERT INTO TELEFONE (Cpf_Cnpj, DDD, Numero_Telefone) VALUES
    ('90000000091',    11, 990000091),
    ('90000000000091', 11, 30000091),
    ('90000000000091', 11, 990000092);

/* Pedido 901: venda completa no Pix (pago, nota emitida, entregue) */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (901, '90000000091', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('900000000000001', 901);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 901;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 901);
INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status)
VALUES (901, 901, 'TX-TESTE-901', NOW(), NOW(), @valor, 'Aprovado');

INSERT INTO NOTA_FISCAL (Id_Nota, Id_Pedido, Tipo_Nota, Natureza) VALUES (901, 901, 'Venda', 'Venda de mercadoria');
INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES ('900000000000001', 901, 950.00);
UPDATE NOTA_FISCAL
   SET Status = 'Emitida', Numero_Nota = 900001, Chave_Acesso = REPEAT('9', 44),
       Data_Emissao = DATE_SUB(NOW(), INTERVAL 2 DAY)
 WHERE Id_Nota = 901;

INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BRTESTE901', 901, 'Transportadora Teste');
UPDATE ENTREGA SET Status_Entrega = 'Em transporte', Data_Despacho = NOW() WHERE Codigo_Rastreio = 'BRTESTE901';
UPDATE ENTREGA SET Status_Entrega = 'Entregue', Data_Entrega = NOW() WHERE Codigo_Rastreio = 'BRTESTE901';

/* Pós-venda 901: defeito no aparelho do pedido 901, avaliado com garantia */
INSERT INTO POS_VENDA (Id_PosVenda, Imei, Id_Pedido, Tipo_Solicitacao, Descricao)
VALUES (901, '900000000000001', 901, 'Defeito', 'Teste: tela piscando');
INSERT INTO AVALIACAO_DANO (Codigo_Avaliacao, Id_PosVenda, Codigo_Funcionario, Classificacao_Dano,
                            Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
VALUES (901, 901, 903, 'Defeito de fabricação', 'Falha no display', 1, 'Em manutenção', CURDATE());

/* Pedido 902: cartão, aguardando pagamento, com cobrança Pendente */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (902, '90000000091', 'Cartão de crédito', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('900000000000002', 902);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 902;
INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Valor) VALUES (902, 902, 2000.00);

/* Pedido 903: aberto e sem itens */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (903, '90000000091', 'Pix', 1);

/* Pedido 904: cartão, pago, nota ainda não emitida, entrega em transporte */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (904, '90000000091', 'Cartão de crédito', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('900000000000009', 904);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 904;
INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status)
VALUES (904, 904, 'TX-TESTE-904', NOW(), NOW(), 1000.00, 'Aprovado');
INSERT INTO NOTA_FISCAL (Id_Nota, Id_Pedido, Tipo_Nota, Natureza) VALUES (902, 904, 'Venda', 'Venda de mercadoria');
INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BRTESTE904', 904, 'Transportadora Teste');
UPDATE ENTREGA SET Status_Entrega = 'Em transporte', Data_Despacho = NOW() WHERE Codigo_Rastreio = 'BRTESTE904';

/* Pedido 905: aguardando pagamento; depois o aparelho vai para manutenção */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (905, '90000000000091', 'Cartão de crédito', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('900000000000012', 905);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 905;
UPDATE APARELHO SET Status = 'Em manutenção' WHERE Imei = '900000000000012';

/* Pedido 906: Pix, pago e cancelado (cancelamento concluído) */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Forma_Pagamento, Numero_Parcelas) VALUES (906, '90000000000091', 'Pix', 1);
INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('900000000000014', 906);
UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 906;
SET @valor = (SELECT Valor_Final FROM PEDIDO WHERE Id_Pedido = 906);
INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status)
VALUES (903, 906, 'TX-TESTE-906', NOW(), NOW(), @valor, 'Aprovado');
INSERT INTO CANCELAMENTO (Codigo_Cancelamento, Id_Pedido, Motivo, Status)
VALUES (901, 906, 'Teste: cliente desistiu', 'Concluído');

/* Requisições de compra: 901 em análise financeira; 902 aguardando a Diretoria */
INSERT INTO REQUISICAO_COMPRA (Id_Requisicao, Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida)
VALUES (901, 903, 0, 5, CURDATE(), 10),
       (902, 901, 1, 2, CURDATE(), 3);
UPDATE REQUISICAO_COMPRA
   SET Status = 'Aguardando Aprovação da Diretoria', Parecer_Financeiro = 'Teste: caixa disponível'
 WHERE Id_Requisicao = 902;

/* Daqui em diante, quem opera é o vendedor (não é Diretoria) */
SET @cellgo_funcionario = 904;


/* =====================================================================
   PARTE 2 — TENTATIVAS QUE DEVEM SER BARRADAS (e controles que passam)
   ===================================================================== */

/* ---------- CLIENTE (RN-01) ---------- */
CALL cellgo_testar('CLIENTE', 'Cliente pessoa física com menos de 18 anos', 'TRIGGER',
    "INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa)
     VALUES ('90000000092', 'Menor Teste', 'menor@cellgo.test', DATE_SUB(CURDATE(), INTERVAL 10 YEAR), 'PF')");
CALL cellgo_testar('CLIENTE', 'Cliente pessoa física sem data de nascimento', 'TRIGGER',
    "INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa)
     VALUES ('90000000093', 'Sem Nascimento', 'semdata@cellgo.test', NULL, 'PF')");
CALL cellgo_testar('CLIENTE', 'Alterar nascimento de cliente para menor de idade', 'TRIGGER',
    "UPDATE CLIENTE SET Data_Nascimento = DATE_SUB(CURDATE(), INTERVAL 15 YEAR) WHERE Cpf_Cnpj = '90000000091'");
CALL cellgo_testar('CLIENTE', 'Cliente que completa 18 anos hoje (deve passar)', 'ACEITAR',
    "INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa)
     VALUES ('90000000094', 'Dezoito Teste', 'dezoito@cellgo.test', DATE_SUB(CURDATE(), INTERVAL 18 YEAR), 'PF')");

/* ---------- ENDERECO e TELEFONE (RN-01) ---------- */
CALL cellgo_testar('ENDERECO', 'Excluir o único endereço do cliente', 'TRIGGER',
    "DELETE FROM ENDERECO WHERE Id_Endereco = 901");
CALL cellgo_testar('ENDERECO', 'Excluir um endereço quando o cliente tem outro (deve passar)', 'ACEITAR',
    "DELETE FROM ENDERECO WHERE Id_Endereco = 903");
CALL cellgo_testar('TELEFONE', 'Excluir o único telefone do cliente', 'TRIGGER',
    "DELETE FROM TELEFONE WHERE Cpf_Cnpj = '90000000091'");

/* ---------- ESPECIFICACAO_APARELHO (RN-02/RN-24) ---------- */
CALL cellgo_testar('ESPECIFICACAO', 'Vendedor alterando o estoque mínimo', 'TRIGGER',
    "UPDATE ESPECIFICACAO_APARELHO SET Estoque_Minimo = 3 WHERE Id_Especificacao = 901");
CALL cellgo_testar('ESPECIFICACAO', 'Vendedor alterando os limites de giro', 'TRIGGER',
    "UPDATE ESPECIFICACAO_APARELHO SET Limite_Dias_Atencao = 20, Limite_Dias_Critico = 40 WHERE Id_Especificacao = 901");
SET @cellgo_funcionario = 901;
CALL cellgo_testar('ESPECIFICACAO', 'Diretoria alterando o estoque mínimo (deve passar)', 'ACEITAR',
    "UPDATE ESPECIFICACAO_APARELHO SET Estoque_Minimo = 3 WHERE Id_Especificacao = 901");
SET @cellgo_funcionario = 904;

/* ---------- AQUISICAO ---------- */
CALL cellgo_testar('AQUISICAO', 'Aquisição registrada por vendedor (não é Estoque e Logística)', 'TRIGGER',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra)
     VALUES (904, '90000000000001', CURDATE(), 'Nota fiscal do fornecedor', 'NF-X1')");
CALL cellgo_testar('AQUISICAO', 'Compra de pessoa física com nota fiscal em vez do termo', 'TRIGGER',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra, Termo_Responsabilidade_Aceito)
     VALUES (902, '90000000001', CURDATE(), 'Nota fiscal do fornecedor', 'NF-X2', 1)");
CALL cellgo_testar('AQUISICAO', 'Compra de pessoa física sem aceitar o termo de responsabilidade', 'TRIGGER',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra, Termo_Responsabilidade_Aceito)
     VALUES (902, '90000000001', CURDATE(), 'Termo de compra e venda', 'TCV-X3', 0)");
CALL cellgo_testar('AQUISICAO', 'Compra de pessoa jurídica com termo de compra e venda', 'TRIGGER',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra)
     VALUES (902, '90000000000001', CURDATE(), 'Termo de compra e venda', 'TCV-X4')");
CALL cellgo_testar('AQUISICAO', 'Compra de pessoa jurídica com termo de responsabilidade preenchido', 'TRIGGER',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra, Termo_Responsabilidade_Aceito)
     VALUES (902, '90000000000001', CURDATE(), 'Nota fiscal do fornecedor', 'NF-X5', 1)");
CALL cellgo_testar('AQUISICAO', 'Nova aquisição já com status Concluída', 'TRIGGER',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra, Status)
     VALUES (902, '90000000000001', CURDATE(), 'Nota fiscal do fornecedor', 'NF-X6', 'Concluída')");
CALL cellgo_testar('AQUISICAO', 'Aquisição correta de pessoa jurídica (deve passar)', 'ACEITAR',
    "INSERT INTO AQUISICAO (Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra)
     VALUES (902, '90000000000001', CURDATE(), 'Nota fiscal do fornecedor', 'NF-X7')");
CALL cellgo_testar('AQUISICAO', 'Trocar o fornecedor de uma aquisição', 'TRIGGER',
    "UPDATE AQUISICAO SET Cpf_Cnpj_Fornecedor = '90000000001' WHERE Id_Aquisicao = 904");
CALL cellgo_testar('AQUISICAO', 'Concluir aquisição sem nenhum aparelho aprovado', 'TRIGGER',
    "UPDATE AQUISICAO SET Status = 'Concluída' WHERE Id_Aquisicao = 904");
CALL cellgo_testar('AQUISICAO', 'Recusar aquisição que tem aparelho aprovado', 'TRIGGER',
    "UPDATE AQUISICAO SET Status = 'Recusada' WHERE Id_Aquisicao = 902");
CALL cellgo_testar('AQUISICAO', 'Reabrir aquisição já concluída', 'TRIGGER',
    "UPDATE AQUISICAO SET Status = 'Em avaliação' WHERE Id_Aquisicao = 901");

/* ---------- AVALIACAO_ENTRADA (RN-25) ---------- */
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Avaliação feita por técnico inativo', 'TRIGGER',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (905, 904, '900000000000030', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Avaliação feita por vendedor (não é Assistência Técnica)', 'TRIGGER',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (904, 904, '900000000000031', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Avaliar aparelho de aquisição já concluída', 'TRIGGER',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (903, 901, '900000000000032', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Consulta do IMEI anterior à data da aquisição', 'TRIGGER',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (903, 904, '900000000000033', 'Celular Seguro', 'Regular', DATE_SUB(NOW(), INTERVAL 20 DAY), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Avaliar IMEI que já está no estoque', 'TRIGGER',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (903, 904, '900000000000001', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', '4º aparelho aprovado do mesmo CPF no mesmo dia', 'TRIGGER',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado)
     VALUES (903, 903, '900000000000020', 'Celular Seguro', 'Regular', NOW(), 0, 1, 'Aprovado')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Aparelho recusado do mesmo CPF no mesmo dia (deve passar)', 'ACEITAR',
    "INSERT INTO AVALIACAO_ENTRADA (Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado, Motivo_Recusa)
     VALUES (903, 903, '900000000000021', 'Celular Seguro', 'Regular', NOW(), 1, NULL, 'Recusado', 'Conta Google vinculada')");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Recusar avaliação de aparelho que já está no estoque', 'TRIGGER',
    "UPDATE AVALIACAO_ENTRADA SET Resultado = 'Recusado', Motivo_Recusa = 'Teste', Reset_Fabrica_Realizado = NULL
     WHERE Id_Avaliacao_Entrada = 901");
CALL cellgo_testar('AVALIACAO_ENTRADA', 'Alterar o IMEI de uma avaliação', 'TRIGGER',
    "UPDATE AVALIACAO_ENTRADA SET Imei_Avaliado = '900000000000098' WHERE Id_Avaliacao_Entrada = 906");

/* ---------- APARELHO (RN-03/RN-05/RN-25) ---------- */
CALL cellgo_testar('APARELHO', 'Cadastrar aparelho com avaliação de entrada recusada', 'TRIGGER',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('900000000000010', 901, 910, 902, 'Novo', 100.00, 50.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'IMEI do aparelho diferente do IMEI avaliado', 'TRIGGER',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('900000000000099', 902, 906, 902, 'Seminovo', 100.00, 50.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'Data de entrada anterior à data da aquisição', 'TRIGGER',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('900000000000006', 902, 906, 902, 'Seminovo', 100.00, 50.00, 'Disponível', DATE_SUB(CURDATE(), INTERVAL 1 DAY))");
CALL cellgo_testar('APARELHO', 'Aparelho cadastrado por funcionário inativo', 'TRIGGER',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('900000000000006', 902, 906, 905, 'Seminovo', 100.00, 50.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'Aparelho entrando no estoque já como Vendido', 'TRIGGER',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('900000000000006', 902, 906, 902, 'Seminovo', 100.00, 50.00, 'Vendido', CURDATE())");
CALL cellgo_testar('APARELHO', 'Seminovo de pessoa física corretamente cadastrado (deve passar)', 'ACEITAR',
    "INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada)
     VALUES ('900000000000006', 902, 906, 902, 'Seminovo', 100.00, 50.00, 'Disponível', CURDATE())");
CALL cellgo_testar('APARELHO', 'Excluir um aparelho do estoque', 'TRIGGER',
    "DELETE FROM APARELHO WHERE Imei = '900000000000013'");
CALL cellgo_testar('APARELHO', 'Alterar a condição (Novo/Seminovo) de um aparelho', 'TRIGGER',
    "UPDATE APARELHO SET Condicao = 'Novo' WHERE Imei = '900000000000003'");
CALL cellgo_testar('APARELHO', 'Mudança de status proibida: Disponível → Em quarentena', 'TRIGGER',
    "UPDATE APARELHO SET Status = 'Em quarentena' WHERE Imei = '900000000000003'");
CALL cellgo_testar('APARELHO', 'Mudança de status proibida: Em quarentena → Vendido', 'TRIGGER',
    "UPDATE APARELHO SET Status = 'Vendido' WHERE Imei = '900000000000004'");
CALL cellgo_testar('APARELHO', 'Liberar da quarentena antes dos 15 dias', 'TRIGGER',
    "UPDATE APARELHO SET Status = 'Disponível' WHERE Imei = '900000000000005'");
CALL cellgo_testar('APARELHO', 'Liberar da quarentena sem nova consulta Regular do IMEI', 'TRIGGER',
    "UPDATE APARELHO SET Status = 'Disponível' WHERE Imei = '900000000000004'");
CALL cellgo_testar('APARELHO', 'Liberar da quarentena após 15 dias e reconsulta Regular (deve passar)', 'ACEITAR',
    "UPDATE APARELHO SET Status = 'Disponível' WHERE Imei = '900000000000011'");
CALL cellgo_testar('APARELHO', 'Vendedor alterando o preço de venda', 'TRIGGER',
    "UPDATE APARELHO SET Preco_Venda = 1400.00 WHERE Imei = '900000000000003'");
CALL cellgo_testar('APARELHO', 'Vendedor alterando a elegibilidade ao desconto Pix', 'TRIGGER',
    "UPDATE APARELHO SET Elegivel_Desconto_Pix = 0 WHERE Imei = '900000000000003'");
SET @cellgo_funcionario = 901;
CALL cellgo_testar('APARELHO', 'Diretoria alterando o preço de venda (deve passar)', 'ACEITAR',
    "UPDATE APARELHO SET Preco_Venda = 1400.00 WHERE Imei = '900000000000003'");
SET @cellgo_funcionario = 904;

/* ---------- PEDIDO e ITEM_PEDIDO (RN-03, RF-07/RF-08) ---------- */
CALL cellgo_testar('ITEM_PEDIDO', 'Incluir aparelho já vendido no pedido', 'TRIGGER',
    "INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('900000000000001', 903)");
CALL cellgo_testar('ITEM_PEDIDO', 'Incluir aparelho que está em quarentena', 'TRIGGER',
    "INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('900000000000004', 903)");
CALL cellgo_testar('ITEM_PEDIDO', 'Incluir item em pedido já finalizado', 'TRIGGER',
    "INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('900000000000003', 901)");
CALL cellgo_testar('ITEM_PEDIDO', 'Alterar manualmente o preço do item', 'TRIGGER',
    "UPDATE ITEM_PEDIDO SET Preco_Unitario = 1.00 WHERE Id_Pedido = 902");
CALL cellgo_testar('ITEM_PEDIDO', 'Remover item de pedido já pago', 'TRIGGER',
    "DELETE FROM ITEM_PEDIDO WHERE Id_Pedido = 904");
CALL cellgo_testar('ITEM_PEDIDO', 'Incluir aparelho disponível em pedido aberto (deve passar)', 'ACEITAR',
    "INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido) VALUES ('900000000000003', 903)");

CALL cellgo_testar('PEDIDO', 'Novo pedido já com status Pago', 'TRIGGER',
    "INSERT INTO PEDIDO (Cpf_Cnpj, Status_Pedido, Forma_Pagamento, Numero_Parcelas) VALUES ('90000000091', 'Pago', 'Pix', 1)");
CALL cellgo_testar('PEDIDO', 'Enviar para pagamento um pedido sem aparelhos', 'TRIGGER',
    "UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 903");
CALL cellgo_testar('PEDIDO', 'Marcar como Pago sem pagamento aprovado', 'TRIGGER',
    "UPDATE PEDIDO SET Status_Pedido = 'Pago' WHERE Id_Pedido = 902");
CALL cellgo_testar('PEDIDO', 'Finalizar pedido sem a entrega concluída', 'TRIGGER',
    "UPDATE PEDIDO SET Status_Pedido = 'Finalizado' WHERE Id_Pedido = 904");
CALL cellgo_testar('PEDIDO', 'Pular etapas: Aberto → Finalizado', 'TRIGGER',
    "UPDATE PEDIDO SET Status_Pedido = 'Finalizado' WHERE Id_Pedido = 903");
CALL cellgo_testar('PEDIDO', 'Alterar o valor final depois do pagamento', 'TRIGGER',
    "UPDATE PEDIDO SET Valor_Final = 10.00 WHERE Id_Pedido = 904");
CALL cellgo_testar('PEDIDO', 'Trocar a forma de pagamento depois do pagamento', 'TRIGGER',
    "UPDATE PEDIDO SET Forma_Pagamento = 'Pix' WHERE Id_Pedido = 904");
CALL cellgo_testar('PEDIDO', 'Cancelar pedido pago sem um cancelamento concluído', 'TRIGGER',
    "UPDATE PEDIDO SET Status_Pedido = 'Cancelado' WHERE Id_Pedido = 904");
CALL cellgo_testar('PEDIDO', 'Excluir um pedido', 'TRIGGER',
    "DELETE FROM PEDIDO WHERE Id_Pedido = 903");
CALL cellgo_testar('PEDIDO', 'Cancelar pedido ainda aberto (deve passar)', 'ACEITAR',
    "UPDATE PEDIDO SET Status_Pedido = 'Cancelado' WHERE Id_Pedido = 903");

/* ---------- PAGAMENTO ---------- */
CALL cellgo_testar('PAGAMENTO', 'Cobrança de pedido que ainda está aberto', 'TRIGGER',
    "INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (903, 100.00)");
CALL cellgo_testar('PAGAMENTO', 'Cobrança com valor diferente do valor final do pedido', 'TRIGGER',
    "INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (902, 1.00)");
CALL cellgo_testar('PAGAMENTO', 'Pagamento registrado já como Estornado', 'TRIGGER',
    "INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Data_Confirmacao, Valor, Status)
     VALUES (902, 'TX-X1', NOW(), 2000.00, 'Estornado')");
CALL cellgo_testar('PAGAMENTO', 'Segunda cobrança Pendente para o mesmo pedido', 'TRIGGER',
    "INSERT INTO PAGAMENTO (Id_Pedido, Valor) VALUES (902, 2000.00)");
CALL cellgo_testar('PAGAMENTO', 'Aprovar pagamento com aparelho que saiu do estoque', 'TRIGGER',
    "INSERT INTO PAGAMENTO (Id_Pedido, Codigo_Transacao, Data_Confirmacao, Valor, Status)
     VALUES (905, 'TX-X2', NOW(), 900.00, 'Aprovado')");
CALL cellgo_testar('PAGAMENTO', 'Mudança proibida: Pendente → Estornado', 'TRIGGER',
    "UPDATE PAGAMENTO SET Status = 'Estornado' WHERE Id_Pagamento = 902");
CALL cellgo_testar('PAGAMENTO', 'Estornar pagamento sem um estorno processado', 'TRIGGER',
    "UPDATE PAGAMENTO SET Status = 'Estornado' WHERE Id_Pagamento = 901");
CALL cellgo_testar('PAGAMENTO', 'Alterar o valor de um pagamento', 'TRIGGER',
    "UPDATE PAGAMENTO SET Valor = 1.00 WHERE Id_Pagamento = 901");

/* ---------- CANCELAMENTO (RN-13) ---------- */
CALL cellgo_testar('CANCELAMENTO', 'Cancelar pedido que ainda está aberto (pelo fluxo de cancelamento)', 'TRIGGER',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Motivo) VALUES (903, 'Teste')");
CALL cellgo_testar('CANCELAMENTO', 'Cancelamento pedido depois de 7 dias da compra', 'TRIGGER',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Data_Solicitacao, Motivo) VALUES (904, DATE_ADD(NOW(), INTERVAL 8 DAY), 'Teste')");
CALL cellgo_testar('CANCELAMENTO', 'Cancelar pedido cujo aparelho já foi enviado', 'TRIGGER',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Motivo) VALUES (904, 'Teste')");
CALL cellgo_testar('CANCELAMENTO', 'Solicitação anterior à data do pedido', 'TRIGGER',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Data_Solicitacao, Motivo) VALUES (902, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Teste')");
CALL cellgo_testar('CANCELAMENTO', 'Cancelamento que já começa Recusado', 'TRIGGER',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Motivo, Status) VALUES (902, 'Teste', 'Recusado')");
CALL cellgo_testar('CANCELAMENTO', 'Cancelar pedido aguardando pagamento (deve passar)', 'ACEITAR',
    "INSERT INTO CANCELAMENTO (Id_Pedido, Motivo, Status) VALUES (902, 'Cliente desistiu', 'Concluído')");

/* ---------- POS_VENDA (RN-14 a RN-17) ---------- */
CALL cellgo_testar('POS_VENDA', 'Solicitação de pós-venda para pedido não pago', 'TRIGGER',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Descricao) VALUES ('900000000000002', 902, 'Defeito', 'Teste')");
CALL cellgo_testar('POS_VENDA', 'Arrependimento depois de 7 dias do recebimento', 'TRIGGER',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Data_Abertura, Descricao)
     VALUES ('900000000000001', 901, 'Arrependimento', DATE_ADD(NOW(), INTERVAL 8 DAY), 'Teste')");
CALL cellgo_testar('POS_VENDA', 'Arrependimento antes de o aparelho ser entregue', 'TRIGGER',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Descricao) VALUES ('900000000000009', 904, 'Arrependimento', 'Teste')");
CALL cellgo_testar('POS_VENDA', 'Defeito depois dos 30 dias da garantia da loja', 'TRIGGER',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Data_Abertura, Descricao)
     VALUES ('900000000000001', 901, 'Defeito', DATE_ADD(NOW(), INTERVAL 31 DAY), 'Teste')");
CALL cellgo_testar('POS_VENDA', 'Garantia depois do fim da garantia do fabricante', 'TRIGGER',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Data_Abertura, Descricao)
     VALUES ('900000000000001', 901, 'Garantia', DATE_ADD(NOW(), INTERVAL 400 DAY), 'Teste')");
CALL cellgo_testar('POS_VENDA', 'Segunda solicitação aberta para o mesmo aparelho', 'TRIGGER',
    "INSERT INTO POS_VENDA (Imei, Id_Pedido, Tipo_Solicitacao, Descricao) VALUES ('900000000000001', 901, 'Garantia', 'Teste')");

/* ---------- AVALIACAO_DANO (RN-18) ---------- */
CALL cellgo_testar('AVALIACAO_DANO', 'Avaliação de dano feita por vendedor', 'TRIGGER',
    "INSERT INTO AVALIACAO_DANO (Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
     VALUES (901, 904, 'Defeito de fabricação', 'Teste', 1, 'Em manutenção', CURDATE())");
CALL cellgo_testar('AVALIACAO_DANO', 'Avaliação anterior à abertura da solicitação', 'TRIGGER',
    "INSERT INTO AVALIACAO_DANO (Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao)
     VALUES (901, 903, 'Defeito de fabricação', 'Teste', 1, 'Em manutenção', DATE_SUB(CURDATE(), INTERVAL 1 DAY))");

/* ---------- TROCA e DEVOLUCAO (RN-14/RN-15/RN-16) ---------- */
CALL cellgo_testar('TROCA', 'Reposição com aparelho que não está disponível', 'TRIGGER',
    "INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca) VALUES (901, '900000000000004', CURDATE())");
CALL cellgo_testar('TROCA', 'Reposição de outro modelo e de valor menor', 'TRIGGER',
    "INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca) VALUES (901, '900000000000013', CURDATE())");
CALL cellgo_testar('TROCA', 'Reposição com o próprio aparelho trocado', 'TRIGGER',
    "INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca) VALUES (901, '900000000000001', CURDATE())");
CALL cellgo_testar('TROCA', 'Troca anterior à abertura da solicitação', 'TRIGGER',
    "INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca) VALUES (901, '900000000000002', DATE_SUB(CURDATE(), INTERVAL 1 DAY))");
CALL cellgo_testar('TROCA', 'Troca que já começa Cancelada', 'TRIGGER',
    "INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca, Status) VALUES (901, '900000000000002', CURDATE(), 'Cancelada')");
CALL cellgo_testar('TROCA', 'Troca por aparelho equivalente disponível (deve passar)', 'ACEITAR',
    "INSERT INTO TROCA (Id_PosVenda, Imei_Reposicao, Data_Troca) VALUES (901, '900000000000002', CURDATE())");
CALL cellgo_testar('DEVOLUCAO', 'Devolução por defeito havendo aparelho equivalente para troca', 'TRIGGER',
    "INSERT INTO DEVOLUCAO (Id_PosVenda, Motivo) VALUES (901, 'Teste')");
CALL cellgo_testar('DEVOLUCAO', 'Devolução anterior à abertura da solicitação', 'TRIGGER',
    "INSERT INTO DEVOLUCAO (Id_PosVenda, Data_Devolucao, Motivo) VALUES (901, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Teste')");

/* ---------- NOTA_FISCAL e ITEM_NOTA_FISCAL (RN-20) ---------- */
CALL cellgo_testar('NOTA_FISCAL', 'Nota de venda para pedido ainda não pago', 'TRIGGER',
    "INSERT INTO NOTA_FISCAL (Id_Pedido, Tipo_Nota, Natureza) VALUES (902, 'Venda', 'Venda de mercadoria')");
CALL cellgo_testar('NOTA_FISCAL', 'Segunda nota de venda ativa para o mesmo pedido', 'TRIGGER',
    "INSERT INTO NOTA_FISCAL (Id_Pedido, Tipo_Nota, Natureza) VALUES (901, 'Venda', 'Venda de mercadoria')");
CALL cellgo_testar('NOTA_FISCAL', 'Nota registrada já como Cancelada', 'TRIGGER',
    "INSERT INTO NOTA_FISCAL (Id_Pedido, Tipo_Nota, Natureza, Status) VALUES (906, 'Venda', 'Venda de mercadoria', 'Cancelada')");
CALL cellgo_testar('NOTA_FISCAL', 'Nota de devolução referenciando a nota de outro pedido', 'TRIGGER',
    "INSERT INTO NOTA_FISCAL (Id_PosVenda, Id_Nota_Referencia, Tipo_Nota, Natureza) VALUES (901, 902, 'Entrada (Devolução)', 'Devolução de venda')");
CALL cellgo_testar('NOTA_FISCAL', 'Nota de reposição sem troca registrada', 'TRIGGER',
    "INSERT INTO NOTA_FISCAL (Id_PosVenda, Id_Nota_Referencia, Tipo_Nota, Natureza) VALUES (901, 901, 'Saída (Reposição)', 'Remessa em troca')");
CALL cellgo_testar('NOTA_FISCAL', 'Cancelar nota de venda depois de 24 horas da emissão', 'TRIGGER',
    "UPDATE NOTA_FISCAL SET Status = 'Cancelada' WHERE Id_Nota = 901");
CALL cellgo_testar('NOTA_FISCAL', 'Alterar o número de uma nota já emitida', 'TRIGGER',
    "UPDATE NOTA_FISCAL SET Numero_Nota = 900099 WHERE Id_Nota = 901");
CALL cellgo_testar('NOTA_FISCAL', 'Excluir uma nota fiscal', 'TRIGGER',
    "DELETE FROM NOTA_FISCAL WHERE Id_Nota = 902");
CALL cellgo_testar('ITEM_NOTA_FISCAL', 'Incluir item em nota já emitida', 'TRIGGER',
    "INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES ('900000000000002', 901, 100.00)");
CALL cellgo_testar('ITEM_NOTA_FISCAL', 'Incluir na nota um aparelho que não é do pedido', 'TRIGGER',
    "INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES ('900000000000002', 902, 100.00)");
CALL cellgo_testar('ITEM_NOTA_FISCAL', 'Incluir na nota o aparelho do pedido (deve passar)', 'ACEITAR',
    "INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES ('900000000000009', 902, 1000.00)");

/* ---------- ESTORNO (RN-19) ---------- */
CALL cellgo_testar('ESTORNO', 'Estorno maior que o valor pago', 'TRIGGER',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor) VALUES (903, 901, 9999.00)");
CALL cellgo_testar('ESTORNO', 'Estorno de pagamento que não foi aprovado', 'TRIGGER',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor) VALUES (902, 901, 100.00)");
CALL cellgo_testar('ESTORNO', 'Estorno do pagamento de outro pedido', 'TRIGGER',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor) VALUES (901, 901, 100.00)");
CALL cellgo_testar('ESTORNO', 'Estorno do pedido cancelado pelo valor pago (deve passar)', 'ACEITAR',
    "INSERT INTO ESTORNO (Id_Pagamento, Codigo_Cancelamento, Valor) VALUES (903, 901, 760.00)");

/* ---------- ENTREGA (RN-11/RN-12) ---------- */
CALL cellgo_testar('ENTREGA', 'Entrega de pedido que não está pago', 'TRIGGER',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BRTESTEX1', 902, 'Transportadora Teste')");
CALL cellgo_testar('ENTREGA', 'Entrega de pedido cancelado', 'TRIGGER',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BRTESTEX2', 906, 'Transportadora Teste')");
CALL cellgo_testar('ENTREGA', 'Segunda entrega de venda para o mesmo pedido', 'TRIGGER',
    "INSERT INTO ENTREGA (Codigo_Rastreio, Id_Pedido, Transportadora) VALUES ('BRTESTEX3', 904, 'Transportadora Teste')");
CALL cellgo_testar('ENTREGA', 'Voltar o status: Em transporte → Aguardando envio', 'TRIGGER',
    "UPDATE ENTREGA SET Status_Entrega = 'Aguardando envio', Data_Despacho = NULL WHERE Codigo_Rastreio = 'BRTESTE904'");
CALL cellgo_testar('ENTREGA', 'Alterar o código de rastreio', 'TRIGGER',
    "UPDATE ENTREGA SET Codigo_Rastreio = 'BRTESTEX4' WHERE Codigo_Rastreio = 'BRTESTE904'");

/* ---------- REQUISICAO_COMPRA (RN-06) ---------- */
CALL cellgo_testar('REQUISICAO_COMPRA', 'Requisição que já começa Aprovada', 'TRIGGER',
    "INSERT INTO REQUISICAO_COMPRA (Codigo_Funcionario, Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Parecer_Financeiro, Data_Abertura, Data_Decisao, Status, Qtd_Sugerida)
     VALUES (901, 902, 0, 1, 'Ok', CURDATE(), CURDATE(), 'Aprovada', 2)");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Segunda requisição em aberto para a mesma especificação', 'TRIGGER',
    "INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Data_Abertura, Qtd_Sugerida)
     VALUES (903, 0, 5, CURDATE(), 10)");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Pular a análise financeira (direto para Aprovada)', 'TRIGGER',
    "UPDATE REQUISICAO_COMPRA SET Status = 'Aprovada', Parecer_Financeiro = 'Ok', Codigo_Funcionario = 901, Data_Decisao = CURDATE()
     WHERE Id_Requisicao = 901");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Requisição aprovada por quem não é da Diretoria', 'TRIGGER',
    "UPDATE REQUISICAO_COMPRA SET Status = 'Aprovada', Codigo_Funcionario = 904, Data_Decisao = CURDATE() WHERE Id_Requisicao = 902");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Alterar a quantidade em estoque registrada na abertura', 'TRIGGER',
    "UPDATE REQUISICAO_COMPRA SET Qtd_Atual_Estoque = 3 WHERE Id_Requisicao = 901");
CALL cellgo_testar('REQUISICAO_COMPRA', 'Requisição aprovada pela Diretoria (deve passar)', 'ACEITAR',
    "UPDATE REQUISICAO_COMPRA SET Status = 'Aprovada', Codigo_Funcionario = 901, Data_Decisao = CURDATE() WHERE Id_Requisicao = 902");

/* ---------- MOVIMENTACAO e AUDITORIA (RN-23 / RNF-07) ---------- */
CALL cellgo_testar('MOVIMENTACAO', 'Movimentação com status diferente do status atual do aparelho', 'TRIGGER',
    "INSERT INTO MOVIMENTACAO (Codigo_Funcionario, Imei, Tipo_Movimento, Status_Anterior, Status_Novo)
     VALUES (902, '900000000000001', 'Retorno ao estoque', 'Vendido', 'Disponível')");
CALL cellgo_testar('MOVIMENTACAO', 'Alterar o histórico de movimentações', 'TRIGGER',
    "UPDATE MOVIMENTACAO SET Data_Hora = NOW() WHERE Imei = '900000000000001'");
CALL cellgo_testar('MOVIMENTACAO', 'Excluir o histórico de movimentações', 'TRIGGER',
    "DELETE FROM MOVIMENTACAO WHERE Imei = '900000000000001'");
CALL cellgo_testar('AUDITORIA', 'Auditoria com autorizador que não é da Diretoria', 'TRIGGER',
    "INSERT INTO AUDITORIA (Codigo_Funcionario, Codigo_Autorizador, Acao, Tabela_Afetada, Registro_Id, Valor_Novo)
     VALUES (904, 904, 'Teste', 'APARELHO', '900000000000003', JSON_OBJECT('Preco_Venda', 1))");
CALL cellgo_testar('AUDITORIA', 'Alterar um registro de auditoria', 'TRIGGER',
    "UPDATE AUDITORIA SET Descricao = 'alterado' WHERE Tabela_Afetada = 'PAGAMENTO'");
CALL cellgo_testar('AUDITORIA', 'Excluir um registro de auditoria', 'TRIGGER',
    "DELETE FROM AUDITORIA WHERE Tabela_Afetada = 'PAGAMENTO'");


/* =====================================================================
   PARTE 3 — VALORES CALCULADOS AUTOMATICAMENTE PELAS TRIGGERS
   ===================================================================== */

INSERT INTO resultado_teste (Grupo, Teste, Esperado, Barrado_Por, Resultado, Mensagem)
SELECT 'CÁLCULO', t.Teste, 'CONFERIR', '-', IF(t.Certo, 'OK', 'FALHOU'), t.Detalhe
  FROM (
    SELECT 'Desconto Pix de 5% no pedido de R$ 1.000,00 (valor final R$ 950,00)' AS Teste,
           (Percentual_Desconto_Pix = 5 AND Valor_Desconto = 50.00 AND Valor_Final = 950.00) AS Certo,
           CONCAT('Percentual ', Percentual_Desconto_Pix, '%, desconto ', Valor_Desconto, ', final ', Valor_Final) AS Detalhe
      FROM PEDIDO WHERE Id_Pedido = 901
    UNION ALL
    SELECT 'Pedido sem desconto quando o aparelho não é elegível ao Pix',
           (Valor_Desconto IS NULL AND Valor_Final = Valor_Produtos),
           CONCAT('Produtos ', Valor_Produtos, ', final ', Valor_Final)
      FROM PEDIDO WHERE Id_Pedido = 904
    UNION ALL
    SELECT 'Pedido passa para Finalizado quando a entrega é concluída',
           (Status_Pedido = 'Finalizado'), CONCAT('Status: ', Status_Pedido)
      FROM PEDIDO WHERE Id_Pedido = 901
    UNION ALL
    SELECT 'Aparelho passa para Vendido quando o pagamento é aprovado',
           (Status = 'Vendido'), CONCAT('Status: ', Status)
      FROM APARELHO WHERE Imei = '900000000000001'
    UNION ALL
    SELECT 'Garantia da loja de 30 dias e do fabricante de 1 ano (aparelho Novo)',
           (Data_Fim_Garantia_Loja = DATE_ADD(Data_Inicio_Garantia, INTERVAL 30 DAY)
            AND Data_Fim_Garantia_Fabricante = DATE_ADD(Data_Inicio_Garantia, INTERVAL 1 YEAR)),
           CONCAT('Início ', Data_Inicio_Garantia, ', loja até ', Data_Fim_Garantia_Loja,
                  ', fabricante até ', Data_Fim_Garantia_Fabricante)
      FROM ITEM_PEDIDO WHERE Imei = '900000000000001' AND Id_Pedido = 901
    UNION ALL
    SELECT 'Seminovo de pessoa física entra em quarentena de 15 dias',
           (Status = 'Em quarentena' AND Data_Fim_Quarentena = DATE_ADD(Data_Entrada, INTERVAL 15 DAY)),
           CONCAT('Status ', Status, ', entrada ', Data_Entrada, ', fim ', Data_Fim_Quarentena)
      FROM APARELHO WHERE Imei = '900000000000005'
    UNION ALL
    SELECT 'Seminovo de pessoa jurídica entra direto como Disponível',
           (Status = 'Disponível' AND Data_Fim_Quarentena IS NULL), CONCAT('Status: ', Status)
      FROM APARELHO WHERE Imei = '900000000000003'
    UNION ALL
    SELECT 'Valor total da aquisição = soma do custo dos aparelhos',
           (aq.Valor_Total = (SELECT SUM(a.Custo_Aquisicao)
                                FROM APARELHO a
                                JOIN AVALIACAO_ENTRADA e ON e.Id_Avaliacao_Entrada = a.Id_Avaliacao_Entrada
                               WHERE e.Id_Aquisicao = aq.Id_Aquisicao)),
           CONCAT('Valor total: ', aq.Valor_Total)
      FROM AQUISICAO aq WHERE aq.Id_Aquisicao = 901
    UNION ALL
    SELECT 'Cancelamento concluído devolve o aparelho e cancela o pedido',
           (pe.Status_Pedido = 'Cancelado' AND a.Status = 'Disponível' AND a.Data_Disponivel = CURDATE()),
           CONCAT('Pedido ', pe.Status_Pedido, ', aparelho ', a.Status, ' desde ', a.Data_Disponivel)
      FROM PEDIDO pe JOIN APARELHO a ON a.Imei = '900000000000014' WHERE pe.Id_Pedido = 906
    UNION ALL
    SELECT 'Histórico do aparelho registra Entrada e Venda',
           (SUM(Tipo_Movimento = 'Entrada') = 1 AND SUM(Tipo_Movimento = 'Venda') = 1),
           CONCAT(COUNT(*), ' movimentações registradas')
      FROM MOVIMENTACAO WHERE Imei = '900000000000001'
    UNION ALL
    SELECT 'Auditoria registra os pagamentos',
           (COUNT(*) >= 1), CONCAT(COUNT(*), ' registros de pagamento na auditoria')
      FROM AUDITORIA WHERE Tabela_Afetada = 'PAGAMENTO' AND Registro_Id = '901'
  ) t;


/* =====================================================================
   PARTE 4 — RELATÓRIO
   ===================================================================== */

/* Resumo: o esperado é que tudo esteja em OK */
SELECT Resultado, COUNT(*) AS Quantidade
  FROM resultado_teste
 GROUP BY Resultado
 ORDER BY FIELD(Resultado, 'FALHOU', 'ERRO NO TESTE', 'ATENÇÃO', 'OK');

/* Detalhe de cada teste, com a mensagem devolvida pelo banco */
SELECT Ordem, Grupo, Teste, Esperado, Barrado_Por, Resultado, Mensagem
  FROM resultado_teste
 ORDER BY Ordem;

SET @cellgo_funcionario = NULL;
DROP PROCEDURE IF EXISTS cellgo_testar;
