/* =====================================================================
   CellGO — Criação do banco de dados e das tabelas
   SGBD: MySQL 8
   Execução: ambiente limpo (o script cria o banco do zero).
   Ordem de criação: cada tabela é criada depois das tabelas que ela
   referencia, para que todas as chaves estrangeiras sejam válidas.
   ===================================================================== */

SET NAMES utf8mb4;

CREATE DATABASE cellgo
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE cellgo;


/* =====================================================================
   1. PERFIL_ACESSO
   ===================================================================== */
CREATE TABLE PERFIL_ACESSO (
    Id_Perfil     INT          NOT NULL AUTO_INCREMENT,
    Nome_Perfil   VARCHAR(40)  NOT NULL,
    Nivel_Acesso  INT          NOT NULL,

    CONSTRAINT pk_perfil_acesso PRIMARY KEY (Id_Perfil),
    CONSTRAINT uq_perfil_nome UNIQUE (Nome_Perfil),

    CONSTRAINT chk_perfil_nome CHECK (Nome_Perfil IN (
        'Vendas e Atendimento',
        'Estoque e Logística',
        'Assistência Técnica',
        'Financeiro/Administrativo',
        'Diretoria')),
    /* Diretoria = nível 2 (Estratégico); demais perfis = nível 1 (Operacional) */
    CONSTRAINT chk_perfil_nivel CHECK (
        (Nome_Perfil = 'Diretoria' AND Nivel_Acesso = 2)
        OR (Nome_Perfil <> 'Diretoria' AND Nivel_Acesso = 1))
);


/* =====================================================================
   2. FUNCIONARIO
   ===================================================================== */
CREATE TABLE FUNCIONARIO (
    Codigo_Funcionario  INT           NOT NULL AUTO_INCREMENT,
    Nome                VARCHAR(150)  NOT NULL,
    Cargo               VARCHAR(50)   NOT NULL,
    Login               VARCHAR(50)   NOT NULL,
    Id_Perfil           INT           NOT NULL,
    Ativo               BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_funcionario PRIMARY KEY (Codigo_Funcionario),
    CONSTRAINT uq_funcionario_login UNIQUE (Login),
    CONSTRAINT fk_funcionario_perfil FOREIGN KEY (Id_Perfil)
        REFERENCES PERFIL_ACESSO (Id_Perfil),

    CONSTRAINT chk_funcionario_nome  CHECK (CHAR_LENGTH(TRIM(Nome)) > 0),
    CONSTRAINT chk_funcionario_cargo CHECK (CHAR_LENGTH(TRIM(Cargo)) > 0),
    /* login sem espaços e com pelo menos 3 caracteres */
    CONSTRAINT chk_funcionario_login CHECK (Login REGEXP '^[A-Za-z0-9._-]{3,50}$'),
    CONSTRAINT chk_funcionario_ativo CHECK (Ativo IN (0, 1))
);


/* =====================================================================
   3. FORNECEDOR
   ===================================================================== */
CREATE TABLE FORNECEDOR (
    Cpf_Cnpj_Fornecedor  VARCHAR(14)      NOT NULL,
    Tipo_Pessoa          ENUM('PF','PJ')  NOT NULL,
    Nome                 VARCHAR(150)     NOT NULL,
    Tipo_Documento       VARCHAR(10)      NULL,
    Numero_Documento     VARCHAR(20)      NULL,
    Telefone_Contato     VARCHAR(11)      NOT NULL,

    CONSTRAINT pk_fornecedor PRIMARY KEY (Cpf_Cnpj_Fornecedor),

    /* CPF: 11 dígitos (PF); CNPJ: 14 dígitos (PJ); apenas números */
    CONSTRAINT chk_fornecedor_documento CHECK (
        (Tipo_Pessoa = 'PF' AND Cpf_Cnpj_Fornecedor REGEXP '^[0-9]{11}$')
        OR (Tipo_Pessoa = 'PJ' AND Cpf_Cnpj_Fornecedor REGEXP '^[0-9]{14}$')),
    CONSTRAINT chk_fornecedor_nome CHECK (CHAR_LENGTH(TRIM(Nome)) > 0),
    /* Pessoa física: documento com foto (RG ou CNH) obrigatório */
    CONSTRAINT chk_fornecedor_doc_foto CHECK (
        Tipo_Pessoa = 'PJ'
        OR (Tipo_Documento IN ('RG', 'CNH')
            AND Numero_Documento IS NOT NULL
            AND CHAR_LENGTH(TRIM(Numero_Documento)) > 0)),
    CONSTRAINT chk_fornecedor_tipo_doc CHECK (
        Tipo_Documento IS NULL OR Tipo_Documento IN ('RG', 'CNH')),
    /* telefone com DDD: 10 (fixo) ou 11 (celular) dígitos */
    CONSTRAINT chk_fornecedor_telefone CHECK (Telefone_Contato REGEXP '^[1-9][0-9][0-9]{8,9}$')
);


/* =====================================================================
   4. MODELO
   ===================================================================== */
CREATE TABLE MODELO (
    Id_Modelo    INT           NOT NULL AUTO_INCREMENT,
    Nome_Modelo  VARCHAR(100)  NOT NULL,
    Marca        VARCHAR(50)   NOT NULL,

    CONSTRAINT pk_modelo PRIMARY KEY (Id_Modelo),
    CONSTRAINT uq_modelo_nome UNIQUE (Nome_Modelo),

    CONSTRAINT chk_modelo_nome  CHECK (CHAR_LENGTH(TRIM(Nome_Modelo)) > 0),
    CONSTRAINT chk_modelo_marca CHECK (CHAR_LENGTH(TRIM(Marca)) > 0)
);


/* =====================================================================
   5. ESPECIFICACAO_APARELHO
   ===================================================================== */
CREATE TABLE ESPECIFICACAO_APARELHO (
    Id_Especificacao     INT          NOT NULL AUTO_INCREMENT,
    Id_Modelo            INT          NOT NULL,
    Cor                  VARCHAR(30)  NOT NULL,
    Capacidade           INT          NOT NULL,
    Estoque_Minimo       INT          NOT NULL DEFAULT 2,
    Limite_Dias_Atencao  INT          NOT NULL DEFAULT 31,
    Limite_Dias_Critico  INT          NOT NULL DEFAULT 61,

    CONSTRAINT pk_especificacao PRIMARY KEY (Id_Especificacao),
    /* modelo + cor + capacidade identificam o "aparelho equivalente" (RN-14) */
    CONSTRAINT uq_especificacao UNIQUE (Id_Modelo, Cor, Capacidade),
    CONSTRAINT fk_especificacao_modelo FOREIGN KEY (Id_Modelo)
        REFERENCES MODELO (Id_Modelo),

    CONSTRAINT chk_especificacao_cor        CHECK (CHAR_LENGTH(TRIM(Cor)) > 0),
    CONSTRAINT chk_especificacao_capacidade CHECK (Capacidade > 0),
    CONSTRAINT chk_especificacao_estoque    CHECK (Estoque_Minimo >= 0),
    CONSTRAINT chk_especificacao_atencao    CHECK (Limite_Dias_Atencao > 0),
    CONSTRAINT chk_especificacao_critico    CHECK (Limite_Dias_Critico > Limite_Dias_Atencao)
);


