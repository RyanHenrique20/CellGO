USE cellgo; 

/* 1. PERFIL_ACESSO */
INSERT INTO perfil_acesso (Id_Perfil, Nome_Perfil, Nivel_Acesso) VALUES
(1, 'Vendas e Atendimento', 1),
(2, 'Estoque e Logística', 1),
(3, 'Assistência Técnica', 1),
(4, 'Financeiro/Administrativo', 1),
(5, 'Diretoria', 2);
 
/* 2. FUNCIONARIO */
INSERT INTO funcionario (Codigo_Funcionario, Nome, Cargo, Login, Id_Perfil, Ativo) VALUES
(1, 'Carlos Eduardo Silva', 'Gerente', 'carlos.silva', 1, 1),
(2, 'Mariana Souza Lima', 'Analista de Sistemas', 'mariana.lima', 2, 1),
(3, 'Roberto Alves Pereira', 'Atendente', 'roberto.pereira', 3, 1),
(4, 'Fernanda Oliveira Costa', 'Assistente Administrativo', 'fernanda.costa', 3, 0),
(5, 'João Pedro Santos', 'Supervisor', 'joao.santos', 2, 1);
 
/* 3. FORNECEDOR */
INSERT INTO fornecedor (Cpf_Cnpj_Fornecedor, Tipo_Pessoa, Nome, Tipo_Documento, Numero_Documento, Telefone_Contato) VALUES
('12345678909',    'PF', 'José Antônio Ferreira',             'RG',  '123456789',    '11987654321'),
('98765432100',    'PF', 'Luciana Martins Rocha',             'CNH', '04567891230',  '11976543210'),
('11222333000181', 'PJ', 'Tech Peças Eletrônicas Ltda',       NULL,  NULL,           '1133445566'),
('44555666000172', 'PJ', 'Distribuidora Celular Brasil S.A.', NULL,  NULL,           '1144556677'),
('55667788000193', 'PJ', 'Acessórios Mobile Comércio Ltda',   'IE',  '123456789110', '11955443322');
 
/* 4. MODELO */
INSERT INTO modelo (Id_Modelo, Nome_Modelo, Marca) VALUES
(1, 'Galaxy S23',    'Samsung'),
(2, 'iPhone 14',     'Apple'),
(3, 'Moto G73',      'Motorola'),
(4, 'Redmi Note 12', 'Xiaomi'),
(5, 'Edge 40',       'Motorola');
 
/* 5. ESPECIFICACAO_APARELHO */
INSERT INTO especificacao_aparelho (Id_Especificacao, Id_Modelo, Cor, Capacidade, Estoque_Minimo, Limite_Dias_Atencao, Limite_Dias_Critico) VALUES
(1, 1, 'Preto',  128, 5, 30, 60),
(2, 1, 'Verde',  256, 3, 30, 60),
(3, 2, 'Azul',   128, 4, 45, 90),
(4, 3, 'Cinza',  256, 6, 20, 40),
(5, 4, 'Branco', 128, 8, 25, 50);
 
/* 6. AQUISICAO
   Valor_Total = soma do custo dos aparelhos vinculados (acq. 1, 2 e 3). */
INSERT INTO aquisicao (Id_Aquisicao, Codigo_Funcionario, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra, Numero_Documento_Compra, Termo_Responsabilidade_Aceito, Valor_Total, Status) VALUES
(1, 1, '11222333000181', '2026-08-10', 'Nota Fiscal',            'NF-000123',    NULL, 7600.00,  'Concluída'),
(2, 2, '44555666000172', '2026-08-25', 'Nota Fiscal',            'NF-000456',    NULL, 12100.00, 'Concluída'),
(3, 1, '12345678909',    '2026-09-05', 'Termo de Compra e Venda','TCV-2026-001', 1,    1300.00,  'Concluída'),
(4, 5, '98765432100',    '2026-09-18', 'Termo de Compra e Venda','TCV-2026-002', 1,    1850.75,  'Recusada'),
(5, 2, '55667788000193', '2026-09-28', 'Nota Fiscal',            'NF-000789',    NULL, 9600.00,  'Recusada');
 
/* 7. AVALIACAO_ENTRADA
   Uma avaliação por aparelho (IMEI). Avaliações 4 e 5 são recusadas (sem aparelho em estoque).
   Avaliações 6 a 10 foram adicionadas para os demais aparelhos usados no script. */
