/* =====================================================================
   CellGO — Triggers
   SGBD: MySQL 8
   Execute depois de tabelas.sql.

   Funcionário responsável pela operação:
   - As triggers leem a variável de sessão @cellgo_funcionario para saber
     quem está executando a ação. A aplicação deve definir essa variável
     logo após o login, por exemplo:  SET @cellgo_funcionario = 5;
   - Quando a variável está vazia (NULL), a ação é registrada como
     automática (MOVIMENTACAO e AUDITORIA aceitam funcionário vazio).
   - Ações exclusivas da Diretoria (alterar preço, elegibilidade ao
     desconto Pix e parâmetros de estoque, decidir requisições de
     compra) exigem que @cellgo_funcionario seja um funcionário ativo
     com perfil Diretoria.
   ===================================================================== */

SET NAMES utf8mb4;
USE cellgo;

DELIMITER $$


/* =====================================================================
   CLIENTE — cliente pessoa física deve ter pelo menos 18 anos (RN-01)
   ===================================================================== */
CREATE TRIGGER trg_cliente_bi
BEFORE INSERT ON CLIENTE
FOR EACH ROW
BEGIN
    IF NEW.Tipo_Pessoa = 'PF' THEN
        IF NEW.Data_Nascimento IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Informe a data de nascimento do cliente pessoa física.';
        ELSEIF TIMESTAMPDIFF(YEAR, NEW.Data_Nascimento, CURDATE()) < 18 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O cliente pessoa física deve ter pelo menos 18 anos.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_cliente_bu
BEFORE UPDATE ON CLIENTE
FOR EACH ROW
BEGIN
    IF NEW.Tipo_Pessoa = 'PF' THEN
        IF NEW.Data_Nascimento IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Informe a data de nascimento do cliente pessoa física.';
        ELSEIF TIMESTAMPDIFF(YEAR, NEW.Data_Nascimento, CURDATE()) < 18 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O cliente pessoa física deve ter pelo menos 18 anos.';
        END IF;
    END IF;
END$$


/* =====================================================================
   ENDERECO e TELEFONE — o cliente precisa manter pelo menos um
   endereço e um telefone (cardinalidade 1,n — RN-01)
   ===================================================================== */
CREATE TRIGGER trg_endereco_bd
BEFORE DELETE ON ENDERECO
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM ENDERECO WHERE Cpf_Cnpj = OLD.Cpf_Cnpj) <= 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O cliente precisa ter pelo menos um endereço cadastrado.';
    END IF;
END$$

CREATE TRIGGER trg_telefone_bd
BEFORE DELETE ON TELEFONE
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM TELEFONE WHERE Cpf_Cnpj = OLD.Cpf_Cnpj) <= 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O cliente precisa ter pelo menos um telefone cadastrado.';
    END IF;
END$$


/* =====================================================================
   ESPECIFICACAO_APARELHO — parâmetros de estoque (estoque mínimo e
   limites de giro) só podem ser ajustados pela Diretoria (RN-02/RN-24)
   ===================================================================== */
CREATE TRIGGER trg_especificacao_bu
BEFORE UPDATE ON ESPECIFICACAO_APARELHO
FOR EACH ROW
BEGIN
    IF NEW.Estoque_Minimo <> OLD.Estoque_Minimo
       OR NEW.Limite_Dias_Atencao <> OLD.Limite_Dias_Atencao
       OR NEW.Limite_Dias_Critico <> OLD.Limite_Dias_Critico THEN
        IF (SELECT COUNT(*)
              FROM FUNCIONARIO f
              JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
             WHERE f.Codigo_Funcionario = @cellgo_funcionario
               AND f.Ativo = 1
               AND p.Nome_Perfil = 'Diretoria') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Somente a Diretoria pode alterar os parâmetros de estoque.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_especificacao_au
AFTER UPDATE ON ESPECIFICACAO_APARELHO
FOR EACH ROW
BEGIN
    IF NEW.Estoque_Minimo <> OLD.Estoque_Minimo
       OR NEW.Limite_Dias_Atencao <> OLD.Limite_Dias_Atencao
       OR NEW.Limite_Dias_Critico <> OLD.Limite_Dias_Critico THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Codigo_Autorizador, Acao, Tabela_Afetada,
                               Registro_Id, Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario, @cellgo_funcionario, 'Alteração de parâmetros de estoque',
                'ESPECIFICACAO_APARELHO', CAST(NEW.Id_Especificacao AS CHAR),
                JSON_OBJECT('Estoque_Minimo', OLD.Estoque_Minimo,
                            'Limite_Dias_Atencao', OLD.Limite_Dias_Atencao,
                            'Limite_Dias_Critico', OLD.Limite_Dias_Critico),
                JSON_OBJECT('Estoque_Minimo', NEW.Estoque_Minimo,
                            'Limite_Dias_Atencao', NEW.Limite_Dias_Atencao,
                            'Limite_Dias_Critico', NEW.Limite_Dias_Critico),
                'Parâmetros de estoque ajustados pela Diretoria.');
    END IF;
END$$


/* =====================================================================
   AQUISICAO
   - registrada por funcionário ativo do perfil Estoque e Logística;
   - pessoa física: termo de compra e venda + termo de responsabilidade
     aceito; pessoa jurídica: nota fiscal do fornecedor, sem termo;
   - Valor_Total é derivado: soma do Custo_Aquisicao dos aparelhos
     cadastrados a partir das avaliações aprovadas desta aquisição.
   ===================================================================== */
CREATE TRIGGER trg_aquisicao_bi
BEFORE INSERT ON AQUISICAO
FOR EACH ROW
BEGIN
    DECLARE v_tipo_pessoa VARCHAR(2);

    IF (SELECT COUNT(*)
          FROM FUNCIONARIO f
          JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
         WHERE f.Codigo_Funcionario = NEW.Codigo_Funcionario
           AND f.Ativo = 1
           AND p.Nome_Perfil = 'Estoque e Logística') = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A aquisição deve ser registrada por funcionário ativo de Estoque e Logística.';
    END IF;

    SELECT Tipo_Pessoa INTO v_tipo_pessoa
      FROM FORNECEDOR
     WHERE Cpf_Cnpj_Fornecedor = NEW.Cpf_Cnpj_Fornecedor;

    IF v_tipo_pessoa = 'PF' THEN
        IF NEW.Tipo_Documento_Compra <> 'Termo de compra e venda' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Compra de pessoa física exige o termo de compra e venda.';
        END IF;
        IF NEW.Termo_Responsabilidade_Aceito IS NULL OR NEW.Termo_Responsabilidade_Aceito <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O fornecedor pessoa física deve aceitar o termo de responsabilidade.';
        END IF;
    ELSEIF v_tipo_pessoa = 'PJ' THEN
        IF NEW.Tipo_Documento_Compra <> 'Nota fiscal do fornecedor' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Compra de pessoa jurídica exige a nota fiscal do fornecedor.';
        END IF;
        IF NEW.Termo_Responsabilidade_Aceito IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O termo de responsabilidade é usado apenas para pessoa física.';
        END IF;
    END IF;

    IF NEW.Status <> 'Em avaliação' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uma nova aquisição começa com status Em avaliação.';
    END IF;

    /* derivado: ainda não há aparelhos cadastrados */
    SET NEW.Valor_Total = 0.00;
END$$

CREATE TRIGGER trg_aquisicao_bu
BEFORE UPDATE ON AQUISICAO
FOR EACH ROW
BEGIN
    IF NEW.Cpf_Cnpj_Fornecedor <> OLD.Cpf_Cnpj_Fornecedor
       OR NEW.Data_Aquisicao <> OLD.Data_Aquisicao THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Fornecedor e data da aquisição não podem ser alterados.';
    END IF;

    IF NEW.Status <> OLD.Status THEN
        IF OLD.Status <> 'Em avaliação' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Aquisição concluída ou recusada não pode mudar de status.';
        END IF;
        IF NEW.Status = 'Concluída'
           AND (SELECT COUNT(*) FROM AVALIACAO_ENTRADA
                 WHERE Id_Aquisicao = NEW.Id_Aquisicao AND Resultado = 'Aprovado') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A aquisição só é concluída com pelo menos um aparelho aprovado.';
        END IF;
        IF NEW.Status = 'Recusada'
           AND (SELECT COUNT(*) FROM AVALIACAO_ENTRADA
                 WHERE Id_Aquisicao = NEW.Id_Aquisicao AND Resultado = 'Aprovado') > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Aquisição com aparelho aprovado não pode ser recusada.';
        END IF;
    END IF;

    /* derivado: sempre recalculado a partir dos aparelhos */
    SET NEW.Valor_Total = (SELECT COALESCE(SUM(a.Custo_Aquisicao), 0)
                             FROM APARELHO a
                             JOIN AVALIACAO_ENTRADA e ON e.Id_Avaliacao_Entrada = a.Id_Avaliacao_Entrada
                            WHERE e.Id_Aquisicao = NEW.Id_Aquisicao);
END$$


/* =====================================================================
   AVALIACAO_ENTRADA
   - feita por funcionário ativo da Assistência Técnica;
   - só em aquisição Em avaliação;
   - limite de 3 aparelhos aprovados por CPF (fornecedor pessoa física)
     por dia (RN-25).
   ===================================================================== */
CREATE TRIGGER trg_aval_entrada_bi
BEFORE INSERT ON AVALIACAO_ENTRADA
FOR EACH ROW
BEGIN
    DECLARE v_status_aquisicao VARCHAR(20);
    DECLARE v_data_aquisicao DATE;
    DECLARE v_fornecedor VARCHAR(14);
    DECLARE v_tipo_pessoa VARCHAR(2);

    IF (SELECT COUNT(*)
          FROM FUNCIONARIO f
          JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
         WHERE f.Codigo_Funcionario = NEW.Codigo_Funcionario
           AND f.Ativo = 1
           AND p.Nome_Perfil = 'Assistência Técnica') = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A avaliação de entrada deve ser feita por funcionário ativo da Assistência Técnica.';
    END IF;

    SELECT aq.Status, aq.Data_Aquisicao, aq.Cpf_Cnpj_Fornecedor, fo.Tipo_Pessoa
      INTO v_status_aquisicao, v_data_aquisicao, v_fornecedor, v_tipo_pessoa
      FROM AQUISICAO aq
      JOIN FORNECEDOR fo ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
     WHERE aq.Id_Aquisicao = NEW.Id_Aquisicao;

    IF v_status_aquisicao <> 'Em avaliação' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Só é possível avaliar aparelhos de uma aquisição Em avaliação.';
    END IF;

    IF DATE(NEW.Data_Consulta) < v_data_aquisicao THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A consulta do IMEI não pode ser anterior à data da aquisição.';
    END IF;

    IF (SELECT COUNT(*) FROM APARELHO WHERE Imei = NEW.Imei_Avaliado) > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Este IMEI já está cadastrado no estoque.';
    END IF;

    IF NEW.Resultado = 'Aprovado' AND v_tipo_pessoa = 'PF'
       AND (SELECT COUNT(*)
              FROM AVALIACAO_ENTRADA e
              JOIN AQUISICAO aq ON aq.Id_Aquisicao = e.Id_Aquisicao
             WHERE aq.Cpf_Cnpj_Fornecedor = v_fornecedor
               AND aq.Data_Aquisicao = v_data_aquisicao
               AND e.Resultado = 'Aprovado') >= 3 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Limite atingido: um mesmo CPF pode vender no máximo 3 aparelhos por dia.';
    END IF;
