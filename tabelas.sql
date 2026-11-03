CREATE DATABASE cellgo;

USE cellgo;


/*24. TABELA PERFIL_ACESSO*/
CREATE TABLE PERFIL_ACESSO (
    Id_Perfil INT NOT NULL,
    Nome_Perfil VARCHAR(40) NOT NULL UNIQUE,
    Nivel_Acesso INT NOT NULL,

    PRIMARY KEY (Id_Perfil),

    CHECK (
        Nome_Perfil IN (
            'Vendas e Atendimento',
            'Estoque e Logística',
            'Assistência Técnica',
            'Financeiro/Administrativo',
            'Diretoria'
        )
    ),

    CHECK (
        (Nome_Perfil = 'Diretoria' AND Nivel_Acesso = 2)
        OR
        (Nome_Perfil <> 'Diretoria' AND Nivel_Acesso = 1)
    )
);

/*23. TABELA FUNCIONARIO*/
CREATE TABLE FUNCIONARIO (
    Codigo_Funcionario INT NOT NULL,
    Nome VARCHAR(150) NOT NULL,
    Cargo VARCHAR(50) NOT NULL,
    Login VARCHAR(50) NOT NULL UNIQUE,
    Id_Perfil INT NOT NULL,
    Ativo BOOLEAN NOT NULL,

    PRIMARY KEY (Codigo_Funcionario),

    FOREIGN KEY (Id_Perfil)
        REFERENCES PERFIL_ACESSO (Id_Perfil),

    CHECK (Ativo IN (0, 1))
);

/*25. TABELA FORNECEDOR*/
CREATE TABLE FORNECEDOR (
    Cpf_Cnpj_Fornecedor VARCHAR(14) NOT NULL,
    Tipo_Pessoa ENUM('PF', 'PJ') NOT NULL,
    Nome VARCHAR(150) NOT NULL,
    Tipo_Documento VARCHAR(10) NULL,
    Numero_Documento VARCHAR(20) NULL,
    Telefone_Contato VARCHAR(11) NOT NULL,

    PRIMARY KEY (Cpf_Cnpj_Fornecedor)
);

/*19. TABELA MODELO*/
CREATE TABLE MODELO (
    Id_Modelo INT NOT NULL,
    Nome_Modelo VARCHAR(100) NOT NULL UNIQUE,
    Marca VARCHAR(50) NOT NULL,

    PRIMARY KEY (Id_Modelo)
);

/*18. TABELA ESPECIFICACAO_APARELHO*/
CREATE TABLE ESPECIFICACAO_APARELHO (
    Id_Especificacao INT NOT NULL,
    Id_Modelo INT NOT NULL,
    Cor VARCHAR(30) NOT NULL,
    Capacidade INT NOT NULL,
    Estoque_Minimo INT NOT NULL,
    Limite_Dias_Atencao INT NOT NULL,
    Limite_Dias_Critico INT NOT NULL,

    PRIMARY KEY (Id_Especificacao),

    FOREIGN KEY (Id_Modelo)
        REFERENCES MODELO (Id_Modelo),

    UNIQUE (Id_Modelo, Cor, Capacidade),

    CHECK (Capacidade > 0),
    CHECK (Estoque_Minimo >= 0),
    CHECK (Limite_Dias_Atencao >= 0),
    CHECK (Limite_Dias_Critico > Limite_Dias_Atencao)
);

/*26. TABELA AQUISICAO*/
CREATE TABLE AQUISICAO (
    Id_Aquisicao INT NOT NULL,
    Codigo_Funcionario INT NOT NULL,
    Cpf_Cnpj_Fornecedor VARCHAR(14) NOT NULL,
    Data_Aquisicao DATE NOT NULL,
    Tipo_Documento_Compra VARCHAR(30) NOT NULL,
    Numero_Documento_Compra VARCHAR(50) NOT NULL,
    Termo_Responsabilidade_Aceito BOOLEAN,
    Valor_Total DECIMAL(10,2) NOT NULL,
    Status VARCHAR(20) NOT NULL,

    PRIMARY KEY (Id_Aquisicao),

    FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    FOREIGN KEY (Cpf_Cnpj_Fornecedor)
        REFERENCES FORNECEDOR (Cpf_Cnpj_Fornecedor),

    CHECK (
        Tipo_Documento_Compra IN (
            'Nota Fiscal',
            'Termo de Compra e Venda'
        )
    ),

    CHECK (
        Status IN (
            'Em avaliação',
            'Concluída',
            'Recusada'
        )
    )
);

