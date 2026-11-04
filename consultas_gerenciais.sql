/* =====================================================================
   CellGO — Consultas gerenciais
   SGBD: MySQL 8
   Execute depois de tabelas.sql e trigger.sql (o banco precisa existir
   e conter dados para as consultas retornarem linhas).

   O QUE É UMA CONSULTA GERENCIAL?
   É uma consulta que responde a uma pergunta de quem toma decisões
   (dono, diretoria, gerente): quanto vendemos? o que dá mais lucro?
   o que precisa ser reposto? Quase sempre usa:
     - JOIN         para juntar tabelas relacionadas;
     - GROUP BY     para agrupar linhas (por mês, por modelo, por cliente);
     - SUM, COUNT, AVG   (funções de agregação) para resumir cada grupo.

   REGRA IMPORTANTE DO GROUP BY (modo ONLY_FULL_GROUP_BY do MySQL 8):
   toda coluna do SELECT que NÃO esteja dentro de SUM/COUNT/AVG/MAX
   precisa aparecer também no GROUP BY.

   REGRA DE NEGÓCIO USADA NAS VENDAS:
   só contam como venda os pedidos com Status_Pedido 'Pago' ou
   'Finalizado'. Pedido 'Aberto', 'Aguardando pagamento' ou 'Cancelado'
   ainda não é (ou deixou de ser) receita.
   ===================================================================== */

USE cellgo;


/* =====================================================================
   1. PAINEL RESUMO (visão geral em uma única linha)
   Pergunta: como está a loja hoje, em poucos números?
   Como funciona: cada coluna é uma subconsulta (SELECT dentro de
   parênteses) que devolve um único valor.
   ===================================================================== */
SELECT
    (SELECT COUNT(*)
       FROM PEDIDO
      WHERE Status_Pedido IN ('Pago', 'Finalizado'))              AS pedidos_vendidos,
    (SELECT COALESCE(SUM(Valor_Final), 0)
       FROM PEDIDO
      WHERE Status_Pedido IN ('Pago', 'Finalizado'))              AS faturamento_total,
    (SELECT COALESCE(ROUND(AVG(Valor_Final), 2), 0)
       FROM PEDIDO
      WHERE Status_Pedido IN ('Pago', 'Finalizado'))              AS ticket_medio,
    (SELECT COUNT(*)
       FROM APARELHO
      WHERE Status = 'Disponível')                                AS aparelhos_disponiveis,
    (SELECT COALESCE(SUM(Custo_Aquisicao), 0)
       FROM APARELHO
      WHERE Status = 'Disponível')                                AS capital_parado_em_estoque,
    (SELECT COUNT(*)
       FROM REQUISICAO_COMPRA
      WHERE Status IN ('Aguardando Análise Financeira',
                       'Aguardando Aprovação da Diretoria'))      AS requisicoes_de_compra_abertas;


/* =====================================================================
   2. FATURAMENTO POR MÊS
   Pergunta: quanto a loja faturou em cada mês?
   Dica: DATE_FORMAT(data, '%Y-%m') transforma uma data em 'ano-mês',
   que é o que usamos para agrupar.
   Valor_Final já considera desconto Pix e taxas do cartão.
   ===================================================================== */
SELECT
    DATE_FORMAT(p.Data_Pedido, '%Y-%m')          AS mes,
    COUNT(*)                                     AS qtd_pedidos,
    SUM(p.Valor_Produtos)                        AS total_produtos,
    SUM(COALESCE(p.Valor_Desconto, 0))           AS total_descontos,
    SUM(COALESCE(p.Valor_Taxas, 0))              AS total_taxas,
    SUM(p.Valor_Final)                           AS faturamento,
    ROUND(AVG(p.Valor_Final), 2)                 AS ticket_medio
FROM PEDIDO p
WHERE p.Status_Pedido IN ('Pago', 'Finalizado')
GROUP BY DATE_FORMAT(p.Data_Pedido, '%Y-%m')
ORDER BY mes;


/* =====================================================================
   3. VENDAS POR FORMA DE PAGAMENTO
   Pergunta: Pix ou cartão? Qual rende mais e quanto damos de desconto?
   Dica: a subconsulta no final calcula o faturamento total para
   transformar cada linha em porcentagem do todo.
   ===================================================================== */
