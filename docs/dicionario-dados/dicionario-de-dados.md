# CellGO — Dicionário de Dados

> Cópia da seção 9 do [README principal](../../README.md).

## 9. Dicionário de Dados

### 1. CLIENTE

Pessoa física ou jurídica que compra aparelhos na loja on-line.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Cpf_Cnpj | PK | VARCHAR | Identificador único do cliente: CPF (11 dígitos) para pessoa física ou CNPJ (14 dígitos) para pessoa jurídica, apenas números. | 14 | NÃO |
| Nome | — | VARCHAR | Nome completo do cliente ou razão social, quando pessoa jurídica. | 150 | NÃO |
| Email | — | VARCHAR | Endereço de e-mail de contato do cliente; usado nas notificações (RF-24). | 254 | NÃO |
| Data_Nascimento | — | DATE | Data de nascimento do cliente pessoa física; usada para impedir compra por menor de 18 anos. Vazia para pessoa jurídica. | — | SIM |
| Tipo_Pessoa | — | ENUM | Tipo do cliente: PF (pessoa física) ou PJ (pessoa jurídica). | — | NÃO |

### 2. ENDERECO

Endereços cadastrados por um cliente, usados para entrega ou cobrança.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Endereco | PK | INT | Identificador único do endereço. | — | NÃO |
| Cpf_Cnpj | FK | VARCHAR | Referencia o CLIENTE dono do endereço. | 14 | NÃO |
| Rua | — | VARCHAR | Nome da rua ou avenida. | 150 | NÃO |
| Bairro | — | VARCHAR | Bairro do endereço. | 100 | NÃO |
| Cidade | — | VARCHAR | Cidade do endereço. | 100 | NÃO |
| CEP | — | VARCHAR | Código de Endereçamento Postal, apenas números. | 8 | NÃO |
| Numero | — | VARCHAR | Número do imóvel (texto, pois pode conter letras, como "120A" ou "S/N"). | 10 | NÃO |
| Complemento | — | VARCHAR | Informação complementar do endereço (apartamento, bloco etc.). | 100 | SIM |
| Tipo_Endereco | — | VARCHAR | Finalidade do endereço: residencial, comercial, entrega ou cobrança. | 20 | NÃO |

### 3. TELEFONE

Entidade fraca: cada número de telefone de um cliente. Identificada pelo Cpf_Cnpj do cliente junto com DDD e número.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| DDD | PK | INT | Código de área do telefone, com dois dígitos. | — | NÃO |
| Numero_Telefone | PK | INT | Número do telefone, apenas dígitos (8 para fixo ou 9 para celular). | — | NÃO |
| Cpf_Cnpj | PK, FK | VARCHAR | Referencia o CLIENTE titular do telefone; faz parte da chave, pois o telefone só existe ligado ao cliente. | 14 | NÃO |

### 4. PEDIDO

A venda feita a um cliente e suas condições comerciais: forma de pagamento escolhida e valores calculados. Os aparelhos ficam em ITEM_PEDIDO e as cobranças em PAGAMENTO.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Pedido | PK | INT | Identificador único do pedido. | — | NÃO |
| Cpf_Cnpj | FK | VARCHAR | Referencia o CLIENTE que realizou o pedido. | 14 | NÃO |
| Data_Pedido | — | DATETIME | Data e hora em que o pedido foi realizado. | — | NÃO |
| Status_Pedido | — | VARCHAR | Situação do pedido: Aberto, Aguardando pagamento, Pago, Finalizado ou Cancelado. | 25 | NÃO |
| Forma_Pagamento | — | ENUM | Forma de pagamento escolhida. Valores permitidos: Pix ou Cartão de crédito (boleto e débito não são aceitos). Define o desconto, as parcelas e as taxas. | — | NÃO |
| Numero_Parcelas | — | INT | Quantidade de parcelas. Pix: sempre 1. Cartão de crédito: de 1 a 12. | — | NÃO |
| Valor_Produtos | Derivado | DECIMAL | Soma dos preços dos aparelhos do pedido (ITEM_PEDIDO). | (10,2) | NÃO |
| Percentual_Desconto_Pix | — | DECIMAL | Percentual de desconto aplicado (5, 7 ou 10). Preenchido só quando a forma de pagamento é Pix e o produto é elegível; vazio no cartão de crédito. | (5,2) | SIM |
| Valor_Desconto | — | DECIMAL | Valor do desconto Pix aplicado ao pedido. Vazio no cartão de crédito. | (10,2) | SIM |
| Valor_Taxas | — | DECIMAL | Juros ou taxas do parcelamento no cartão de crédito, quando houver. Vazio no Pix. | (10,2) | SIM |
| Valor_Final | Derivado | DECIMAL | Valor_Produtos − Valor_Desconto + Valor_Taxas (campos vazios contam como zero). | (10,2) | NÃO |