/*27. TABELA AVALIACAO_ENTRADA*/
CREATE TABLE AVALIACAO_ENTRADA (
    Id_Avaliacao_Entrada INT NOT NULL,
    Codigo_Funcionario INT NOT NULL,
    Id_Aquisicao INT NOT NULL,
    Imei_Avaliado CHAR(15) NOT NULL,
    Base_Consultada VARCHAR(50) NOT NULL,
    Resultado_Consulta_Imei VARCHAR(20) NOT NULL,
    Data_Consulta DATETIME NOT NULL,

    Checklist_Bateria BOOLEAN NULL,
    Checklist_Tela BOOLEAN NULL,
    Checklist_Cameras BOOLEAN NULL,
    Checklist_Botoes BOOLEAN NULL,
    Checklist_Som BOOLEAN NULL,
    Checklist_Conectividade BOOLEAN NULL,
    Checklist_Pecas_Originais BOOLEAN NULL,
    Bloqueio_Conta BOOLEAN NULL,
    Reset_Fabrica_Realizado BOOLEAN NULL,

    Resultado VARCHAR(10) NOT NULL,
    Motivo_Recusa VARCHAR(255) NULL,
    Data_Reconsulta_Imei DATETIME NULL,
    Resultado_Reconsulta_Imei VARCHAR(20) NULL,

    PRIMARY KEY (Id_Avaliacao_Entrada),

    FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    FOREIGN KEY (Id_Aquisicao)
        REFERENCES AQUISICAO (Id_Aquisicao),

    CHECK (
        Resultado_Consulta_Imei IN (
            'Regular',
            'Roubado/Furtado',
            'Bloqueado',
            'Adulterado'
        )
    ),

    CHECK (
        Resultado_Reconsulta_Imei IN (
            'Regular',
            'Roubado/Furtado',
            'Bloqueado',
            'Adulterado'
        )
    ),

    CHECK (Resultado IN ('Aprovado', 'Recusado')),

    CHECK (
        Resultado <> 'Recusado'
        OR (
            Motivo_Recusa IS NOT NULL
            AND CHAR_LENGTH(TRIM(Motivo_Recusa)) > 0
        )
    ),

    CHECK (Checklist_Bateria IN (0, 1)),
    CHECK (Checklist_Tela IN (0, 1)),
    CHECK (Checklist_Cameras IN (0, 1)),
    CHECK (Checklist_Botoes IN (0, 1)),
    CHECK (Checklist_Som IN (0, 1)),
    CHECK (Checklist_Conectividade IN (0, 1)),
    CHECK (Checklist_Pecas_Originais IN (0, 1)),
    CHECK (Bloqueio_Conta IN (0, 1)),
    CHECK (Reset_Fabrica_Realizado IN (0, 1)),

    CHECK (Data_Reconsulta_Imei >= Data_Consulta),

    CHECK (
        (Data_Reconsulta_Imei IS NULL
         AND Resultado_Reconsulta_Imei IS NULL)
        OR
        (Data_Reconsulta_Imei IS NOT NULL
         AND Resultado_Reconsulta_Imei IS NOT NULL)
    )
);

/*16. TABELA APARELHO*/
CREATE TABLE APARELHO (
    Imei CHAR(15) NOT NULL,
    Id_Especificacao INT NOT NULL,
    Id_Avaliacao_Entrada INT NOT NULL UNIQUE,
    Codigo_Funcionario INT NOT NULL,
    Condicao ENUM('Novo', 'Seminovo') NOT NULL,
    Preco_Venda DECIMAL(10,2) NOT NULL,
    Custo_Aquisicao DECIMAL(10,2) NOT NULL,

    Status ENUM(
        'Em quarentena',
        'Disponível',
        'Vendido',
        'Em avaliação',
        'Em manutenção',
        'Inativo'
    ) NOT NULL,

    Data_Entrada DATE NOT NULL,
    Data_Disponivel DATE NULL,
    Data_Fim_Quarentena DATE NULL,
    Elegivel_Desconto_Pix BOOLEAN NOT NULL,

    PRIMARY KEY (Imei),

    FOREIGN KEY (Id_Especificacao)
        REFERENCES ESPECIFICACAO_APARELHO (Id_Especificacao),

    FOREIGN KEY (Id_Avaliacao_Entrada)
        REFERENCES AVALIACAO_ENTRADA (Id_Avaliacao_Entrada),

    FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    CHECK (Preco_Venda >= 0),
    CHECK (Custo_Aquisicao >= 0),

    CHECK (Data_Disponivel >= Data_Entrada),
    CHECK (Data_Fim_Quarentena >= Data_Entrada),

    CHECK (Elegivel_Desconto_Pix IN (0, 1))
);