END$$

CREATE TRIGGER trg_aval_entrada_bu
BEFORE UPDATE ON AVALIACAO_ENTRADA
FOR EACH ROW
BEGIN
    DECLARE v_data_aquisicao DATE;
    DECLARE v_fornecedor VARCHAR(14);
    DECLARE v_tipo_pessoa VARCHAR(2);

    IF NEW.Id_Aquisicao <> OLD.Id_Aquisicao OR NEW.Imei_Avaliado <> OLD.Imei_Avaliado THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Aquisição e IMEI avaliado não podem ser alterados.';
    END IF;

    /* o aparelho já cadastrado não pode perder a aprovação */
    IF OLD.Resultado = 'Aprovado' AND NEW.Resultado = 'Recusado'
       AND (SELECT COUNT(*) FROM APARELHO WHERE Id_Avaliacao_Entrada = NEW.Id_Avaliacao_Entrada) > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Avaliação com aparelho já cadastrado não pode ser recusada.';
    END IF;

    IF OLD.Resultado = 'Recusado' AND NEW.Resultado = 'Aprovado' THEN
        SELECT aq.Data_Aquisicao, aq.Cpf_Cnpj_Fornecedor, fo.Tipo_Pessoa
          INTO v_data_aquisicao, v_fornecedor, v_tipo_pessoa
          FROM AQUISICAO aq
          JOIN FORNECEDOR fo ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
         WHERE aq.Id_Aquisicao = NEW.Id_Aquisicao;

        IF v_tipo_pessoa = 'PF'
           AND (SELECT COUNT(*)
                  FROM AVALIACAO_ENTRADA e
                  JOIN AQUISICAO aq ON aq.Id_Aquisicao = e.Id_Aquisicao
                 WHERE aq.Cpf_Cnpj_Fornecedor = v_fornecedor
                   AND aq.Data_Aquisicao = v_data_aquisicao
                   AND e.Resultado = 'Aprovado'
                   AND e.Id_Avaliacao_Entrada <> NEW.Id_Avaliacao_Entrada) >= 3 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Limite atingido: um mesmo CPF pode vender no máximo 3 aparelhos por dia.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_aval_entrada_au
AFTER UPDATE ON AVALIACAO_ENTRADA
FOR EACH ROW
BEGIN
    /* registro do fim de quarentena (nova consulta do IMEI) — RF-25 */
    IF OLD.Resultado_Reconsulta_Imei IS NULL AND NEW.Resultado_Reconsulta_Imei IS NOT NULL THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                               Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario, 'Reconsulta de IMEI', 'AVALIACAO_ENTRADA',
                CAST(NEW.Id_Avaliacao_Entrada AS CHAR),
                NULL,
                JSON_OBJECT('Imei', NEW.Imei_Avaliado,
                            'Data_Reconsulta_Imei', NEW.Data_Reconsulta_Imei,
                            'Resultado_Reconsulta_Imei', NEW.Resultado_Reconsulta_Imei),
                'Nova consulta do IMEI ao fim da quarentena.');
    END IF;
END$$


/* =====================================================================
   APARELHO
   BEFORE INSERT
   - só entra com avaliação de entrada Aprovada e com o mesmo IMEI;
   - seminovo comprado de pessoa física entra Em quarentena por 15 dias
     (Data_Fim_Quarentena = Data_Entrada + 15); os demais entram
     Disponíveis (RN-25).
   ===================================================================== */
CREATE TRIGGER trg_aparelho_bi
BEFORE INSERT ON APARELHO
FOR EACH ROW
BEGIN
    DECLARE v_resultado VARCHAR(10);
    DECLARE v_imei_avaliado CHAR(15);
    DECLARE v_data_aquisicao DATE;
    DECLARE v_tipo_pessoa VARCHAR(2);

    SELECT e.Resultado, e.Imei_Avaliado, aq.Data_Aquisicao, fo.Tipo_Pessoa
      INTO v_resultado, v_imei_avaliado, v_data_aquisicao, v_tipo_pessoa
      FROM AVALIACAO_ENTRADA e
      JOIN AQUISICAO aq ON aq.Id_Aquisicao = e.Id_Aquisicao
      JOIN FORNECEDOR fo ON fo.Cpf_Cnpj_Fornecedor = aq.Cpf_Cnpj_Fornecedor
     WHERE e.Id_Avaliacao_Entrada = NEW.Id_Avaliacao_Entrada;

    IF v_resultado <> 'Aprovado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Só é possível cadastrar aparelho com avaliação de entrada Aprovada.';
    END IF;

    IF v_imei_avaliado <> NEW.Imei THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O IMEI do aparelho deve ser o mesmo IMEI da avaliação de entrada.';
    END IF;

    IF NEW.Data_Entrada < v_data_aquisicao THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A data de entrada não pode ser anterior à data da aquisição.';
    END IF;

    IF (SELECT COUNT(*) FROM FUNCIONARIO
         WHERE Codigo_Funcionario = NEW.Codigo_Funcionario AND Ativo = 1) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O aparelho deve ser cadastrado por um funcionário ativo.';
    END IF;

    IF NEW.Status NOT IN ('Em quarentena', 'Disponível') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Um aparelho novo no estoque entra Em quarentena ou Disponível.';
    END IF;

    IF NEW.Condicao = 'Seminovo' AND v_tipo_pessoa = 'PF' THEN
        SET NEW.Status = 'Em quarentena';
        SET NEW.Data_Fim_Quarentena = DATE_ADD(NEW.Data_Entrada, INTERVAL 15 DAY);
        SET NEW.Data_Disponivel = NULL;
    ELSE
        SET NEW.Status = 'Disponível';
        SET NEW.Data_Fim_Quarentena = NULL;
        SET NEW.Data_Disponivel = COALESCE(NEW.Data_Disponivel, NEW.Data_Entrada);
    END IF;
END$$

/* AFTER INSERT: registra a entrada no histórico e recalcula o
   Valor_Total da aquisição */
CREATE TRIGGER trg_aparelho_ai
AFTER INSERT ON APARELHO
FOR EACH ROW
BEGIN
    INSERT INTO MOVIMENTACAO (Codigo_Funcionario, Imei, Tipo_Movimento,
                              Status_Anterior, Status_Novo, Data_Hora)
    VALUES (NEW.Codigo_Funcionario, NEW.Imei, 'Entrada', NULL, NEW.Status, NOW());

    /* a trigger de AQUISICAO recalcula o Valor_Total */
    UPDATE AQUISICAO
       SET Valor_Total = Valor_Total
     WHERE Id_Aquisicao = (SELECT Id_Aquisicao FROM AVALIACAO_ENTRADA
                            WHERE Id_Avaliacao_Entrada = NEW.Id_Avaliacao_Entrada);
END$$

/* BEFORE UPDATE
   - transições de status permitidas (RN-03);
   - fim de quarentena só depois dos 15 dias e com nova consulta Regular;
   - ao voltar para Disponível, a contagem do tempo em estoque reinicia
     (Data_Disponivel = hoje — RN-05);
   - preço e elegibilidade ao desconto Pix: somente a Diretoria. */