INSERT INTO avaliacao_entrada (Id_Avaliacao_Entrada, Codigo_Funcionario, Id_Aquisicao, Imei_Avaliado, Base_Consultada, Resultado_Consulta_Imei, Data_Consulta, Checklist_Bateria, Checklist_Tela, Checklist_Cameras, Checklist_Botoes, Checklist_Som, Checklist_Conectividade, Checklist_Pecas_Originais, Bloqueio_Conta, Reset_Fabrica_Realizado, Resultado, Motivo_Recusa, Data_Reconsulta_Imei, Resultado_Reconsulta_Imei) VALUES
(1,  3, 1, '356938035643809', 'CEIR/Anatel', 'Regular',         '2026-08-10 09:30:00', 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado', NULL, NULL, NULL),
(2,  3, 2, '490154203237518', 'CEIR/Anatel', 'Regular',         '2026-08-25 10:15:00', 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado', NULL, '2026-08-26 14:00:00', 'Regular'),
(3,  3, 3, '352099001761481', 'GSMA',        'Regular',         '2026-09-05 11:00:00', 1, 0, 1, 1, 1, 1, 0, 0, 1, 'Aprovado', NULL, NULL, NULL),
(4,  5, 4, '867530902314556', 'CEIR/Anatel', 'Bloqueado',       '2026-09-18 15:20:00', 1, 1, 1, 1, 1, 1, 1, 1, 0, 'Recusado', 'IMEI com bloqueio ativo e conta do proprietário anterior vinculada ao aparelho.', '2026-09-19 09:00:00', 'Bloqueado'),
(5,  3, 5, '358240051111110', 'GSMA',        'Roubado/Furtado', '2026-09-28 16:45:00', 1, 1, 1, 1, 1, 1, 1, 0, 0, 'Recusado', 'IMEI consta como roubado/furtado na base consultada.', NULL, NULL),
(6,  3, 1, '351756051523999', 'CEIR/Anatel', 'Regular',         '2026-08-10 09:45:00', 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado', NULL, NULL, NULL),
(7,  3, 2, '353879234252633', 'CEIR/Anatel', 'Regular',         '2026-08-25 10:30:00', 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado', NULL, NULL, NULL),
(8,  3, 1, '678901234567890', 'CEIR/Anatel', 'Regular',         '2026-08-10 10:00:00', 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado', NULL, NULL, NULL),
(9,  3, 2, '789012345678901', 'GSMA',        'Regular',         '2026-08-25 10:45:00', 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado', NULL, NULL, NULL),
(10, 3, 2, '890123456789012', 'GSMA',        'Regular',         '2026-08-25 11:00:00', 1, 1, 1, 1, 1, 1, 1, 0, 1, 'Aprovado', NULL, NULL, NULL);
 
/* 8. APARELHO
   Todos os IMEIs usados nas demais tabelas existem aqui e batem com as avaliações de entrada.
   Quarentena = 15 dias após a entrada. */
INSERT INTO aparelho (Imei, Id_Especificacao, Id_Avaliacao_Entrada, Codigo_Funcionario, Condicao, Preco_Venda, Custo_Aquisicao, Status, Data_Entrada, Data_Disponivel, Data_Fim_Quarentena, Elegivel_Desconto_Pix) VALUES
('356938035643809', 1, 1,  3, 'Seminovo', 3999.00, 2800.00, 'Vendido',    '2026-08-10', '2026-08-25', '2026-08-25', TRUE),
('490154203237518', 3, 2,  3, 'Seminovo', 5499.90, 4200.00, 'Vendido',    '2026-08-25', '2026-09-09', '2026-09-09', TRUE),
('352099001761481', 4, 3,  3, 'Seminovo', 1899.00, 1300.00, 'Vendido',    '2026-09-05', '2026-09-20', '2026-09-20', TRUE),
('351756051523999', 2, 6,  3, 'Seminovo', 2750.00, 2000.00, 'Vendido',    '2026-08-10', '2026-08-25', '2026-08-25', TRUE),
('353879234252633', 5, 7,  3, 'Seminovo', 3200.00, 2400.00, 'Vendido',    '2026-08-25', '2026-09-09', '2026-09-09', TRUE),
('678901234567890', 1, 8,  3, 'Seminovo', 3999.00, 2800.00, 'Vendido',    '2026-08-10', '2026-08-25', '2026-08-25', TRUE),
('789012345678901', 4, 9,  3, 'Seminovo', 1899.00, 1300.00, 'Disponível', '2026-08-25', '2026-09-09', '2026-09-09', TRUE),
('890123456789012', 3, 10, 3, 'Seminovo', 5499.90, 4200.00, 'Vendido',    '2026-08-25', '2026-09-09', '2026-09-09', TRUE);
 
/* 9. CLIENTE */
INSERT INTO cliente (Cpf_Cnpj, Nome, Email, Data_Nascimento, Tipo_Pessoa) VALUES
('32165498700',    'Ana Beatriz Carvalho',      'ana.carvalho@email.com',      '1990-04-15', 'PF'),
('74185296300',    'Ricardo Mendes Barbosa',    'ricardo.barbosa@email.com',   '1985-11-02', 'PF'),
('15935748600',    'Juliana Ferreira Duarte',   'juliana.duarte@email.com',    '1998-07-28', 'PF'),
('66777888000155', 'Mercado Bom Preço Ltda',    'contato@bompreco.com.br',     NULL,         'PJ'),
('77888999000166', 'Construtora Horizonte S.A.','financeiro@horizonte.com.br', NULL,         'PJ');
 
/* 10. ENDERECO */
INSERT INTO endereco (Id_endereco, Cpf_Cnpj, Rua, Bairro, Cidade, CEP, Numero, Complemento, Tipo_endereco) VALUES
(1, '32165498700',    'Rua das Flores',    'Centro',    'São Paulo', '01001000', '120', 'Apartamento 12', 'Residencial'),
(2, '74185296300',    'Rua das Palmeiras', 'Tatuapé',   'São Paulo', '03065000', '250', NULL,             'Residencial'),
(3, '15935748600',    'Avenida Central',   'Centro',    'Guarulhos', '07010000', '85',  'Casa 2',         'Residencial'),
(4, '66777888000155', 'Rua dos Pinheiros', 'Pinheiros', 'São Paulo', '05422000', '430', 'Sala 5',         'Comercial'),
(5, '77888999000166', 'Rua do Comércio',   'Centro',    'Osasco',    '06010000', '90',  NULL,             'Comercial');
 
/* 11. TELEFONE */
INSERT INTO telefone (DDD, Numero_Telefone, Cpf_Cnpj) VALUES
('11', '987654321', '32165498700'),
('11', '976543210', '74185296300'),
('11', '965432109', '15935748600'),
('11', '33445566',  '66777888000155'),
('11', '988776655', '77888999000166');
 
/* 12. PEDIDO
   Valores conferidos: Valor_Final = Valor_Produtos - Valor_Desconto + Valor_Taxas. */
INSERT INTO pedido (Id_Pedido, Cpf_Cnpj, Data_Pedido, Status_Pedido, Forma_Pagamento, Numero_Parcelas, Valor_Produtos, Percentual_Desconto_Pix, Valor_Desconto, Valor_Taxas, Valor_Final) VALUES
(1, '32165498700',    '2026-10-05 10:15:00', 'Finalizado', 'Pix',               1,  3999.00, 10.00, 399.90, 0.00,   3599.10),
(2, '66777888000155', '2026-10-10 14:30:00', 'Finalizado', 'Cartão de crédito', 10, 7398.90, NULL,  NULL,   369.95, 7768.85),
(3, '74185296300',    '2026-10-20 09:45:00', 'Pago',       'Pix',               1,  2750.00, 5.00,  137.50, 0.00,   2612.50),
(4, '15935748600',    '2026-10-25 16:20:00', 'Pago',       'Cartão de crédito', 3,  3200.00, NULL,  NULL,   96.00,  3296.00);
 
/* 13. IMAGEM_APARELHO (insert incompleto removido) */
INSERT INTO imagem_aparelho (Id_Imagem, Imei, URL) VALUES
(1, '356938035643809', 'https://cellgo.com.br/imagens/aparelhos/356938035643809_frente.jpg'),
(2, '356938035643809', 'https://cellgo.com.br/imagens/aparelhos/356938035643809_traseira.jpg'),
(3, '490154203237518', 'https://cellgo.com.br/imagens/aparelhos/490154203237518_frente.jpg'),
(4, '352099001761481', 'https://cellgo.com.br/imagens/aparelhos/352099001761481_frente.jpg'),
(5, '351756051523999', 'https://cellgo.com.br/imagens/aparelhos/351756051523999_frente.jpg');
 
/* 14. ITEM_PEDIDO
   Garantia da loja = 90 dias; garantia do fabricante = 1 ano (aparelho comprado de PF não tem garantia de fabricante). */
INSERT INTO item_pedido (Imei, Id_Pedido, Preco_Unitario, Data_Inicio_Garantia, Data_Fim_Garantia_Loja, Data_Fim_Garantia_Fabricante) VALUES
('356938035643809', 1, 3999.00, '2026-10-05', '2027-01-03', '2027-10-05'),
('490154203237518', 2, 5499.90, '2026-10-10', '2027-01-08', '2027-10-10'),
('352099001761481', 2, 1899.00, '2026-10-10', '2027-01-08', NULL),
('351756051523999', 3, 2750.00, '2026-10-20', '2027-01-18', '2027-10-20'),
('353879234252633', 4, 3200.00, '2026-10-25', '2027-01-23', '2027-10-25');
 
/* 15. PAGAMENTO
   Valores iguais ao Valor_Final de cada pedido; pedidos "Pago/Finalizado" possuem pagamento aprovado. */
INSERT INTO pagamento (Id_Pagamento, Id_Pedido, Codigo_Transacao, Data_Tentativa, Data_Confirmacao, Valor, Status, Comprovante) VALUES
(1, 1, 'TESTE-TRANSACAO-001', '2026-10-05 10:20:00', NULL,                  3599.10, 'Recusado', NULL),
(2, 1, 'TESTE-TRANSACAO-002', '2026-10-05 10:25:00', '2026-10-05 10:26:00', 3599.10, 'Aprovado', 'comprovantes/pagamento-002.pdf'),
(3, 2, 'TESTE-TRANSACAO-003', '2026-10-10 14:35:00', NULL,                  7768.85, 'Expirado', NULL),
(4, 2, 'TESTE-TRANSACAO-004', '2026-10-10 15:00:00', '2026-10-10 15:02:00', 7768.85, 'Aprovado', 'comprovantes/pagamento-004.pdf'),
(5, 3, 'TESTE-TRANSACAO-005', '2026-10-20 09:50:00', '2026-10-20 09:51:00', 2612.50, 'Aprovado', 'comprovantes/pagamento-005.pdf'),
(6, 4, 'TESTE-TRANSACAO-006', '2026-10-25 16:30:00', '2026-10-25 16:32:00', 3296.00, 'Aprovado', 'comprovantes/pagamento-006.pdf');
 
/* 16. CANCELAMENTO
   O cancelamento 3 foi removido: apontava para o pedido 5, que não existe. */
INSERT INTO cancelamento (Codigo_Cancelamento, Id_Pedido, Data_Solicitacao, Motivo, Status) VALUES
(1, 3, '2026-10-22 10:00:00', 'Cliente desistiu da compra antes de receber o pedido.', 'Pendente'),
(2, 4, '2026-10-26 11:00:00', 'Cliente realizou o pedido por engano.', 'Pendente');
 
/* 17. POS_VENDA */
INSERT INTO pos_venda (Id_PosVenda, Imei, Id_Pedido, Tipo_Solicitacao, Data_Abertura, Descricao, Status) VALUES
(1, '356938035643809', 1, 'Defeito',  '2026-10-25 10:00:00', 'Cliente informou que o aparelho desliga durante o uso.', 'Aberto'),
(2, '352099001761481', 2, 'Garantia', '2026-10-26 14:00:00', 'Cliente solicitou atendimento em garantia por falha no carregamento.', 'Aberto'),
(3, '490154203237518', 2, 'Garantia', '2026-11-01 09:00:00', 'Cliente relatou falha no alto-falante e solicitou análise em garantia.', 'Aberto');
 
/* 18. DEVOLUCAO */
INSERT INTO devolucao (Codigo_Devolucao, Id_PosVenda, Data_Devolucao, Motivo, Status) VALUES
(1, 1, '2026-10-26 10:00:00', 'Aparelho devolvido por desligamentos durante o uso.', 'Recebida'),
(2, 2, '2026-10-27 14:00:00', 'Aparelho devolvido por falha no carregamento.', 'Em análise'),
(3, 3, '2026-11-02 09:00:00', 'Aparelho devolvido por falha no alto-falante.', 'Recebida');
 
/* 19. AVALIACAO_DANO */
INSERT INTO avaliacao_dano (Codigo_Avaliacao, Id_PosVenda, Codigo_Funcionario, Classificacao_Dano, Descricao_Dano, Cobertura_Garantia, Destino_Aparelho, Data_Avaliacao) VALUES
(1, 1, 3, 'Defeito de fabricação', 'Falha no circuito de alimentação causando desligamentos durante o uso.', TRUE,  'Em manutenção', '2026-10-27'),
(2, 2, 3, 'Mau uso',               'Conector de carregamento danificado por uso inadequado.',                FALSE, 'Em manutenção', '2026-10-28'),
(3, 3, 3, 'Defeito de fabricação', 'Falha no alto-falante, sem sinais de impacto ou contato com líquidos.',  TRUE,  'Em manutenção', '2026-11-02');
 
/* 20. TROCA
   Aparelhos de reposição com a mesma especificação do aparelho trocado. */
INSERT INTO troca (Codigo_Troca, Id_PosVenda, Imei_Reposicao, Data_Troca, Status) VALUES
(1, 1, '678901234567890', '2026-10-28', 'Concluída'),
(2, 2, '789012345678901', '2026-10-29', 'Cancelada'),
(3, 3, '890123456789012', '2026-11-02', 'Concluída');
 
/* 21. NOTA_FISCAL */
INSERT INTO nota_fiscal (Id_Nota, Numero_Nota, Id_PosVenda, Id_Nota_Referencia, Codigo_Cancelamento, Id_Pedido, Chave_Acesso, Tipo_Nota, Natureza, Status, Data_Emissao) VALUES
(1, 1001, NULL, NULL, NULL, 1,    '35261012345678000190550010000010011000010019', 'Venda',               'Venda de mercadoria',                  'Emitida',            '2026-10-05 15:30:00'),
(2, 1002, NULL, NULL, NULL, 2,    '35261012345678000190550010000010021000010026', 'Venda',               'Venda de mercadoria',                  'Emitida',            '2026-10-10 17:00:00'),
(3, 1003, 1,    1,    NULL, NULL, '35261012345678000190550010000010031000010033', 'Entrada (Devolução)', 'Devolução de venda de mercadoria',     'Emitida',            '2026-10-27 09:45:00'),
(4, NULL, NULL, NULL, 1,    NULL, NULL,                                           'Venda',               'Cancelamento de venda de mercadoria',  'Aguardando emissão', NULL),
(5, NULL, 3,    2,    NULL, NULL, NULL,                                           'Saída (Reposição)',   'Remessa de mercadoria para reposição', 'Pendente',           NULL);
 
/* 22. ESTORNO
   Cada estorno aponta para uma devolução OU um cancelamento, sempre ligado a um pagamento aprovado do mesmo pedido. */
INSERT INTO estorno (Id_Estorno, Id_Pagamento, Codigo_Devolucao, Codigo_Cancelamento, Valor, Banco, Agencia, Conta, Tipo_Conta, Data_Abertura, Data_Conclusao, Status) VALUES
(1, 2, 1,    NULL, 3599.10, 'Banco do Brasil',          '1234-5', '12345-6',   'Corrente', '2026-10-27 10:00:00', '2026-10-30 15:30:00', 'Recusado'),
(2, 4, 2,    NULL, 1899.00, 'Caixa Econômica Federal',  '0987',   '00123456-7','Poupança', '2026-10-28 14:15:00', NULL,                  'Pendente'),
(3, 5, NULL, 1,    2612.50, NULL,                       NULL,     NULL,        NULL,       '2026-10-22 11:00:00', NULL,                  'Pendente'),
(4, 6, NULL, 2,    3296.00, 'Itaú',                     '4321',   '98765-4',   'Corrente', '2026-10-27 16:40:00', NULL,                  'Pendente'),
(5, 4, 3,    NULL, 5499.90, 'Bradesco',                 '5678',   '54321-0',   'Corrente', '2026-11-02 09:30:00', '2026-11-02 10:00:00', 'Recusado');
 
/* 23. ENTREGA */
INSERT INTO entrega (Codigo_Rastreio, Codigo_Troca, Id_Pedido, Transportadora, Status_Entrega, Data_Despacho, Data_Entrega, Origem_Atualizacao) VALUES
('BR123456789SP', NULL, 1, 'Correios', 'Entregue',         '2026-10-06 10:00:00', '2026-10-09 14:30:00', 'Automática'),
('BR987654321SP', NULL, 2, 'Jadlog',   'Entregue',         '2026-10-11 09:15:00', '2026-10-14 16:45:00', 'Automática'),
('LP456789123BR', NULL, 3, 'Loggi',    'Em transporte',    '2026-10-21 11:30:00', NULL,                  'Automática'),
('JD321654987BR', NULL, 4, 'Jadlog',   'Aguardando envio', NULL,                  NULL,                  'Manual'),
('BR555666777SP', 1,    1, 'Correios', 'Entregue',         '2026-10-28 08:30:00', '2026-10-31 11:20:00', 'Manual');
 
/* 24. REQUISICAO_COMPRA
   Estoque_Minimo igual ao definido em especificacao_aparelho. */
INSERT INTO requisicao_compra (Id_Requisicao, Codigo_Funcionario, Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo, Parecer_Financeiro, Data_Abertura, Data_Decisao, Motivo_Recusa, Status, Qtd_Sugerida) VALUES
(1, 2,    1, 3, 5, NULL, '2026-10-26', NULL, NULL, 'Aguardando Análise Financeira', 10),
(2, 5,    2, 1, 3, 'Orçamento disponível para reposição dentro do limite mensal.', '2026-10-27', NULL, NULL, 'Aguardando Aprovação da Diretoria', 6),
(3, 1,    3, 2, 4, 'Parecer favorável. Giro alto e margem adequada.', '2026-10-20', '2026-10-24', NULL, 'Aprovada', 8),
(4, 2,    4, 5, 6, 'Estoque próximo do mínimo, mas sem previsão de caixa no período.', '2026-10-21', '2026-10-27', 'Recusada por restrição orçamentária no trimestre.', 'Recusada', 4),
(5, NULL, 5, 4, 8, NULL, '2026-10-30', NULL, NULL, 'Aguardando Análise Financeira', 12);
 
/* 25. MOVIMENTACAO
   Somente IMEIs existentes em aparelho. */
INSERT INTO movimentacao (Numero_Movimentacao, Codigo_Funcionario, Imei, Tipo_Movimento, Status_Anterior, Status_Novo, Data_Hora) VALUES
(1, 3, '356938035643809', 'Entrada',    NULL,            'Em quarentena', '2026-08-10 09:30:00'),
(2, 3, '356938035643809', 'Avaliação',  'Em quarentena', 'Disponível',    '2026-08-25 10:00:00'),
(3, 3, '356938035643809', 'Venda',      'Disponível',    'Vendido',       '2026-10-05 10:26:00'),
(4, 3, '356938035643809', 'Manutenção', 'Vendido',       'Em manutenção', '2026-10-26 11:00:00'),
(5, 3, '352099001761481', 'Manutenção', 'Vendido',       'Em manutenção', '2026-10-27 11:00:00');
 
/* 26. AUDITORIA */
INSERT INTO auditoria (Id_Auditoria, Codigo_Funcionario, Codigo_Autorizador, Acao, Tabela_Afetada, Registro_Id, Valor_Anterior, Valor_Novo, Data_Hora, Descricao) VALUES
(1, 1,    NULL, 'INSERT', 'aquisicao',       '1', NULL,
    '{"Status": "Em avaliação", "Valor_Total": 7600.00}',
    '2026-08-10 09:00:00', 'Cadastro da aquisição junto ao fornecedor Tech Peças Eletrônicas Ltda.'),
(2, 3,    NULL, 'UPDATE', 'aquisicao',       '1', '{"Status": "Em avaliação"}', '{"Status": "Concluída"}',
    '2026-08-10 10:00:00', 'Aquisição concluída após aprovação na avaliação de entrada.'),
(3, 5,    1,    'UPDATE', 'aquisicao',       '4', '{"Status": "Em avaliação"}', '{"Status": "Recusada"}',
    '2026-09-19 09:30:00', 'Aquisição recusada por IMEI bloqueado. Alteração autorizada pelo gerente.'),
(4, 2,    1,    'UPDATE', 'funcionario',     '4', '{"Ativo": 1}', '{"Ativo": 0}',
    '2026-09-30 14:15:00', 'Desativação do funcionário Fernanda Oliveira Costa, autorizada pelo gerente.'),
(5, NULL, NULL, 'DELETE', 'imagem_aparelho', '6',
    '{"Imei": "356938035643809", "URL": "https://cellgo.com.br/imagens/aparelhos/356938035643809_lateral.jpg"}', NULL,
    '2026-10-30 08:00:00', 'Remoção automática de imagem por rotina de limpeza do sistema.');