/*9. TABELA CLIENTE*/
CREATE TABLE CLIENTE (
    Cpf_Cnpj VARCHAR(14) NOT NULL,
    Nome VARCHAR(150) NOT NULL,
    Email VARCHAR(254) NOT NULL,
    Data_Nascimento DATE NULL,
    Tipo_Pessoa ENUM('PF', 'PJ') NOT NULL,

    PRIMARY KEY (Cpf_Cnpj),

    CHECK (
        Tipo_Pessoa <> 'PF'
        OR Data_Nascimento IS NOT NULL
    )
);

/*10. TABELA ENDERECO*/
CREATE TABLE ENDERECO (
    Id_endereco INT NOT NULL,
    Cpf_Cnpj VARCHAR(14) NOT NULL,
    Rua VARCHAR(150) NOT NULL,
    Bairro VARCHAR(100) NOT NULL,
    Cidade VARCHAR(100) NOT NULL,
    CEP VARCHAR(8) NOT NULL,
    Numero VARCHAR(10) NOT NULL,
    Complemento VARCHAR(100) NULL,
    Tipo_endereco VARCHAR(20) NOT NULL,

    PRIMARY KEY (Id_endereco),

    FOREIGN KEY (Cpf_Cnpj)
        REFERENCES CLIENTE (Cpf_Cnpj)
);

/*11. TABELA TELEFONE*/
CREATE TABLE TELEFONE (
    DDD CHAR(2) NOT NULL,
    Numero_Telefone VARCHAR(9) NOT NULL,
    Cpf_Cnpj VARCHAR(14) NOT NULL,

    PRIMARY KEY (Cpf_Cnpj, DDD, Numero_Telefone),

    FOREIGN KEY (Cpf_Cnpj)
        REFERENCES CLIENTE (Cpf_Cnpj)
);

/*12. TABELA PEDIDO*/
CREATE TABLE PEDIDO (
    Id_Pedido INT NOT NULL,
    Cpf_Cnpj VARCHAR(14) NOT NULL,
    Data_Pedido DATETIME NOT NULL,
    Status_Pedido VARCHAR(25) NOT NULL,
    Forma_Pagamento ENUM('Pix', 'Cartão de crédito') NOT NULL,
    Numero_Parcelas INT NOT NULL,
    Valor_Produtos DECIMAL(10,2) NOT NULL,
    Percentual_Desconto_Pix DECIMAL(5,2) NULL,
    Valor_Desconto DECIMAL(10,2) NULL,
    Valor_Taxas DECIMAL(10,2) NULL,
    Valor_Final DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (Id_Pedido),

    FOREIGN KEY (Cpf_Cnpj)
        REFERENCES CLIENTE (Cpf_Cnpj),

    CHECK (
        Status_Pedido IN (
            'Aberto',
            'Aguardando pagamento',
            'Pago',
            'Finalizado',
            'Cancelado'
        )
    ),

    CHECK (Numero_Parcelas BETWEEN 1 AND 12),

    CHECK (
        Forma_Pagamento = 'Cartão de crédito'
        OR Numero_Parcelas = 1
    ),

    CHECK (
        Percentual_Desconto_Pix IS NULL
        OR (
            Forma_Pagamento = 'Pix'
            AND Percentual_Desconto_Pix IN (5, 7, 10)
        )
    ),

    CHECK (Valor_Produtos >= 0),
    CHECK (Valor_Desconto >= 0),
    CHECK (Valor_Taxas >= 0),
    CHECK (Valor_Final >= 0)
);

/*13. TABELA IMAGEM_APARELHO*/
CREATE TABLE IMAGEM_APARELHO (
    Id_Imagem INT NOT NULL,
    Imei CHAR(15) NOT NULL,
    URL VARCHAR(500) NOT NULL,

    PRIMARY KEY (Id_Imagem),

    FOREIGN KEY (Imei)
        REFERENCES APARELHO (Imei)
);