SELECT
    p.Forma_Pagamento,
    COUNT(*)                                     AS qtd_pedidos,
    SUM(p.Valor_Final)                           AS faturamento,
    ROUND(AVG(p.Valor_Final), 2)                 AS ticket_medio,
    ROUND(AVG(p.Numero_Parcelas), 1)             AS media_parcelas,
    SUM(COALESCE(p.Valor_Desconto, 0))           AS descontos_concedidos,
    ROUND(100 * SUM(p.Valor_Final) /
          (SELECT SUM(Valor_Final)
             FROM PEDIDO
            WHERE Status_Pedido IN ('Pago', 'Finalizado')), 1) AS pct_do_faturamento
FROM PEDIDO p
WHERE p.Status_Pedido IN ('Pago', 'Finalizado')
GROUP BY p.Forma_Pagamento
ORDER BY faturamento DESC;


/* =====================================================================
   4. DESEMPENHO POR MODELO (mais vendidos e mais lucrativos)
   Pergunta: quais modelos vendem mais e deixam mais lucro?
   Lucro bruto = preço de venda do item - custo de aquisição do aparelho
   (antes de descontos Pix e taxas).
   Cadeia de JOINs: ITEM_PEDIDO -> PEDIDO (status da venda)
                    ITEM_PEDIDO -> APARELHO (custo)
                    APARELHO -> ESPECIFICACAO_APARELHO -> MODELO (nome)
   ===================================================================== */
SELECT
    m.Marca,
    m.Nome_Modelo,
    COUNT(*)                                          AS unidades_vendidas,
    SUM(i.Preco_Unitario)                             AS receita,
    SUM(a.Custo_Aquisicao)                            AS custo,
    SUM(i.Preco_Unitario - a.Custo_Aquisicao)         AS lucro_bruto,
    ROUND(100 * SUM(i.Preco_Unitario - a.Custo_Aquisicao)
              / SUM(i.Preco_Unitario), 1)             AS margem_pct
FROM ITEM_PEDIDO i
JOIN PEDIDO p                  ON p.Id_Pedido = i.Id_Pedido
JOIN APARELHO a                ON a.Imei = i.Imei
JOIN ESPECIFICACAO_APARELHO e  ON e.Id_Especificacao = a.Id_Especificacao
JOIN MODELO m                  ON m.Id_Modelo = e.Id_Modelo
WHERE p.Status_Pedido IN ('Pago', 'Finalizado')
GROUP BY m.Id_Modelo, m.Marca, m.Nome_Modelo
ORDER BY lucro_bruto DESC;


/* =====================================================================
   5. NOVO x SEMINOVO
   Pergunta: qual condição de aparelho dá mais retorno?
   ===================================================================== */
SELECT
    a.Condicao,
    COUNT(*)                                          AS unidades_vendidas,
    SUM(i.Preco_Unitario)                             AS receita,
    SUM(i.Preco_Unitario - a.Custo_Aquisicao)         AS lucro_bruto,
    ROUND(AVG(i.Preco_Unitario - a.Custo_Aquisicao), 2) AS lucro_medio_por_aparelho,
    ROUND(100 * SUM(i.Preco_Unitario - a.Custo_Aquisicao)
              / SUM(i.Preco_Unitario), 1)             AS margem_pct
FROM ITEM_PEDIDO i
JOIN PEDIDO p   ON p.Id_Pedido = i.Id_Pedido
JOIN APARELHO a ON a.Imei = i.Imei
WHERE p.Status_Pedido IN ('Pago', 'Finalizado')
GROUP BY a.Condicao
ORDER BY lucro_bruto DESC;


/* =====================================================================
   6. MELHORES CLIENTES (top 10)
   Pergunta: quem mais compra na loja?
   Dica: LIMIT 10 mostra só as 10 primeiras linhas depois do ORDER BY.
   ===================================================================== */
SELECT
    c.Cpf_Cnpj,
    c.Nome,
    c.Tipo_Pessoa,
    COUNT(p.Id_Pedido)       AS qtd_pedidos,
    SUM(p.Valor_Final)       AS total_gasto,
    MAX(p.Data_Pedido)       AS ultima_compra
