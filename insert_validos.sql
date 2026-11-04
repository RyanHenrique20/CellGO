/* =====================================================================
   CellGO — Carga de dados de teste (INSERTs)
   SGBD: MySQL 8
   Execute depois de tabelas.sql e triggers.sql.

   COMO ESTE SCRIPT FUNCIONA
   As triggers do banco calculam e controlam parte dos dados. Por isso os
   INSERTs seguem o fluxo de negócio, na ordem em que a operação real
   aconteceria, e alguns registros mudam de situação por UPDATE:
   - Valor_Total (AQUISICAO) e Valor_Produtos, desconto Pix, Valor_Final
     (PEDIDO) são calculados pelas triggers a partir dos itens;
   - APARELHO entra Disponível ou Em quarentena (seminovo de pessoa física);
     os demais status (Vendido, Em avaliação, Em manutenção...) vêm de
     UPDATE ou das triggers de pagamento, troca, devolução e cancelamento;
   - MOVIMENTACAO é preenchida automaticamente pelas triggers de APARELHO
     (entrada, venda, devolução, manutenção, retorno ao estoque). Não há
     INSERT manual porque a trigger exige que o status novo seja o status
     atual do aparelho, e um INSERT manual duplicaria o histórico;
   - AUDITORIA recebe registros automáticos das triggers, além dos
     registros manuais da seção final;
   - @cellgo_funcionario informa às triggers quem executa cada operação.
   ===================================================================== */

SET NAMES utf8mb4;
USE cellgo;

SET @cellgo_funcionario = NULL;


/* =====================================================================
   1. PERFIL_ACESSO
   ===================================================================== */
INSERT INTO PERFIL_ACESSO (Id_Perfil, Nome_Perfil, Nivel_Acesso) VALUES
(1, 'Vendas e Atendimento',      1),
(2, 'Estoque e Logística',       1),
(3, 'Assistência Técnica',       1),
(4, 'Financeiro/Administrativo', 1),
(5, 'Diretoria',                 2);


/* =====================================================================
   2. FUNCIONARIO
   Cada perfil exigido pelas triggers tem ao menos um funcionário ativo:
   Estoque e Logística (aquisição), Assistência Técnica (avaliações),
   Diretoria (autorizador da auditoria e decisão de requisição).
   ===================================================================== */
INSERT INTO FUNCIONARIO (Codigo_Funcionario, Nome, Cargo, Login, Id_Perfil, Ativo) VALUES
(1, 'Carlos Eduardo Silva',    'Diretor',                   'carlos.silva',    5, 1),
(2, 'Mariana Souza Lima',      'Analista de Estoque',       'mariana.lima',    2, 1),
(3, 'Roberto Alves Pereira',   'Técnico de Assistência',    'roberto.pereira', 3, 1),
(4, 'Fernanda Oliveira Costa', 'Assistente Administrativo', 'fernanda.costa',  4, 0),
(5, 'João Pedro Santos',       'Supervisor de Estoque',     'joao.santos',     2, 1),
(6, 'Paula Regina Almeida',    'Atendente de Vendas',       'paula.almeida',   1, 1),
(7, 'Marcos Vinícius Rocha',   'Analista Financeiro',       'marcos.rocha',    4, 1);


/* =====================================================================
   3. FORNECEDOR
   PF: RG ou CNH obrigatório. PJ: sem documento com foto.
   ===================================================================== */
INSERT INTO FORNECEDOR (Cpf_Cnpj_Fornecedor, Tipo_Pessoa, Nome, Tipo_Documento, Numero_Documento, Telefone_Contato) VALUES
('12345678909',    'PF', 'José Antônio Ferreira',             'RG',  '123456789',   '11987654321'),
('98765432100',    'PF', 'Luciana Martins Rocha',             'CNH', '04567891230', '11976543210'),
('11222333000181', 'PJ', 'Tech Peças Eletrônicas Ltda',       NULL,  NULL,          '1133445566'),
('44555666000172', 'PJ', 'Distribuidora Celular Brasil S.A.', NULL,  NULL,          '1144556677'),
('55667788000193', 'PJ', 'Acessórios Mobile Comércio Ltda',   NULL,  NULL,          '11955443322');


/* =====================================================================
   4. MODELO
   ===================================================================== */
INSERT INTO MODELO (Id_Modelo, Nome_Modelo, Marca) VALUES
(1, 'Galaxy S23',    'Samsung'),
(2, 'iPhone 14',     'Apple'),
(3, 'Moto G73',      'Motorola'),
(4, 'Redmi Note 12', 'Xiaomi'),
(5, 'Edge 40',       'Motorola');


/* =====================================================================
   5. ESPECIFICACAO_APARELHO
   ===================================================================== */
INSERT INTO ESPECIFICACAO_APARELHO (Id_Especificacao, Id_Modelo, Cor, Capacidade, Estoque_Minimo, Limite_Dias_Atencao, Limite_Dias_Critico) VALUES
(1, 1, 'Preto',  128, 5, 30, 60),
(2, 1, 'Verde',  256, 3, 30, 60),
(3, 2, 'Azul',   128, 4, 45, 90),
(4, 3, 'Cinza',  256, 6, 20, 40),
(5, 4, 'Branco', 128, 8, 25, 50);