/*14. TABELA ITEM_PEDIDO*/
CREATE TABLE ITEM_PEDIDO (
    Imei CHAR(15) NOT NULL,
    Id_Pedido INT NOT NULL,
    Preco_Unitario DECIMAL(10,2) NOT NULL,
    Data_Inicio_Garantia DATE NOT NULL,
    Data_Fim_Garantia_Loja DATE NOT NULL,
    Data_Fim_Garantia_Fabricante DATE NULL,

    PRIMARY KEY (Id_Pedido, Imei),

    FOREIGN KEY (Imei)
        REFERENCES APARELHO (Imei),

    FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido)
);

/*15. TABELA PAGAMENTO*/
CREATE TABLE PAGAMENTO (
    Id_Pagamento INT NOT NULL,
    Id_Pedido INT NOT NULL,
    Codigo_Transacao VARCHAR(100) NULL,
    Data_Tentativa DATETIME NOT NULL,
    Data_Confirmacao DATETIME NULL,
    Valor DECIMAL(10,2) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    Comprovante VARCHAR(100) NULL,

    Pedido_Aprovado INT
        GENERATED ALWAYS AS (
            CASE
                WHEN Status = 'Aprovado' THEN Id_Pedido
                ELSE NULL
            END
        ) VIRTUAL,

    PRIMARY KEY (Id_Pagamento),

    FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido),

    CONSTRAINT uq_pagamento_aprovado
        UNIQUE (Pedido_Aprovado),

    CHECK (
        Status IN (
            'Pendente',
            'Aprovado',
            'Recusado',
            'Expirado',
            'Estornado'
        )
    ),

    CHECK (Valor >= 0),

    CHECK (Data_Confirmacao >= Data_Tentativa),

    CHECK (
        Status <> 'Aprovado'
        OR Data_Confirmacao IS NOT NULL
    )
);

/*16. TABELA CANCELAMENTO*/
CREATE TABLE CANCELAMENTO (
    Codigo_Cancelamento INT NOT NULL,
    Id_Pedido INT NOT NULL UNIQUE,
    Data_Solicitacao DATETIME NOT NULL,
    Motivo VARCHAR(255) NOT NULL,
    Status VARCHAR(20) NOT NULL,

    PRIMARY KEY (Codigo_Cancelamento),

    FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido)
);



/*17. TABELA POS_VENDA*/
CREATE TABLE POS_VENDA (
    Id_PosVenda INT NOT NULL,
    Imei CHAR(15) NOT NULL,
    Id_Pedido INT NOT NULL,
    Tipo_Solicitacao VARCHAR(15) NOT NULL,
    Data_Abertura DATETIME NOT NULL,
    Descricao VARCHAR(500) NOT NULL,
    Status VARCHAR(20) NOT NULL,

    PRIMARY KEY (Id_PosVenda),

    FOREIGN KEY (Id_Pedido, Imei)
        REFERENCES ITEM_PEDIDO (Id_Pedido, Imei),

    CHECK (
        Tipo_Solicitacao IN (
            'Arrependimento',
            'Defeito',
            'Garantia'
        )
    )
);

/*18. TABELA DEVOLUCAO*/
CREATE TABLE DEVOLUCAO (
    Codigo_Devolucao INT NOT NULL,
    Id_PosVenda INT NOT NULL,
    Data_Devolucao DATETIME NOT NULL,
    Motivo VARCHAR(255) NOT NULL,
    Status VARCHAR(20) NOT NULL,

    PRIMARY KEY (Codigo_Devolucao),

    FOREIGN KEY (Id_PosVenda)
        REFERENCES POS_VENDA (Id_PosVenda)
);

/*19. TABELA AVALIACAO_DANO*/
CREATE TABLE AVALIACAO_DANO (
    Codigo_Avaliacao INT NOT NULL,
    Id_PosVenda INT NOT NULL,
    Codigo_Funcionario INT NOT NULL,

    Classificacao_Dano ENUM(
        'Defeito de fabricação',
        'Mau uso',
        'Dano acidental',
        'Outros'
    ) NOT NULL,

    Descricao_Dano VARCHAR(500) NOT NULL,
    Cobertura_Garantia BOOLEAN NOT NULL,

    Destino_Aparelho ENUM(
        'Disponível',
        'Em manutenção',
        'Inativo'
    ) NOT NULL,

    Data_Avaliacao DATE NOT NULL,

    PRIMARY KEY (Codigo_Avaliacao),

    FOREIGN KEY (Id_PosVenda)
        REFERENCES POS_VENDA (Id_PosVenda),

    FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    CHECK (Cobertura_Garantia IN (0, 1))
);