### 5. ITEM_PEDIDO

Entidade associativa: resolve o relacionamento N:N entre PEDIDO e APARELHO, guardando o preço praticado e a garantia de cada aparelho naquele pedido.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Imei | PK, FK | CHAR | Referencia o APARELHO vendido nesse item. | 15 | NÃO |
| Id_Pedido | PK, FK | INT | Referencia o PEDIDO ao qual o item pertence. | — | NÃO |
| Preco_Unitario | — | DECIMAL | Preço do aparelho praticado naquele pedido. | (10,2) | NÃO |
| Data_Inicio_Garantia | — | DATE | Início da garantia (data da venda). | — | NÃO |
| Data_Fim_Garantia_Loja | Derivado | DATE | Fim da garantia da loja (início + 30 dias). | — | NÃO |
| Data_Fim_Garantia_Fabricante | — | DATE | Fim da garantia do fabricante. Vazia para seminovos sem garantia do fabricante. | — | SIM |

### 6. PAGAMENTO

Cada tentativa de cobrança do pedido enviada à instituição de pagamento. A forma de pagamento e as parcelas ficam no PEDIDO.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Pagamento | PK | INT | Identificador único do pagamento. | — | NÃO |
| Id_Pedido | FK | INT | Referencia o PEDIDO cobrado. | — | NÃO |
| Codigo_Transacao | — | VARCHAR | Identificador da transação na instituição de pagamento: txid do Pix ou código de autorização (NSU) do cartão de crédito. | 100 | SIM |
| Data_Tentativa | — | DATETIME | Data e hora em que a cobrança foi gerada. | — | NÃO |
| Data_Confirmacao | — | DATETIME | Data e hora da aprovação. Vazia enquanto o pagamento não for aprovado. | — | SIM |
| Valor | — | DECIMAL | Valor cobrado nesta tentativa (Valor_Final do pedido no momento da cobrança). | (10,2) | NÃO |
| Status | — | VARCHAR | Pendente, Aprovado, Recusado, Expirado ou Estornado. No máximo um pagamento Aprovado por pedido. | 20 | NÃO |
| Comprovante | — | VARCHAR | Referência do comprovante de pagamento. | 100 | SIM |

### 7. NOTA_FISCAL

Documento fiscal de uma operação com mercadoria: venda, entrada (devolução) ou saída (reposição). Cada nota tem uma única origem: pedido, cancelamento ou pós-venda.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Nota | PK | INT | Identificador interno da nota, criado quando a emissão é iniciada. | — | NÃO |
| Numero_Nota | — | INT | Número da NF-e atribuído na autorização da SEFAZ. Vazio enquanto a nota estiver Aguardando emissão ou Pendente. | — | SIM |
| Id_PosVenda | FK | INT | Referencia o POS_VENDA, quando a nota é de devolução, troca ou reposição. | — | SIM |
| Id_Nota_Referencia | FK | INT | Referencia a NOTA_FISCAL de venda original (autorrelacionamento). Vazia na própria nota de venda. | — | SIM |
| Codigo_Cancelamento | FK | INT | Referencia o CANCELAMENTO, quando a nota é de entrada por cancelamento fora do prazo de cancelamento direto. | — | SIM |
| Id_Pedido | FK | INT | Referencia o PEDIDO, quando a nota é de venda. | — | SIM |
| Chave_Acesso | Único | VARCHAR | Chave de acesso de 44 dígitos gerada pela SEFAZ. Vazia enquanto a nota não for autorizada. | 44 | SIM |
| Tipo_Nota | — | VARCHAR | Venda, Entrada (Devolução) ou Saída (Reposição). | 20 | NÃO |
| Natureza | — | VARCHAR | Natureza da operação fiscal. | 60 | NÃO |
| Status | — | VARCHAR | Aguardando emissão, Emitida, Pendente ou Cancelada. | 20 | NÃO |
| Data_Emissao | — | DATETIME | Data e hora de emissão. Vazia enquanto a nota não for emitida. | — | SIM |