CREATE TRIGGER trg_aparelho_bu
BEFORE UPDATE ON APARELHO
FOR EACH ROW
BEGIN
    IF NEW.Imei <> OLD.Imei
       OR NEW.Id_Avaliacao_Entrada <> OLD.Id_Avaliacao_Entrada
       OR NEW.Condicao <> OLD.Condicao
       OR NEW.Data_Entrada <> OLD.Data_Entrada THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'IMEI, avaliação de entrada, condição e data de entrada não podem ser alterados.';
    END IF;

    IF NEW.Status <> OLD.Status THEN
        IF NOT (
               (OLD.Status = 'Em quarentena' AND NEW.Status IN ('Disponível', 'Inativo'))
            OR (OLD.Status = 'Disponível'    AND NEW.Status IN ('Vendido', 'Em avaliação', 'Em manutenção', 'Inativo'))
            OR (OLD.Status = 'Vendido'       AND NEW.Status IN ('Disponível', 'Em avaliação'))
            OR (OLD.Status = 'Em avaliação'  AND NEW.Status IN ('Disponível', 'Em manutenção', 'Inativo'))
            OR (OLD.Status = 'Em manutenção' AND NEW.Status IN ('Disponível', 'Em avaliação', 'Inativo'))
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Mudança de status do aparelho não permitida.';
        END IF;

        IF OLD.Status = 'Em quarentena' AND NEW.Status = 'Disponível' THEN
            IF CURDATE() < OLD.Data_Fim_Quarentena THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'A quarentena de 15 dias ainda não terminou.';
            END IF;
            IF (SELECT COALESCE(Resultado_Reconsulta_Imei, '')
                  FROM AVALIACAO_ENTRADA
                 WHERE Id_Avaliacao_Entrada = NEW.Id_Avaliacao_Entrada) <> 'Regular' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Ao fim da quarentena, a nova consulta do IMEI precisa ser Regular.';
            END IF;
        END IF;

        IF NEW.Status = 'Disponível' THEN
            SET NEW.Data_Disponivel = CURDATE();
        END IF;
    END IF;

    IF NEW.Preco_Venda <> OLD.Preco_Venda
       OR NEW.Elegivel_Desconto_Pix <> OLD.Elegivel_Desconto_Pix THEN
        IF (SELECT COUNT(*)
              FROM FUNCIONARIO f
              JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
             WHERE f.Codigo_Funcionario = @cellgo_funcionario
               AND f.Ativo = 1
               AND p.Nome_Perfil = 'Diretoria') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Somente a Diretoria pode alterar o preço ou a elegibilidade ao desconto Pix.';
        END IF;
    END IF;
END$$

/* AFTER UPDATE
   - toda mudança de status gera uma MOVIMENTACAO (histórico por IMEI);
   - alteração de preço/desconto e de custo gera AUDITORIA;
   - quando a quantidade Disponível fica abaixo do estoque mínimo, abre
     uma requisição de compra, sem duplicar requisição em aberto (RN-06). */
CREATE TRIGGER trg_aparelho_au
AFTER UPDATE ON APARELHO
FOR EACH ROW
BEGIN
    DECLARE v_qtd_disponivel INT;
    DECLARE v_estoque_minimo INT;

    IF NEW.Status <> OLD.Status THEN
        INSERT INTO MOVIMENTACAO (Codigo_Funcionario, Imei, Tipo_Movimento,
                                  Status_Anterior, Status_Novo, Data_Hora)
        VALUES (@cellgo_funcionario, NEW.Imei,
                CASE
                    WHEN NEW.Status = 'Vendido' THEN 'Venda'
                    WHEN NEW.Status = 'Em avaliação' AND OLD.Status = 'Vendido' THEN 'Devolução'
                    WHEN NEW.Status = 'Em avaliação' THEN 'Avaliação'
                    WHEN NEW.Status = 'Em manutenção' THEN 'Manutenção'
                    WHEN NEW.Status = 'Disponível' AND OLD.Status = 'Em quarentena' THEN 'Fim de quarentena'
                    WHEN NEW.Status = 'Disponível' THEN 'Retorno ao estoque'
                    ELSE 'Inativação'
                END,
                OLD.Status, NEW.Status, NOW());
    END IF;

    IF NEW.Preco_Venda <> OLD.Preco_Venda
       OR NEW.Elegivel_Desconto_Pix <> OLD.Elegivel_Desconto_Pix THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Codigo_Autorizador, Acao, Tabela_Afetada,
                               Registro_Id, Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario, @cellgo_funcionario, 'Alteração de preço/desconto', 'APARELHO', NEW.Imei,
                JSON_OBJECT('Preco_Venda', OLD.Preco_Venda, 'Elegivel_Desconto_Pix', OLD.Elegivel_Desconto_Pix),
                JSON_OBJECT('Preco_Venda', NEW.Preco_Venda, 'Elegivel_Desconto_Pix', NEW.Elegivel_Desconto_Pix),
                'Alteração autorizada pela Diretoria.');
    END IF;

    IF NEW.Custo_Aquisicao <> OLD.Custo_Aquisicao THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                               Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario, 'Alteração de custo', 'APARELHO', NEW.Imei,
                JSON_OBJECT('Custo_Aquisicao', OLD.Custo_Aquisicao),
                JSON_OBJECT('Custo_Aquisicao', NEW.Custo_Aquisicao),
                'Custo de aquisição corrigido.');

        UPDATE AQUISICAO
           SET Valor_Total = Valor_Total
         WHERE Id_Aquisicao = (SELECT Id_Aquisicao FROM AVALIACAO_ENTRADA
                                WHERE Id_Avaliacao_Entrada = NEW.Id_Avaliacao_Entrada);
    END IF;

    /* ponto de pedido: o aparelho deixou de estar Disponível */
    IF OLD.Status = 'Disponível' AND NEW.Status <> 'Disponível' THEN
        SELECT COUNT(*) INTO v_qtd_disponivel
          FROM APARELHO
         WHERE Id_Especificacao = NEW.Id_Especificacao
           AND Status = 'Disponível';

        SELECT Estoque_Minimo INTO v_estoque_minimo
          FROM ESPECIFICACAO_APARELHO
         WHERE Id_Especificacao = NEW.Id_Especificacao;

        IF v_estoque_minimo > 0
           AND v_qtd_disponivel < v_estoque_minimo
           AND (SELECT COUNT(*) FROM REQUISICAO_COMPRA
                 WHERE Id_Especificacao = NEW.Id_Especificacao
                   AND Status IN ('Aguardando Análise Financeira',
                                  'Aguardando Aprovação da Diretoria')) = 0 THEN
            INSERT INTO REQUISICAO_COMPRA (Id_Especificacao, Qtd_Atual_Estoque, Estoque_Minimo,
                                           Data_Abertura, Status, Qtd_Sugerida)
            VALUES (NEW.Id_Especificacao, v_qtd_disponivel, v_estoque_minimo,
                    CURDATE(), 'Aguardando Análise Financeira',
                    GREATEST(2 * v_estoque_minimo - v_qtd_disponivel, 1));
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_aparelho_bd
BEFORE DELETE ON APARELHO
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Aparelho não pode ser excluído; use o status Inativo.';
END$$


/* =====================================================================
   REQUISICAO_COMPRA (RN-06)
   - não pode haver duas requisições em aberto para a mesma especificação;
   - fluxo: Aguardando Análise Financeira → Aguardando Aprovação da
     Diretoria → Aprovada ou Recusada;
   - a decisão (aprovar ou recusar) é exclusiva da Diretoria.
   ===================================================================== */
CREATE TRIGGER trg_requisicao_bi
BEFORE INSERT ON REQUISICAO_COMPRA
FOR EACH ROW
BEGIN
    IF NEW.Status <> 'Aguardando Análise Financeira' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A requisição de compra começa com status Aguardando Análise Financeira.';
    END IF;

    IF (SELECT COUNT(*) FROM REQUISICAO_COMPRA
         WHERE Id_Especificacao = NEW.Id_Especificacao
           AND Status IN ('Aguardando Análise Financeira',
                          'Aguardando Aprovação da Diretoria')) > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Já existe uma requisição de compra em aberto para esta especificação.';
    END IF;
END$$

CREATE TRIGGER trg_requisicao_bu
BEFORE UPDATE ON REQUISICAO_COMPRA
FOR EACH ROW
BEGIN
    IF NEW.Id_Especificacao <> OLD.Id_Especificacao
       OR NEW.Qtd_Atual_Estoque <> OLD.Qtd_Atual_Estoque
       OR NEW.Estoque_Minimo <> OLD.Estoque_Minimo
       OR NEW.Data_Abertura <> OLD.Data_Abertura THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Os dados históricos da requisição não podem ser alterados.';
    END IF;

    IF NEW.Status <> OLD.Status THEN
        IF NOT (
               (OLD.Status = 'Aguardando Análise Financeira'
                AND NEW.Status = 'Aguardando Aprovação da Diretoria')
            OR (OLD.Status = 'Aguardando Aprovação da Diretoria'
                AND NEW.Status IN ('Aprovada', 'Recusada'))
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Mudança de status da requisição não permitida.';
        END IF;

        IF NEW.Status IN ('Aprovada', 'Recusada')
           AND (SELECT COUNT(*)
                  FROM FUNCIONARIO f
                  JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
                 WHERE f.Codigo_Funcionario = NEW.Codigo_Funcionario
                   AND f.Ativo = 1
                   AND p.Nome_Perfil = 'Diretoria') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A requisição só pode ser aprovada ou recusada pela Diretoria.';
        END IF;
    ELSEIF OLD.Status IN ('Aprovada', 'Recusada') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Requisição já decidida não pode ser alterada.';
    END IF;
END$$

CREATE TRIGGER trg_requisicao_ai
AFTER INSERT ON REQUISICAO_COMPRA
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                           Valor_Anterior, Valor_Novo, Descricao)
    VALUES (@cellgo_funcionario, 'Abertura de requisição de compra', 'REQUISICAO_COMPRA',
            CAST(NEW.Id_Requisicao AS CHAR), NULL,
            JSON_OBJECT('Id_Especificacao', NEW.Id_Especificacao,
                        'Qtd_Atual_Estoque', NEW.Qtd_Atual_Estoque,
                        'Estoque_Minimo', NEW.Estoque_Minimo,
                        'Qtd_Sugerida', NEW.Qtd_Sugerida,
                        'Status', NEW.Status),
            'Estoque disponível abaixo do mínimo.');
END$$

CREATE TRIGGER trg_requisicao_au
AFTER UPDATE ON REQUISICAO_COMPRA
FOR EACH ROW
BEGIN
    IF NEW.Status <> OLD.Status THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Codigo_Autorizador, Acao, Tabela_Afetada,
                               Registro_Id, Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario,
                IF(NEW.Status IN ('Aprovada', 'Recusada'), NEW.Codigo_Funcionario, NULL),
                'Etapa da requisição de compra', 'REQUISICAO_COMPRA',
                CAST(NEW.Id_Requisicao AS CHAR),
                JSON_OBJECT('Status', OLD.Status),
                JSON_OBJECT('Status', NEW.Status, 'Parecer_Financeiro', NEW.Parecer_Financeiro,
                            'Motivo_Recusa', NEW.Motivo_Recusa),
                NULL);
    END IF;
END$$


/* =====================================================================
   PEDIDO
   Campos derivados, sempre calculados pelo banco (RF-07/RF-08):
   - Valor_Produtos = soma do Preco_Unitario dos itens;
   - desconto Pix: só no Pix e quando todos os aparelhos do pedido são
     elegíveis; faixas: até R$ 1.000,00 = 5%; até R$ 2.500,00 = 7%;
     acima de R$ 2.500,00 = 10%;
   - Valor_Final = Valor_Produtos - Valor_Desconto + Valor_Taxas.
   Os valores são recalculados enquanto o pedido está Aberto ou
   Aguardando pagamento; depois do pagamento, ficam congelados.
   ===================================================================== */
CREATE TRIGGER trg_pedido_bi
BEFORE INSERT ON PEDIDO
FOR EACH ROW
BEGIN
    IF NEW.Status_Pedido <> 'Aberto' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Um novo pedido começa com status Aberto.';
    END IF;

    /* ainda não há itens: os derivados começam zerados */
    SET NEW.Valor_Produtos = 0.00;
    SET NEW.Percentual_Desconto_Pix = NULL;
    SET NEW.Valor_Desconto = NULL;
    SET NEW.Valor_Final = COALESCE(NEW.Valor_Taxas, 0);
END$$