/* =====================================================================
   6. AQUISICAO
   Registrada por funcionário de Estoque e Logística, sempre com status
   Em avaliação e Valor_Total zerado (a trigger recalcula o total).
   PF: termo de compra e venda + termo de responsabilidade aceito.
   PJ: nota fiscal do fornecedor, sem termo.
   ===================================================================== */
SET @cellgo_funcionario = 2;

INSERT INTO AQUISICAO (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra, Termo_Responsabilidade_Aceito, Valor_Total, Status) VALUES
(1, 2, '11222333000181', '2026-08-10', 'Nota fiscal do fornecedor', 'NF-000123',    NULL, 0.00, 'Em avaliação'),
(2, 5, '44555666000172', '2026-08-25', 'Nota fiscal do fornecedor', 'NF-000456',    NULL, 0.00, 'Em avaliação'),
(3, 2, '12345678909',    '2026-09-05', 'Termo de compra e venda',   'TCV-2026-001', 1,    0.00, 'Em avaliação'),
(4, 5, '98765432100',    '2026-09-18', 'Termo de compra e venda',   'TCV-2026-002', 1,    0.00, 'Em avaliação'),
(5, 2, '55667788000193', '2026-09-28', 'Nota fiscal do fornecedor', 'NF-000789',    NULL, 0.00, 'Em avaliação');


/* =====================================================================
   7. AVALIACAO_ENTRADA
   Feita por funcionário de Assistência Técnica. Aprovada: IMEI Regular,
   checklist completo, sem bloqueio de conta e com reset de fábrica.
   Recusada: motivo obrigatório e reset de fábrica vazio.
   Avaliações 4 e 5 são recusadas (não geram aparelho).
   ===================================================================== */
SET @cellgo_funcionario = 3;

INSERT INTO AVALIACAO_ENTRADA (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado, Motivo_Recusa, Data_Reconsulta_Imei, Resultado_Reconsulta_Imei) VALUES
(1,  3, 1, '356938035643809', 'CEIR/Anatel', 'Regular',         '2026-08-10 09:30:00', 1, 1, 1, 1, 1, 1, 1, 0, 1,    'Aprovado', NULL, NULL, NULL),
(2,  3, 2, '490154203237518', 'CEIR/Anatel', 'Regular',         '2026-08-25 10:15:00', 1, 1, 1, 1, 1, 1, 1, 0, 1,    'Aprovado', NULL, NULL, NULL),
(3,  3, 3, '352099001761481', 'GSMA',        'Regular',         '2026-09-05 11:00:00', 1, 1, 1, 1, 1, 1, 1, 0, 1,    'Aprovado', NULL, NULL, NULL),
(4,  3, 4, '867530902314556', 'CEIR/Anatel', 'Bloqueado',       '2026-09-18 15:20:00', 1, 1, 1, 1, 1, 1, 1, 1, NULL, 'Recusado', 'IMEI com bloqueio ativo e conta do proprietário anterior vinculada ao aparelho.', NULL, NULL),
(5,  3, 5, '358240051111110', 'GSMA',        'Roubado/Furtado', '2026-09-28 16:45:00', 1, 1, 1, 1, 1, 1, 1, 0, NULL, 'Recusado', 'IMEI consta como roubado/furtado na base consultada.', NULL, NULL),
(6,  3, 1, '351756051523999', 'CEIR/Anatel', 'Regular',         '2026-08-10 09:45:00', 1, 1, 1, 1, 1, 1, 1, 0, 1,    'Aprovado', NULL, NULL, NULL),
(7,  3, 2, '353879234252633', 'CEIR/Anatel', 'Regular',         '2026-08-25 10:30:00', 1, 1, 1, 1, 1, 1, 1, 0, 1,    'Aprovado', NULL, NULL, NULL),
(8,  3, 1, '678901234567890', 'CEIR/Anatel', 'Regular',         '2026-08-10 10:00:00', 1, 1, 1, 1, 1, 1, 1, 0, 1,    'Aprovado', NULL, NULL, NULL),
(9,  3, 2, '789012345678901', 'GSMA',        'Regular',         '2026-08-25 10:45:00', 1, 1, 1, 1, 1, 1, 1, 0, 1,    'Aprovado', NULL, NULL, NULL),
(10, 3, 2, '890123456789012', 'GSMA',        'Regular',         '2026-08-25 11:00:00', 1, 1, 1, 1, 1, 1, 1, 0, 1,    'Aprovado', NULL, NULL, NULL);


/* =====================================================================
   8. APARELHO
   Só entra com avaliação de entrada Aprovada e o mesmo IMEI. Seminovo de
   fornecedor PF (aparelho 352099001761481) entra Em quarentena por 15
   dias; os demais entram Disponíveis. A trigger registra a entrada em
   MOVIMENTACAO e recalcula o Valor_Total da aquisição.
   ===================================================================== */