/* =====================================================================
   6. AQUISICAO
   ===================================================================== */
CREATE TABLE AQUISICAO (
    Id_Aquisicao                   INT            NOT NULL AUTO_INCREMENT,
    Codigo_Funcionario             INT            NOT NULL,
    Cpf_Cnpj_Fornecedor            VARCHAR(14)    NOT NULL,
    Data_Aquisicao                 DATE           NOT NULL,
    Tipo_Documento_Compra          VARCHAR(30)    NOT NULL,
    Numero_Documento_Compra        VARCHAR(50)    NOT NULL,
    Termo_Responsabilidade_Aceito  BOOLEAN        NULL,
    Valor_Total                    DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    Status                         VARCHAR(20)    NOT NULL DEFAULT 'Em avaliação',

    CONSTRAINT pk_aquisicao PRIMARY KEY (Id_Aquisicao),
    CONSTRAINT fk_aquisicao_funcionario FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),
    CONSTRAINT fk_aquisicao_fornecedor FOREIGN KEY (Cpf_Cnpj_Fornecedor)
        REFERENCES FORNECEDOR (Cpf_Cnpj_Fornecedor),

    CONSTRAINT chk_aquisicao_tipo_doc CHECK (Tipo_Documento_Compra IN (
        'Nota fiscal do fornecedor',
        'Termo de compra e venda')),
    CONSTRAINT chk_aquisicao_num_doc CHECK (CHAR_LENGTH(TRIM(Numero_Documento_Compra)) > 0),
    CONSTRAINT chk_aquisicao_termo   CHECK (Termo_Responsabilidade_Aceito IN (0, 1)),
    CONSTRAINT chk_aquisicao_valor   CHECK (Valor_Total >= 0),
    CONSTRAINT chk_aquisicao_status  CHECK (Status IN ('Em avaliação', 'Concluída', 'Recusada'))
);


/* =====================================================================
   7. AVALIACAO_ENTRADA
   ===================================================================== */
CREATE TABLE AVALIACAO_ENTRADA (
    Id_Avaliacao_Entrada       INT           NOT NULL AUTO_INCREMENT,
    Codigo_Funcionario         INT           NOT NULL,
    Id_Aquisicao               INT           NOT NULL,
    Imei_Avaliado              CHAR(15)      NOT NULL,
    Base_Consultada            VARCHAR(50)   NOT NULL,
    Resultado_Consulta_Imei    VARCHAR(20)   NOT NULL,
    Data_Consulta              DATETIME      NOT NULL,
    Checklist_Bateria          BOOLEAN       NULL,
    Checklist_Tela             BOOLEAN       NULL,
    Checklist_Cameras          BOOLEAN       NULL,
    Checklist_Botoes           BOOLEAN       NULL,
    Checklist_Som              BOOLEAN       NULL,
    Checklist_Conectividade    BOOLEAN       NULL,
    Checklist_Pecas_Originais  BOOLEAN       NULL,
    Bloqueio_Conta             BOOLEAN       NULL,
    Reset_Fabrica_Realizado    BOOLEAN       NULL,
    Resultado                  VARCHAR(10)   NOT NULL,
    Motivo_Recusa              VARCHAR(255)  NULL,
    Data_Reconsulta_Imei       DATETIME      NULL,
    Resultado_Reconsulta_Imei  VARCHAR(20)   NULL,

    CONSTRAINT pk_avaliacao_entrada PRIMARY KEY (Id_Avaliacao_Entrada),
    CONSTRAINT fk_aval_entrada_funcionario FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),
    CONSTRAINT fk_aval_entrada_aquisicao FOREIGN KEY (Id_Aquisicao)
        REFERENCES AQUISICAO (Id_Aquisicao),

    CONSTRAINT chk_aval_entrada_imei CHECK (Imei_Avaliado REGEXP '^[0-9]{15}$'),
    CONSTRAINT chk_aval_entrada_base CHECK (CHAR_LENGTH(TRIM(Base_Consultada)) > 0),
    CONSTRAINT chk_aval_entrada_consulta CHECK (Resultado_Consulta_Imei IN (
        'Regular', 'Roubado/Furtado', 'Bloqueado', 'Adulterado')),
    CONSTRAINT chk_aval_entrada_reconsulta CHECK (Resultado_Reconsulta_Imei IS NULL
        OR Resultado_Reconsulta_Imei IN ('Regular', 'Roubado/Furtado', 'Bloqueado', 'Adulterado')),
    CONSTRAINT chk_aval_entrada_resultado CHECK (Resultado IN ('Aprovado', 'Recusado')),
    CONSTRAINT chk_aval_entrada_booleanos CHECK (
        (Checklist_Bateria IS NULL OR Checklist_Bateria IN (0, 1))
        AND (Checklist_Tela IS NULL OR Checklist_Tela IN (0, 1))
        AND (Checklist_Cameras IS NULL OR Checklist_Cameras IN (0, 1))
        AND (Checklist_Botoes IS NULL OR Checklist_Botoes IN (0, 1))
        AND (Checklist_Som IS NULL OR Checklist_Som IN (0, 1))
        AND (Checklist_Conectividade IS NULL OR Checklist_Conectividade IN (0, 1))
        AND (Checklist_Pecas_Originais IS NULL OR Checklist_Pecas_Originais IN (0, 1))
        AND (Bloqueio_Conta IS NULL OR Bloqueio_Conta IN (0, 1))
        AND (Reset_Fabrica_Realizado IS NULL OR Reset_Fabrica_Realizado IN (0, 1))),
    /* Recusa exige motivo; aprovação não tem motivo de recusa */
    CONSTRAINT chk_aval_entrada_motivo CHECK (
        (Resultado = 'Recusado' AND Motivo_Recusa IS NOT NULL AND CHAR_LENGTH(TRIM(Motivo_Recusa)) > 0)
        OR (Resultado = 'Aprovado' AND Motivo_Recusa IS NULL)),
    /* Aprovado: IMEI regular, nenhum item do checklist reprovado,
       sem bloqueio de conta e com reset de fábrica realizado */
    CONSTRAINT chk_aval_entrada_aprovado CHECK (
        Resultado <> 'Aprovado'
        OR (Resultado_Consulta_Imei = 'Regular'
            AND COALESCE(Checklist_Bateria, 1) = 1
            AND COALESCE(Checklist_Tela, 1) = 1
            AND COALESCE(Checklist_Cameras, 1) = 1
            AND COALESCE(Checklist_Botoes, 1) = 1
            AND COALESCE(Checklist_Som, 1) = 1
            AND COALESCE(Checklist_Conectividade, 1) = 1
            AND COALESCE(Checklist_Pecas_Originais, 1) = 1
            AND COALESCE(Bloqueio_Conta, 0) = 0
            AND Reset_Fabrica_Realizado = 1)),
    /* Aparelho recusado não passa pelo reset de fábrica */
    CONSTRAINT chk_aval_entrada_reset CHECK (
        Resultado <> 'Recusado' OR Reset_Fabrica_Realizado IS NULL),
    /* A reconsulta (fim da quarentena) tem data e resultado juntos,
       só existe para aparelho aprovado e é posterior à primeira consulta */
    CONSTRAINT chk_aval_entrada_reconsulta_par CHECK (
        (Data_Reconsulta_Imei IS NULL AND Resultado_Reconsulta_Imei IS NULL)
        OR (Data_Reconsulta_Imei IS NOT NULL AND Resultado_Reconsulta_Imei IS NOT NULL
            AND Resultado = 'Aprovado'
            AND Data_Reconsulta_Imei >= Data_Consulta))
);