CREATE TRIGGER trg_pedido_bu
BEFORE UPDATE ON PEDIDO
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_itens INT;
    DECLARE v_nao_elegiveis INT;

    IF NEW.Id_Pedido <> OLD.Id_Pedido
       OR NEW.Cpf_Cnpj <> OLD.Cpf_Cnpj
       OR NEW.Data_Pedido <> OLD.Data_Pedido THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cliente e data do pedido não podem ser alterados.';
    END IF;

    /* ---------- recálculo dos valores ---------- */
    IF OLD.Status_Pedido IN ('Aberto', 'Aguardando pagamento') THEN
        /* troca para Pix: à vista e sem taxas (recalculado antes da nova tentativa) */
        IF NEW.Forma_Pagamento = 'Pix' AND OLD.Forma_Pagamento <> 'Pix' THEN
            SET NEW.Numero_Parcelas = 1;
            SET NEW.Valor_Taxas = NULL;
        END IF;

        SELECT COALESCE(SUM(i.Preco_Unitario), 0),
               COUNT(*),
               COALESCE(SUM(CASE WHEN a.Elegivel_Desconto_Pix = 0 THEN 1 ELSE 0 END), 0)
          INTO v_total, v_itens, v_nao_elegiveis
          FROM ITEM_PEDIDO i
          JOIN APARELHO a ON a.Imei = i.Imei
         WHERE i.Id_Pedido = NEW.Id_Pedido;

        SET NEW.Valor_Produtos = v_total;

        IF NEW.Forma_Pagamento = 'Pix' AND v_itens > 0 AND v_nao_elegiveis = 0 THEN
            SET NEW.Percentual_Desconto_Pix = CASE
                                                  WHEN v_total <= 1000.00 THEN 5
                                                  WHEN v_total <= 2500.00 THEN 7
                                                  ELSE 10
                                              END;
            SET NEW.Valor_Desconto = ROUND(v_total * NEW.Percentual_Desconto_Pix / 100, 2);
        ELSE
            SET NEW.Percentual_Desconto_Pix = NULL;
            SET NEW.Valor_Desconto = NULL;
        END IF;

        SET NEW.Valor_Final = NEW.Valor_Produtos
                            - COALESCE(NEW.Valor_Desconto, 0)
                            + COALESCE(NEW.Valor_Taxas, 0);
    ELSEIF NEW.Forma_Pagamento <> OLD.Forma_Pagamento
        OR NEW.Numero_Parcelas <> OLD.Numero_Parcelas
        OR NOT (NEW.Valor_Produtos <=> OLD.Valor_Produtos)
        OR NOT (NEW.Percentual_Desconto_Pix <=> OLD.Percentual_Desconto_Pix)
        OR NOT (NEW.Valor_Desconto <=> OLD.Valor_Desconto)
        OR NOT (NEW.Valor_Taxas <=> OLD.Valor_Taxas)
        OR NOT (NEW.Valor_Final <=> OLD.Valor_Final) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Forma de pagamento e valores não podem mudar depois do pagamento.';
    END IF;

    /* ---------- fluxo de status ---------- */
    IF NEW.Status_Pedido <> OLD.Status_Pedido THEN
        IF NOT (
               (OLD.Status_Pedido = 'Aberto'               AND NEW.Status_Pedido IN ('Aguardando pagamento', 'Cancelado'))
            OR (OLD.Status_Pedido = 'Aguardando pagamento' AND NEW.Status_Pedido IN ('Aberto', 'Pago', 'Cancelado'))
            OR (OLD.Status_Pedido = 'Pago'                 AND NEW.Status_Pedido IN ('Finalizado', 'Cancelado'))
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Mudança de status do pedido não permitida.';
        END IF;

        IF NEW.Status_Pedido = 'Aguardando pagamento'
           AND (SELECT COUNT(*) FROM ITEM_PEDIDO WHERE Id_Pedido = NEW.Id_Pedido) = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O pedido precisa ter pelo menos um aparelho.';
        END IF;

        IF NEW.Status_Pedido = 'Pago'
           AND (SELECT COUNT(*) FROM PAGAMENTO
                 WHERE Id_Pedido = NEW.Id_Pedido AND Status = 'Aprovado') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O pedido só fica Pago com um pagamento Aprovado.';
        END IF;

        IF NEW.Status_Pedido = 'Finalizado'
           AND (SELECT COUNT(*) FROM ENTREGA
                 WHERE Id_Pedido = NEW.Id_Pedido
                   AND Codigo_Troca IS NULL
                   AND Status_Entrega = 'Entregue') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O pedido só é Finalizado depois da entrega ao cliente.';
        END IF;

        /* pedido pago só é cancelado por um CANCELAMENTO concluído (RN-13) */
        IF NEW.Status_Pedido = 'Cancelado' AND OLD.Status_Pedido = 'Pago'
           AND (SELECT COUNT(*) FROM CANCELAMENTO
                 WHERE Id_Pedido = NEW.Id_Pedido AND Status = 'Concluído') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Pedido pago só pode ser cancelado por um cancelamento concluído.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_pedido_bd
BEFORE DELETE ON PEDIDO
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pedido não pode ser excluído; use o status Cancelado.';
END$$


/* =====================================================================
   ITEM_PEDIDO
   - itens só entram ou saem enquanto o pedido está Aberto ou Aguardando
     pagamento, e só com aparelho Disponível (RN-03);
   - o preço do item é o preço de venda do aparelho (sem desconto manual);
   - garantia da loja: início + 30 dias; aparelho Novo: garantia do
     fabricante de 1 ano quando não informada (RN-17).
   ===================================================================== */
CREATE TRIGGER trg_item_pedido_bi
BEFORE INSERT ON ITEM_PEDIDO
FOR EACH ROW
BEGIN
    DECLARE v_status_pedido VARCHAR(25);
    DECLARE v_status_aparelho VARCHAR(20);
    DECLARE v_condicao VARCHAR(10);
    DECLARE v_preco DECIMAL(10,2);

    SELECT Status_Pedido INTO v_status_pedido FROM PEDIDO WHERE Id_Pedido = NEW.Id_Pedido;
    SELECT Status, Condicao, Preco_Venda INTO v_status_aparelho, v_condicao, v_preco
      FROM APARELHO WHERE Imei = NEW.Imei;

    IF v_status_pedido NOT IN ('Aberto', 'Aguardando pagamento') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Só é possível incluir itens em pedido Aberto ou Aguardando pagamento.';
    END IF;

    IF v_status_aparelho <> 'Disponível' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Aparelho indisponível: só aparelhos com status Disponível podem ser vendidos.';
    END IF;

    SET NEW.Preco_Unitario = v_preco;
    SET NEW.Data_Inicio_Garantia = COALESCE(NEW.Data_Inicio_Garantia, CURDATE());
    SET NEW.Data_Fim_Garantia_Loja = DATE_ADD(NEW.Data_Inicio_Garantia, INTERVAL 30 DAY);

    IF v_condicao = 'Novo' AND NEW.Data_Fim_Garantia_Fabricante IS NULL THEN
        SET NEW.Data_Fim_Garantia_Fabricante = DATE_ADD(NEW.Data_Inicio_Garantia, INTERVAL 1 YEAR);
    END IF;
END$$

CREATE TRIGGER trg_item_pedido_bu
BEFORE UPDATE ON ITEM_PEDIDO
FOR EACH ROW
BEGIN
    DECLARE v_condicao VARCHAR(10);

    IF NEW.Imei <> OLD.Imei OR NEW.Id_Pedido <> OLD.Id_Pedido THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Para trocar o aparelho do pedido, exclua o item e inclua outro.';
    END IF;

    IF NEW.Preco_Unitario <> OLD.Preco_Unitario THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O preço do item vem do aparelho e não pode ser alterado manualmente.';
    END IF;

    SET NEW.Data_Fim_Garantia_Loja = DATE_ADD(NEW.Data_Inicio_Garantia, INTERVAL 30 DAY);

    SELECT Condicao INTO v_condicao FROM APARELHO WHERE Imei = NEW.Imei;
    IF v_condicao = 'Novo'
       AND (NEW.Data_Fim_Garantia_Fabricante IS NULL
            OR NEW.Data_Inicio_Garantia <> OLD.Data_Inicio_Garantia) THEN
        SET NEW.Data_Fim_Garantia_Fabricante = DATE_ADD(NEW.Data_Inicio_Garantia, INTERVAL 1 YEAR);
    END IF;
END$$

CREATE TRIGGER trg_item_pedido_bd
BEFORE DELETE ON ITEM_PEDIDO
FOR EACH ROW
BEGIN
    IF (SELECT Status_Pedido FROM PEDIDO WHERE Id_Pedido = OLD.Id_Pedido)
       NOT IN ('Aberto', 'Aguardando pagamento') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Só é possível remover itens de pedido Aberto ou Aguardando pagamento.';
    END IF;
END$$

/* Depois de incluir ou remover itens, a trigger de PEDIDO recalcula
   Valor_Produtos, desconto Pix e Valor_Final */
CREATE TRIGGER trg_item_pedido_ai
AFTER INSERT ON ITEM_PEDIDO
FOR EACH ROW
BEGIN
    UPDATE PEDIDO SET Valor_Produtos = Valor_Produtos WHERE Id_Pedido = NEW.Id_Pedido;
END$$

CREATE TRIGGER trg_item_pedido_ad
AFTER DELETE ON ITEM_PEDIDO
FOR EACH ROW
BEGIN
    UPDATE PEDIDO SET Valor_Produtos = Valor_Produtos WHERE Id_Pedido = OLD.Id_Pedido;
END$$


/* =====================================================================
   PAGAMENTO
   - cobrança só de pedido Aguardando pagamento e pelo Valor_Final;
   - fluxo: Pendente → Aprovado, Recusado ou Expirado; Aprovado → Estornado
     (somente com estorno Processado);
   - na aprovação: nova verificação de disponibilidade, pedido Pago,
     aparelhos Vendidos e início da garantia na data da confirmação.
   ===================================================================== */
CREATE TRIGGER trg_pagamento_bi
BEFORE INSERT ON PAGAMENTO
FOR EACH ROW
BEGIN
    DECLARE v_status_pedido VARCHAR(25);
    DECLARE v_valor_final DECIMAL(10,2);

    SELECT Status_Pedido, Valor_Final INTO v_status_pedido, v_valor_final
      FROM PEDIDO WHERE Id_Pedido = NEW.Id_Pedido;

    IF v_status_pedido <> 'Aguardando pagamento' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Só é possível gerar cobrança para pedido Aguardando pagamento.';
    END IF;

    IF NEW.Valor <> v_valor_final THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O valor do pagamento deve ser igual ao Valor_Final do pedido.';
    END IF;

    IF NEW.Status = 'Estornado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Um pagamento não pode ser registrado já como Estornado.';
    END IF;

    IF (SELECT COUNT(*) FROM PAGAMENTO
         WHERE Id_Pedido = NEW.Id_Pedido AND Status = 'Pendente') > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Já existe uma cobrança Pendente para este pedido.';
    END IF;

    IF NEW.Status = 'Aprovado'
       AND (SELECT COUNT(*)
              FROM ITEM_PEDIDO i
              JOIN APARELHO a ON a.Imei = i.Imei
             WHERE i.Id_Pedido = NEW.Id_Pedido
               AND a.Status <> 'Disponível') > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pagamento não aprovado: há aparelho do pedido que não está mais Disponível.';
    END IF;
END$$

CREATE TRIGGER trg_pagamento_bu
BEFORE UPDATE ON PAGAMENTO
FOR EACH ROW
BEGIN
    DECLARE v_status_pedido VARCHAR(25);
    DECLARE v_valor_final DECIMAL(10,2);

    IF NEW.Id_Pedido <> OLD.Id_Pedido
       OR NEW.Valor <> OLD.Valor
       OR NEW.Data_Tentativa <> OLD.Data_Tentativa THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pedido, valor e data da tentativa não podem ser alterados.';
    END IF;

    IF NEW.Status <> OLD.Status THEN
        IF NOT (
               (OLD.Status = 'Pendente' AND NEW.Status IN ('Aprovado', 'Recusado', 'Expirado'))
            OR (OLD.Status = 'Aprovado' AND NEW.Status = 'Estornado')
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Mudança de status do pagamento não permitida.';
        END IF;

        IF NEW.Status = 'Aprovado' THEN
            SELECT Status_Pedido, Valor_Final INTO v_status_pedido, v_valor_final
              FROM PEDIDO WHERE Id_Pedido = NEW.Id_Pedido;

            IF v_status_pedido <> 'Aguardando pagamento' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Só é possível aprovar pagamento de pedido Aguardando pagamento.';
            END IF;

            IF NEW.Valor <> v_valor_final THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'O pedido foi recalculado; gere uma nova cobrança com o valor atual.';
            END IF;

            IF (SELECT COUNT(*)
                  FROM ITEM_PEDIDO i
                  JOIN APARELHO a ON a.Imei = i.Imei
                 WHERE i.Id_Pedido = NEW.Id_Pedido
                   AND a.Status <> 'Disponível') > 0 THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Pagamento não aprovado: há aparelho do pedido que não está mais Disponível.';
            END IF;
        END IF;

        IF NEW.Status = 'Estornado'
           AND (SELECT COUNT(*) FROM ESTORNO
                 WHERE Id_Pagamento = NEW.Id_Pagamento AND Status = 'Processado') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O pagamento só fica Estornado com um estorno Processado.';
        END IF;
    ELSEIF OLD.Status IN ('Recusado', 'Expirado', 'Estornado') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pagamento encerrado não pode ser alterado.';
    END IF;
END$$

CREATE TRIGGER trg_pagamento_ai
AFTER INSERT ON PAGAMENTO
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Aprovado' THEN
        UPDATE PEDIDO SET Status_Pedido = 'Pago' WHERE Id_Pedido = NEW.Id_Pedido;

        UPDATE APARELHO
           SET Status = 'Vendido'
         WHERE Imei IN (SELECT Imei FROM ITEM_PEDIDO WHERE Id_Pedido = NEW.Id_Pedido);

        UPDATE ITEM_PEDIDO
           SET Data_Inicio_Garantia = DATE(NEW.Data_Confirmacao)
         WHERE Id_Pedido = NEW.Id_Pedido;
    END IF;

    INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                           Valor_Anterior, Valor_Novo, Descricao)
    VALUES (@cellgo_funcionario, 'Registro de pagamento', 'PAGAMENTO', CAST(NEW.Id_Pagamento AS CHAR),
            NULL,
            JSON_OBJECT('Id_Pedido', NEW.Id_Pedido, 'Valor', NEW.Valor, 'Status', NEW.Status),
            NULL);
END$$

CREATE TRIGGER trg_pagamento_au
AFTER UPDATE ON PAGAMENTO
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Aprovado' AND OLD.Status <> 'Aprovado' THEN
        UPDATE PEDIDO SET Status_Pedido = 'Pago' WHERE Id_Pedido = NEW.Id_Pedido;

        UPDATE APARELHO
           SET Status = 'Vendido'
         WHERE Imei IN (SELECT Imei FROM ITEM_PEDIDO WHERE Id_Pedido = NEW.Id_Pedido);

        UPDATE ITEM_PEDIDO
           SET Data_Inicio_Garantia = DATE(NEW.Data_Confirmacao)
         WHERE Id_Pedido = NEW.Id_Pedido;
    END IF;

    IF NEW.Status <> OLD.Status THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                               Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario, 'Alteração de pagamento', 'PAGAMENTO', CAST(NEW.Id_Pagamento AS CHAR),
                JSON_OBJECT('Status', OLD.Status),
                JSON_OBJECT('Status', NEW.Status, 'Data_Confirmacao', NEW.Data_Confirmacao),
                NULL);
    END IF;