/*20. TABELA TROCA*/
CREATE TABLE TROCA (
    Codigo_Troca INT NOT NULL,
    Id_PosVenda INT NOT NULL,
    Imei_Reposicao CHAR(15) NOT NULL,
    Data_Troca DATE NOT NULL,

    Status ENUM(
        'Pendente',
        'Concluída',
        'Cancelada'
    ) NOT NULL,

    PRIMARY KEY (Codigo_Troca),

    FOREIGN KEY (Id_PosVenda)
        REFERENCES POS_VENDA (Id_PosVenda),

    FOREIGN KEY (Imei_Reposicao)
        REFERENCES APARELHO (Imei)
);

/*21. TABELA NOTA_FISCAL*/
CREATE TABLE NOTA_FISCAL (
    Id_Nota INT NOT NULL,
    Numero_Nota INT NULL,
    Id_PosVenda INT NULL,
    Id_Nota_Referencia INT NULL,
    Codigo_Cancelamento INT NULL,
    Id_Pedido INT NULL,
    Chave_Acesso VARCHAR(44) NULL UNIQUE,
    Tipo_Nota VARCHAR(20) NOT NULL,
    Natureza VARCHAR(60) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    Data_Emissao DATETIME NULL,

    PRIMARY KEY (Id_Nota),

    FOREIGN KEY (Id_PosVenda)
        REFERENCES POS_VENDA (Id_PosVenda),

    FOREIGN KEY (Id_Nota_Referencia)
        REFERENCES NOTA_FISCAL (Id_Nota),

    FOREIGN KEY (Codigo_Cancelamento)
        REFERENCES CANCELAMENTO (Codigo_Cancelamento),

    FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido),

    CHECK (
        Tipo_Nota IN (
            'Venda',
            'Entrada (Devolução)',
            'Saída (Reposição)'
        )
    ),

    CHECK (
        Status IN (
            'Aguardando emissão',
            'Emitida',
            'Pendente',
            'Cancelada'
        )
    ),

    CHECK (
        (CASE WHEN Id_Pedido IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN Codigo_Cancelamento IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN Id_PosVenda IS NOT NULL THEN 1 ELSE 0 END)
        = 1
    ),

    CHECK (Numero_Nota > 0),

    CHECK (
        Id_Nota_Referencia IS NULL
        OR Id_Nota_Referencia <> Id_Nota
    ),

    CHECK (
        Status <> 'Emitida'
        OR (
            Numero_Nota IS NOT NULL
            AND Chave_Acesso IS NOT NULL
            AND Data_Emissao IS NOT NULL
        )
    )
);

/*22. TABELA ESTORNO*/
CREATE TABLE ESTORNO (
    Id_Estorno INT NOT NULL,
    Id_Pagamento INT NOT NULL,
    Codigo_Devolucao INT NULL,
    Codigo_Cancelamento INT NULL,
    Valor DECIMAL(10,2) NOT NULL,
    Banco VARCHAR(50) NULL,
    Agencia VARCHAR(10) NULL,
    Conta VARCHAR(20) NULL,
    Tipo_Conta ENUM('Corrente', 'Poupança') NULL,
    Data_Abertura DATETIME NOT NULL,

    Prazo_Limite DATETIME
        GENERATED ALWAYS AS (
            DATE_ADD(Data_Abertura, INTERVAL 15 DAY)
        ) STORED,

    Data_Conclusao DATETIME NULL,
    Status VARCHAR(20) NOT NULL,

    PRIMARY KEY (Id_Estorno),

    FOREIGN KEY (Id_Pagamento)
        REFERENCES PAGAMENTO (Id_Pagamento),

    FOREIGN KEY (Codigo_Devolucao)
        REFERENCES DEVOLUCAO (Codigo_Devolucao),

    FOREIGN KEY (Codigo_Cancelamento)
        REFERENCES CANCELAMENTO (Codigo_Cancelamento),

    CHECK (
        (Codigo_Devolucao IS NOT NULL
         AND Codigo_Cancelamento IS NULL)
        OR
        (Codigo_Devolucao IS NULL
         AND Codigo_Cancelamento IS NOT NULL)
    ),

    CHECK (Valor > 0),

    CHECK (
        Status IN ('Pendente', 'Processado', 'Recusado')
    ),

    CHECK (Data_Conclusao >= Data_Abertura),

    CHECK (
        Status <> 'Processado'
        OR Data_Conclusao IS NOT NULL
    )
);