### 8. ITEM_NOTA_FISCAL

Entidade associativa: resolve o relacionamento N:N entre NOTA_FISCAL e APARELHO, registrando cada aparelho (IMEI) documentado em uma nota.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Imei | PK, FK | CHAR | Referencia o APARELHO documentado na nota. | 15 | NÃO |
| Id_Nota | PK, FK | INT | Referencia a NOTA_FISCAL à qual o item pertence. | — | NÃO |
| Valor_Item | — | DECIMAL | Valor do aparelho na nota (na reposição de troca, o valor fiscal, sem cobrança ao cliente). | (10,2) | NÃO |

### 9. CANCELAMENTO

Cancelamento de um pedido antes do envio, em até 7 dias da compra.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Cancelamento | PK | INT | Identificador único do cancelamento. | — | NÃO |
| Id_Pedido | FK | INT | Referencia o PEDIDO cancelado. | — | NÃO |
| Data_Solicitacao | — | DATETIME | Data e hora da solicitação de cancelamento. | — | NÃO |
| Motivo | — | VARCHAR | Motivo informado para o cancelamento. | 255 | NÃO |
| Status | — | VARCHAR | Situação do cancelamento. | 20 | NÃO |

### 10. ESTORNO

Devolução de valor ao cliente, originada por um cancelamento ou por uma devolução, sempre ligada ao pagamento revertido.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Estorno | PK | INT | Identificador único do estorno. | — | NÃO |
| Id_Pagamento | FK | INT | Referencia o PAGAMENTO Aprovado que está sendo revertido. A forma de restituição vem da forma de pagamento do pedido: Pix → devolução Pix para a conta de origem; cartão de crédito → estorno na operadora. | — | NÃO |
| Codigo_Devolucao | FK | INT | Referencia a DEVOLUCAO que originou o estorno, quando aplicável. | — | SIM |
| Codigo_Cancelamento | FK | INT | Referencia o CANCELAMENTO que originou o estorno, quando aplicável. Apenas uma das duas origens é preenchida. | — | SIM |
| Valor | — | DECIMAL | Valor a restituir ao cliente. | (10,2) | NÃO |
| Data_Abertura | — | DATETIME | Data e hora de abertura do estorno. | — | NÃO |
| Prazo_Limite | Derivado | DATETIME | Data_Abertura + 15 dias. O estorno é considerado atrasado se esse prazo vencer com status Pendente. | — | NÃO |
| Data_Conclusao | — | DATETIME | Data em que o estorno foi concluído. | — | SIM |
| Status | — | VARCHAR | Pendente, Processado ou Recusado. | 20 | NÃO |

### 11. ENTREGA

Envio e rastreamento de um pedido ou de um aparelho de reposição de troca.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Rastreio | PK | VARCHAR | Código de rastreamento da transportadora (contém letras e números). | 30 | NÃO |
| Codigo_Troca | FK | INT | Referencia a TROCA que originou uma entrega de reposição. Vazio na entrega de venda; é este campo que indica se o envio é de venda ou de reposição. | — | SIM |
| Id_Pedido | FK | INT | Referencia o PEDIDO ao qual a entrega se refere. | — | NÃO |
| Transportadora | — | VARCHAR | Nome da transportadora responsável pela entrega. | 100 | NÃO |
| Status_Entrega | — | VARCHAR | Aguardando envio, Em transporte ou Entregue. | 20 | NÃO |
| Data_Despacho | — | DATETIME | Data e hora em que a entrega foi despachada. | — | SIM |
| Data_Entrega | — | DATETIME | Data e hora em que a entrega foi concluída. | — | SIM |
| Origem_Atualizacao | — | VARCHAR | Origem da última atualização do status: Automática (API da transportadora) ou Manual. | 10 | NÃO |

### 12. POS_VENDA