END$$


/* =====================================================================
   CANCELAMENTO (RN-13)
   - até 7 dias corridos da data do pedido;
   - só enquanto a entrega estiver Aguardando envio (depois disso, segue
     o fluxo de devolução);
   - concluído: pedido Cancelado e aparelhos de volta para Disponível.
   ===================================================================== */
CREATE TRIGGER trg_cancelamento_bi
BEFORE INSERT ON CANCELAMENTO
FOR EACH ROW
BEGIN
    DECLARE v_status_pedido VARCHAR(25);
    DECLARE v_data_pedido DATETIME;

    SELECT Status_Pedido, Data_Pedido INTO v_status_pedido, v_data_pedido
      FROM PEDIDO WHERE Id_Pedido = NEW.Id_Pedido;

    IF v_status_pedido NOT IN ('Aguardando pagamento', 'Pago') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Só é possível cancelar pedido Aguardando pagamento ou Pago.';
    END IF;

    IF NEW.Data_Solicitacao > DATE_ADD(v_data_pedido, INTERVAL 7 DAY) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prazo de cancelamento vencido: o limite é de 7 dias corridos da compra.';
    END IF;

    IF NEW.Data_Solicitacao < v_data_pedido THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A solicitação de cancelamento não pode ser anterior ao pedido.';
    END IF;

    IF (SELECT COUNT(*) FROM ENTREGA
         WHERE Id_Pedido = NEW.Id_Pedido
           AND Codigo_Troca IS NULL
           AND Status_Entrega IN ('Em transporte', 'Entregue')) > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O aparelho já foi enviado: a solicitação deve seguir o fluxo de devolução.';
    END IF;

    IF NEW.Status = 'Recusado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Um cancelamento começa com status Solicitado ou Concluído.';
    END IF;
END$$

CREATE TRIGGER trg_cancelamento_bu
BEFORE UPDATE ON CANCELAMENTO
FOR EACH ROW
BEGIN
    IF NEW.Id_Pedido <> OLD.Id_Pedido OR NEW.Data_Solicitacao <> OLD.Data_Solicitacao THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pedido e data da solicitação não podem ser alterados.';
    END IF;

    IF NEW.Status <> OLD.Status THEN
        IF OLD.Status <> 'Solicitado' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cancelamento concluído ou recusado não pode mudar de status.';
        END IF;

        IF NEW.Status = 'Concluído'
           AND (SELECT COUNT(*) FROM ENTREGA
                 WHERE Id_Pedido = NEW.Id_Pedido
                   AND Codigo_Troca IS NULL
                   AND Status_Entrega IN ('Em transporte', 'Entregue')) > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O aparelho já foi enviado: a solicitação deve seguir o fluxo de devolução.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_cancelamento_ai
AFTER INSERT ON CANCELAMENTO
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Concluído' THEN
        UPDATE APARELHO
           SET Status = 'Disponível'
         WHERE Status = 'Vendido'
           AND Imei IN (SELECT Imei FROM ITEM_PEDIDO WHERE Id_Pedido = NEW.Id_Pedido);

        UPDATE PEDIDO SET Status_Pedido = 'Cancelado' WHERE Id_Pedido = NEW.Id_Pedido;
    END IF;

    INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                           Valor_Anterior, Valor_Novo, Descricao)
    VALUES (@cellgo_funcionario, 'Cancelamento', 'CANCELAMENTO', CAST(NEW.Codigo_Cancelamento AS CHAR),
            NULL,
            JSON_OBJECT('Id_Pedido', NEW.Id_Pedido, 'Status', NEW.Status, 'Motivo', NEW.Motivo),
            NULL);
END$$

CREATE TRIGGER trg_cancelamento_au
AFTER UPDATE ON CANCELAMENTO
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Concluído' AND OLD.Status <> 'Concluído' THEN
        UPDATE APARELHO
           SET Status = 'Disponível'
         WHERE Status = 'Vendido'
           AND Imei IN (SELECT Imei FROM ITEM_PEDIDO WHERE Id_Pedido = NEW.Id_Pedido);

        UPDATE PEDIDO SET Status_Pedido = 'Cancelado' WHERE Id_Pedido = NEW.Id_Pedido;
    END IF;

    IF NEW.Status <> OLD.Status THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                               Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario, 'Cancelamento', 'CANCELAMENTO', CAST(NEW.Codigo_Cancelamento AS CHAR),
                JSON_OBJECT('Status', OLD.Status), JSON_OBJECT('Status', NEW.Status), NULL);
    END IF;
END$$


/* =====================================================================
   POS_VENDA — prazos da solicitação
   - Arrependimento: até 7 dias corridos do recebimento (RN-15);
   - Defeito: dentro da garantia da loja, 30 dias (RN-14/RN-16);
   - Garantia: dentro da garantia da loja ou do fabricante (RN-17).
   ===================================================================== */
CREATE TRIGGER trg_pos_venda_bi
BEFORE INSERT ON POS_VENDA
FOR EACH ROW
BEGIN
    DECLARE v_status_pedido VARCHAR(25);
    DECLARE v_data_entrega DATETIME;
    DECLARE v_fim_loja DATE;
    DECLARE v_fim_fabricante DATE;

    SELECT Status_Pedido INTO v_status_pedido FROM PEDIDO WHERE Id_Pedido = NEW.Id_Pedido;

    IF v_status_pedido NOT IN ('Pago', 'Finalizado') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solicitação de pós-venda só para pedido Pago ou Finalizado.';
    END IF;

    SELECT Data_Fim_Garantia_Loja, Data_Fim_Garantia_Fabricante
      INTO v_fim_loja, v_fim_fabricante
      FROM ITEM_PEDIDO
     WHERE Id_Pedido = NEW.Id_Pedido AND Imei = NEW.Imei;

    IF NEW.Tipo_Solicitacao = 'Arrependimento' THEN
        SELECT MAX(Data_Entrega) INTO v_data_entrega
          FROM ENTREGA
         WHERE Id_Pedido = NEW.Id_Pedido
           AND Codigo_Troca IS NULL
           AND Status_Entrega = 'Entregue';

        IF v_data_entrega IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Arrependimento só depois que o aparelho for entregue.';
        END IF;
        IF NEW.Data_Abertura > DATE_ADD(v_data_entrega, INTERVAL 7 DAY) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Prazo de arrependimento vencido: o limite é de 7 dias do recebimento.';
        END IF;
    ELSEIF NEW.Tipo_Solicitacao = 'Defeito' THEN
        IF DATE(NEW.Data_Abertura) > v_fim_loja THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Fora do prazo: troca ou devolução por defeito é aceita em até 30 dias da compra.';
        END IF;
    ELSE
        IF DATE(NEW.Data_Abertura) > GREATEST(v_fim_loja, COALESCE(v_fim_fabricante, v_fim_loja)) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O aparelho está fora do prazo de garantia.';
        END IF;
    END IF;

    IF (SELECT COUNT(*) FROM POS_VENDA
         WHERE Id_Pedido = NEW.Id_Pedido
           AND Imei = NEW.Imei
           AND Status IN ('Aberta', 'Em análise')) > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Já existe uma solicitação de pós-venda em aberto para este aparelho.';
    END IF;