INSERT INTO APARELHO (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada, Data_Disponivel, Data_Fim_Quarentena, Elegivel_Desconto_Pix) VALUES
('356938035643809', 1, 1,  3, 'Seminovo', 3999.00, 2800.00, 'Disponível',    '2026-08-10', '2026-08-10', NULL,         TRUE),
('490154203237518', 3, 2,  3, 'Seminovo', 5499.90, 4200.00, 'Disponível',    '2026-08-25', '2026-08-25', NULL,         TRUE),
('352099001761481', 4, 3,  3, 'Seminovo', 1899.00, 1300.00, 'Em quarentena', '2026-09-05', NULL,         '2026-09-20', TRUE),
('351756051523999', 2, 6,  3, 'Seminovo', 2750.00, 2000.00, 'Disponível',    '2026-08-10', '2026-08-10', NULL,         TRUE),
('353879234252633', 5, 7,  3, 'Seminovo', 3200.00, 2400.00, 'Disponível',    '2026-08-25', '2026-08-25', NULL,         TRUE),
('678901234567890', 1, 8,  3, 'Seminovo', 3999.00, 2800.00, 'Disponível',    '2026-08-10', '2026-08-10', NULL,         TRUE),
('789012345678901', 4, 9,  3, 'Seminovo', 1899.00, 1300.00, 'Disponível',    '2026-08-25', '2026-08-25', NULL,         TRUE),
('890123456789012', 3, 10, 3, 'Seminovo', 5499.90, 4200.00, 'Disponível',    '2026-08-25', '2026-08-25', NULL,         TRUE);

/* Fechamento das aquisições (o Valor_Total é recalculado pela trigger):
   com aparelho aprovado = Concluída; sem nenhum aparelho aprovado = Recusada */
UPDATE AQUISICAO SET Status = 'Concluída' WHERE Id_Aquisicao IN (1, 2, 3);
UPDATE AQUISICAO SET Status = 'Recusada'  WHERE Id_Aquisicao IN (4, 5);

/* Fim da quarentena do aparelho 352099001761481: nova consulta do IMEI
   (Regular) depois de 15 dias e então liberação para venda */
UPDATE AVALIACAO_ENTRADA
   SET Data_Reconsulta_Imei = '2026-09-21 10:00:00',
       Resultado_Reconsulta_Imei = 'Regular'
 WHERE Id_Avaliacao_Entrada = 3;

SET @cellgo_funcionario = 2;
UPDATE APARELHO SET Status = 'Disponível' WHERE Imei = '352099001761481';
/* a trigger usa a data de hoje; aqui se registra a data real da liberação */
UPDATE APARELHO SET Data_Disponivel = '2026-09-21' WHERE Imei = '352099001761481';


/* =====================================================================
   9. REQUISICAO_COMPRA
   Abertas antes das vendas, para a trigger de APARELHO não abrir
   requisições duplicadas quando o estoque ficar abaixo do mínimo.
   Em aberto: sem decisor, sem data de decisão e sem motivo de recusa.
   A análise financeira e a decisão da Diretoria acontecem na última
   seção (depois de todas as movimentações de estoque).
   ===================================================================== */
INSERT INTO REQUISICAO_COMPRA (Id_Requisicao, Codigo_Funcionario, Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Parecer_Financeiro, Data_Abertura, Data_Decisao, Motivo_Recusa, Status, Qtd_Sugerida) VALUES
(1, NULL, 1, 3, 5, NULL, '2026-10-26', NULL, NULL, 'Aguardando Análise Financeira', 10),
(2, NULL, 2, 1, 3, NULL, '2026-10-27', NULL, NULL, 'Aguardando Análise Financeira', 6),
(3, NULL, 3, 2, 4, NULL, '2026-10-20', NULL, NULL, 'Aguardando Análise Financeira', 8),
(4, NULL, 4, 5, 6, NULL, '2026-10-21', NULL, NULL, 'Aguardando Análise Financeira', 4),
(5, NULL, 5, 4, 8, NULL, '2026-10-30', NULL, NULL, 'Aguardando Análise Financeira', 12);


/* =====================================================================
   10. CLIENTE
   PF: data de nascimento obrigatória e idade mínima de 18 anos.
   PJ: sem data de nascimento.
   ===================================================================== */