/* =====================================================================
   8. APARELHO
   ===================================================================== */
CREATE TABLE APARELHO (
    Imei                   CHAR(15)       NOT NULL,
    Id_Especificacao       INT            NOT NULL,
    Id_Avaliacao_Entrada   INT            NOT NULL,
    Codigo_Funcionario     INT            NOT NULL,
    Condicao               ENUM('Novo','Seminovo') NOT NULL,
    Preco_Venda            DECIMAL(10,2)  NOT NULL,
    Custo_Aquisicao        DECIMAL(10,2)  NOT NULL,
    Status                 ENUM('Em quarentena','Disponível','Vendido',
                                'Em avaliação','Em manutenção','Inativo') NOT NULL,
    Data_Entrada           DATE           NOT NULL,
    Data_Disponivel        DATE           NULL,
    Data_Fim_Quarentena    DATE           NULL,
    Elegivel_Desconto_Pix  BOOLEAN        NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_aparelho PRIMARY KEY (Imei),
    /* cada avaliação de entrada aprovada libera um único aparelho */
    CONSTRAINT uq_aparelho_avaliacao UNIQUE (Id_Avaliacao_Entrada),
    CONSTRAINT fk_aparelho_especificacao FOREIGN KEY (Id_Especificacao)
        REFERENCES ESPECIFICACAO_APARELHO (Id_Especificacao),
    CONSTRAINT fk_aparelho_avaliacao FOREIGN KEY (Id_Avaliacao_Entrada)
        REFERENCES AVALIACAO_ENTRADA (Id_Avaliacao_Entrada),
    CONSTRAINT fk_aparelho_funcionario FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    CONSTRAINT chk_aparelho_imei    CHECK (Imei REGEXP '^[0-9]{15}$'),
    CONSTRAINT chk_aparelho_preco   CHECK (Preco_Venda > 0),
    CONSTRAINT chk_aparelho_custo   CHECK (Custo_Aquisicao >= 0),
    CONSTRAINT chk_aparelho_pix     CHECK (Elegivel_Desconto_Pix IN (0, 1)),
    CONSTRAINT chk_aparelho_data_disp CHECK (Data_Disponivel IS NULL OR Data_Disponivel >= Data_Entrada),
    /* aparelho Disponível precisa da data em que ficou disponível (base do giro, RN-05) */
    CONSTRAINT chk_aparelho_disp_data CHECK (Status <> 'Disponível' OR Data_Disponivel IS NOT NULL),
    /* quarentena (somente seminovo): fim = Data_Entrada + 15 dias */
    CONSTRAINT chk_aparelho_quarentena CHECK (
        Data_Fim_Quarentena IS NULL
        OR (Condicao = 'Seminovo'
            AND Data_Fim_Quarentena = DATE_ADD(Data_Entrada, INTERVAL 15 DAY))),
    CONSTRAINT chk_aparelho_status_quarentena CHECK (
        Status <> 'Em quarentena' OR Data_Fim_Quarentena IS NOT NULL)
);


/* =====================================================================
   9. IMAGEM_APARELHO
   ===================================================================== */
CREATE TABLE IMAGEM_APARELHO (
    Id_Imagem  INT           NOT NULL AUTO_INCREMENT,
    Imei       CHAR(15)      NOT NULL,
    URL        VARCHAR(500)  NOT NULL,

    CONSTRAINT pk_imagem_aparelho PRIMARY KEY (Id_Imagem),
    CONSTRAINT uq_imagem_url UNIQUE (Imei, URL),
    CONSTRAINT fk_imagem_aparelho FOREIGN KEY (Imei)
        REFERENCES APARELHO (Imei),

    CONSTRAINT chk_imagem_url CHECK (URL REGEXP '^https?://[^ ]+$')
);


/* =====================================================================
   10. CLIENTE
   ===================================================================== */
CREATE TABLE CLIENTE (
    Cpf_Cnpj         VARCHAR(14)      NOT NULL,
    Nome             VARCHAR(150)     NOT NULL,
    Email            VARCHAR(254)     NOT NULL,
    Data_Nascimento  DATE             NULL,
    Tipo_Pessoa      ENUM('PF','PJ')  NOT NULL,

    CONSTRAINT pk_cliente PRIMARY KEY (Cpf_Cnpj),
    CONSTRAINT uq_cliente_email UNIQUE (Email),

    /* CPF: 11 dígitos (PF); CNPJ: 14 dígitos (PJ); apenas números */
    CONSTRAINT chk_cliente_documento CHECK (
        (Tipo_Pessoa = 'PF' AND Cpf_Cnpj REGEXP '^[0-9]{11}$')
        OR (Tipo_Pessoa = 'PJ' AND Cpf_Cnpj REGEXP '^[0-9]{14}$')),
    CONSTRAINT chk_cliente_nome  CHECK (CHAR_LENGTH(TRIM(Nome)) > 0),
    CONSTRAINT chk_cliente_email CHECK (Email REGEXP '^[^@ ]+@[^@ ]+\\.[^@ ]+$'),
    /* PF: data de nascimento obrigatória (a idade mínima de 18 anos é
       validada por trigger, pois depende da data atual); PJ: vazia */
    CONSTRAINT chk_cliente_nascimento CHECK (
        (Tipo_Pessoa = 'PF' AND Data_Nascimento IS NOT NULL)
        OR (Tipo_Pessoa = 'PJ' AND Data_Nascimento IS NULL)),
    CONSTRAINT chk_cliente_nasc_minima CHECK (Data_Nascimento IS NULL OR Data_Nascimento >= '1900-01-01')
);