END$$

CREATE TRIGGER trg_pos_venda_bu
BEFORE UPDATE ON POS_VENDA
FOR EACH ROW
BEGIN
    IF NEW.Imei <> OLD.Imei
       OR NEW.Id_Pedido <> OLD.Id_Pedido
       OR NEW.Tipo_Solicitacao <> OLD.Tipo_Solicitacao
       OR NEW.Data_Abertura <> OLD.Data_Abertura THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Item, tipo e data de abertura da solicitação não podem ser alterados.';
    END IF;

    IF NEW.Status <> OLD.Status AND OLD.Status IN ('Concluída', 'Recusada') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solicitação encerrada não pode mudar de status.';
    END IF;
END$$


/* =====================================================================
   AVALIACAO_DANO (RN-18) — feita por funcionário ativo da Assistência
   Técnica, depois da abertura da solicitação
   ===================================================================== */
CREATE TRIGGER trg_aval_dano_bi
BEFORE INSERT ON AVALIACAO_DANO
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*)
          FROM FUNCIONARIO f
          JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
         WHERE f.Codigo_Funcionario = NEW.Codigo_Funcionario
           AND f.Ativo = 1
           AND p.Nome_Perfil = 'Assistência Técnica') = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A avaliação de dano deve ser feita por funcionário ativo da Assistência Técnica.';
    END IF;

    IF NEW.Data_Avaliacao < (SELECT DATE(Data_Abertura) FROM POS_VENDA
                              WHERE Id_PosVenda = NEW.Id_PosVenda) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A avaliação não pode ser anterior à abertura da solicitação.';
    END IF;

    IF (SELECT Status FROM POS_VENDA WHERE Id_PosVenda = NEW.Id_PosVenda)
       IN ('Concluída', 'Recusada') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Não é possível avaliar uma solicitação encerrada.';
    END IF;
END$$


/* =====================================================================
   DEVOLUCAO (RN-15/RN-16)
   - só para solicitação de Arrependimento ou Defeito;
   - por defeito: precisa de avaliação com cobertura da garantia e só é
     permitida quando não há aparelho equivalente Disponível para troca;
   - uma solicitação não pode gerar troca e devolução ao mesmo tempo;
   - o aparelho devolvido volta para Em avaliação.
   ===================================================================== */
CREATE TRIGGER trg_devolucao_bi
BEFORE INSERT ON DEVOLUCAO
FOR EACH ROW
BEGIN
    DECLARE v_tipo VARCHAR(15);
    DECLARE v_status_pv VARCHAR(20);
    DECLARE v_abertura DATETIME;
    DECLARE v_imei CHAR(15);

    SELECT Tipo_Solicitacao, Status, Data_Abertura, Imei
      INTO v_tipo, v_status_pv, v_abertura, v_imei
      FROM POS_VENDA WHERE Id_PosVenda = NEW.Id_PosVenda;

    IF v_tipo NOT IN ('Arrependimento', 'Defeito') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Devolução só para solicitação de Arrependimento ou Defeito.';
    END IF;

    IF v_status_pv IN ('Concluída', 'Recusada') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A solicitação de pós-venda já está encerrada.';
    END IF;

    IF NEW.Data_Devolucao < v_abertura THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A devolução não pode ser anterior à abertura da solicitação.';
    END IF;

    IF (SELECT COUNT(*) FROM TROCA
         WHERE Id_PosVenda = NEW.Id_PosVenda AND Status <> 'Cancelada') > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Esta solicitação já gerou uma troca.';
    END IF;

    IF v_tipo = 'Defeito' THEN
        IF (SELECT COUNT(*) FROM AVALIACAO_DANO
             WHERE Id_PosVenda = NEW.Id_PosVenda AND Cobertura_Garantia = 1) = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Devolução por defeito exige avaliação técnica com cobertura da garantia.';
        END IF;

        IF (SELECT COUNT(*)
              FROM APARELHO a
             WHERE a.Status = 'Disponível'
               AND a.Id_Especificacao = (SELECT Id_Especificacao FROM APARELHO WHERE Imei = v_imei)) > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Há aparelho equivalente Disponível: o caso deve seguir como troca (RN-14).';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_devolucao_bu
BEFORE UPDATE ON DEVOLUCAO
FOR EACH ROW
BEGIN
    IF NEW.Id_PosVenda <> OLD.Id_PosVenda OR NEW.Data_Devolucao <> OLD.Data_Devolucao THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solicitação e data da devolução não podem ser alteradas.';
    END IF;

    IF NEW.Status <> OLD.Status AND OLD.Status <> 'Pendente' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Devolução concluída ou recusada não pode mudar de status.';
    END IF;
END$$

CREATE TRIGGER trg_devolucao_ai
AFTER INSERT ON DEVOLUCAO
FOR EACH ROW
BEGIN
    UPDATE APARELHO
       SET Status = 'Em avaliação'
     WHERE Status = 'Vendido'
       AND Imei = (SELECT Imei FROM POS_VENDA WHERE Id_PosVenda = NEW.Id_PosVenda);

    INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                           Valor_Anterior, Valor_Novo, Descricao)
    VALUES (@cellgo_funcionario, 'Devolução', 'DEVOLUCAO', CAST(NEW.Codigo_Devolucao AS CHAR),
            NULL,
            JSON_OBJECT('Id_PosVenda', NEW.Id_PosVenda, 'Status', NEW.Status, 'Motivo', NEW.Motivo),
            NULL);
END$$

CREATE TRIGGER trg_devolucao_au
AFTER UPDATE ON DEVOLUCAO
FOR EACH ROW
BEGIN
    IF NEW.Status <> OLD.Status THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                               Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario, 'Devolução', 'DEVOLUCAO', CAST(NEW.Codigo_Devolucao AS CHAR),
                JSON_OBJECT('Status', OLD.Status), JSON_OBJECT('Status', NEW.Status), NULL);
    END IF;
END$$


/* =====================================================================
   TROCA (RN-14)
   - só para solicitação de Defeito ou Garantia, com avaliação técnica
     que confirme a cobertura da garantia;
   - o aparelho de reposição deve estar Disponível e ser equivalente
     (mesma especificação) ou de valor igual ou superior;
   - a troca não gera estorno; o aparelho de reposição fica Vendido e o
     aparelho com defeito volta para Em avaliação.
   ===================================================================== */
CREATE TRIGGER trg_troca_bi
BEFORE INSERT ON TROCA
FOR EACH ROW
BEGIN
    DECLARE v_tipo VARCHAR(15);
    DECLARE v_status_pv VARCHAR(20);
    DECLARE v_abertura DATETIME;
    DECLARE v_imei_original CHAR(15);
    DECLARE v_pedido INT;
    DECLARE v_espec_original INT;
    DECLARE v_preco_original DECIMAL(10,2);
    DECLARE v_status_repos VARCHAR(20);
    DECLARE v_espec_repos INT;
    DECLARE v_preco_repos DECIMAL(10,2);

    SELECT Tipo_Solicitacao, Status, Data_Abertura, Imei, Id_Pedido
      INTO v_tipo, v_status_pv, v_abertura, v_imei_original, v_pedido
      FROM POS_VENDA WHERE Id_PosVenda = NEW.Id_PosVenda;

    IF v_tipo NOT IN ('Defeito', 'Garantia') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Troca só para solicitação de Defeito ou Garantia.';
    END IF;

    IF v_status_pv IN ('Concluída', 'Recusada') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A solicitação de pós-venda já está encerrada.';
    END IF;

    IF NEW.Data_Troca < DATE(v_abertura) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A troca não pode ser anterior à abertura da solicitação.';
    END IF;

    IF (SELECT COUNT(*) FROM AVALIACAO_DANO
         WHERE Id_PosVenda = NEW.Id_PosVenda AND Cobertura_Garantia = 1) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A troca exige avaliação técnica com cobertura da garantia.';
    END IF;

    IF (SELECT COUNT(*) FROM DEVOLUCAO
         WHERE Id_PosVenda = NEW.Id_PosVenda AND Status <> 'Recusada') > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Esta solicitação já gerou uma devolução.';
    END IF;

    IF NEW.Imei_Reposicao = v_imei_original THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O aparelho de reposição deve ser diferente do aparelho trocado.';
    END IF;

    SELECT a.Id_Especificacao, i.Preco_Unitario INTO v_espec_original, v_preco_original
      FROM APARELHO a
      JOIN ITEM_PEDIDO i ON i.Imei = a.Imei AND i.Id_Pedido = v_pedido
     WHERE a.Imei = v_imei_original;

    SELECT Status, Id_Especificacao, Preco_Venda INTO v_status_repos, v_espec_repos, v_preco_repos
      FROM APARELHO WHERE Imei = NEW.Imei_Reposicao;

    IF v_status_repos <> 'Disponível' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O aparelho de reposição precisa estar Disponível.';
    END IF;

    IF v_espec_repos <> v_espec_original AND v_preco_repos < v_preco_original THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A reposição deve ser equivalente ou de valor igual ou superior ao aparelho trocado.';
    END IF;

    IF NEW.Status = 'Cancelada' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uma troca começa com status Pendente ou Concluída.';
    END IF;
END$$

CREATE TRIGGER trg_troca_bu
BEFORE UPDATE ON TROCA
FOR EACH ROW
BEGIN
    IF NEW.Id_PosVenda <> OLD.Id_PosVenda
       OR NEW.Imei_Reposicao <> OLD.Imei_Reposicao
       OR NEW.Data_Troca <> OLD.Data_Troca THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Solicitação, aparelho de reposição e data da troca não podem ser alterados.';
    END IF;

    IF NEW.Status <> OLD.Status AND OLD.Status <> 'Pendente' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Troca concluída ou cancelada não pode mudar de status.';
    END IF;