INSERT INTO CLIENTE (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES
('32165498700',    'Ana Beatriz Carvalho',       'ana.carvalho@email.com',      '1990-04-15', 'PF'),
('74185296300',    'Ricardo Mendes Barbosa',     'ricardo.barbosa@email.com',   '1985-11-02', 'PF'),
('15935748600',    'Juliana Ferreira Duarte',    'juliana.duarte@email.com',    '1998-07-28', 'PF'),
('66777888000155', 'Mercado Bom Preço Ltda',     'contato@bompreco.com.br',     NULL,         'PJ'),
('77888999000166', 'Construtora Horizonte S.A.', 'financeiro@horizonte.com.br', NULL,         'PJ');


/* =====================================================================
   11. ENDERECO
   ===================================================================== */
INSERT INTO ENDERECO (Id_Endereco, Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Complemento, Tipo_Endereco) VALUES
(1, '32165498700',    'Rua das Flores',    'Centro',    'São Paulo', '01001000', '120', 'Apartamento 12', 'Residencial'),
(2, '74185296300',    'Rua das Palmeiras', 'Tatuapé',   'São Paulo', '03065000', '250', NULL,             'Residencial'),
(3, '15935748600',    'Avenida Central',   'Centro',    'Guarulhos', '07010000', '85',  'Casa 2',         'Residencial'),
(4, '66777888000155', 'Rua dos Pinheiros', 'Pinheiros', 'São Paulo', '05422000', '430', 'Sala 5',         'Comercial'),
(5, '77888999000166', 'Rua do Comércio',   'Centro',    'Osasco',    '06010000', '90',  NULL,             'Comercial');


/* =====================================================================
   12. TELEFONE
   Celular: 9 dígitos começando com 9. Fixo: 8 dígitos começando de 2 a 5.
   ===================================================================== */
INSERT INTO TELEFONE (Cpf_Cnpj, DDD, Numero_Telefone) VALUES
('32165498700',    11, 987654321),
('74185296300',    11, 976543210),
('15935748600',    11, 965432109),
('66777888000155', 11, 33445566),
('77888999000166', 11, 988776655);


/* =====================================================================
   13. IMAGEM_APARELHO
   A imagem 6 é removida na última seção (registro de AUDITORIA 5).
   ===================================================================== */
INSERT INTO IMAGEM_APARELHO (Id_Imagem, Imei, URL) VALUES
(1, '356938035643809', 'https://cellgo.com.br/imagens/aparelhos/356938035643809_frente.jpg'),
(2, '356938035643809', 'https://cellgo.com.br/imagens/aparelhos/356938035643809_traseira.jpg'),
(3, '490154203237518', 'https://cellgo.com.br/imagens/aparelhos/490154203237518_frente.jpg'),
(4, '352099001761481', 'https://cellgo.com.br/imagens/aparelhos/352099001761481_frente.jpg'),
(5, '351756051523999', 'https://cellgo.com.br/imagens/aparelhos/351756051523999_frente.jpg'),
(6, '356938035643809', 'https://cellgo.com.br/imagens/aparelhos/356938035643809_lateral.jpg');


/* =====================================================================
   14. PEDIDO, ITEM_PEDIDO e PAGAMENTO
   Fluxo de cada pedido:
   1) PEDIDO nasce Aberto (as triggers zeram os valores calculados);
   2) ITEM_PEDIDO com aparelho Disponível: preço = Preco_Venda do aparelho,
      garantia da loja = início + 30 dias;
   3) UPDATE para Aguardando pagamento: a trigger calcula Valor_Produtos,
      desconto Pix (até R$ 1.000 = 5%; até R$ 2.500 = 7%; acima = 10%) e
      Valor_Final = Valor_Produtos - Valor_Desconto + Valor_Taxas;
   4) PAGAMENTO com o Valor_Final; ao aprovar, o pedido vira Pago, os
      aparelhos viram Vendidos e a garantia começa na data da confirmação.
   Pix: sem taxas (Valor_Taxas vazio). Cartão: taxa só quando há juros.
   ===================================================================== */
SET @cellgo_funcionario = 6;

/* ---------- Pedido 1: Pix, 1 aparelho (10% de desconto) ---------- */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Data_Pedido, Status_Pedido, Forma_Pagamento, Numero_Parcelas, Valor_Taxas) VALUES
(1, '32165498700', '2026-10-05 10:15:00', 'Aberto', 'Pix', 1, NULL);

INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido, Preco_Unitario, Data_Inicio_Garantia, Data_Fim_Garantia_Loja, Data_Fim_Garantia_Fabricante) VALUES
('356938035643809', 1, 3999.00, '2026-10-05', '2026-11-04', '2027-10-05');

UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 1;

INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status, Comprovante) VALUES
(1, 1, 'TESTE-TRANSACAO-001', '2026-10-05 10:20:00', NULL,                  3599.10, 'Recusado', NULL),
(2, 1, 'TESTE-TRANSACAO-002', '2026-10-05 10:25:00', '2026-10-05 10:26:00', 3599.10, 'Aprovado', 'comprovantes/pagamento-002.pdf');

/* ---------- Pedido 2: cartão em 10x com juros, 2 aparelhos ---------- */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Data_Pedido, Status_Pedido, Forma_Pagamento, Numero_Parcelas, Valor_Taxas) VALUES
(2, '66777888000155', '2026-10-10 14:30:00', 'Aberto', 'Cartão de crédito', 10, 369.95);

INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido, Preco_Unitario, Data_Inicio_Garantia, Data_Fim_Garantia_Loja, Data_Fim_Garantia_Fabricante) VALUES
('490154203237518', 2, 5499.90, '2026-10-10', '2026-11-09', '2027-10-10'),
('352099001761481', 2, 1899.00, '2026-10-10', '2026-11-09', NULL);

UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 2;

INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status, Comprovante) VALUES
(3, 2, 'TESTE-TRANSACAO-003', '2026-10-10 14:35:00', NULL,                  7768.85, 'Expirado', NULL),
(4, 2, 'TESTE-TRANSACAO-004', '2026-10-10 15:00:00', '2026-10-10 15:02:00', 7768.85, 'Aprovado', 'comprovantes/pagamento-004.pdf');

/* ---------- Pedido 3: Pix, 1 aparelho (10% de desconto) ---------- */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Data_Pedido, Status_Pedido, Forma_Pagamento, Numero_Parcelas, Valor_Taxas) VALUES
(3, '74185296300', '2026-10-20 09:45:00', 'Aberto', 'Pix', 1, NULL);

INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido, Preco_Unitario, Data_Inicio_Garantia, Data_Fim_Garantia_Loja, Data_Fim_Garantia_Fabricante) VALUES
('351756051523999', 3, 2750.00, '2026-10-20', '2026-11-19', '2027-10-20');

UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 3;

INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status, Comprovante) VALUES
(5, 3, 'TESTE-TRANSACAO-005', '2026-10-20 09:50:00', '2026-10-20 09:51:00', 2475.00, 'Aprovado', 'comprovantes/pagamento-005.pdf');

/* ---------- Pedido 4: cartão em 3x com juros (será cancelado) ---------- */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Data_Pedido, Status_Pedido, Forma_Pagamento, Numero_Parcelas, Valor_Taxas) VALUES
(4, '15935748600', '2026-10-25 16:20:00', 'Aberto', 'Cartão de crédito', 3, 96.00);

INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido, Preco_Unitario, Data_Inicio_Garantia, Data_Fim_Garantia_Loja, Data_Fim_Garantia_Fabricante) VALUES
('353879234252633', 4, 3200.00, '2026-10-25', '2026-11-24', '2027-10-25');

UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 4;

INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status, Comprovante) VALUES
(6, 4, 'TESTE-TRANSACAO-006', '2026-10-25 16:30:00', '2026-10-25 16:32:00', 3296.00, 'Aprovado', 'comprovantes/pagamento-006.pdf');

/* ---------- Pedido 5: Pix, 1 aparelho (7% de desconto; será devolvido) ---------- */
INSERT INTO PEDIDO (Id_Pedido, Cpf_Cnpj, Data_Pedido, Status_Pedido, Forma_Pagamento, Numero_Parcelas, Valor_Taxas) VALUES
(5, '77888999000166', '2026-10-28 09:30:00', 'Aberto', 'Pix', 1, NULL);

INSERT INTO ITEM_PEDIDO (Imei, Id_Pedido, Preco_Unitario, Data_Inicio_Garantia, Data_Fim_Garantia_Loja, Data_Fim_Garantia_Fabricante) VALUES
('789012345678901', 5, 1899.00, '2026-10-28', '2026-11-27', '2027-10-28');

UPDATE PEDIDO SET Status_Pedido = 'Aguardando pagamento' WHERE Id_Pedido = 5;

INSERT INTO PAGAMENTO (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status, Comprovante) VALUES
(7, 5, 'TESTE-TRANSACAO-007', '2026-10-28 10:00:00', '2026-10-28 10:02:00', 1766.07, 'Aprovado', 'comprovantes/pagamento-007.pdf');


/* =====================================================================
   15. NOTA_FISCAL e ITEM_NOTA_FISCAL — notas de venda
   A nota nasce Aguardando emissão (sem número, chave e data); os itens só
   entram antes da emissão; depois ela passa para Emitida.
   ===================================================================== */
SET @cellgo_funcionario = 7;

INSERT INTO NOTA_FISCAL (Id_Nota, Numero_Nota, Id_PosVenda, Id_Nota_Referencia, Codigo_Cancelamento, Id_Pedido, Chave_Acesso, Tipo_Nota, Natureza, Status, Data_Emissao) VALUES
(1, NULL, NULL, NULL, NULL, 1, NULL, 'Venda', 'Venda de mercadoria', 'Aguardando emissão', NULL),
(2, NULL, NULL, NULL, NULL, 2, NULL, 'Venda', 'Venda de mercadoria', 'Aguardando emissão', NULL),
(3, NULL, NULL, NULL, NULL, 4, NULL, 'Venda', 'Venda de mercadoria', 'Aguardando emissão', NULL),
(4, NULL, NULL, NULL, NULL, 5, NULL, 'Venda', 'Venda de mercadoria', 'Aguardando emissão', NULL);

INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES
('356938035643809', 1, 3999.00),
('490154203237518', 2, 5499.90),
('352099001761481', 2, 1899.00),
('353879234252633', 3, 3200.00),
('789012345678901', 4, 1899.00);

UPDATE NOTA_FISCAL SET Numero_Nota = 1001, Chave_Acesso = '35261012345678000190550010000010011000100019', Status = 'Emitida', Data_Emissao = '2026-10-05 15:30:00' WHERE Id_Nota = 1;
UPDATE NOTA_FISCAL SET Numero_Nota = 1002, Chave_Acesso = '35261012345678000190550010000010021000100026', Status = 'Emitida', Data_Emissao = '2026-10-10 17:00:00' WHERE Id_Nota = 2;
UPDATE NOTA_FISCAL SET Numero_Nota = 1003, Chave_Acesso = '35261012345678000190550010000010031000100033', Status = 'Emitida', Data_Emissao = '2026-10-25 17:30:00' WHERE Id_Nota = 3;
UPDATE NOTA_FISCAL SET Numero_Nota = 1004, Chave_Acesso = '35261012345678000190550010000010041000100040', Status = 'Emitida', Data_Emissao = '2026-10-28 11:00:00' WHERE Id_Nota = 4;


/* =====================================================================
   16. ENTREGA — entregas de venda
   Só para pedido Pago. Entregue: o pedido vira Finalizado (pedidos 1, 2
   e 5). Os pedidos 3 e 4 ficam Aguardando envio por enquanto.
   ===================================================================== */