Solicitação do cliente sobre um aparelho já vendido (arrependimento, defeito ou garantia).

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_PosVenda | PK | INT | Identificador único da solicitação. | — | NÃO |
| Imei | FK | CHAR | Junto com Id_Pedido, referencia o ITEM_PEDIDO objeto da solicitação (FK composta). | 15 | NÃO |
| Id_Pedido | FK | INT | Junto com Imei, referencia o ITEM_PEDIDO objeto da solicitação (FK composta). | — | NÃO |
| Tipo_Solicitacao | — | VARCHAR | Arrependimento, Defeito ou Garantia. | 15 | NÃO |
| Data_Abertura | — | DATETIME | Data e hora de abertura da solicitação. | — | NÃO |
| Descricao | — | VARCHAR | Detalhamento da solicitação feito pelo cliente. | 500 | NÃO |
| Status | — | VARCHAR | Situação atual da solicitação. | 20 | NÃO |

### 13. DEVOLUCAO

Devolução de um aparelho, por arrependimento ou por defeito, originada de uma solicitação de pós-venda.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Devolucao | PK | INT | Identificador único da devolução. | — | NÃO |
| Id_PosVenda | FK | INT | Referencia o POS_VENDA que originou a devolução; o tipo da devolução (Arrependimento ou Defeito) vem do Tipo_Solicitacao do POS_VENDA. | — | NÃO |
| Data_Devolucao | — | DATETIME | Data e hora da devolução. | — | NÃO |
| Motivo | — | VARCHAR | Justificativa da devolução. | 255 | NÃO |
| Status | — | VARCHAR | Situação atual da devolução. | 20 | NÃO |

### 14. AVALIACAO_DANO

Avaliação técnica do aparelho em uma solicitação de pós-venda.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Avaliacao | PK | INT | Identificador único da avaliação de dano. | — | NÃO |
| Id_PosVenda | FK | INT | Referencia o POS_VENDA avaliado. | — | NÃO |
| Codigo_Funcionario | FK | INT | Referencia o FUNCIONARIO (Assistência Técnica) que fez a avaliação. | — | NÃO |
| Classificacao_Dano | — | ENUM | Defeito de fabricação, Mau uso, Dano acidental ou Outros. | — | NÃO |
| Descricao_Dano | — | VARCHAR | Detalhamento do dano constatado. | 500 | NÃO |
| Cobertura_Garantia | — | BOOLEAN | Verdadeiro quando o dano é coberto pela garantia. | — | NÃO |
| Destino_Aparelho | — | ENUM | Disponível, Em manutenção ou Inativo. | — | NÃO |
| Data_Avaliacao | — | DATE | Data da avaliação técnica. | — | NÃO |

### 15. TROCA

Troca de um aparelho com defeito coberto pela garantia por um aparelho equivalente.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Troca | PK | INT | Identificador único da troca. | — | NÃO |
| Id_PosVenda | FK | INT | Referencia o POS_VENDA que originou a troca. | — | NÃO |
| Imei_Reposicao | FK | CHAR | Referencia o APARELHO enviado como reposição. | 15 | NÃO |
| Data_Troca | — | DATE | Data em que a troca foi realizada. | — | NÃO |
| Status | — | ENUM | Situação atual da troca. | — | NÃO |

### 16. APARELHO

Unidade física de celular, identificada pelo IMEI, desde a entrada no estoque até a venda.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Imei | PK | CHAR | Identificador único internacional do aparelho (15 dígitos). | 15 | NÃO |
| Id_Especificacao | FK | INT | Referencia a ESPECIFICACAO_APARELHO (modelo, cor e capacidade). | — | NÃO |
| Id_Avaliacao_Entrada | FK, Único | INT | Referencia a AVALIACAO_ENTRADA aprovada que liberou a entrada do aparelho; por ela se chega à AQUISICAO e ao FORNECEDOR. | — | NÃO |
| Codigo_Funcionario | FK | INT | Referencia o FUNCIONARIO que cadastrou o aparelho. | — | NÃO |
| Condicao | — | ENUM | Novo ou Seminovo; define o prazo de garantia. | — | NÃO |
| Preco_Venda | — | DECIMAL | Preço de venda do aparelho. | (10,2) | NÃO |
| Custo_Aquisicao | — | DECIMAL | Valor pago pela loja na aquisição. | (10,2) | NÃO |
| Status | — | ENUM | Em quarentena, Disponível, Vendido, Em avaliação, Em manutenção ou Inativo. | — | NÃO |
| Data_Entrada | — | DATE | Data de entrada no estoque. | — | NÃO |
| Data_Disponivel | — | DATE | Data em que o aparelho passou a Disponível; base do cálculo do tempo em estoque (RN-05). | — | SIM |
| Data_Fim_Quarentena | Derivado | DATE | Data_Entrada + 15 dias, apenas para seminovos comprados de pessoa física. | — | SIM |
| Elegivel_Desconto_Pix | — | BOOLEAN | Verdadeiro quando o aparelho participa do desconto Pix (definido pela Diretoria). | — | NÃO |