/*23. TABELA ENTREGA*/
CREATE TABLE ENTREGA (
    Codigo_Rastreio VARCHAR(30) NOT NULL,
    Codigo_Troca INT NULL,
    Id_Pedido INT NOT NULL,
    Transportadora VARCHAR(100) NOT NULL,
    Status_Entrega VARCHAR(20) NOT NULL,
    Data_Despacho DATETIME NULL,
    Data_Entrega DATETIME NULL,
    Origem_Atualizacao VARCHAR(10) NOT NULL,

    PRIMARY KEY (Codigo_Rastreio),

    FOREIGN KEY (Codigo_Troca)
        REFERENCES TROCA (Codigo_Troca),

    FOREIGN KEY (Id_Pedido)
        REFERENCES PEDIDO (Id_Pedido),

    CHECK (
        Status_Entrega IN (
            'Aguardando envio',
            'Em transporte',
            'Entregue'
        )
    ),

    CHECK (
        Origem_Atualizacao IN ('Automática', 'Manual')
    ),

    CHECK (Data_Entrega >= Data_Despacho),

    CHECK (
        Status_Entrega NOT IN ('Em transporte', 'Entregue')
        OR Data_Despacho IS NOT NULL
    ),

    CHECK (
        Status_Entrega <> 'Entregue'
        OR Data_Entrega IS NOT NULL
    ),

    CHECK (
        Data_Entrega IS NULL
        OR Data_Despacho IS NOT NULL
    )
);

/*24. TABELA REQUISICAO_COMPRA*/
CREATE TABLE REQUISICAO_COMPRA (
    Id_Requisicao INT NOT NULL,
    Codigo_Funcionario INT NULL,
    Id_Especificacao INT NOT NULL,
    Qtd_Atual_Estoque INT NOT NULL,
    Estoque_Minimo INT NOT NULL,
    Parecer_Financeiro VARCHAR(500) NULL,
    Data_Abertura DATE NOT NULL,
    Data_Decisao DATE NULL,
    Motivo_Recusa VARCHAR(255) NULL,
    Status VARCHAR(40) NOT NULL,
    Qtd_Sugerida INT NOT NULL,

    PRIMARY KEY (Id_Requisicao),

    FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    FOREIGN KEY (Id_Especificacao)
        REFERENCES ESPECIFICACAO_APARELHO (Id_Especificacao),

    CHECK (
        Status IN (
            'Aguardando Análise Financeira',
            'Aguardando Aprovação da Diretoria',
            'Aprovada',
            'Recusada'
        )
    ),

    CHECK (
        Status <> 'Recusada'
        OR Motivo_Recusa IS NOT NULL
    )
);



/*25. TABELA MOVIMENTACAO*/
CREATE TABLE MOVIMENTACAO (
    Numero_Movimentacao INT NOT NULL,
    Codigo_Funcionario INT NULL,
    Imei CHAR(15) NOT NULL,

    Tipo_Movimento ENUM(
        'Entrada',
        'Venda',
        'Devolução',
        'Avaliação',
        'Manutenção',
        'Inativação'
    ) NOT NULL,

    Status_Anterior ENUM(
        'Em quarentena',
        'Disponível',
        'Vendido',
        'Em avaliação',
        'Em manutenção',
        'Inativo'
    ) NULL,

    Status_Novo ENUM(
        'Em quarentena',
        'Disponível',
        'Vendido',
        'Em avaliação',
        'Em manutenção',
        'Inativo'
    ) NOT NULL,

    Data_Hora DATETIME NOT NULL,

    PRIMARY KEY (Numero_Movimentacao),

    FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    FOREIGN KEY (Imei)
        REFERENCES APARELHO (Imei)
);

/*26. TABELA AUDITORIA*/
CREATE TABLE AUDITORIA (
    Id_Auditoria INT NOT NULL,
    Codigo_Funcionario INT NULL,
    Codigo_Autorizador INT NULL,
    Acao VARCHAR(50) NOT NULL,
    Tabela_Afetada VARCHAR(50) NOT NULL,
    Registro_Id VARCHAR(50) NOT NULL,
    Valor_Anterior JSON NULL,
    Valor_Novo JSON NULL,
    Data_Hora DATETIME NOT NULL,
    Descricao VARCHAR(500) NULL,

    PRIMARY KEY (Id_Auditoria),

    FOREIGN KEY (Codigo_Funcionario)
        REFERENCES FUNCIONARIO (Codigo_Funcionario),

    FOREIGN KEY (Codigo_Autorizador)
        REFERENCES FUNCIONARIO (Codigo_Funcionario)
);