SET @cellgo_funcionario = 6;

INSERT INTO ENTREGA (Codigo_Rastreio, Codigo_Troca, Id_Pedido, Transportadora, Status_Entrega, Data_Despacho, Data_Entrega, Origem_Atualizacao) VALUES
('BR123456789SP', NULL, 1, 'Correios', 'Entregue',         '2026-10-06 10:00:00', '2026-10-09 14:30:00', 'Automática'),
('BR987654321SP', NULL, 2, 'Jadlog',   'Entregue',         '2026-10-11 09:15:00', '2026-10-14 16:45:00', 'Automática'),
('LP456789123BR', NULL, 3, 'Loggi',    'Aguardando envio', NULL,                  NULL,                  'Automática'),
('JD321654987BR', NULL, 4, 'Jadlog',   'Aguardando envio', NULL,                  NULL,                  'Manual'),
('LG741852963BR', NULL, 5, 'Loggi',    'Entregue',         '2026-10-29 08:00:00', '2026-10-31 11:20:00', 'Automática');


/* =====================================================================
   17. CANCELAMENTO
   Até 7 dias da compra e só com a entrega Aguardando envio.
   - Cancelamento 1 (pedido 3): solicitado antes do envio; o pedido foi
     despachado em seguida, então a solicitação é Recusada.
   - Cancelamento 2 (pedido 4): Concluído; o pedido vira Cancelado e o
     aparelho volta a ficar Disponível.
   ===================================================================== */
INSERT INTO CANCELAMENTO (Codigo_Cancelamento, Id_Pedido, Data_Solicitacao, Motivo, Status) VALUES
(1, 3, '2026-10-22 10:00:00', 'Cliente desistiu da compra antes de receber o pedido.', 'Solicitado'),
(2, 4, '2026-10-26 11:00:00', 'Cliente realizou o pedido por engano.',                'Solicitado');

UPDATE ENTREGA
   SET Status_Entrega = 'Em transporte', Data_Despacho = '2026-10-21 11:30:00'
 WHERE Codigo_Rastreio = 'LP456789123BR';

UPDATE CANCELAMENTO SET Status = 'Recusado'  WHERE Codigo_Cancelamento = 1;
UPDATE CANCELAMENTO SET Status = 'Concluído' WHERE Codigo_Cancelamento = 2;

/* Nota de entrada do cancelamento 2 (referencia a nota de venda do pedido 4) */
SET @cellgo_funcionario = 7;

INSERT INTO NOTA_FISCAL (Id_Nota, Numero_Nota, Id_PosVenda, Id_Nota_Referencia, Codigo_Cancelamento, Id_Pedido, Chave_Acesso, Tipo_Nota, Natureza, Status, Data_Emissao) VALUES
(5, NULL, NULL, 3, 2, NULL, NULL, 'Entrada (Devolução)', 'Cancelamento de venda de mercadoria', 'Aguardando emissão', NULL);

INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES
('353879234252633', 5, 3200.00);


/* =====================================================================
   18. ESTORNO — do cancelamento 2
   O cancelamento precisa estar Concluído. Processado: o pagamento 6 passa
   para Estornado. Sem dados bancários: a restituição segue a forma de
   pagamento do pedido. O prazo limite (15 dias) é calculado pelo banco.
   ===================================================================== */
INSERT INTO ESTORNO (Id_Estorno, Id_Pagamento, Codigo_Devolucao, Codigo_Cancelamento, Valor, Data_Abertura, Data_Conclusao, Status) VALUES
(1, 6, NULL, 2, 3296.00, '2026-10-26 12:00:00', '2026-10-30 15:30:00', 'Processado');


/* =====================================================================
   19. POS_VENDA
   - Defeito: até 30 dias da compra; Garantia: loja ou fabricante;
     Arrependimento: até 7 dias do recebimento.
   - Um item não pode ter duas solicitações em aberto ao mesmo tempo.
   ===================================================================== */
SET @cellgo_funcionario = 6;

INSERT INTO POS_VENDA (Id_PosVenda, Imei, Id_Pedido, Tipo_Solicitacao, Data_Abertura, Descricao, Status) VALUES
(1, '356938035643809', 1, 'Defeito',        '2026-10-25 10:00:00', 'Cliente informou que o aparelho desliga durante o uso.', 'Aberta'),
(2, '352099001761481', 2, 'Garantia',       '2026-10-26 14:00:00', 'Cliente solicitou atendimento em garantia por falha no carregamento.', 'Aberta'),
(3, '490154203237518', 2, 'Garantia',       '2026-11-01 09:00:00', 'Cliente relatou falha no alto-falante e solicitou análise em garantia.', 'Aberta'),
(4, '789012345678901', 5, 'Arrependimento', '2026-11-02 09:00:00', 'Cliente se arrependeu da compra dentro do prazo de 7 dias do recebimento.', 'Aberta');


/* =====================================================================
   20. AVALIACAO_DANO
   Feita por funcionário de Assistência Técnica. Mau uso e dano acidental
   não têm cobertura da garantia.
   ===================================================================== */
SET @cellgo_funcionario = 3;

