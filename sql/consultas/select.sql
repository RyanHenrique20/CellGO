/* =====================================================================
   CellGO — Consultas SELECT
   SGBD: MySQL 8
   Execute depois de tabelas.sql, trigger.sql e dos inserts.

   Consultas em uma única tabela, mostrando os recursos do SELECT:
   WHERE, operadores (=, <>, >, BETWEEN, IN, LIKE, IS NULL), ORDER BY,
   LIMIT, DISTINCT, funções de data e funções de agregação com
   GROUP BY e HAVING.
   As consultas que cruzam tabelas estão no arquivo join.sql.
   ===================================================================== */

USE cellgo;


/* =====================================================================
   1. Consultas simples (projeção e ordenação)
   ===================================================================== */

/* 1.1 Todos os modelos cadastrados, em ordem de marca e nome */
SELECT Id_Modelo, Marca, Nome_Modelo
  FROM MODELO
 ORDER BY Marca, Nome_Modelo;

/* 1.2 Marcas trabalhadas pela loja (sem repetição) */
SELECT DISTINCT Marca
  FROM MODELO
 ORDER BY Marca;

/* 1.3 Perfis de acesso e seus níveis */
SELECT Id_Perfil, Nome_Perfil,
       CASE Nivel_Acesso WHEN 2 THEN 'Estratégico' ELSE 'Operacional' END AS Nivel
  FROM PERFIL_ACESSO
 ORDER BY Nivel_Acesso DESC, Nome_Perfil;


/* =====================================================================
   2. Filtros com WHERE
   ===================================================================== */

/* 2.1 Funcionários ativos */
SELECT Codigo_Funcionario, Nome, Cargo, Login
  FROM FUNCIONARIO
 WHERE Ativo = 1
 ORDER BY Nome;

/* 2.2 Funcionários inativos (desligados) */
SELECT Codigo_Funcionario, Nome, Cargo
  FROM FUNCIONARIO
 WHERE Ativo = 0;

/* 2.3 Aparelhos disponíveis para venda, do mais barato ao mais caro */
SELECT Imei, Condicao, Preco_Venda, Data_Disponivel
  FROM APARELHO
 WHERE Status = 'Disponível'
 ORDER BY Preco_Venda;

/* 2.4 Aparelhos seminovos ainda em quarentena e quando ela termina (RN-25) */
SELECT Imei, Data_Entrada, Data_Fim_Quarentena,
       DATEDIFF(Data_Fim_Quarentena, CURDATE()) AS Dias_Restantes
  FROM APARELHO
 WHERE Status = 'Em quarentena'
 ORDER BY Data_Fim_Quarentena;

/* 2.5 Aparelhos disponíveis elegíveis ao desconto Pix */
SELECT Imei, Condicao, Preco_Venda
  FROM APARELHO
 WHERE Status = 'Disponível'
   AND Elegivel_Desconto_Pix = 1;

/* 2.6 Aparelhos fora do estoque de venda (manutenção, avaliação ou inativos) */
SELECT Imei, Status, Condicao
  FROM APARELHO
 WHERE Status IN ('Em manutenção', 'Em avaliação', 'Inativo')
 ORDER BY Status;

/* 2.7 Aparelhos com preço de venda entre R$ 1.000,00 e R$ 3.000,00 */
SELECT Imei, Condicao, Preco_Venda, Status
  FROM APARELHO
 WHERE Preco_Venda BETWEEN 1000.00 AND 3000.00
 ORDER BY Preco_Venda;

/* 2.8 Os 5 aparelhos disponíveis mais caros */
SELECT Imei, Condicao, Preco_Venda
  FROM APARELHO
 WHERE Status = 'Disponível'
 ORDER BY Preco_Venda DESC
 LIMIT 5;


/* =====================================================================
   3. Clientes e fornecedores
   ===================================================================== */

/* 3.1 Clientes pessoa física com a idade calculada */
SELECT Cpf_Cnpj, Nome, Email, Data_Nascimento,
       TIMESTAMPDIFF(YEAR, Data_Nascimento, CURDATE()) AS Idade
  FROM CLIENTE
 WHERE Tipo_Pessoa = 'PF'
 ORDER BY Nome;

/* 3.2 Clientes pessoa jurídica */
SELECT Cpf_Cnpj AS Cnpj, Nome, Email
  FROM CLIENTE
 WHERE Tipo_Pessoa = 'PJ'
 ORDER BY Nome;

/* 3.3 Clientes com e-mail do Gmail (LIKE) */
SELECT Nome, Email
  FROM CLIENTE
 WHERE Email LIKE '%@gmail.com';

/* 3.4 Fornecedores pessoa física e o documento com foto apresentado */
SELECT Cpf_Cnpj_Fornecedor AS Cpf, Nome, Tipo_Documento, Numero_Documento
  FROM FORNECEDOR
 WHERE Tipo_Pessoa = 'PF';

/* 3.5 Fornecedores empresas (nome contendo Ltda ou S.A.) */
SELECT Cpf_Cnpj_Fornecedor AS Cnpj, Nome, Telefone_Contato
  FROM FORNECEDOR
 WHERE Tipo_Pessoa = 'PJ'
   AND (Nome LIKE '%Ltda%' OR Nome LIKE '%S.A.%');


/* =====================================================================
   4. Pedidos, pagamentos e entregas
   ===================================================================== */

/* 4.1 Pedidos aguardando pagamento */
SELECT Id_Pedido, Cpf_Cnpj, Data_Pedido, Forma_Pagamento, Valor_Final
  FROM PEDIDO
 WHERE Status_Pedido = 'Aguardando pagamento'
 ORDER BY Data_Pedido;

