# Projeto ERP — CellGO

## 1. Identificação da Equipe

| Nº | Integrante |
|---:|---|
| 01 | Bernardo Farias de Jesus |
| 02 | Bruno Ferreira Gonçalves |
| 03 | Gabriely Moreira Manna |
| 04 | Henrique Santos da Rocha |
| 05 | Henry Gonçalves dos Santos |
| 06 | João Wyctor França dos Santos |
| 07 | Katharine Louise de Oliveira Guedes |
| 08 | Murilo Alves de Sousa |
| 09 | Rafaela Teresa de Oliveira Corrente |
| 10 | Ryan Henrique de Aguiar dos Santos |
| 11 | Victor Rodrigues da Costa |



## 2. Caracterização da Empresa

### 2.1 Identificação

- **Razão Social:** CellGo Comércio de Celulares Ltda.
- **Nome Fantasia:** CellGo
- **CNPJ:** 48.920.852/0001-23
- **Data de Fundação:** 01/09/2026
- **Endereço:** Rua das Comunicações, 245 – Centro, São Paulo/SP – CEP 01000-000
- **Setor de Atuação:** Comércio varejista de produtos de telefonia móvel (novos e seminovos)

### 2.2 Natureza Jurídica

- **Tipo Societário:** LTDA (Sociedade Empresária Limitada)
- **Regime Tributário:** Simples Nacional
- **Porte da Empresa:** Pequena Empresa (EPP)

### 2.3 Perfil do Negócio

- **Ramo de Atividade:** Compra e venda de smartphones novos e seminovos, com comércio complementar de acessórios.
- **Produtos/Serviços Oferecidos:**
  - Smartphones novos, lacrados e com garantia de fábrica;
  - Smartphones seminovos revisados e certificados, com garantia própria;
  - Acessórios, como capinhas, películas, fones e carregadores;
  - Pagamento parcelado;
  - Vendas online.

- **Missão:** Democratizar o acesso à tecnologia móvel, oferecendo smartphones de qualidade — novos ou seminovos — com procedência garantida, preço justo e atendimento transparente.

- **Visão:** Ser referência regional em compra e venda de celulares até 2028, reconhecida pela confiabilidade e pelo compromisso com a sustentabilidade tecnológica.

- **Valores:**
  - Transparência;
  - Procedência garantida;
  - Sustentabilidade e economia circular;
  - Acessibilidade;
  - Atendimento humanizado.

### 2.4 Estrutura Organizacional

- **Quadro Societário:** 2 sócios, com participação de 50% cada.
- **Número de Funcionários:** 8 colaboradores.
- **Principais Áreas:**
  - Diretoria;
  - Vendas e Atendimento;
  - Estoque e Logística;
  - Assistência Técnica;
  - Financeiro/Administrativo.

### 2.5 Histórico

A CellGo foi fundada em 2026 por dois sócios que identificaram uma lacuna no mercado local: a falta de lojas que oferecessem, com a mesma seriedade, celulares novos e seminovos com garantia.

Iniciando as operações em um pequeno ponto comercial, a empresa cresceu investindo em processos próprios de certificação de aparelhos seminovos. Atualmente, conta também com um canal de vendas online, consolidando-se como uma alternativa confiável frente ao mercado informal de celulares usados.



## 3. Justificativa da Escolha



## 4. Problemas Identificados



## 5. Processos de Negócios



## 6. Requisitos Funcionais



## 7. Requisitos Não Funcionais



## 8. Regras de Negócio

### Status Padronizados

| Entidade | Status Possíveis |
|---|---|
| **Aparelho** | Disponível, Vendido, Em avaliação, Em manutenção, Inativo |
| **Venda** | Aberta, Aguardando pagamento, Pago, Parcialmente pago, Finalizada, Cancelada |
| **Entrega da venda** | Aguardando envio, Em transporte, Entregue |



# Módulo 1 — Cadastro

## RN-01 — Cadastro de Cliente

**Módulo:** Cadastro