INSERT INTO AVALIACAO_DANO (Codigo_Avaliacao, Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao) VALUES
(1, 1, 3, 'Defeito de fabricação', 'Falha no circuito de alimentação causando desligamentos durante o uso.', TRUE,  'Em manutenção', '2026-10-27'),
(2, 2, 3, 'Mau uso',               'Conector de carregamento danificado por uso inadequado.',                FALSE, 'Em manutenção', '2026-10-28'),
(3, 3, 3, 'Defeito de fabricação', 'Falha no alto-falante, sem sinais de impacto ou contato com líquidos.',  TRUE,  'Em manutenção', '2026-11-02');


/* =====================================================================
   21. TROCA
   Exige avaliação com cobertura da garantia. Reposição Disponível e da
   mesma especificação. A troca deixa a reposição Vendida e o aparelho com
   defeito Em avaliação. A troca 1 vira Concluída quando a entrega de
   reposição é entregue; a troca 2 segue Pendente.
   ===================================================================== */
SET @cellgo_funcionario = 6;

INSERT INTO TROCA (Codigo_Troca, Id_PosVenda, Imei_Reposicao, Data_Troca, Status) VALUES
(1, 1, '678901234567890', '2026-10-28', 'Pendente'),
(2, 3, '890123456789012', '2026-11-02', 'Pendente');

/* Entrega de reposição da troca 1 (no mesmo pedido da venda) */
INSERT INTO ENTREGA (Codigo_Rastreio, Codigo_Troca, Id_Pedido, Transportadora, Status_Entrega, Data_Despacho, Data_Entrega, Origem_Atualizacao) VALUES
('BR555666777SP', 1, 1, 'Correios', 'Entregue', '2026-10-28 08:30:00', '2026-10-31 11:20:00', 'Manual');

/* Aparelhos com defeito seguem do Em avaliação para a manutenção */
SET @cellgo_funcionario = 3;
UPDATE APARELHO SET Status = 'Em manutenção' WHERE Imei = '356938035643809';
UPDATE APARELHO SET Status = 'Em manutenção' WHERE Imei = '490154203237518';


/* =====================================================================
   22. DEVOLUCAO
   Só para Arrependimento ou Defeito. O aparelho devolvido volta para
   Em avaliação. A devolução 1 é concluída depois do estorno.
   ===================================================================== */
SET @cellgo_funcionario = 6;

INSERT INTO DEVOLUCAO (Codigo_Devolucao, Id_PosVenda, Data_Devolucao, Motivo, Status) VALUES
(1, 4, '2026-11-02 14:00:00', 'Aparelho devolvido por arrependimento da compra.', 'Pendente');


/* =====================================================================
   23. NOTA_FISCAL e ITEM_NOTA_FISCAL — notas do pós-venda
   - nota 6: entrada do aparelho com defeito (pós-venda 1);
   - nota 7: saída da reposição da troca 1 (Emitida);
   - nota 8: saída da reposição da troca 2 (Pendente: aguardando emissão);
   - nota 9: entrada da devolução 1 (libera o estorno).
   ===================================================================== */
SET @cellgo_funcionario = 7;

INSERT INTO NOTA_FISCAL (Id_Nota, Numero_Nota, Id_PosVenda, Id_Nota_Referencia, Codigo_Cancelamento, Id_Pedido, Chave_Acesso, Tipo_Nota, Natureza, Status, Data_Emissao) VALUES
(6, NULL, 1, 1, NULL, NULL, NULL, 'Entrada (Devolução)', 'Devolução de venda de mercadoria',     'Aguardando emissão', NULL),
(7, NULL, 1, 1, NULL, NULL, NULL, 'Saída (Reposição)',   'Remessa de mercadoria para reposição', 'Aguardando emissão', NULL),
(8, NULL, 3, 2, NULL, NULL, NULL, 'Saída (Reposição)',   'Remessa de mercadoria para reposição', 'Aguardando emissão', NULL),
(9, NULL, 4, 4, NULL, NULL, NULL, 'Entrada (Devolução)', 'Devolução de venda de mercadoria',     'Aguardando emissão', NULL);

INSERT INTO ITEM_NOTA_FISCAL (Imei, Id_Nota, Valor_Item) VALUES
('356938035643809', 6, 3999.00),
('678901234567890', 7, 3999.00),
('890123456789012', 8, 5499.90),
('789012345678901', 9, 1899.00);

UPDATE NOTA_FISCAL SET Numero_Nota = 1005, Chave_Acesso = '35261012345678000190550010000010051000100057', Status = 'Emitida',  Data_Emissao = '2026-10-29 09:45:00' WHERE Id_Nota = 6;
UPDATE NOTA_FISCAL SET Numero_Nota = 1006, Chave_Acesso = '35261012345678000190550010000010061000100064', Status = 'Emitida',  Data_Emissao = '2026-10-29 10:00:00' WHERE Id_Nota = 7;
UPDATE NOTA_FISCAL SET Status = 'Pendente' WHERE Id_Nota = 8;
UPDATE NOTA_FISCAL SET Numero_Nota = 1007, Chave_Acesso = '35261012345678000190550010000010071000100071', Status = 'Emitida',  Data_Emissao = '2026-11-03 10:00:00' WHERE Id_Nota = 9;


/* =====================================================================
   24. ESTORNO — da devolução 1
   Só é liberado com a nota de entrada (devolução) Emitida. Fica Pendente.
   ===================================================================== */