FROM CLIENTE c
JOIN PEDIDO p ON p.Cpf_Cnpj = c.Cpf_Cnpj
WHERE p.Status_Pedido IN ('Pago', 'Finalizado')
GROUP BY c.Cpf_Cnpj, c.Nome, c.Tipo_Pessoa
ORDER BY total_gasto DESC
LIMIT 10;


/* =====================================================================
   7. ESTOQUE ATUAL x ESTOQUE MÍNIMO
   Pergunta: o que precisa ser reposto?
   Dica: usamos LEFT JOIN para que uma especificação SEM nenhum aparelho
   disponível também apareça (com quantidade 0). Com JOIN comum ela
   sumiria justamente quando o problema é maior.
   SUM(CASE WHEN ... THEN 1 ELSE 0 END) conta só as linhas que atendem
   à condição. A consulta de fora (t) reaproveita o resultado da de
   dentro para calcular 'faltam' e 'situacao'.
   ===================================================================== */
SELECT
    t.*,
    GREATEST(t.Estoque_Minimo - t.qtd_disponivel, 0)       AS faltam,
    CASE
        WHEN t.qtd_disponivel < t.Estoque_Minimo THEN 'Repor'
        ELSE 'OK'
    END                                                    AS situacao
FROM (
    SELECT
        e.Id_Especificacao,
        m.Marca,
        m.Nome_Modelo,
        e.Cor,
        e.Capacidade,
        e.Estoque_Minimo,
        SUM(CASE WHEN a.Status = 'Disponível' THEN 1 ELSE 0 END) AS qtd_disponivel
    FROM ESPECIFICACAO_APARELHO e
    JOIN MODELO m          ON m.Id_Modelo = e.Id_Modelo
    LEFT JOIN APARELHO a   ON a.Id_Especificacao = e.Id_Especificacao
    GROUP BY e.Id_Especificacao, m.Marca, m.Nome_Modelo,
             e.Cor, e.Capacidade, e.Estoque_Minimo
) t
ORDER BY faltam DESC, t.Marca, t.Nome_Modelo;


/* =====================================================================
   8. APARELHOS POR STATUS E CAPITAL IMOBILIZADO
   Pergunta: onde está o dinheiro do estoque?
   valor_a_custo   = quanto a loja pagou pelos aparelhos;
   valor_de_venda  = quanto receberia se vendesse todos pelo preço atual.
   ===================================================================== */
SELECT
    a.Status,
    COUNT(*)                  AS qtd_aparelhos,
    SUM(a.Custo_Aquisicao)    AS valor_a_custo,
    SUM(a.Preco_Venda)        AS valor_de_venda
FROM APARELHO a
GROUP BY a.Status
ORDER BY qtd_aparelhos DESC;


/* =====================================================================
   9. GIRO: TEMPO PARADO NO ESTOQUE
   Pergunta: quais aparelhos disponíveis estão encalhados?
   Regra: cada especificação tem seus limites em dias
   (Limite_Dias_Atencao e Limite_Dias_Critico). Ao atingir o limite,
   o aparelho muda de faixa: Normal -> Atenção -> Crítico.
   Dica: DATEDIFF(data_fim, data_inicio) devolve a diferença em dias.
   ===================================================================== */
SELECT
    t.*,
    CASE
        WHEN t.dias_em_estoque >= t.Limite_Dias_Critico THEN 'Crítico'
        WHEN t.dias_em_estoque >= t.Limite_Dias_Atencao THEN 'Atenção'
        ELSE 'Normal'
    END AS situacao_giro
FROM (
    SELECT
        a.Imei,
        m.Marca,
        m.Nome_Modelo,
        e.Cor,
        e.Capacidade,
        a.Preco_Venda,
        a.Data_Disponivel,
        DATEDIFF(CURDATE(), a.Data_Disponivel) AS dias_em_estoque,
        e.Limite_Dias_Atencao,
        e.Limite_Dias_Critico
    FROM APARELHO a
    JOIN ESPECIFICACAO_APARELHO e ON e.Id_Especificacao = a.Id_Especificacao
    JOIN MODELO m                 ON m.Id_Modelo = e.Id_Modelo
    WHERE a.Status = 'Disponível'
) t
ORDER BY t.dias_em_estoque DESC;