END$$

CREATE TRIGGER trg_troca_ai
AFTER INSERT ON TROCA
FOR EACH ROW
BEGIN
    /* reposição sai do estoque */
    UPDATE APARELHO SET Status = 'Vendido' WHERE Imei = NEW.Imei_Reposicao;

    /* aparelho com defeito volta para a loja */
    UPDATE APARELHO
       SET Status = 'Em avaliação'
     WHERE Status = 'Vendido'
       AND Imei = (SELECT Imei FROM POS_VENDA WHERE Id_PosVenda = NEW.Id_PosVenda);

    INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                           Valor_Anterior, Valor_Novo, Descricao)
    VALUES (@cellgo_funcionario, 'Troca', 'TROCA', CAST(NEW.Codigo_Troca AS CHAR),
            NULL,
            JSON_OBJECT('Id_PosVenda', NEW.Id_PosVenda, 'Imei_Reposicao', NEW.Imei_Reposicao,
                        'Status', NEW.Status),
            NULL);
END$$

CREATE TRIGGER trg_troca_au
AFTER UPDATE ON TROCA
FOR EACH ROW
BEGIN
    /* troca cancelada: a reposição volta para o estoque */
    IF NEW.Status = 'Cancelada' AND OLD.Status <> 'Cancelada' THEN
        UPDATE APARELHO
           SET Status = 'Disponível'
         WHERE Imei = NEW.Imei_Reposicao AND Status = 'Vendido';
    END IF;

    IF NEW.Status <> OLD.Status THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                               Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario, 'Troca', 'TROCA', CAST(NEW.Codigo_Troca AS CHAR),
                JSON_OBJECT('Status', OLD.Status), JSON_OBJECT('Status', NEW.Status), NULL);
    END IF;
END$$


/* =====================================================================
   NOTA_FISCAL (RN-20)
   - venda: pedido Pago ou Finalizado, uma nota de venda ativa por pedido;
   - entrada (devolução) e saída (reposição) referenciam a nota de venda
     do mesmo pedido;
   - Emitida → Cancelada só para nota de venda, em até 24 horas da emissão;
   - número, chave e data de emissão não mudam depois de emitida.
   ===================================================================== */
CREATE TRIGGER trg_nota_fiscal_bi
BEFORE INSERT ON NOTA_FISCAL
FOR EACH ROW
BEGIN
    DECLARE v_pedido_origem INT;
    DECLARE v_pedido_ref INT;
    DECLARE v_tipo_ref VARCHAR(20);

    IF NEW.Status = 'Cancelada' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uma nota fiscal não pode ser registrada já como Cancelada.';
    END IF;

    IF NEW.Tipo_Nota = 'Venda' THEN
        IF (SELECT Status_Pedido FROM PEDIDO WHERE Id_Pedido = NEW.Id_Pedido)
           NOT IN ('Pago', 'Finalizado') THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A nota fiscal de venda só é emitida depois do pagamento aprovado.';
        END IF;

        IF (SELECT COUNT(*) FROM NOTA_FISCAL
             WHERE Id_Pedido = NEW.Id_Pedido
               AND Tipo_Nota = 'Venda'
               AND Status <> 'Cancelada') > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Este pedido já possui nota fiscal de venda ativa.';
        END IF;
    ELSE
        /* pedido da operação de origem (cancelamento ou pós-venda) */
        IF NEW.Codigo_Cancelamento IS NOT NULL THEN
            SELECT Id_Pedido INTO v_pedido_origem
              FROM CANCELAMENTO WHERE Codigo_Cancelamento = NEW.Codigo_Cancelamento;
        ELSE
            SELECT Id_Pedido INTO v_pedido_origem
              FROM POS_VENDA WHERE Id_PosVenda = NEW.Id_PosVenda;
        END IF;

        SELECT Id_Pedido, Tipo_Nota INTO v_pedido_ref, v_tipo_ref
          FROM NOTA_FISCAL WHERE Id_Nota = NEW.Id_Nota_Referencia;

        IF v_tipo_ref <> 'Venda' OR v_pedido_ref <> v_pedido_origem THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A nota de referência deve ser a nota de venda do mesmo pedido.';
        END IF;

        IF NEW.Tipo_Nota = 'Saída (Reposição)'
           AND (SELECT COUNT(*) FROM TROCA
                 WHERE Id_PosVenda = NEW.Id_PosVenda AND Status <> 'Cancelada') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Nota de reposição exige uma troca registrada para a solicitação.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_nota_fiscal_bu
