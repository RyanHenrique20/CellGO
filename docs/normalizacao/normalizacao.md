# CellGO — Normalização

> Cópia da seção 8 do [README principal](../../README.md).

## 8. Normalização (1FN, 2FN e 3FN)

**Decisão:** O modelo foi revisado para atender à 1ª, à 2ª e à 3ª Forma Normal. Os campos calculados (marcados como "Derivado" no dicionário) foram mantidos de propósito, como desnormalização controlada.

**Justificativa:**

**1ª Forma Normal (valores atômicos, sem grupos repetidos).** Todas as tabelas têm chave primária, e cada campo guarda um único valor. Os dados que podem se repetir para um mesmo registro ganharam tabelas próprias: telefones (TELEFONE), endereços (ENDERECO), fotos (IMAGEM_APARELHO), itens do pedido (ITEM_PEDIDO) e itens da nota (ITEM_NOTA_FISCAL). Os campos Valor_Anterior e Valor_Novo de AUDITORIA usam JSON porque guardam uma cópia do registro alterado apenas para consulta: o sistema nunca pesquisa nem altera dados dentro desse conteúdo, e ele não pode mais ser modificado depois de gravado (RNF-07).

**2ª Forma Normal (sem dependência de parte da chave).** Só se aplica às tabelas com chave composta, e as três atendem: em TELEFONE não há atributos fora da chave; em ITEM_PEDIDO, o preço praticado e as datas de garantia dependem do par pedido + aparelho, e não de só um deles; em ITEM_NOTA_FISCAL, o valor do item depende do par nota + aparelho.

**3ª Forma Normal (sem dependência entre atributos que não são chave).** Foram eliminadas as dependências transitivas encontradas no modelo: o nível de acesso, que dependia do perfil, foi para PERFIL_ACESSO; a marca, que dependia do modelo, foi para MODELO; e saíram os atributos que podiam ser deduzidos de outra tabela: a forma de restituição do estorno (vem da forma de pagamento do pedido), o tipo da devolução (vem do Tipo_Solicitacao do POS_VENDA) e o tipo de envio da entrega (é de reposição quando Codigo_Troca está preenchido).

**Campos calculados mantidos (desnormalização controlada).** Alguns campos podem ser calculados a partir de outros e, pela 3FN rígida, poderiam sair do modelo. Eles foram mantidos de propósito:

| Campo | Cálculo | Por que foi mantido |
|---|---|---|
| PEDIDO.Valor_Produtos, Valor_Desconto e Valor_Final | Soma dos itens; percentual × valor; produtos − desconto + taxas | Registram os valores exatamente como foram apresentados ao cliente e cobrados na venda (RN-09), servem de base para a nota fiscal e o financeiro e não mudam depois da confirmação |
| ITEM_PEDIDO.Data_Fim_Garantia_Loja | Início da garantia + 30 dias | Consultada em toda solicitação de pós-venda para saber se a garantia está vigente (RN-17); se a política de prazo mudar, as vendas antigas mantêm o prazo da época |
| ESTORNO.Prazo_Limite | Data de abertura + 15 dias | Usado diariamente para identificar estornos atrasados e notificar o Financeiro (RN-19) |
| APARELHO.Data_Fim_Quarentena | Data de entrada + 15 dias | Usado para liberar os aparelhos ao fim da quarentena (RN-25) |
| AQUISICAO.Valor_Total | Soma dos custos dos aparelhos aprovados | Registra o valor total da compra, conferido com o documento do fornecedor |

Em todos os casos, o valor é calculado pelo sistema no momento da gravação e não pode ser digitado pelo usuário, o que evita que ele fique diferente dos campos de origem. O ganho é que as consultas mais frequentes (garantia vigente, estornos atrasados, total da venda) não precisam refazer o cálculo, e o valor da época fica registrado mesmo se a regra mudar depois.

**Campos que parecem repetidos, mas não são.** ITEM_PEDIDO.Preco_Unitario, PEDIDO.Percentual_Desconto_Pix, PAGAMENTO.Valor e os campos Qtd_Atual_Estoque e Estoque_Minimo de REQUISICAO_COMPRA guardam o valor **do momento** em que o registro foi criado. O preço do aparelho, a regra de desconto e o estoque mínimo podem mudar depois, e o registro antigo precisa continuar mostrando o valor da época. Como não dependem do valor atual da outra tabela, não violam a 3FN.

**Endereço e CEP.** Em ENDERECO, a cidade pode ser deduzida do CEP. Mesmo assim, Cidade, Bairro e Rua foram mantidos como atributos do endereço porque, no Brasil, o CEP nem sempre identifica a rua (em muitas cidades pequenas, um único CEP vale para a cidade inteira) e porque o endereço precisa ser guardado exatamente como foi informado para a entrega e para a nota fiscal. Criar uma tabela de CEPs exigiria manter uma base nacional atualizada, o que está fora do escopo do sistema.