/* =====================================================================
   11. ENDERECO
   ===================================================================== */
CREATE TABLE ENDERECO (
    Id_Endereco    INT           NOT NULL AUTO_INCREMENT,
    Cpf_Cnpj       VARCHAR(14)   NOT NULL,
    Rua            VARCHAR(150)  NOT NULL,
    Bairro         VARCHAR(100)  NOT NULL,
    Cidade         VARCHAR(100)  NOT NULL,
    CEP            VARCHAR(8)    NOT NULL,
    Numero         VARCHAR(10)   NOT NULL,
    Complemento    VARCHAR(100)  NULL,
    Tipo_Endereco  VARCHAR(20)   NOT NULL,

    CONSTRAINT pk_endereco PRIMARY KEY (Id_Endereco),
    CONSTRAINT fk_endereco_cliente FOREIGN KEY (Cpf_Cnpj)
        REFERENCES CLIENTE (Cpf_Cnpj),

    CONSTRAINT chk_endereco_textos CHECK (
        CHAR_LENGTH(TRIM(Rua)) > 0
        AND CHAR_LENGTH(TRIM(Bairro)) > 0
        AND CHAR_LENGTH(TRIM(Cidade)) > 0
        AND CHAR_LENGTH(TRIM(Numero)) > 0),
    CONSTRAINT chk_endereco_cep  CHECK (CEP REGEXP '^[0-9]{8}$'),
    CONSTRAINT chk_endereco_tipo CHECK (Tipo_Endereco IN (
        'Residencial', 'Comercial', 'Entrega', 'Cobrança'))
);


/* =====================================================================
   12. TELEFONE (entidade fraca de CLIENTE)
   ===================================================================== */
CREATE TABLE TELEFONE (
    Cpf_Cnpj         VARCHAR(14)  NOT NULL,
    DDD              INT          NOT NULL,
    Numero_Telefone  INT          NOT NULL,

    CONSTRAINT pk_telefone PRIMARY KEY (Cpf_Cnpj, DDD, Numero_Telefone),
    CONSTRAINT fk_telefone_cliente FOREIGN KEY (Cpf_Cnpj)
        REFERENCES CLIENTE (Cpf_Cnpj),

    /* DDD com dois dígitos (11 a 99) */
    CONSTRAINT chk_telefone_ddd CHECK (DDD BETWEEN 11 AND 99),
    /* 8 dígitos (fixo, começa de 2 a 5) ou 9 dígitos (celular, começa com 9) */
    CONSTRAINT chk_telefone_numero CHECK (
        Numero_Telefone BETWEEN 20000000 AND 59999999
        OR Numero_Telefone BETWEEN 900000000 AND 999999999)
);


/* =====================================================================
   13. PEDIDO
   Condições de pagamento (somente Pix e cartão de crédito):
   - Pix: 1 parcela; desconto de 5, 7 ou 10% quando elegível; sem taxas.
   - Cartão de crédito: 1 a 12 parcelas; sem desconto Pix; taxas só
     quando houver juros.
   Valor_Final = Valor_Produtos - Valor_Desconto + Valor_Taxas
   (os valores vazios contam como zero).
   ===================================================================== */
CREATE TABLE PEDIDO (
    Id_Pedido                INT            NOT NULL AUTO_INCREMENT,
    Cpf_Cnpj                 VARCHAR(14)    NOT NULL,
    Data_Pedido              DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status_Pedido            VARCHAR(25)    NOT NULL DEFAULT 'Aberto',
    Forma_Pagamento          ENUM('Pix','Cartão de crédito') NOT NULL,
    Numero_Parcelas          INT            NOT NULL DEFAULT 1,
    Valor_Produtos           DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    Percentual_Desconto_Pix  DECIMAL(5,2)   NULL,
    Valor_Desconto           DECIMAL(10,2)  NULL,
    Valor_Taxas              DECIMAL(10,2)  NULL,
    Valor_Final              DECIMAL(10,2)  NOT NULL DEFAULT 0.00,

    CONSTRAINT pk_pedido PRIMARY KEY (Id_Pedido),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (Cpf_Cnpj)
        REFERENCES CLIENTE (Cpf_Cnpj),

    CONSTRAINT chk_pedido_status CHECK (Status_Pedido IN (
        'Aberto', 'Aguardando pagamento', 'Pago', 'Finalizado', 'Cancelado')),
    CONSTRAINT chk_pedido_parcelas CHECK (
        (Forma_Pagamento = 'Pix' AND Numero_Parcelas = 1)
        OR (Forma_Pagamento = 'Cartão de crédito' AND Numero_Parcelas BETWEEN 1 AND 12)),
    /* desconto Pix: só no Pix, com percentual 5, 7 ou 10 */
    CONSTRAINT chk_pedido_percentual CHECK (
        Percentual_Desconto_Pix IS NULL
        OR (Forma_Pagamento = 'Pix' AND Percentual_Desconto_Pix IN (5, 7, 10))),
    /* percentual e valor do desconto são preenchidos juntos */
    CONSTRAINT chk_pedido_desconto_par CHECK (
        (Percentual_Desconto_Pix IS NULL AND Valor_Desconto IS NULL)
        OR (Percentual_Desconto_Pix IS NOT NULL AND Valor_Desconto IS NOT NULL)),
    /* taxas/juros só existem no cartão de crédito */
    CONSTRAINT chk_pedido_taxas CHECK (
        Valor_Taxas IS NULL
        OR (Forma_Pagamento = 'Cartão de crédito' AND Valor_Taxas > 0)),
    CONSTRAINT chk_pedido_valores CHECK (
        Valor_Produtos >= 0
        AND (Valor_Desconto IS NULL OR (Valor_Desconto > 0 AND Valor_Desconto <= Valor_Produtos))),
    CONSTRAINT chk_pedido_valor_final CHECK (
        Valor_Final = Valor_Produtos - COALESCE(Valor_Desconto, 0) + COALESCE(Valor_Taxas, 0))
);


/* =====================================================================
   14. ITEM_PEDIDO (associativa PEDIDO x APARELHO)
   ===================================================================== */