**Descrição:**  
O sistema deverá permitir o cadastro dos clientes que realizam compras, mantendo os dados necessários para localizar vendas, emitir nota fiscal e processar solicitações de pós-venda. O cadastro poderá ser de pessoa física ou pessoa jurídica.

**Regras:**

- Pessoa física: o cadastro deverá conter, no mínimo, nome completo, CPF, e-mail, telefone e endereço.
- Pessoa jurídica: o cadastro deverá conter, no mínimo, nome ou razão social, CNPJ, e-mail, telefone e endereço.
- O CPF ou CNPJ deverá ser único por cliente.
- O sistema deverá permitir localizar um cliente e suas vendas por CPF/CNPJ, e-mail ou número da venda.
- Os dados cadastrais deverão poder ser atualizados pelo próprio cliente ou por usuário autorizado.

**Resultado esperado:**  
Garantir que todo cliente, pessoa física ou jurídica, tenha um cadastro completo o suficiente para viabilizar venda, nota fiscal, garantia e pós-venda.



## RN-02 — Cadastro de Aparelho/Produto

**Módulo:** Cadastro

**Descrição:**  
O sistema deverá permitir o cadastro dos aparelhos disponíveis para venda, com as informações necessárias para estoque, garantia e nota fiscal.

**Regras:**

- O cadastro deverá conter, no mínimo:
  - Modelo;
  - Marca;
  - IMEI/número de série;
  - Condição (Novo ou Seminovo);
  - Preço de venda;
  - Custo de aquisição;
  - Status inicial.

- O IMEI/número de série deverá ser único no sistema.
- A condição (Novo/Seminovo) é obrigatória e determina o período de garantia aplicável (ver **RN-15**).
- A entrada do aparelho no estoque deverá registrar data de entrada, custo e identificador, conforme previsto no controle de estoque (**RN-03**).
- O cadastro de aparelhos deverá ser realizado apenas por funcionários autorizados, de acordo com seu nível de acesso e permissão no sistema (ver **RN-22**).

**Resultado esperado:**  
Garantir que todo aparelho tenha um cadastro completo, permitindo o correto funcionamento das regras de estoque, venda, garantia e nota fiscal que dependem desses dados, restrito a usuários autorizados.



# Módulo 2 — Estoque

## RN-03 — Controle de Estoque

**Módulo:** Estoque

**Descrição:**  
O sistema deverá controlar a disponibilidade individual de cada aparelho comercializado pela empresa, sem uso de reserva prévia à confirmação da venda.

**Regras:**

- Um aparelho com status **Disponível** poderá ser vendido.
- O sistema não realizará reserva de aparelhos antes da confirmação do pagamento da venda.
- Um aparelho com status **Vendido** não retorna automaticamente ao estoque.
- Toda alteração de status do aparelho deverá ser registrada no histórico do aparelho, com data, hora e usuário responsável, quando aplicável.
- O sistema deverá impedir a venda de um aparelho inexistente, já vendido ou indisponível.
- Status possíveis:
  - Disponível;
  - Vendido;
  - Em avaliação;
  - Em manutenção;
  - Inativo.

**Resultado esperado:**  
Evitar vendas duplicadas e garantir rastreabilidade dos aparelhos comercializados, sem depender de um mecanismo de reserva.



## RN-04 — Validação de Disponibilidade no Fechamento da Venda

**Módulo:** Estoque

**Descrição:**  
O sistema deverá validar novamente a disponibilidade do aparelho no exato momento da finalização da venda, para evitar que dois clientes concluam a compra do mesmo aparelho.

**Regras:**

- A validação de disponibilidade deverá ocorrer de forma atômica junto com a confirmação do pagamento, de modo que não seja possível duas vendas concluírem simultaneamente para o mesmo aparelho.
- Caso o aparelho já tenha sido vendido por outra transação, a nova tentativa de compra deverá ser bloqueada e o cliente informado.

**Resultado esperado:**  
Evitar conflitos de estoque decorrentes da ausência de reserva prévia.