/* =====================================================================
   10. AQUISIÇÕES: GASTO E QUALIDADE POR FORNECEDOR
   Pergunta: de quem compramos, quanto gastamos e quantos aparelhos
   são aprovados na avaliação de entrada?
   Atenção: Valor_Total fica em AQUISICAO. Se juntássemos com
   AVALIACAO_ENTRADA no mesmo SELECT, o valor se repetiria a cada
   aparelho e a soma sairia errada. Por isso são duas consultas.
   ===================================================================== */

/* 10a) Gasto por fornecedor (aquisições concluídas) */
SELECT
    f.Cpf_Cnpj_Fornecedor,
    f.Nome,
    f.Tipo_Pessoa,
    COUNT(*)                 AS qtd_aquisicoes,
    SUM(aq.Valor_Total)      AS total_gasto
FROM AQUISICAO aq
JOIN FORNECEDOR f ON f.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
WHERE aq.Status = 'Concluída'
GROUP BY f.Cpf_Cnpj_Fornecedor, f.Nome, f.Tipo_Pessoa
ORDER BY total_gasto DESC;

/* 10b) Taxa de aprovação/recusa na avaliação de entrada */
SELECT
    f.Cpf_Cnpj_Fornecedor,
    f.Nome,
    COUNT(*)                                                    AS aparelhos_avaliados,
    SUM(CASE WHEN ae.Resultado = 'Aprovado' THEN 1 ELSE 0 END)  AS aprovados,
    SUM(CASE WHEN ae.Resultado = 'Recusado' THEN 1 ELSE 0 END)  AS recusados,
    ROUND(100 * SUM(CASE WHEN ae.Resultado = 'Recusado' THEN 1 ELSE 0 END)
              / COUNT(*), 1)                                    AS taxa_recusa_pct
FROM AVALIACAO_ENTRADA ae
JOIN AQUISICAO aq ON aq.Id_Aquisicao = ae.Id_Aquisicao
JOIN FORNECEDOR f ON f.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
GROUP BY f.Cpf_Cnpj_Fornecedor, f.Nome
ORDER BY taxa_recusa_pct DESC;


/* =====================================================================
   11. REQUISIÇÕES DE COMPRA POR ETAPA
   Pergunta: quantas reposições estão paradas em cada etapa do fluxo
   (análise financeira -> diretoria -> aprovada/recusada)?
   ===================================================================== */
SELECT
    rc.Status,
    COUNT(*)               AS qtd_requisicoes,
    SUM(rc.Qtd_Sugerida)   AS aparelhos_sugeridos
FROM REQUISICAO_COMPRA rc
GROUP BY rc.Status
ORDER BY qtd_requisicoes DESC;


/* =====================================================================
   12. PÓS-VENDA: PROBLEMAS POR MODELO
   Pergunta: quais modelos mais voltam com defeito, garantia ou
   arrependimento?
   ===================================================================== */
SELECT
    m.Marca,
    m.Nome_Modelo,
    COUNT(*)                                                            AS qtd_solicitacoes,
    SUM(CASE WHEN pv.Tipo_Solicitacao = 'Defeito' THEN 1 ELSE 0 END)        AS defeitos,
    SUM(CASE WHEN pv.Tipo_Solicitacao = 'Garantia' THEN 1 ELSE 0 END)       AS garantias,
    SUM(CASE WHEN pv.Tipo_Solicitacao = 'Arrependimento' THEN 1 ELSE 0 END) AS arrependimentos
FROM POS_VENDA pv
JOIN APARELHO a                ON a.Imei = pv.Imei
JOIN ESPECIFICACAO_APARELHO e  ON e.Id_Especificacao = a.Id_Especificacao
JOIN MODELO m                  ON m.Id_Modelo = e.Id_Modelo
GROUP BY m.Id_Modelo, m.Marca, m.Nome_Modelo
ORDER BY qtd_solicitacoes DESC;


/* =====================================================================
   13. PÓS-VENDA: EM QUE CADA TIPO DE SOLICITAÇÃO SE TRANSFORMA
   Pergunta: quantas solicitações viram troca, devolução ou nada?
   Dica: como TROCA e DEVOLUCAO têm no máximo uma linha por solicitação
   (UNIQUE em Id_PosVenda), o LEFT JOIN não duplica contagens.
   ===================================================================== */