CREATE TABLE ITEM_PEDIDO (
    Imei                          CHAR(15)       NOT NULL,
    Id_Pedido                     INT            NOT NULL,
    Preco_Unitario                DECIMAL(10,2)  NOT NULL,
    Data_Inicio_Garantia          DATE           NOT NULL,
    Data_Fim_Garantia_Loja        DATE           NOT NULL,
    Data_Fim_Garantia_Fabricante  DATE           NULL,

    CONSTRAINT pk_item_pedido PRIMARY KEY (Id_Pedido, Imei),
    CONSTRAINT fk_item_pedido_aparelho FOREIGN KEY (Imei)
        REFERENCES APARELHO (Imei),
    CONSTRAINT fk_item_pedido_pedido FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido),

    CONSTRAINT chk_item_pedido_preco CHECK (Preco_Unitario > 0),
    /* garantia da loja: 30 dias a partir do início */
    CONSTRAINT chk_item_pedido_garantia_loja CHECK (
        Data_Fim_Garantia_Loja = DATE_ADD(Data_Inicio_Garantia, INTERVAL 30 DAY)),
    CONSTRAINT chk_item_pedido_garantia_fab CHECK (
        Data_Fim_Garantia_Fabricante IS NULL
        OR Data_Fim_Garantia_Fabricante > Data_Inicio_Garantia)
);


/* =====================================================================
   15. PAGAMENTO
   ===================================================================== */
CREATE TABLE PAGAMENTO (
    Id_Pagamento      INT            NOT NULL AUTO_INCREMENT,
    Id_Pedido         INT            NOT NULL,
    Codigo_Transacao  VARCHAR(100)   NULL,
    Data_Tentativa    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Data_Confirmacao  DATETIME       NULL,
    Valor             DECIMAL(10,2)  NOT NULL,
    Status            VARCHAR(20)    NOT NULL DEFAULT 'Pendente',
    Comprovante       VARCHAR(100)   NULL,
    /* coluna técnica (não aparece no modelo lógico): recebe o Id_Pedido
       apenas quando o pagamento está Aprovado; o UNIQUE abaixo garante
       no máximo um pagamento Aprovado por pedido */
    Pedido_Aprovado   INT GENERATED ALWAYS AS (
                          CASE WHEN Status = 'Aprovado' THEN Id_Pedido ELSE NULL END) VIRTUAL,

    CONSTRAINT pk_pagamento PRIMARY KEY (Id_Pagamento),
    CONSTRAINT uq_pagamento_aprovado UNIQUE (Pedido_Aprovado),
    CONSTRAINT uq_pagamento_transacao UNIQUE (Codigo_Transacao),
    CONSTRAINT fk_pagamento_pedido FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido),

    CONSTRAINT chk_pagamento_status CHECK (Status IN (
        'Pendente', 'Aprovado', 'Recusado', 'Expirado', 'Estornado')),
    CONSTRAINT chk_pagamento_valor CHECK (Valor > 0),
    CONSTRAINT chk_pagamento_datas CHECK (
        Data_Confirmacao IS NULL OR Data_Confirmacao >= Data_Tentativa),
    /* aprovado (ou estornado depois de aprovado): confirmação e transação obrigatórias */
    CONSTRAINT chk_pagamento_aprovado CHECK (
        Status NOT IN ('Aprovado', 'Estornado')
        OR (Data_Confirmacao IS NOT NULL AND Codigo_Transacao IS NOT NULL)),
    /* sem aprovação não há data de confirmação */
    CONSTRAINT chk_pagamento_nao_aprovado CHECK (
        Status IN ('Aprovado', 'Estornado') OR Data_Confirmacao IS NULL)
);


/* =====================================================================
   16. CANCELAMENTO
   ===================================================================== */
CREATE TABLE CANCELAMENTO (
    Codigo_Cancelamento  INT           NOT NULL AUTO_INCREMENT,
    Id_Pedido            INT           NOT NULL,
    Data_Solicitacao     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Motivo               VARCHAR(255)  NOT NULL,
    Status               VARCHAR(20)   NOT NULL DEFAULT 'Solicitado',

    CONSTRAINT pk_cancelamento PRIMARY KEY (Codigo_Cancelamento),
    /* um pedido é cancelado no máximo uma vez */
    CONSTRAINT uq_cancelamento_pedido UNIQUE (Id_Pedido),
    CONSTRAINT fk_cancelamento_pedido FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido),

    CONSTRAINT chk_cancelamento_motivo CHECK (CHAR_LENGTH(TRIM(Motivo)) > 0),
    CONSTRAINT chk_cancelamento_status CHECK (Status IN ('Solicitado', 'Concluído', 'Recusado'))
);


/* =====================================================================
   17. POS_VENDA
   ===================================================================== */
CREATE TABLE POS_VENDA (
    Id_PosVenda       INT           NOT NULL AUTO_INCREMENT,
    Imei              CHAR(15)      NOT NULL,
    Id_Pedido         INT           NOT NULL,
    Tipo_Solicitacao  VARCHAR(15)   NOT NULL,
    Data_Abertura     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Descricao         VARCHAR(500)  NOT NULL,
    Status            VARCHAR(20)   NOT NULL DEFAULT 'Aberta',

    CONSTRAINT pk_pos_venda PRIMARY KEY (Id_PosVenda),
    /* FK composta: a solicitação é sobre um item de um pedido */
    CONSTRAINT fk_pos_venda_item FOREIGN KEY (Id_Pedido, Imei)
        REFERENCES ITEM_PEDIDO (Id_Pedido, Imei),

    CONSTRAINT chk_pos_venda_tipo CHECK (Tipo_Solicitacao IN ('Arrependimento', 'Defeito', 'Garantia')),
    CONSTRAINT chk_pos_venda_descricao CHECK (CHAR_LENGTH(TRIM(Descricao)) > 0),
    CONSTRAINT chk_pos_venda_status CHECK (Status IN ('Aberta', 'Em análise', 'Concluída', 'Recusada'))
);


/* =====================================================================
   18. AVALIACAO_DANO
   ===================================================================== */