# Módulo 3 — Venda

## RN-05 — Venda de Aparelho

**Módulo:** Venda

**Descrição:**  
O sistema deverá permitir a realização da venda de aparelhos cadastrados no estoque, vinculando o(s) produto(s) a um cliente e registrando todas as informações financeiras da operação.

**Regras:**

- Só poderá ser realizada uma venda para um aparelho com status **Disponível**.
- A venda deverá possuir obrigatoriamente:
  - Cliente;
  - Aparelho(s);
  - Data da venda;
  - Valor do produto;
  - Desconto, quando aplicável;
  - Valor final;
  - Forma de pagamento;
  - Status da venda.

- Após a confirmação do pagamento, o aparelho deverá ter seu status alterado para **Vendido**.
- O IMEI/número de série deverá ficar vinculado ao registro da venda.
- A venda deverá ser registrada no histórico do cliente (ver **RN-20**).
- O sistema deverá gerar um comprovante de venda.
- Status da venda:
  - Aberta;
  - Aguardando pagamento;
  - Pago;
  - Parcialmente pago;
  - Finalizada;
  - Cancelada.

**Resultado esperado:**  
Garantir que toda venda seja registrada corretamente, vinculando cliente, aparelho, estoque e financeiro.



## RN-06 — Forma de Venda: À Vista ou Parcelada

**Módulo:** Venda

**Descrição:**  
O sistema deverá permitir a realização de vendas à vista ou parceladas, conforme a forma de pagamento escolhida.

**Regras:**

- O cliente poderá optar por compra à vista ou parcelada.
- O parcelamento é permitido apenas para pagamento via cartão de crédito, em até 12 vezes.
- O número de parcelas deverá ser informado antes da confirmação da venda.
- O sistema deverá calcular automaticamente o valor de cada parcela.

**Resultado esperado:**  
Permitir vendas à vista e parceladas, mantendo o controle correto dos valores e parcelas.


## RN-07 — Cálculo do Valor da Venda

**Módulo:** Venda

**Descrição:**  
O sistema deverá calcular automaticamente o valor final da venda considerando o preço do aparelho e os descontos aplicáveis.

**Regras:**

- **Valor Final = Valor do Produto − Desconto + Taxas (quando houver).**
- No modelo de e-commerce, não há desconto discricionário aplicado manualmente por um vendedor. O único desconto previsto é o desconto automático por pagamento via Pix, aplicável apenas aos produtos elegíveis (ver **RN-08**).
- O valor final deverá ser apresentado ao cliente antes da confirmação da venda.
- Após a confirmação, o valor da venda deverá ser registrado no módulo financeiro.

**Resultado esperado:**  
Garantir que o valor cobrado seja calculado corretamente e de forma consistente com o modelo de e-commerce.



## RN-08 — Desconto para Pagamento via Pix

**Módulo:** Venda

**Descrição:**  
O sistema deverá aplicar desconto exclusivamente para pagamentos realizados via Pix, conforme faixa de valor do produto, e apenas para os produtos elegíveis.

**Regras:**

| Valor do Produto | Desconto via Pix |
|---|---:|
| Até R$ 1.000,00 | 5% |
| De R$ 1.001,00 a R$ 2.500,00 | 7% |
| Acima de R$ 2.500,00 | 10% |

- O desconto é aplicado somente quando a forma de pagamento é **Pix**.
- Nem todos os produtos participarão do desconto Pix. A elegibilidade de cada produto deverá ser configurável no cadastro do aparelho (**RN-02**).
- Não será aplicado desconto para pagamentos via cartão de crédito ou boleto.
- O desconto deverá ser apresentado ao cliente antes da confirmação da compra, incluindo os casos em que o produto não é elegível ao desconto.
- O sistema deverá registrar o percentual e o valor do desconto na venda.

**Resultado esperado:**  
Controlar os descontos concedidos para pagamentos via Pix, evitando descontos indevidos em outras formas de pagamento ou em produtos não elegíveis.