INSERT INTO ESTORNO (Id_Estorno, Id_Pagamento, Codigo_Devolucao, Codigo_Cancelamento, Valor, Data_Abertura, Data_Conclusao, Status) VALUES
(2, 7, 1, NULL, 1766.07, '2026-11-03 10:30:00', NULL, 'Pendente');


/* =====================================================================
   25. Fechamento do pós-venda
   ===================================================================== */
SET @cellgo_funcionario = 6;

UPDATE DEVOLUCAO SET Status = 'Concluída' WHERE Codigo_Devolucao = 1;

UPDATE POS_VENDA SET Status = 'Concluída'  WHERE Id_PosVenda IN (1, 4);
UPDATE POS_VENDA SET Status = 'Recusada'   WHERE Id_PosVenda = 2;
UPDATE POS_VENDA SET Status = 'Em análise' WHERE Id_PosVenda = 3;

/* aparelho devolvido (Arrependimento) volta ao estoque depois da avaliação */
SET @cellgo_funcionario = 3;
UPDATE APARELHO SET Status = 'Disponível' WHERE Imei = '789012345678901';


/* =====================================================================
   26. REQUISICAO_COMPRA — análise financeira e decisão da Diretoria
   Fluxo: Aguardando Análise Financeira → Aguardando Aprovação da
   Diretoria → Aprovada ou Recusada. Só a Diretoria decide.
   Executado por último para que nenhuma movimentação de estoque abra
   requisição nova. Requisições 1 e 5 continuam aguardando análise.
   ===================================================================== */
SET @cellgo_funcionario = 7;

UPDATE REQUISICAO_COMPRA
   SET Parecer_Financeiro = 'Orçamento disponível para reposição dentro do limite mensal.',
       Status = 'Aguardando Aprovação da Diretoria'
 WHERE Id_Requisicao = 2;

UPDATE REQUISICAO_COMPRA
   SET Parecer_Financeiro = 'Parecer favorável. Giro alto e margem adequada.',
       Status = 'Aguardando Aprovação da Diretoria'
 WHERE Id_Requisicao = 3;

UPDATE REQUISICAO_COMPRA
   SET Parecer_Financeiro = 'Estoque próximo do mínimo, mas sem previsão de caixa no período.',
       Status = 'Aguardando Aprovação da Diretoria'
 WHERE Id_Requisicao = 4;

SET @cellgo_funcionario = 1;

UPDATE REQUISICAO_COMPRA
   SET Codigo_Funcionario = 1, Data_Decisao = '2026-10-24', Status = 'Aprovada'
 WHERE Id_Requisicao = 3;

UPDATE REQUISICAO_COMPRA
   SET Codigo_Funcionario = 1, Data_Decisao = '2026-10-27',
       Motivo_Recusa = 'Recusada por restrição orçamentária no trimestre.', Status = 'Recusada'
 WHERE Id_Requisicao = 4;


/* =====================================================================
   27. Remoção da imagem 6 (origem do registro de AUDITORIA 5)
   ===================================================================== */
DELETE FROM IMAGEM_APARELHO WHERE Id_Imagem = 6;


/* =====================================================================
   28. AUDITORIA — registros manuais
   As triggers já gravaram registros automáticos (parâmetros, pagamentos,
   cancelamentos, devoluções, trocas, estornos, requisições). Aqui ficam
   os registros de operações sem trigger. O autorizador, quando
   informado, é da Diretoria (funcionário 1).
   ===================================================================== */
INSERT INTO AUDITORIA (Codigo_Funcionario, Codigo_Autorizador, Acao, Tabela_Afetada, Registro_Id, Valor_Anterior, Valor_Novo, Data_Hora, Descricao) VALUES
(2, NULL, 'INSERT', 'AQUISICAO', '1', NULL,
    '{"Status": "Em avaliação", "Valor_Total": 0.00}',
    '2026-08-10 09:00:00', 'Cadastro da aquisição junto ao fornecedor Tech Peças Eletrônicas Ltda.'),
(3, NULL, 'UPDATE', 'AQUISICAO', '1', '{"Status": "Em avaliação"}', '{"Status": "Concluída"}',
    '2026-08-10 10:00:00', 'Aquisição concluída após aprovação na avaliação de entrada.'),
(5, 1,    'UPDATE', 'AQUISICAO', '4', '{"Status": "Em avaliação"}', '{"Status": "Recusada"}',
    '2026-09-19 09:30:00', 'Aquisição recusada por IMEI bloqueado. Alteração autorizada pela Diretoria.'),
(2, 1,    'UPDATE', 'FUNCIONARIO', '4', '{"Ativo": 1}', '{"Ativo": 0}',
    '2026-09-30 14:15:00', 'Desativação da funcionária Fernanda Oliveira Costa, autorizada pela Diretoria.'),
(NULL, NULL, 'DELETE', 'IMAGEM_APARELHO', '6',
    '{"Imei": "356938035643809", "URL": "https://cellgo.com.br/imagens/aparelhos/356938035643809_lateral.jpg"}', NULL,
    '2026-10-30 08:00:00', 'Remoção automática de imagem por rotina de limpeza do sistema.');

SET @cellgo_funcionario = NULL;