BEFORE UPDATE ON NOTA_FISCAL
FOR EACH ROW
BEGIN
    IF NOT (NEW.Id_Pedido <=> OLD.Id_Pedido)
       OR NOT (NEW.Codigo_Cancelamento <=> OLD.Codigo_Cancelamento)
       OR NOT (NEW.Id_PosVenda <=> OLD.Id_PosVenda)
       OR NOT (NEW.Id_Nota_Referencia <=> OLD.Id_Nota_Referencia)
       OR NEW.Tipo_Nota <> OLD.Tipo_Nota THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Origem, referência e tipo da nota não podem ser alterados.';
    END IF;

    IF OLD.Status IN ('Emitida', 'Cancelada')
       AND (NOT (NEW.Numero_Nota <=> OLD.Numero_Nota)
            OR NOT (NEW.Chave_Acesso <=> OLD.Chave_Acesso)
            OR NOT (NEW.Data_Emissao <=> OLD.Data_Emissao)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Número, chave e data de uma nota emitida não podem ser alterados.';
    END IF;

    IF NEW.Status <> OLD.Status THEN
        IF NOT (
               (OLD.Status = 'Aguardando emissão' AND NEW.Status IN ('Emitida', 'Pendente'))
            OR (OLD.Status = 'Pendente'           AND NEW.Status = 'Emitida')
            OR (OLD.Status = 'Emitida'            AND NEW.Status = 'Cancelada')
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Mudança de status da nota fiscal não permitida.';
        END IF;

        IF NEW.Status = 'Cancelada' THEN
            IF NEW.Tipo_Nota <> 'Venda' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Somente a nota fiscal de venda pode ser cancelada.';
            END IF;
            IF NOW() > DATE_ADD(OLD.Data_Emissao, INTERVAL 24 HOUR) THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Prazo de 24 horas vencido: emita uma nota de entrada (devolução).';
            END IF;
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_nota_fiscal_bd
BEFORE DELETE ON NOTA_FISCAL
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nota fiscal não pode ser excluída.';
END$$


/* =====================================================================
   ITEM_NOTA_FISCAL — o aparelho precisa fazer parte da operação da nota,
   e os itens só mudam antes da emissão
   ===================================================================== */
CREATE TRIGGER trg_item_nota_bi
BEFORE INSERT ON ITEM_NOTA_FISCAL
FOR EACH ROW
BEGIN
    DECLARE v_tipo VARCHAR(20);
    DECLARE v_status VARCHAR(20);
    DECLARE v_pedido INT;
    DECLARE v_cancelamento INT;
    DECLARE v_pos_venda INT;

    SELECT Tipo_Nota, Status, Id_Pedido, Codigo_Cancelamento, Id_PosVenda
      INTO v_tipo, v_status, v_pedido, v_cancelamento, v_pos_venda
      FROM NOTA_FISCAL WHERE Id_Nota = NEW.Id_Nota;

    IF v_status NOT IN ('Aguardando emissão', 'Pendente') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Itens só podem ser incluídos antes da emissão da nota.';
    END IF;

    IF v_tipo = 'Venda'
       AND (SELECT COUNT(*) FROM ITEM_PEDIDO
             WHERE Id_Pedido = v_pedido AND Imei = NEW.Imei) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O aparelho não pertence ao pedido desta nota de venda.';
    END IF;

    IF v_tipo = 'Entrada (Devolução)' AND v_cancelamento IS NOT NULL
       AND (SELECT COUNT(*)
              FROM ITEM_PEDIDO i
              JOIN CANCELAMENTO c ON c.Id_Pedido = i.Id_Pedido
             WHERE c.Codigo_Cancelamento = v_cancelamento AND i.Imei = NEW.Imei) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O aparelho não pertence ao pedido cancelado.';
    END IF;

    IF v_tipo = 'Entrada (Devolução)' AND v_pos_venda IS NOT NULL
       AND (SELECT COUNT(*) FROM POS_VENDA
             WHERE Id_PosVenda = v_pos_venda AND Imei = NEW.Imei) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O aparelho não é o aparelho da solicitação de pós-venda.';
    END IF;

    IF v_tipo = 'Saída (Reposição)'
       AND (SELECT COUNT(*) FROM TROCA
             WHERE Id_PosVenda = v_pos_venda
               AND Imei_Reposicao = NEW.Imei
               AND Status <> 'Cancelada') = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O aparelho não é o aparelho de reposição da troca.';
    END IF;
END$$

CREATE TRIGGER trg_item_nota_bu
BEFORE UPDATE ON ITEM_NOTA_FISCAL
FOR EACH ROW
BEGIN
    IF (SELECT Status FROM NOTA_FISCAL WHERE Id_Nota = OLD.Id_Nota)
       NOT IN ('Aguardando emissão', 'Pendente') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Itens de nota emitida não podem ser alterados.';
    END IF;

    IF NEW.Imei <> OLD.Imei OR NEW.Id_Nota <> OLD.Id_Nota THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Para trocar o aparelho da nota, exclua o item e inclua outro.';
    END IF;
END$$

CREATE TRIGGER trg_item_nota_bd
BEFORE DELETE ON ITEM_NOTA_FISCAL
FOR EACH ROW
BEGIN
    IF (SELECT Status FROM NOTA_FISCAL WHERE Id_Nota = OLD.Id_Nota)
       NOT IN ('Aguardando emissão', 'Pendente') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Itens de nota emitida não podem ser excluídos.';
    END IF;
END$$


/* =====================================================================
   ESTORNO (RN-19)
   - reverte um pagamento Aprovado, pelo valor pago no máximo;
   - a origem (cancelamento ou devolução) deve ser do mesmo pedido;
   - cancelamento: precisa estar Concluído;
   - devolução: só é liberado depois que a nota fiscal de entrada
     (devolução) estiver Emitida;
   - processado: o pagamento passa para Estornado.
   ===================================================================== */
CREATE TRIGGER trg_estorno_bi
BEFORE INSERT ON ESTORNO
FOR EACH ROW
BEGIN
    DECLARE v_status_pag VARCHAR(20);
    DECLARE v_valor_pag DECIMAL(10,2);
    DECLARE v_pedido_pag INT;
    DECLARE v_pedido_origem INT;
    DECLARE v_status_origem VARCHAR(20);
    DECLARE v_pos_venda INT;

    SELECT Status, Valor, Id_Pedido INTO v_status_pag, v_valor_pag, v_pedido_pag
      FROM PAGAMENTO WHERE Id_Pagamento = NEW.Id_Pagamento;

    IF v_status_pag <> 'Aprovado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Só é possível estornar um pagamento Aprovado.';
    END IF;

    IF NEW.Valor > v_valor_pag THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O valor do estorno não pode ser maior que o valor pago.';
    END IF;

    IF NEW.Codigo_Cancelamento IS NOT NULL THEN
        SELECT Id_Pedido, Status INTO v_pedido_origem, v_status_origem
          FROM CANCELAMENTO WHERE Codigo_Cancelamento = NEW.Codigo_Cancelamento;

        IF v_status_origem <> 'Concluído' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O estorno de cancelamento exige cancelamento Concluído.';
        END IF;
    ELSE
        SELECT pv.Id_Pedido, d.Status, d.Id_PosVenda
          INTO v_pedido_origem, v_status_origem, v_pos_venda
          FROM DEVOLUCAO d
          JOIN POS_VENDA pv ON pv.Id_PosVenda = d.Id_PosVenda
         WHERE d.Codigo_Devolucao = NEW.Codigo_Devolucao;

        IF v_status_origem = 'Recusada' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Devolução recusada não gera estorno.';
        END IF;

        IF (SELECT COUNT(*) FROM NOTA_FISCAL
             WHERE Id_PosVenda = v_pos_venda
               AND Tipo_Nota = 'Entrada (Devolução)'
               AND Status = 'Emitida') = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O estorno só é liberado depois da nota fiscal de devolução Emitida.';
        END IF;
    END IF;

    IF v_pedido_origem <> v_pedido_pag THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O pagamento estornado deve ser do mesmo pedido da origem do estorno.';
    END IF;
END$$

CREATE TRIGGER trg_estorno_bu
BEFORE UPDATE ON ESTORNO
FOR EACH ROW
BEGIN
    IF NEW.Id_Pagamento <> OLD.Id_Pagamento
       OR NOT (NEW.Codigo_Devolucao <=> OLD.Codigo_Devolucao)
       OR NOT (NEW.Codigo_Cancelamento <=> OLD.Codigo_Cancelamento)
       OR NEW.Valor <> OLD.Valor
       OR NEW.Data_Abertura <> OLD.Data_Abertura THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pagamento, origem, valor e data de abertura do estorno não podem ser alterados.';
    END IF;

    IF NEW.Status <> OLD.Status AND OLD.Status <> 'Pendente' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estorno processado ou recusado não pode mudar de status.';
    END IF;
END$$

CREATE TRIGGER trg_estorno_ai
AFTER INSERT ON ESTORNO
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Processado' THEN
        UPDATE PAGAMENTO SET Status = 'Estornado' WHERE Id_Pagamento = NEW.Id_Pagamento;
    END IF;

    INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                           Valor_Anterior, Valor_Novo, Descricao)
    VALUES (@cellgo_funcionario, 'Estorno', 'ESTORNO', CAST(NEW.Id_Estorno AS CHAR),
            NULL,
            JSON_OBJECT('Id_Pagamento', NEW.Id_Pagamento, 'Valor', NEW.Valor,
                        'Status', NEW.Status, 'Prazo_Limite', NEW.Prazo_Limite),
            NULL);
END$$

CREATE TRIGGER trg_estorno_au
AFTER UPDATE ON ESTORNO
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Processado' AND OLD.Status <> 'Processado' THEN
        UPDATE PAGAMENTO SET Status = 'Estornado' WHERE Id_Pagamento = NEW.Id_Pagamento;
    END IF;

    IF NEW.Status <> OLD.Status THEN
        INSERT INTO AUDITORIA (Codigo_Funcionario, Acao, Tabela_Afetada, Registro_Id,
                               Valor_Anterior, Valor_Novo, Descricao)
        VALUES (@cellgo_funcionario, 'Estorno', 'ESTORNO', CAST(NEW.Id_Estorno AS CHAR),
                JSON_OBJECT('Status', OLD.Status),
                JSON_OBJECT('Status', NEW.Status, 'Data_Conclusao', NEW.Data_Conclusao),
                NULL);
    END IF;
END$$


/* =====================================================================
   ENTREGA (RN-11/RN-12)
   - entrega de venda: pedido Pago, uma por pedido;
   - entrega de reposição: a troca deve ser do mesmo pedido;
   - o status só avança: Aguardando envio → Em transporte → Entregue;
   - venda entregue: pedido Finalizado; reposição entregue: troca Concluída.
   ===================================================================== */
CREATE TRIGGER trg_entrega_bi
BEFORE INSERT ON ENTREGA
FOR EACH ROW
BEGIN
    IF NEW.Codigo_Troca IS NULL THEN
        IF (SELECT Status_Pedido FROM PEDIDO WHERE Id_Pedido = NEW.Id_Pedido) <> 'Pago' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A entrega de venda só é criada para pedido Pago.';
        END IF;

        IF (SELECT COUNT(*) FROM ENTREGA
             WHERE Id_Pedido = NEW.Id_Pedido AND Codigo_Troca IS NULL) > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Este pedido já possui entrega de venda.';
        END IF;
    ELSE
        IF (SELECT pv.Id_Pedido
              FROM TROCA t
              JOIN POS_VENDA pv ON pv.Id_PosVenda = t.Id_PosVenda
             WHERE t.Codigo_Troca = NEW.Codigo_Troca) <> NEW.Id_Pedido THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A troca da entrega de reposição deve ser do mesmo pedido.';
        END IF;

        IF (SELECT Status FROM TROCA WHERE Codigo_Troca = NEW.Codigo_Troca) = 'Cancelada' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Troca cancelada não gera entrega de reposição.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_entrega_bu
BEFORE UPDATE ON ENTREGA
FOR EACH ROW
BEGIN
    IF NEW.Codigo_Rastreio <> OLD.Codigo_Rastreio
       OR NEW.Id_Pedido <> OLD.Id_Pedido
       OR NOT (NEW.Codigo_Troca <=> OLD.Codigo_Troca) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rastreio, pedido e troca da entrega não podem ser alterados.';
    END IF;

    IF (CASE NEW.Status_Entrega WHEN 'Aguardando envio' THEN 1 WHEN 'Em transporte' THEN 2 ELSE 3 END)
     < (CASE OLD.Status_Entrega WHEN 'Aguardando envio' THEN 1 WHEN 'Em transporte' THEN 2 ELSE 3 END) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O status da entrega não pode voltar para uma etapa anterior.';
    END IF;

    IF NEW.Status_Entrega <> 'Aguardando envio' AND NEW.Codigo_Troca IS NULL
       AND (SELECT Status_Pedido FROM PEDIDO WHERE Id_Pedido = NEW.Id_Pedido) = 'Cancelado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pedido cancelado não pode ser enviado.';
    END IF;
END$$

CREATE TRIGGER trg_entrega_ai
AFTER INSERT ON ENTREGA
FOR EACH ROW
BEGIN
    IF NEW.Status_Entrega = 'Entregue' THEN
        IF NEW.Codigo_Troca IS NULL THEN
            UPDATE PEDIDO SET Status_Pedido = 'Finalizado'
             WHERE Id_Pedido = NEW.Id_Pedido AND Status_Pedido = 'Pago';
        ELSE
            UPDATE TROCA SET Status = 'Concluída'
             WHERE Codigo_Troca = NEW.Codigo_Troca AND Status = 'Pendente';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_entrega_au
AFTER UPDATE ON ENTREGA
FOR EACH ROW
BEGIN
    IF NEW.Status_Entrega = 'Entregue' AND OLD.Status_Entrega <> 'Entregue' THEN
        IF NEW.Codigo_Troca IS NULL THEN
            UPDATE PEDIDO SET Status_Pedido = 'Finalizado'
             WHERE Id_Pedido = NEW.Id_Pedido AND Status_Pedido = 'Pago';
        ELSE
            UPDATE TROCA SET Status = 'Concluída'
             WHERE Codigo_Troca = NEW.Codigo_Troca AND Status = 'Pendente';
        END IF;
    END IF;
END$$


/* =====================================================================
   MOVIMENTACAO — histórico do aparelho
   - o status novo deve ser o status atual do aparelho;
   - o histórico não pode ser alterado nem excluído.
   ===================================================================== */
CREATE TRIGGER trg_movimentacao_bi
BEFORE INSERT ON MOVIMENTACAO
FOR EACH ROW
BEGIN
    IF (SELECT Status FROM APARELHO WHERE Imei = NEW.Imei) <> NEW.Status_Novo THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O status novo da movimentação deve ser o status atual do aparelho.';
    END IF;
END$$

CREATE TRIGGER trg_movimentacao_bu
BEFORE UPDATE ON MOVIMENTACAO
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O histórico de movimentações não pode ser alterado.';
END$$

CREATE TRIGGER trg_movimentacao_bd
BEFORE DELETE ON MOVIMENTACAO
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O histórico de movimentações não pode ser excluído.';
END$$


/* =====================================================================
   AUDITORIA (RN-23 / RNF-07)
   - o autorizador, quando informado, deve ser da Diretoria;
   - os registros não podem ser alterados nem excluídos.
   ===================================================================== */
CREATE TRIGGER trg_auditoria_bi
BEFORE INSERT ON AUDITORIA
FOR EACH ROW
BEGIN
    IF NEW.Codigo_Autorizador IS NOT NULL
       AND (SELECT COUNT(*)
              FROM FUNCIONARIO f
              JOIN PERFIL_ACESSO p ON p.Id_Perfil = f.Id_Perfil
             WHERE f.Codigo_Funcionario = NEW.Codigo_Autorizador
               AND f.Ativo = 1
               AND p.Nome_Perfil = 'Diretoria') = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O autorizador registrado na auditoria deve ser da Diretoria.';
    END IF;
END$$

CREATE TRIGGER trg_auditoria_bu
BEFORE UPDATE ON AUDITORIA
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Registros de auditoria não podem ser alterados.';
END$$

CREATE TRIGGER trg_auditoria_bd
BEFORE DELETE ON AUDITORIA
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Registros de auditoria não podem ser excluídos.';
END$$

DELIMITER ;