## RN-09 — Formas de Pagamento

**Módulo:** Venda

**Descrição:**  
O sistema deverá aceitar pagamentos via Pix, cartão de crédito e boleto bancário. Não haverá aceitação de cartão de débito como forma de pagamento.

**Regras:**

- A venda deverá informar obrigatoriamente a forma de pagamento.
- Para cartão de crédito, deverá ser informado o número de parcelas, com máximo de 12.
- O sistema deverá registrar o status do pagamento.
- Uma venda somente será considerada **Finalizada** após a confirmação do pagamento, conforme a forma utilizada.
- Cartão de débito não é uma forma de pagamento aceita nesta consolidação, por decisão do negócio.

**Resultado esperado:**  
Garantir o controle dos pagamentos e a correta vinculação entre venda e financeiro, com as formas de pagamento efetivamente aceitas pelo e-commerce.



## RN-10 — Parcelamento

**Módulo:** Venda

**Descrição:**  
O sistema deverá permitir o parcelamento de vendas pagas por cartão de crédito em até 12 parcelas.

**Regras:**

- Número mínimo de parcelas: **1**.
- Número máximo de parcelas: **12**.
- O sistema deverá calcular automaticamente o valor das parcelas.
- O valor total da venda deverá permanecer registrado independentemente da quantidade de parcelas.
- Caso existam juros ou taxas, estes deverão ser apresentados antes da confirmação da venda.

**Resultado esperado:**  
Permitir o parcelamento das vendas de forma transparente e controlada.



# Módulo 4 — Pós-venda: Cancelamento

## RN-11 — Cancelamento da Venda

**Módulo:** Pós-venda

**Descrição:**  
O sistema deverá permitir o cancelamento de uma venda no prazo de até 7 dias corridos a partir da data da venda, desde que o aparelho ainda não tenha saído para entrega.

**Regras:**

- O sistema deverá verificar a data da venda antes de permitir o cancelamento.
- O cancelamento por esta regra somente será permitido enquanto o status de entrega da venda for **Aguardando envio**.
- A partir do momento em que o status de entrega passar para **Em transporte** ou **Entregue**, a solicitação do cliente deixa de ser tratada como cancelamento e passa a seguir o fluxo do **Módulo 5 — Devolução (RN-13/RN-14)**, conforme o caso.
- O motivo do cancelamento deverá ser registrado.
- Caso o pagamento já tenha sido realizado, deverá ser aberto o processo de estorno (ver **RN-17**).
- Como o aparelho ainda não foi enviado, ele deverá ser diretamente direcionado a nova avaliação de estoque, com status **Em avaliação**, antes de retornar como **Disponível**.
- A venda cancelada não deverá ser excluída do sistema. O cancelamento fica registrado no histórico do cliente e da venda para fins de auditoria (ver **RN-21**).

**Resultado esperado:**  
Permitir o cancelamento dentro do prazo estabelecido e apenas antes da saída do aparelho para entrega, mantendo o histórico financeiro e de estoque e direcionando corretamente os casos pós-envio para o fluxo de devolução.


# Módulo 5 — Pós-venda: Troca e Devolução

## RN-12 — Troca por Defeito Coberto pela Garantia

**Módulo:** Pós-venda

**Descrição:**  
O sistema deverá permitir a troca de um aparelho vendido por outro equivalente, quando for identificado defeito coberto pela garantia da loja, dentro do prazo de 30 dias da compra.

**Regras:**

- A solicitação deverá estar vinculada à venda original e ao IMEI/número de série do aparelho.
- O aparelho deverá passar por avaliação técnica, com status **Em avaliação**, antes da decisão.
- A troca somente será autorizada quando o defeito estiver coberto pela garantia da loja (**RN-15**).
- Danos causados por mau uso não são elegíveis para esta troca (ver **RN-16**).
- O novo aparelho deverá estar **Disponível** no estoque.
- Caso não exista aparelho equivalente disponível, aplica-se a política de devolução por defeito (**RN-14**) como alternativa.
- O aparelho substituído deverá ser direcionado para **Em manutenção** ou **Inativo**, conforme avaliação.
- A troca deverá ser registrada no histórico do cliente e da venda.