### 17. IMAGEM_APARELHO

Foto de um aparelho exibida na loja on-line.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Imagem | PK | INT | Identificador único da imagem. | — | NÃO |
| Imei | FK | CHAR | Referencia o APARELHO fotografado. | 15 | NÃO |
| URL | — | VARCHAR | Endereço onde a imagem está armazenada. | 500 | NÃO |

### 18. ESPECIFICACAO_APARELHO

Combinação de modelo, cor e capacidade, com os parâmetros de estoque mínimo e de giro.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Especificacao | PK | INT | Identificador único da especificação. | — | NÃO |
| Id_Modelo | FK | INT | Referencia o MODELO do aparelho; a marca vem do modelo. | — | NÃO |
| Cor | — | VARCHAR | Cor do aparelho. | 30 | NÃO |
| Capacidade | — | INT | Capacidade de armazenamento, em GB. | — | NÃO |
| Estoque_Minimo | — | INT | Quantidade mínima de aparelhos Disponíveis; dispara a requisição de compra (RN-06). | — | NÃO |
| Limite_Dias_Atencao | — | INT | Dias a partir dos quais o aparelho é classificado como Atenção/Giro Lento. | — | NÃO |
| Limite_Dias_Critico | — | INT | Dias a partir dos quais o aparelho é classificado como Crítico/Encalhado. | — | NÃO |

### 19. MODELO

Modelo de celular e sua marca. Separado da especificação porque a marca depende só do modelo, e não da cor ou da capacidade (3FN).

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Modelo | PK | INT | Identificador único do modelo. | — | NÃO |
| Nome_Modelo | Único | VARCHAR | Nome comercial do modelo (ex.: iPhone 15, Galaxy S24). | 100 | NÃO |
| Marca | — | VARCHAR | Fabricante do modelo. | 50 | NÃO |

### 20. REQUISICAO_COMPRA

Pedido interno de reposição de estoque de uma especificação.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Requisicao | PK | INT | Identificador único da requisição. | — | NÃO |
| Codigo_Funcionario | FK | INT | Referencia o FUNCIONARIO da Diretoria que decidiu a requisição. Vazio até a decisão. | — | SIM |
| Id_Especificacao | FK | INT | Referencia a ESPECIFICACAO_APARELHO requisitada. | — | NÃO |
| Qtd_Atual_Estoque | — | INT | Quantidade Disponível no momento da abertura (registro histórico). | — | NÃO |
| Estoque_Minimo | — | INT | Estoque mínimo vigente na abertura (registro histórico, pois o parâmetro pode mudar). | — | NÃO |
| Parecer_Financeiro | — | VARCHAR | Análise do Financeiro (fluxo de caixa ou orçamento). | 500 | SIM |
| Data_Abertura | — | DATE | Data de abertura da requisição. | — | NÃO |
| Data_Decisao | — | DATE | Data da aprovação ou recusa. | — | SIM |
| Motivo_Recusa | — | VARCHAR | Justificativa da recusa; obrigatória quando a requisição é recusada. | 255 | SIM |
| Status | — | ENUM | Aguardando Análise Financeira, Aguardando Aprovação da Diretoria, Aprovada ou Recusada. | — | NÃO |
| Qtd_Sugerida | — | INT | Quantidade sugerida para compra. | — | NÃO |

### 21. MOVIMENTACAO