CREATE TABLE AVALIACAO_DANO (
    Codigo_Avaliacao    INT           NOT NULL AUTO_INCREMENT,
    Id_PosVenda         INT           NOT NULL,
    Codigo_Funcionario  INT           NOT NULL,
    Classificacao_Dano  ENUM('Defeito de fabricação','Mau uso','Dano acidental','Outros') NOT NULL,
    Descricao_Dano      VARCHAR(500)  NOT NULL,
    Cobertura_Garantia  BOOLEAN       NOT NULL,
    Destino_Aparelho    ENUM('Disponível','Em manutenção','Inativo') NOT NULL,
    Data_Avaliacao      DATE          NOT NULL,

    CONSTRAINT pk_avaliacao_dano PRIMARY KEY (Codigo_Avaliacao),
    CONSTRAINT fk_aval_dano_pos_venda FOREIGN KEY (Id_PosVenda)
        REFERENCES POS_VENDA (Id_PosVenda),
    CONSTRAINT fk_aval_dano_funcionario FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    CONSTRAINT chk_aval_dano_descricao CHECK (CHAR_LENGTH(TRIM(Descricao_Dano)) > 0),
    CONSTRAINT chk_aval_dano_cobertura CHECK (Cobertura_Garantia IN (0, 1)),
    /* mau uso e dano acidental não são cobertos pela garantia */
    CONSTRAINT chk_aval_dano_mau_uso CHECK (
        Classificacao_Dano NOT IN ('Mau uso', 'Dano acidental') OR Cobertura_Garantia = 0)
);


/* =====================================================================
   19. DEVOLUCAO
   ===================================================================== */
CREATE TABLE DEVOLUCAO (
    Codigo_Devolucao  INT           NOT NULL AUTO_INCREMENT,
    Id_PosVenda       INT           NOT NULL,
    Data_Devolucao    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Motivo            VARCHAR(255)  NOT NULL,
    Status            VARCHAR(20)   NOT NULL DEFAULT 'Pendente',

    CONSTRAINT pk_devolucao PRIMARY KEY (Codigo_Devolucao),
    /* uma solicitação gera no máximo uma devolução */
    CONSTRAINT uq_devolucao_pos_venda UNIQUE (Id_PosVenda),
    CONSTRAINT fk_devolucao_pos_venda FOREIGN KEY (Id_PosVenda)
        REFERENCES POS_VENDA (Id_PosVenda),

    CONSTRAINT chk_devolucao_motivo CHECK (CHAR_LENGTH(TRIM(Motivo)) > 0),
    CONSTRAINT chk_devolucao_status CHECK (Status IN ('Pendente', 'Concluída', 'Recusada'))
);


/* =====================================================================
   20. TROCA
   ===================================================================== */
CREATE TABLE TROCA (
    Codigo_Troca    INT       NOT NULL AUTO_INCREMENT,
    Id_PosVenda     INT       NOT NULL,
    Imei_Reposicao  CHAR(15)  NOT NULL,
    Data_Troca      DATE      NOT NULL,
    Status          ENUM('Pendente','Concluída','Cancelada') NOT NULL DEFAULT 'Pendente',

    CONSTRAINT pk_troca PRIMARY KEY (Codigo_Troca),
    /* uma solicitação gera no máximo uma troca */
    CONSTRAINT uq_troca_pos_venda UNIQUE (Id_PosVenda),
    CONSTRAINT fk_troca_pos_venda FOREIGN KEY (Id_PosVenda)
        REFERENCES POS_VENDA (Id_PosVenda),
    CONSTRAINT fk_troca_aparelho FOREIGN KEY (Imei_Reposicao)
        REFERENCES APARELHO (Imei)
);


/* =====================================================================
   21. NOTA_FISCAL
   ===================================================================== */
CREATE TABLE NOTA_FISCAL (
    Id_Nota              INT          NOT NULL AUTO_INCREMENT,
    Numero_Nota          INT          NULL,
    Id_PosVenda          INT          NULL,
    Id_Nota_Referencia   INT          NULL,
    Codigo_Cancelamento  INT          NULL,
    Id_Pedido            INT          NULL,
    Chave_Acesso         VARCHAR(44)  NULL,
    Tipo_Nota            VARCHAR(20)  NOT NULL,
    Natureza             VARCHAR(60)  NOT NULL,
    Status               VARCHAR(20)  NOT NULL DEFAULT 'Aguardando emissão',
    Data_Emissao         DATETIME     NULL,

    CONSTRAINT pk_nota_fiscal PRIMARY KEY (Id_Nota),
    CONSTRAINT uq_nota_numero UNIQUE (Numero_Nota),
    CONSTRAINT uq_nota_chave UNIQUE (Chave_Acesso),
    CONSTRAINT fk_nota_pos_venda FOREIGN KEY (Id_PosVenda)
        REFERENCES POS_VENDA (Id_PosVenda),
    CONSTRAINT fk_nota_referencia FOREIGN KEY (Id_Nota_Referencia)
        REFERENCES NOTA_FISCAL (Id_Nota),
    CONSTRAINT fk_nota_cancelamento FOREIGN KEY (Codigo_Cancelamento)
        REFERENCES CANCELAMENTO (Codigo_Cancelamento),
    CONSTRAINT fk_nota_pedido FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido),

    CONSTRAINT chk_nota_tipo CHECK (Tipo_Nota IN (
        'Venda', 'Entrada (Devolução)', 'Saída (Reposição)')),
    CONSTRAINT chk_nota_status CHECK (Status IN (
        'Aguardando emissão', 'Emitida', 'Pendente', 'Cancelada')),
    CONSTRAINT chk_nota_natureza CHECK (CHAR_LENGTH(TRIM(Natureza)) > 0),
    CONSTRAINT chk_nota_numero CHECK (Numero_Nota IS NULL OR Numero_Nota > 0),
    CONSTRAINT chk_nota_chave CHECK (Chave_Acesso IS NULL OR Chave_Acesso REGEXP '^[0-9]{44}$'),
    /* exatamente uma origem: pedido (venda), cancelamento ou pós-venda */
    CONSTRAINT chk_nota_origem CHECK (
        (Id_Pedido IS NOT NULL) + (Codigo_Cancelamento IS NOT NULL) + (Id_PosVenda IS NOT NULL) = 1),
    /* nota de venda: origem no pedido e sem nota de referência */
    CONSTRAINT chk_nota_venda CHECK (
        Tipo_Nota <> 'Venda' OR (Id_Pedido IS NOT NULL AND Id_Nota_Referencia IS NULL)),
    /* nota de entrada: vem de cancelamento ou de devolução e referencia a nota de venda */
    CONSTRAINT chk_nota_entrada CHECK (
        Tipo_Nota <> 'Entrada (Devolução)'
        OR (Id_Pedido IS NULL AND Id_Nota_Referencia IS NOT NULL)),
    /* nota de reposição (troca): vem do pós-venda e referencia a nota de venda */
    CONSTRAINT chk_nota_reposicao CHECK (
        Tipo_Nota <> 'Saída (Reposição)'
        OR (Id_PosVenda IS NOT NULL AND Id_Nota_Referencia IS NOT NULL)),
    /* nota emitida tem número, chave e data; antes da autorização ficam vazios */
    CONSTRAINT chk_nota_emitida CHECK (
        Status NOT IN ('Emitida', 'Cancelada')
        OR (Numero_Nota IS NOT NULL AND Chave_Acesso IS NOT NULL AND Data_Emissao IS NOT NULL)),
    CONSTRAINT chk_nota_nao_emitida CHECK (
        Status NOT IN ('Aguardando emissão', 'Pendente')
        OR (Numero_Nota IS NULL AND Chave_Acesso IS NULL AND Data_Emissao IS NULL))
);