**Resultado esperado:**  
Permitir trocas por defeito dentro do período de garantia da loja, evitando trocas decorrentes de mau uso.



## RN-13 — Devolução por Arrependimento

**Módulo:** Pós-venda

**Descrição:**  
O sistema deverá permitir a devolução de um aparelho no prazo de até 7 dias corridos a partir do recebimento, independentemente de defeito, em conformidade com o direito de arrependimento previsto no Art. 49 do Código de Defesa do Consumidor para compras realizadas fora do estabelecimento comercial (e-commerce).

**Regras:**

- A devolução deverá estar vinculada à venda original.
- O sistema deverá registrar a data e o motivo da devolução, quando informado pelo cliente.
- O aparelho deverá ser devolvido em condições de revenda e passar por avaliação, com status **Em avaliação**.
- O valor pago deverá ser integralmente restituído ao cliente (ver **RN-17**), sem necessidade de comprovação de defeito.
- O aparelho somente retorna ao estoque como **Disponível** após avaliação e aprovação. Caso apresente dano, será direcionado para **Em manutenção** ou **Inativo**.

**Resultado esperado:**  
Garantir o cumprimento do direito de arrependimento do consumidor em compras de e-commerce, controlando devoluções sem perder o histórico da venda.



## RN-14 — Devolução por Defeito

**Módulo:** Pós-venda

**Descrição:**  
O sistema deverá permitir a devolução, com reembolso, do aparelho quando for identificado defeito coberto pela garantia, sem solução adequada por troca, ou quando o aparelho já tiver sido entregue no momento em que o cliente reporta o problema (ver **RN-11**).

**Regras:**

- O cliente deverá apresentar o aparelho para avaliação. A venda poderá ser localizada por:
  - CPF/CNPJ;
  - Número da venda;
  - IMEI/número de série.

- O aparelho deverá ser submetido a avaliação técnica, com status **Em avaliação**.
- Se o defeito for coberto pela garantia e não houver aparelho equivalente para troca (**RN-12**), a empresa deverá seguir o procedimento de devolução com restituição (**RN-17**).
- Se o problema for causado por mau uso, a devolução por esta regra não será autorizada (ver **RN-16**).
- O sistema deverá registrar o diagnóstico e a decisão tomada.
- O processo deverá ficar registrado no histórico do cliente e do aparelho.

**Resultado esperado:**  
Garantir que devoluções por defeito sejam realizadas somente quando a troca não for uma alternativa viável, mantendo a cobertura de garantia como critério central — inclusive para os casos em que o aparelho já foi enviado e o cliente precisa acionar o pós-venda em vez do cancelamento.



# Módulo 6 — Pós-venda: Garantia e Avaliação de Danos

## RN-15 — Garantia do Aparelho

**Módulo:** Pós-venda

**Descrição:**  
Todo aparelho vendido possui garantia da loja e, quando aplicável, garantia adicional do fabricante, conforme sua condição de cadastro (Novo ou Seminovo).

**Regras:**

| Condição | Garantia |
|---|---|
| **Novo** | 30 dias de garantia da loja + 1 ano de garantia do fabricante, conforme condições estabelecidas pelo fabricante |
| **Seminovo** | 30 dias de garantia da loja, sem garantia adicional do fabricante, salvo quando expressamente informado pelo fabricante |

- A garantia da loja tem início na data da venda.
- O sistema deverá registrar a data de início e término da garantia e permitir consultar se está vigente ou encerrada.
- O IMEI/número de série deverá ser utilizado para identificar o aparelho.
- Danos decorrentes de mau uso não são cobertos pela garantia da loja (ver **RN-16**).
- O sistema deverá registrar todas as solicitações de garantia.