Histórico de cada mudança de status de um aparelho.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Numero_Movimentacao | PK | INT | Identificador único da movimentação. | — | NÃO |
| Codigo_Funcionario | FK | INT | Referencia o FUNCIONARIO que fez a movimentação. Vazio quando a mudança é automática (ex.: baixa na aprovação do pagamento). | — | SIM |
| Imei | FK | CHAR | Referencia o APARELHO movimentado. | 15 | NÃO |
| Tipo_Movimento | — | ENUM | Tipo da movimentação (entrada, venda, devolução, avaliação, manutenção, inativação etc.). | — | NÃO |
| Status_Anterior | — | ENUM | Status antes da movimentação. Vazio na primeira movimentação (entrada no estoque). | — | SIM |
| Status_Novo | — | ENUM | Status depois da movimentação. | — | NÃO |
| Data_Hora | — | DATETIME | Data e hora da movimentação. | — | NÃO |

### 22. AUDITORIA

Registro das operações sensíveis, com quem executou e quem autorizou.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Auditoria | PK | INT | Identificador único do registro. | — | NÃO |
| Codigo_Funcionario | FK | INT | Referencia o FUNCIONARIO que executou a ação. Vazio quando a ação é automática. | — | SIM |
| Codigo_Autorizador | FK | INT | Referencia o FUNCIONARIO que autorizou a ação. Vazio quando não exige autorização. | — | SIM |
| Acao | — | VARCHAR | Tipo de ação realizada. | 50 | NÃO |
| Tabela_Afetada | — | VARCHAR | Tabela afetada pela ação. | 50 | NÃO |
| Registro_Id | — | VARCHAR | Identificador do registro afetado. | 50 | NÃO |
| Valor_Anterior | — | JSON | Dados antes da alteração. | — | SIM |
| Valor_Novo | — | JSON | Dados depois da alteração. | — | SIM |
| Data_Hora | — | DATETIME | Data e hora do registro. | — | NÃO |
| Descricao | — | VARCHAR | Detalhamento da ação. | 500 | SIM |

### 23. FUNCIONARIO

Colaborador ou sócio que usa o sistema, com o seu perfil de acesso.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Funcionario | PK | INT | Identificador único do funcionário. | — | NÃO |
| Nome | — | VARCHAR | Nome completo. | 150 | NÃO |
| Cargo | — | VARCHAR | Cargo ou função. | 50 | NÃO |
| Login | Único | VARCHAR | Login de acesso ao sistema. | 50 | NÃO |
| Id_Perfil | FK | INT | Referencia o PERFIL_ACESSO do funcionário; o nível de acesso vem do perfil. | — | NÃO |
| Ativo | — | BOOLEAN | Verdadeiro quando o funcionário está ativo. | — | NÃO |

### 24. PERFIL_ACESSO

Perfis de acesso do sistema e o nível hierárquico de cada um. Separado de FUNCIONARIO porque o nível depende só do perfil (3FN).

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Perfil | PK | INT | Identificador único do perfil. | — | NÃO |
| Nome_Perfil | Único | VARCHAR | Vendas e Atendimento, Estoque e Logística, Assistência Técnica, Financeiro/Administrativo ou Diretoria. | 40 | NÃO |
| Nivel_Acesso | — | INT | 1 (Operacional) para os perfis das áreas ou 2 (Estratégico) para a Diretoria. | — | NÃO |

### 25. FORNECEDOR

Pessoa física ou distribuidor que vende aparelhos para a loja.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Cpf_Cnpj_Fornecedor | PK | VARCHAR | CPF (pessoa física) ou CNPJ (distribuidor), apenas números; base do limite de 3 aparelhos por CPF/dia. | 14 | NÃO |
| Tipo_Pessoa | — | ENUM | PF ou PJ. | — | NÃO |
| Nome | — | VARCHAR | Nome completo ou razão social. | 150 | NÃO |
| Tipo_Documento | — | VARCHAR | Documento oficial com foto apresentado (RG ou CNH). Obrigatório para pessoa física. | 10 | SIM |
| Numero_Documento | — | VARCHAR | Número do documento com foto. Obrigatório para pessoa física. | 20 | SIM |
| Telefone_Contato | — | VARCHAR | Telefone de contato com DDD, apenas números. | 11 | NÃO |

### 26. AQUISICAO