/* =====================================================================
   22. ITEM_NOTA_FISCAL (associativa NOTA_FISCAL x APARELHO)
   ===================================================================== */
CREATE TABLE ITEM_NOTA_FISCAL (
    Imei        CHAR(15)       NOT NULL,
    Id_Nota     INT            NOT NULL,
    Valor_Item  DECIMAL(10,2)  NOT NULL,

    CONSTRAINT pk_item_nota_fiscal PRIMARY KEY (Id_Nota, Imei),
    CONSTRAINT fk_item_nota_aparelho FOREIGN KEY (Imei)
        REFERENCES APARELHO (Imei),
    CONSTRAINT fk_item_nota_nota FOREIGN KEY (Id_Nota)
        REFERENCES NOTA_FISCAL (Id_Nota),

    CONSTRAINT chk_item_nota_valor CHECK (Valor_Item > 0)
);


/* =====================================================================
   23. ESTORNO
   A forma de restituição vem da forma de pagamento do pedido
   (Pix → devolução Pix; cartão → estorno na fatura). Por isso não há
   dados bancários nesta tabela.
   ===================================================================== */
CREATE TABLE ESTORNO (
    Id_Estorno           INT            NOT NULL AUTO_INCREMENT,
    Id_Pagamento         INT            NOT NULL,
    Codigo_Devolucao     INT            NULL,
    Codigo_Cancelamento  INT            NULL,
    Valor                DECIMAL(10,2)  NOT NULL,
    Data_Abertura        DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    /* derivado: Data_Abertura + 15 dias */
    Prazo_Limite         DATETIME GENERATED ALWAYS AS (
                             DATE_ADD(Data_Abertura, INTERVAL 15 DAY)) STORED,
    Data_Conclusao       DATETIME       NULL,
    Status               VARCHAR(20)    NOT NULL DEFAULT 'Pendente',

    CONSTRAINT pk_estorno PRIMARY KEY (Id_Estorno),
    CONSTRAINT uq_estorno_devolucao UNIQUE (Codigo_Devolucao),
    CONSTRAINT uq_estorno_cancelamento UNIQUE (Codigo_Cancelamento),
    CONSTRAINT fk_estorno_pagamento FOREIGN KEY (Id_Pagamento)
        REFERENCES PAGAMENTO (Id_Pagamento),
    CONSTRAINT fk_estorno_devolucao FOREIGN KEY (Codigo_Devolucao)
        REFERENCES DEVOLUCAO (Codigo_Devolucao),
    CONSTRAINT fk_estorno_cancelamento FOREIGN KEY (Codigo_Cancelamento)
        REFERENCES CANCELAMENTO (Codigo_Cancelamento),

    /* exatamente uma origem: devolução ou cancelamento */
    CONSTRAINT chk_estorno_origem CHECK (
        (Codigo_Devolucao IS NOT NULL AND Codigo_Cancelamento IS NULL)
        OR (Codigo_Devolucao IS NULL AND Codigo_Cancelamento IS NOT NULL)),
    CONSTRAINT chk_estorno_valor  CHECK (Valor > 0),
    CONSTRAINT chk_estorno_status CHECK (Status IN ('Pendente', 'Processado', 'Recusado')),
    CONSTRAINT chk_estorno_datas  CHECK (Data_Conclusao IS NULL OR Data_Conclusao >= Data_Abertura),
    /* concluído (Processado ou Recusado) tem data de conclusão; Pendente não tem */
    CONSTRAINT chk_estorno_conclusao CHECK (
        (Status = 'Pendente' AND Data_Conclusao IS NULL)
        OR (Status IN ('Processado', 'Recusado') AND Data_Conclusao IS NOT NULL))
);


/* =====================================================================
   24. ENTREGA
   ===================================================================== */
CREATE TABLE ENTREGA (
    Codigo_Rastreio     VARCHAR(30)   NOT NULL,
    Codigo_Troca        INT           NULL,
    Id_Pedido           INT           NOT NULL,
    Transportadora      VARCHAR(100)  NOT NULL,
    Status_Entrega      VARCHAR(20)   NOT NULL DEFAULT 'Aguardando envio',
    Data_Despacho       DATETIME      NULL,
    Data_Entrega        DATETIME      NULL,
    Origem_Atualizacao  VARCHAR(10)   NOT NULL DEFAULT 'Manual',

    CONSTRAINT pk_entrega PRIMARY KEY (Codigo_Rastreio),
    /* cada troca gera no máximo uma entrega de reposição */
    CONSTRAINT uq_entrega_troca UNIQUE (Codigo_Troca),
    CONSTRAINT fk_entrega_troca FOREIGN KEY (Codigo_Troca)
        REFERENCES TROCA (Codigo_Troca),
    CONSTRAINT fk_entrega_pedido FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido),

    CONSTRAINT chk_entrega_rastreio CHECK (Codigo_Rastreio REGEXP '^[A-Za-z0-9]{8,30}$'),
    CONSTRAINT chk_entrega_transportadora CHECK (CHAR_LENGTH(TRIM(Transportadora)) > 0),
    CONSTRAINT chk_entrega_status CHECK (Status_Entrega IN (
        'Aguardando envio', 'Em transporte', 'Entregue')),
    CONSTRAINT chk_entrega_origem CHECK (Origem_Atualizacao IN ('Automática', 'Manual')),
    /* datas coerentes com o status */
    CONSTRAINT chk_entrega_aguardando CHECK (
        Status_Entrega <> 'Aguardando envio' OR (Data_Despacho IS NULL AND Data_Entrega IS NULL)),
    CONSTRAINT chk_entrega_transporte CHECK (
        Status_Entrega <> 'Em transporte' OR (Data_Despacho IS NOT NULL AND Data_Entrega IS NULL)),
    CONSTRAINT chk_entrega_entregue CHECK (
        Status_Entrega <> 'Entregue' OR (Data_Despacho IS NOT NULL AND Data_Entrega IS NOT NULL)),
    CONSTRAINT chk_entrega_datas CHECK (
        Data_Entrega IS NULL OR Data_Despacho IS NULL OR Data_Entrega >= Data_Despacho)
);


/* =====================================================================
   25. REQUISICAO_COMPRA
   ===================================================================== */