**Resultado esperado:**  
Controlar os diferentes períodos de garantia e diferenciar claramente a cobertura da loja da cobertura do fabricante.



## RN-16 — Avaliação de Dano e Elegibilidade para Cobertura

**Módulo:** Pós-venda

**Descrição:**  
Quando o aparelho apresentar dano, o sistema deverá registrar a ocorrência e determinar se o caso é coberto pela garantia ou se é caracterizado como mau uso, sem cobertura da empresa.

**Regras:**

- O aparelho deverá ser avaliado tecnicamente, com status **Em avaliação**.
- O sistema deverá registrar o tipo de dano e classificá-lo como:
  - Defeito de fabricação;
  - Dano por mau uso;
  - Dano acidental;
  - Outros.

- Exemplos de mau uso, não cobertos pela garantia:
  - Tela quebrada por impacto;
  - Aparelho amassado;
  - Danos por líquido não cobertos;
  - Alterações não autorizadas;
  - Outros danos por uso inadequado.

- Caso esteja dentro da garantia e seja identificado defeito coberto, o atendimento seguirá as regras de garantia (**RN-15**) e, conforme o caso, troca (**RN-12**) ou devolução (**RN-14**).
- Caso o dano seja caracterizado como mau uso, a solicitação de troca ou devolução não será autorizada e o aparelho não será reparado pela empresa. O cliente deverá ser informado do diagnóstico e o atendimento será encerrado sem custo para a empresa.

**Resultado esperado:**  
Diferenciar de forma clara problemas cobertos pela garantia de danos causados por mau uso, sem que a empresa assuma qualquer serviço de reparo nesses casos.



# Módulo 7 — Financeiro e Fiscal

## RN-17 — Estorno e Restituição

**Módulo:** Financeiro

**Descrição:**  
O sistema deverá processar estornos e restituições decorrentes de cancelamento, devolução ou troca com diferença de valor a favor do cliente.

**Regras:**

- O estorno deverá seguir a forma de pagamento original utilizada na venda.
- Pagamentos via Pix deverão ser estornados diretamente para a chave/conta de origem.
- Pagamentos via cartão de crédito deverão ser estornados junto à operadora do cartão.
- Pagamentos via boleto deverão gerar restituição por transferência bancária, mediante dados informados pelo cliente.
- O processo completo de estorno, da abertura da solicitação até a efetiva liberação do valor ao cliente, deverá ocorrer dentro do prazo de **7 a 15 dias corridos**, podendo variar conforme a forma de pagamento:
  - Pix tende ao início da faixa;
  - Cartão de crédito e boleto podem levar até o limite superior, por dependerem de prazos de operadoras e instituições financeiras.

- O sistema deverá registrar:
  - Valor;
  - Data de abertura;
  - Prazo-limite (data de abertura + 15 dias);
  - Status do estorno.

- Status do estorno:
  - Pendente;
  - Processado;
  - Recusado.

- Caso o prazo de 15 dias seja ultrapassado sem conclusão, o sistema deverá sinalizar o estorno como **Atrasado** e notificar o perfil Financeiro/Administrativo (**RN-22**) para tratamento manual.
- Em vendas parceladas canceladas após pagamento de parte das parcelas, o estorno deverá considerar apenas os valores já pagos.

**Resultado esperado:**  
Garantir que todo valor devido ao cliente em cancelamentos, devoluções ou trocas seja restituído de forma rastreável e dentro de um prazo definido.



## RN-18 — Emissão de Nota Fiscal

**Módulo:** Fiscal

**Descrição:**  
O sistema deverá possuir integração ou funcionalidade para emissão de nota fiscal eletrônica referente às vendas realizadas, incluindo tratamento fiscal específico para cancelamento, troca e devolução.

**Regras:**