Cada compra de aparelhos feita pela loja junto a um fornecedor.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Aquisicao | PK | INT | Identificador único da aquisição. | — | NÃO |
| Codigo_Funcionario | FK | INT | Referencia o FUNCIONARIO (Estoque e Logística) que registrou a aquisição. | — | NÃO |
| Cpf_Cnpj_Fornecedor | FK | VARCHAR | Referencia o FORNECEDOR que vendeu os aparelhos. | 14 | NÃO |
| Data_Aquisicao | — | DATE | Data da aquisição; usada no limite diário por CPF. | — | NÃO |
| Tipo_Documento_Compra | — | VARCHAR | Nota fiscal do fornecedor ou Termo de compra e venda. | 30 | NÃO |
| Numero_Documento_Compra | — | VARCHAR | Número da nota fiscal ou do termo. | 50 | NÃO |
| Termo_Responsabilidade_Aceito | — | BOOLEAN | Verdadeiro quando o fornecedor pessoa física aceitou o termo de remoção de contas e dados. Vazio para pessoa jurídica. | — | SIM |
| Valor_Total | Derivado | DECIMAL | Soma do Custo_Aquisicao dos aparelhos aprovados. | (10,2) | NÃO |
| Status | — | VARCHAR | Em avaliação, Concluída ou Recusada. | 20 | NÃO |

### 27. AVALIACAO_ENTRADA

Consulta do IMEI e checklist técnico de cada aparelho oferecido à loja, registrada mesmo quando o aparelho é recusado.

| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Avaliacao_Entrada | PK | INT | Identificador único da avaliação de entrada. | — | NÃO |
| Codigo_Funcionario | FK | INT | Referencia o FUNCIONARIO (Assistência Técnica) que fez a avaliação. | — | NÃO |
| Id_Aquisicao | FK | INT | Referencia a AQUISICAO em que o aparelho foi oferecido. | — | NÃO |
| Imei_Avaliado | — | CHAR | IMEI do aparelho oferecido. Não é FK, porque o aparelho recusado não é cadastrado em APARELHO. | 15 | NÃO |
| Base_Consultada | — | VARCHAR | Base em que o IMEI foi consultado. | 50 | NÃO |
| Resultado_Consulta_Imei | — | VARCHAR | Regular, Roubado/Furtado, Bloqueado ou Adulterado. | 20 | NÃO |
| Data_Consulta | — | DATETIME | Data e hora da consulta do IMEI. | — | NÃO |
| Checklist_Bateria | — | BOOLEAN | Verdadeiro quando aprovado. Vazio para aparelho lacrado. | — | SIM |
| Checklist_Tela | — | BOOLEAN | Verdadeiro quando aprovado. Vazio para aparelho lacrado. | — | SIM |
| Checklist_Cameras | — | BOOLEAN | Verdadeiro quando aprovado. Vazio para aparelho lacrado. | — | SIM |
| Checklist_Botoes | — | BOOLEAN | Verdadeiro quando aprovado. Vazio para aparelho lacrado. | — | SIM |
| Checklist_Som | — | BOOLEAN | Verdadeiro quando aprovado (autofalante e microfone). Vazio para aparelho lacrado. | — | SIM |
| Checklist_Conectividade | — | BOOLEAN | Verdadeiro quando aprovado (rede, Wi-Fi e Bluetooth). Vazio para aparelho lacrado. | — | SIM |
| Checklist_Pecas_Originais | — | BOOLEAN | Verdadeiro quando as peças são originais. Vazio para aparelho lacrado. | — | SIM |
| Bloqueio_Conta | — | BOOLEAN | Verdadeiro quando há bloqueio iCloud/FRP que não pôde ser removido (motivo de recusa). Vazio para aparelho lacrado. | — | SIM |
| Reset_Fabrica_Realizado | — | BOOLEAN | Verdadeiro quando o reset de fábrica foi feito. Vazio para aparelho recusado. | — | SIM |
| Resultado | — | VARCHAR | Aprovado ou Recusado. | 10 | NÃO |
| Motivo_Recusa | — | VARCHAR | Motivo da recusa; obrigatório quando o resultado for Recusado. | 255 | SIM |
| Data_Reconsulta_Imei | — | DATETIME | Data da nova consulta do IMEI ao fim da quarentena. Vazia quando não há quarentena. | — | SIM |
| Resultado_Reconsulta_Imei | — | VARCHAR | Resultado da nova consulta: Regular, Roubado/Furtado, Bloqueado ou Adulterado. Vazio quando não há quarentena. | 20 | SIM |