CREATE TABLE REQUISICAO_COMPRA (
    Id_Requisicao       INT           NOT NULL AUTO_INCREMENT,
    Codigo_Funcionario  INT           NULL,
    Id_Especificacao    INT           NOT NULL,
    Qtd_Atual_Estoque   INT           NOT NULL,
    Estoque_Minimo      INT           NOT NULL,
    Parecer_Financeiro  VARCHAR(500)  NULL,
    Data_Abertura       DATE          NOT NULL,
    Data_Decisao        DATE          NULL,
    Motivo_Recusa       VARCHAR(255)  NULL,
    Status              ENUM('Aguardando Análise Financeira',
                             'Aguardando Aprovação da Diretoria',
                             'Aprovada','Recusada') NOT NULL DEFAULT 'Aguardando Análise Financeira',
    Qtd_Sugerida        INT           NOT NULL,

    CONSTRAINT pk_requisicao_compra PRIMARY KEY (Id_Requisicao),
    CONSTRAINT fk_requisicao_funcionario FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),
    CONSTRAINT fk_requisicao_especificacao FOREIGN KEY (Id_Especificacao)
        REFERENCES ESPECIFICACAO_APARELHO (Id_Especificacao),

    CONSTRAINT chk_requisicao_qtd CHECK (
        Qtd_Atual_Estoque >= 0 AND Estoque_Minimo >= 0 AND Qtd_Sugerida > 0),
    CONSTRAINT chk_requisicao_datas CHECK (Data_Decisao IS NULL OR Data_Decisao >= Data_Abertura),
    /* em aberto: sem decisão, sem decisor e sem motivo de recusa */
    CONSTRAINT chk_requisicao_aberta CHECK (
        Status NOT IN ('Aguardando Análise Financeira', 'Aguardando Aprovação da Diretoria')
        OR (Codigo_Funcionario IS NULL AND Data_Decisao IS NULL AND Motivo_Recusa IS NULL)),
    /* depois da análise financeira, o parecer é obrigatório */
    CONSTRAINT chk_requisicao_parecer CHECK (
        Status = 'Aguardando Análise Financeira'
        OR (Parecer_Financeiro IS NOT NULL AND CHAR_LENGTH(TRIM(Parecer_Financeiro)) > 0)),
    /* decidida (aprovada ou recusada): decisor (Diretoria) e data obrigatórios */
    CONSTRAINT chk_requisicao_decidida CHECK (
        Status NOT IN ('Aprovada', 'Recusada')
        OR (Codigo_Funcionario IS NOT NULL AND Data_Decisao IS NOT NULL)),
    /* recusa exige motivo; aprovação não tem motivo de recusa */
    CONSTRAINT chk_requisicao_recusa CHECK (
        (Status = 'Recusada' AND Motivo_Recusa IS NOT NULL AND CHAR_LENGTH(TRIM(Motivo_Recusa)) > 0)
        OR (Status <> 'Recusada' AND Motivo_Recusa IS NULL))
);


/* =====================================================================
   26. MOVIMENTACAO
   ===================================================================== */
CREATE TABLE MOVIMENTACAO (
    Numero_Movimentacao  INT       NOT NULL AUTO_INCREMENT,
    Codigo_Funcionario   INT       NULL,
    Imei                 CHAR(15)  NOT NULL,
    Tipo_Movimento       ENUM('Entrada','Fim de quarentena','Venda','Devolução',
                              'Avaliação','Manutenção','Retorno ao estoque',
                              'Inativação') NOT NULL,
    Status_Anterior      ENUM('Em quarentena','Disponível','Vendido',
                              'Em avaliação','Em manutenção','Inativo') NULL,
    Status_Novo          ENUM('Em quarentena','Disponível','Vendido',
                              'Em avaliação','Em manutenção','Inativo') NOT NULL,
    Data_Hora            DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_movimentacao PRIMARY KEY (Numero_Movimentacao),
    CONSTRAINT fk_movimentacao_funcionario FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),
    CONSTRAINT fk_movimentacao_aparelho FOREIGN KEY (Imei)
        REFERENCES APARELHO (Imei),

    /* a movimentação sempre muda o status */
    CONSTRAINT chk_movimentacao_status CHECK (
        Status_Anterior IS NULL OR Status_Anterior <> Status_Novo),
    /* só a entrada no estoque não tem status anterior */
    CONSTRAINT chk_movimentacao_entrada CHECK (
        (Tipo_Movimento = 'Entrada') = (Status_Anterior IS NULL))
);


/* =====================================================================
   27. AUDITORIA
   ===================================================================== */
CREATE TABLE AUDITORIA (
    Id_Auditoria        INT           NOT NULL AUTO_INCREMENT,
    Codigo_Funcionario  INT           NULL,
    Codigo_Autorizador  INT           NULL,
    Acao                VARCHAR(50)   NOT NULL,
    Tabela_Afetada      VARCHAR(50)   NOT NULL,
    Registro_Id         VARCHAR(50)   NOT NULL,
    Valor_Anterior      JSON          NULL,
    Valor_Novo          JSON          NULL,
    Data_Hora           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Descricao           VARCHAR(500)  NULL,

    CONSTRAINT pk_auditoria PRIMARY KEY (Id_Auditoria),
    CONSTRAINT fk_auditoria_funcionario FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),
    CONSTRAINT fk_auditoria_autorizador FOREIGN KEY (Codigo_Autorizador)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    CONSTRAINT chk_auditoria_textos CHECK (
        CHAR_LENGTH(TRIM(Acao)) > 0
        AND CHAR_LENGTH(TRIM(Tabela_Afetada)) > 0
        AND CHAR_LENGTH(TRIM(Registro_Id)) > 0),
    CONSTRAINT chk_auditoria_tabela CHECK (Tabela_Afetada IN (
        'PERFIL_ACESSO','FUNCIONARIO','FORNECEDOR','MODELO','ESPECIFICACAO_APARELHO',
        'AQUISICAO','AVALIACAO_ENTRADA','APARELHO','IMAGEM_APARELHO','CLIENTE',
        'ENDERECO','TELEFONE','PEDIDO','ITEM_PEDIDO','PAGAMENTO','CANCELAMENTO',
        'POS_VENDA','AVALIACAO_DANO','DEVOLUCAO','TROCA','NOTA_FISCAL',
        'ITEM_NOTA_FISCAL','ESTORNO','ENTREGA','REQUISICAO_COMPRA','MOVIMENTACAO')),
    /* pelo menos um dos dois estados (antes ou depois) é registrado */
    CONSTRAINT chk_auditoria_valores CHECK (Valor_Anterior IS NOT NULL OR Valor_Novo IS NOT NULL)
);