/* 4.2 Pedidos pagos no Pix que receberam desconto */
SELECT Id_Pedido, Valor_Produtos, Percentual_Desconto_Pix, Valor_Desconto, Valor_Final
  FROM PEDIDO
 WHERE Forma_Pagamento = 'Pix'
   AND Valor_Desconto IS NOT NULL;

/* 4.3 Pedidos no cartão parcelados em mais de 1 vez */
SELECT Id_Pedido, Numero_Parcelas, Valor_Taxas, Valor_Final,
       ROUND(Valor_Final / Numero_Parcelas, 2) AS Valor_Parcela
  FROM PEDIDO
 WHERE Forma_Pagamento = 'Cartão de crédito'
   AND Numero_Parcelas > 1;

/* 4.4 Pedidos feitos nos últimos 30 dias */
SELECT Id_Pedido, Data_Pedido, Status_Pedido, Valor_Final
  FROM PEDIDO
 WHERE Data_Pedido >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
 ORDER BY Data_Pedido DESC;

/* 4.5 Pagamentos recusados ou expirados */
SELECT Id_Pagamento, Id_Pedido, Data_Tentativa, Valor, Status
  FROM PAGAMENTO
 WHERE Status IN ('Recusado', 'Expirado')
 ORDER BY Data_Tentativa;

/* 4.6 Entregas em transporte há mais de 5 dias */
SELECT Codigo_Rastreio, Id_Pedido, Transportadora, Data_Despacho,
       DATEDIFF(CURDATE(), Data_Despacho) AS Dias_Em_Transporte
  FROM ENTREGA
 WHERE Status_Entrega = 'Em transporte'
   AND DATEDIFF(CURDATE(), Data_Despacho) > 5;

/* 4.7 Entregas de reposição (geradas por troca) */
SELECT Codigo_Rastreio, Id_Pedido, Codigo_Troca, Status_Entrega
  FROM ENTREGA
 WHERE Codigo_Troca IS NOT NULL;


/* =====================================================================
   5. Pós-venda, fiscal e financeiro
   ===================================================================== */

/* 5.1 Solicitações de pós-venda em aberto */
SELECT Id_PosVenda, Id_Pedido, Imei, Tipo_Solicitacao, Data_Abertura, Status
  FROM POS_VENDA
 WHERE Status IN ('Aberta', 'Em análise')
 ORDER BY Data_Abertura;

/* 5.2 Notas fiscais ainda não emitidas */
SELECT Id_Nota, Tipo_Nota, Natureza, Status
  FROM NOTA_FISCAL
 WHERE Status IN ('Aguardando emissão', 'Pendente');

/* 5.3 Estornos pendentes e quantos dias faltam para o prazo de 15 dias (RN-19) */
SELECT Id_Estorno, Id_Pagamento, Valor, Data_Abertura, Prazo_Limite,
       DATEDIFF(Prazo_Limite, NOW()) AS Dias_Para_O_Prazo
  FROM ESTORNO
 WHERE Status = 'Pendente'
 ORDER BY Prazo_Limite;

/* 5.4 Requisições de compra em aberto */
SELECT Id_Requisicao, Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo,
       Qtd_Sugerida, Data_Abertura, Status
  FROM REQUISICAO_COMPRA
 WHERE Status IN ('Aguardando Análise Financeira', 'Aguardando Aprovação da Diretoria')
 ORDER BY Data_Abertura;

/* 5.5 Aquisições recusadas */
SELECT Id_Aquisicao, Cpf_Cnpj_Fornecedor, Data_Aquisicao, Tipo_Documento_Compra
  FROM AQUISICAO
 WHERE Status = 'Recusada';


/* =====================================================================
   6. Funções de agregação (COUNT, SUM, AVG, MIN, MAX)
   ===================================================================== */

/* 6.1 Quantidade de aparelhos por status */
SELECT Status, COUNT(*) AS Quantidade
  FROM APARELHO
 GROUP BY Status
 ORDER BY Quantidade DESC;

/* 6.2 Preço médio, mínimo e máximo dos aparelhos disponíveis, por condição */
SELECT Condicao,
       COUNT(*)                   AS Quantidade,
       ROUND(AVG(Preco_Venda), 2) AS Preco_Medio,
       MIN(Preco_Venda)           AS Menor_Preco,
       MAX(Preco_Venda)           AS Maior_Preco
  FROM APARELHO
 WHERE Status = 'Disponível'
 GROUP BY Condicao;

/* 6.3 Quantidade de pedidos e valor total por status do pedido */
SELECT Status_Pedido, COUNT(*) AS Pedidos, SUM(Valor_Final) AS Valor_Total
  FROM PEDIDO
 GROUP BY Status_Pedido;

/* 6.4 Quantidade de pedidos por forma de pagamento */
SELECT Forma_Pagamento, COUNT(*) AS Pedidos
  FROM PEDIDO
 GROUP BY Forma_Pagamento;

/* 6.5 Tipos de solicitação de pós-venda com mais de 1 ocorrência (HAVING) */
SELECT Tipo_Solicitacao, COUNT(*) AS Quantidade
  FROM POS_VENDA
 GROUP BY Tipo_Solicitacao
HAVING COUNT(*) > 1;

/* 6.6 Aquisições concluídas por fornecedor e o valor investido */
SELECT Cpf_Cnpj_Fornecedor, COUNT(*) AS Aquisicoes, SUM(Valor_Total) AS Valor_Investido
  FROM AQUISICAO
 WHERE Status = 'Concluída'
 GROUP BY Cpf_Cnpj_Fornecedor
 ORDER BY Valor_Investido DESC;