SELECT
    pv.Tipo_Solicitacao,
    COUNT(*)                                                       AS total,
    SUM(CASE WHEN t.Codigo_Troca IS NOT NULL THEN 1 ELSE 0 END)    AS viraram_troca,
    SUM(CASE WHEN d.Codigo_Devolucao IS NOT NULL THEN 1 ELSE 0 END) AS viraram_devolucao,
    SUM(CASE WHEN t.Codigo_Troca IS NULL
              AND d.Codigo_Devolucao IS NULL THEN 1 ELSE 0 END)    AS sem_troca_nem_devolucao
FROM POS_VENDA pv
LEFT JOIN TROCA t      ON t.Id_PosVenda = pv.Id_PosVenda
LEFT JOIN DEVOLUCAO d  ON d.Id_PosVenda = pv.Id_PosVenda
GROUP BY pv.Tipo_Solicitacao
ORDER BY total DESC;


/* =====================================================================
   14. AVALIAÇÕES DE DANO: CAUSA x COBERTURA DA GARANTIA
   Pergunta: o que está causando os danos e quanto a garantia cobre?
   Cobertura_Garantia é BOOLEAN (0 ou 1): SUM dá o total de cobertos.
   ===================================================================== */
SELECT
    ad.Classificacao_Dano,
    ad.Destino_Aparelho,
    COUNT(*)                                  AS qtd_avaliacoes,
    SUM(ad.Cobertura_Garantia)                AS cobertas_pela_garantia,
    COUNT(*) - SUM(ad.Cobertura_Garantia)     AS nao_cobertas
FROM AVALIACAO_DANO ad
GROUP BY ad.Classificacao_Dano, ad.Destino_Aparelho
ORDER BY qtd_avaliacoes DESC;


/* =====================================================================
   15. ESTORNOS: VALOR E PRAZO
   Pergunta: quanto dinheiro devolvemos e há estorno atrasado?
   Regra: Prazo_Limite = Data_Abertura + 15 dias. Estorno Pendente
   depois desse prazo está fora do prazo.
   ===================================================================== */
SELECT
    e.Status,
    COUNT(*)        AS qtd_estornos,
    SUM(e.Valor)    AS valor_total,
    SUM(CASE WHEN e.Status = 'Pendente' AND NOW() > e.Prazo_Limite
             THEN 1 ELSE 0 END)   AS pendentes_fora_do_prazo
FROM ESTORNO e
GROUP BY e.Status
ORDER BY valor_total DESC;


/* =====================================================================
   16. TAXA DE CANCELAMENTO
   Pergunta: que porcentagem dos pedidos acaba cancelada?
   ===================================================================== */
SELECT
    COUNT(*)                                                         AS total_pedidos,
    SUM(CASE WHEN p.Status_Pedido = 'Cancelado' THEN 1 ELSE 0 END)   AS cancelados,
    ROUND(100 * SUM(CASE WHEN p.Status_Pedido = 'Cancelado' THEN 1 ELSE 0 END)
              / COUNT(*), 1)                                         AS taxa_cancelamento_pct
FROM PEDIDO p;


/* =====================================================================
   17. DESEMPENHO DAS TRANSPORTADORAS
   Pergunta: qual transportadora entrega mais e mais rápido?
   Dica: o CASE dentro do AVG ignora entregas ainda não concluídas
   (valores NULL não entram na média).
   Tempo médio em dias = horas entre despacho e entrega / 24.
   ===================================================================== */
SELECT
    en.Transportadora,
    COUNT(*)                                                         AS total_entregas,
    SUM(CASE WHEN en.Status_Entrega = 'Entregue' THEN 1 ELSE 0 END)  AS entregues,
    ROUND(AVG(CASE WHEN en.Status_Entrega = 'Entregue'
                   THEN TIMESTAMPDIFF(HOUR, en.Data_Despacho, en.Data_Entrega)
              END) / 24, 1)                                          AS media_dias_ate_entrega
FROM ENTREGA en
GROUP BY en.Transportadora
ORDER BY entregues DESC;