- A nota fiscal deverá estar vinculada à venda, utilizando os dados cadastrados do cliente (**RN-01**) e do aparelho (**RN-02**).
- A emissão deverá ocorrer conforme as regras fiscais aplicáveis.
- O sistema deverá registrar o número e a chave de acesso da nota fiscal, quando disponíveis, e permitir consultar seu status.
- Em caso de cancelamento (**RN-11**) dentro do prazo legal da SEFAZ para cancelamento direto, via de regra até 24 horas da emissão, a nota fiscal deverá ser cancelada diretamente. Fora desse prazo, o cancelamento deverá seguir o mesmo procedimento fiscal da devolução (nota de entrada).
- Em caso de devolução (**RN-13 — arrependimento** ou **RN-14 — defeito**), o sistema deverá emitir uma Nota Fiscal de Entrada (devolução), referenciando a NF-e de venda original, para desfazer fiscalmente a operação. A liberação do estorno (**RN-17**) só deverá ocorrer após a emissão dessa nota de devolução.
- Em caso de troca por defeito (**RN-12**), o sistema deverá emitir duas notas:
  1. Uma Nota Fiscal de Entrada (devolução), referenciando a NF-e original, para o aparelho defeituoso devolvido;
  2. Uma nova Nota Fiscal de Saída para o aparelho de reposição.

- Quando não houver diferença de valor entre os aparelhos, a nova nota será emitida sem cobrança adicional ao cliente.
- O usuário deverá ser informado caso ocorra erro na emissão, e a venda deverá ficar sinalizada como **Nota fiscal pendente** até a regularização. Nesse caso, o estorno ou a troca correspondente também ficarão retidos até a regularização fiscal.

**Resultado esperado:**  
Garantir que todas as vendas e movimentações de pós-venda — incluindo cancelamento, troca e devolução — sejam devidamente documentadas fiscalmente antes da liberação do respectivo estorno ou da saída do aparelho de reposição.



## RN-19 — Comissão de Vendedores — Não Aplicável

**Módulo:** Financeiro

**Descrição:**  
O sistema não possuirá controle de comissão de vendedores, pois o modelo de negócio é de e-commerce, sem vendedor associado à venda.

**Regras:**

- Não haverá cálculo nem lançamento financeiro de comissão.
- O sistema poderá registrar o usuário responsável por atendimentos de pós-venda apenas para fins de auditoria (ver **RN-21**), sem gerar comissão.

**Resultado esperado:**  
Manter o módulo financeiro simplificado, coerente com a ausência de vendedores no modelo de e-commerce.



# Módulo 8 — Histórico, Auditoria e Acesso

## RN-20 — Histórico do Cliente

**Módulo:** Histórico

**Descrição:**  
O sistema deverá manter o histórico comercial completo de cada cliente.

**Regras:**

- Compras realizadas e aparelhos adquiridos, com IMEI/número de série e valores.
- Pagamentos, cancelamentos, trocas por defeito e devoluções.
- Solicitações de garantia e respectivos diagnósticos.
- Créditos ou estornos concedidos.

**Resultado esperado:**  
Permitir que a empresa tenha uma visão completa do relacionamento comercial com o cliente.



## RN-21 — Auditoria das Operações

**Módulo:** Histórico

**Descrição:**  
Operações importantes realizadas no sistema deverão possuir registro para auditoria.

**Regras:**

- Registrar:
  - Usuário responsável;
  - Data e hora;
  - Operação realizada;
  - Venda afetada;
  - Aparelho afetado;
  - Valores anteriores e novos, quando aplicável.

- Auditar principalmente:
  - Alterações de preço/desconto;
  - Cancelamentos;
  - Trocas;
  - Devoluções;
  - Estornos;
  - Alterações de pagamento;
  - Alterações de estoque.

**Resultado esperado:**  
Garantir rastreabilidade de todas as operações relevantes realizadas no ERP.



## RN-22 — Perfis de Acesso e Autorizações

**Módulo:** Histórico

**Descrição:**  
O sistema deverá definir perfis de acesso que determinam quais usuários podem executar operações sensíveis, como cancelamentos, aprovações de troca/devolução, cadastro de aparelhos e ajustes financeiros.

Os perfis seguem a estrutura organizacional do negócio:

- Diretoria: 2 sócios;
- Vendas e Atendimento: 2 colaboradores;
- Estoque e Logística: 2 colaboradores;
- Assistência Técnica: 2 colaboradores;
- Financeiro/Administrativo: 2 colaboradores.

**Regras:**

- São definidos 2 níveis hierárquicos de acesso:
  - **Nível 1 — Operacional:** um perfil por área, destinado aos 8 colaboradores;
  - **Nível 2 — Estratégico:** perfil único da Diretoria, destinado aos 2 sócios.

- Cada colaborador recebe o perfil operacional correspondente à sua área.
- Os sócios recebem o perfil de Diretoria, com acesso a todas as áreas.
- O perfil de Diretoria é o único autorizado a criar, editar ou remover perfis de acesso e a autorizar exceções fora do fluxo automático em qualquer área.
- Toda ação que exigir autorização deverá registrar o usuário autorizador, seu perfil e a área correspondente (ver **RN-21**).
- O sistema deverá impedir que usuários sem o perfil adequado executem operações fora de sua área ou nível de autorização.

**Resultado esperado:**  
Fechar a lacuna de definição de quem é o "usuário autorizado" ou "usuário responsável" citado em várias regras do documento original, com uma estrutura de perfis compatível com o tamanho da empresa, composta por 2 sócios e 8 colaboradores.

### Matriz de Perfis de Acesso

| Perfil / Área | Colaboradores | Pode Realizar | Pode Autorizar / Aprovar |
|---|---:|---|---|
| **Diretoria — Nível 2 Estratégico** | 2 sócios | Todas as operações do sistema, em todas as áreas. | Qualquer operação sensível; exceções fora do fluxo automático em qualquer área, como cancelamento fora do prazo e troca sem aparelho equivalente (RN-12); ajustes financeiros extraordinários; criação/edição de perfis de acesso; elegibilidade de produtos ao desconto Pix (RN-08). |
| **Vendas e Atendimento — Nível 1 Operacional** | 2 | Registrar vendas (RN-05 a RN-10); abrir cancelamento dentro do prazo padrão (RN-11); registrar solicitações de troca/devolução (RN-12/RN-13/RN-14) e encaminhá-las; consultar histórico do cliente (RN-20). | Cancelamento dentro da janela padrão, antes do envio e dentro de 7 dias — fluxo automático. Não autoriza exceções. |
| **Estoque e Logística — Nível 1 Operacional** | 2 | Cadastrar aparelhos (RN-02); controlar e validar estoque (RN-03/RN-04); atualizar status de entrega da venda (Aguardando envio/Em transporte/Entregue). | Retorno do aparelho a Disponível após avaliação já concluída pela Assistência Técnica. Não autoriza troca, devolução ou estorno. |
| **Assistência Técnica — Nível 1 Operacional** | 2 | Avaliação técnica de dano (RN-16); análise de cobertura de garantia (RN-15); emissão de parecer técnico para troca (RN-12) e devolução por defeito (RN-14). | Troca por defeito coberto pela garantia (RN-12) e devolução por defeito (RN-14), dentro dos critérios definidos nas regras. Escalona à Diretoria quando não há aparelho equivalente em estoque. |
| **Financeiro/Administrativo — Nível 1 Operacional** | 2 | Processar estornos e restituições (RN-17); emitir nota fiscal (RN-18); lançar valores no módulo financeiro decorrentes de vendas, cancelamentos, trocas e devoluções; consultar auditoria financeira (RN-21). | Liberação de estornos e emissões de nota fiscal dentro dos valores e prazos definidos nas regras. Não autoriza mudanças de política comercial nem exceções fora do fluxo. |


## 9. Restrições e Políticas Organizacionais


## 10. Fluxogramas


## 11. Entidades


## 12. Atributos


## 13. Relacionamentos


## 14. Cardinalidades


## 15. Dicionário de Dados Conceitual


## 16. DER


## 17. Justificativas Técnicas


## 18. Conclusão