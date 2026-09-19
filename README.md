# Projeto ERP - CellGO

## 1. Identificação da Equipe

| Nº | Integrante |
|---:|---|
| 01 | Bernardo Farias de Jesus |
| 02 | Bruno Ferreira Gonçalves |
| 03 | Gabriely Moreira Manna |
| 04 | Henry Gonçalves dos Santos |
| 05 | João Wyctor França dos Santos |
| 06 | Katharine Louise de Oliveira Guedes |
| 07 | Murilo Alves de Sousa |
| 08 | Rafaela Teresa de Oliveira Corrente |
| 09 | Ryan Henrique de Aguiar dos Santos |
| 10 | Victor Rodrigues da Costa |

## 2. Caracterização da Empresa

**Qual é o nome da empresa?**  
CellGo Comércio de Celulares Ltda.

**Qual é o segmento?**  
Comércio varejista de celulares , atuando com aparelhos novos e seminovos.

**O que ela vende ou oferece?**  
Smartphones novos, lacrados e com garantia de fábrica; smartphones seminovos revisados e certificados, com garantia própria da loja; acessórios como capinhas, películas, fones e carregadores; pagamento parcelado em cartão de crédito; e vendas por canal online, além do ponto físico.

**Quem são seus principais clientes?**  
Consumidores finais (pessoa física) que buscam smartphones com procedência garantida e preço mais acessível do que o de aparelhos novos - tanto quem quer um aparelho novo quanto quem prefere um seminovo confiável em vez de comprar no mercado informal. A empresa também atende pessoa jurídica, já que o cadastro de clientes contempla CNPJ além de CPF.

**Quais são seus principais setores?**  
A empresa é organizada em cinco áreas: Diretoria (2 sócios, decisão estratégica e autorização de exceções); Vendas e Atendimento (registro de vendas e contato com o cliente); Estoque e Logística (cadastro de aparelhos, controle de disponibilidade e envio); Assistência Técnica (avaliação de aparelhos, diagnóstico de defeitos e garantia); e Financeiro/Administrativo (estornos, nota fiscal e controle de pagamentos).

**Como funciona atualmente?**  
Hoje a operação depende de controles manuais e dispersos: o cadastro de clientes e aparelhos, o controle de estoque e o acompanhamento financeiro não estão centralizados em um único sistema. Isso significa que informações como status do aparelho (disponível, vendido, em avaliação), histórico de vendas de cada cliente, prazos de garantia e pedidos de estorno acabam sendo controlados separadamente - dificultando saber rapidamente se um aparelho já foi vendido, se uma garantia ainda está no prazo, ou se um estorno está atrasado. É justamente essa falta de integração entre vendas, estoque, pós-venda e financeiro que motiva o desenvolvimento do ERP.

**Quais informações são importantes para o negócio?**  
Dados completos do cliente (CPF/CNPJ, contato, histórico de compras); identificação única de cada aparelho por IMEI/número de série, com sua condição (novo/seminovo) e status atual; dados de cada venda (valor, forma de pagamento, parcelas, status); prazos e cobertura de garantia por aparelho; registros de trocas, devoluções e estornos com seus prazos; e trilha de auditoria de quem realizou cada operação sensível no sistema.

## 3. Justificativa da Escolha

Escolhemos a CellGO porque alguns processos da empresa estão manuais , desunificados e não estão sendo guardados em um único sistema, isso está impactando a atualização de algumas informações que precisam ser dinâmicas assim que um evento acontece, como por exemplo: venda de aparelho e status do estoque, acompanhamento financeiro, prazos de garantia, pedidos de estorno e o histórico de compras de cada cliente.

Está faltando a integração entre vendas, estoque, assistência técnica/pós-venda e financeiro, isso motiva a criação de um ERP para essa empresa, além de unificar tudo em um só sistema, atualizando os dados de forma dinâmica após a venda do aparelho - evitando que aconteça de um cliente comprar um aparelho que não há mais em estoque, que uma garantia vencida seja aceita por engano, ou que um pedido de estorno fique parado sem controle.

Esse projeto é adequado para um projeto de modelagem de dados, pois além de estarmos pegando um problema real e tentando propor uma solução, estamos reforçando cada vez mais os conceitos que a modelagem de dados possui, como entidades, atributos, relacionamentos, entre outros conceitos.

## 4. Problemas Identificados



## 5. Processos de Negócios



## 6. Requisitos Funcionais

**RF-01 - Cadastrar clientes**  
O sistema deve permitir o cadastro de clientes pessoa física (nome, CPF, e-mail, telefone, endereço) ou pessoa jurídica (razão social, CNPJ, e-mail, telefone, endereço), com CPF/CNPJ único, e permitir localizar o cliente por CPF/CNPJ, e-mail ou número da venda (RN-01).

**RF-02 - Cadastrar aparelhos**  
O sistema deve permitir o cadastro de aparelhos com modelo, marca, IMEI único, condição (novo/seminovo), preço de venda, custo de aquisição e status inicial, restrito a usuários autorizados (RN-02).

**RF-03 - Controlar status do aparelho**  
O sistema deve controlar o status individual de cada aparelho (Disponível, Vendido, Em avaliação, Em manutenção, Inativo) e impedir a venda de aparelhos inexistentes, já vendidos ou indisponíveis, registrando todo o histórico de mudança de status (RN-03).

**RF-04 - Validar disponibilidade no fechamento da venda**  
O sistema deve revalidar, de forma atômica junto à confirmação do pagamento, se o aparelho ainda está disponível, bloqueando a compra caso outra venda já o tenha adquirido (RN-04).

**RF-05 - Registrar venda**  
O sistema deve registrar a venda vinculando cliente, aparelho(s), data, valor do produto, desconto, valor final, forma de pagamento e status; ao confirmar o pagamento, deve alterar o status do aparelho para Vendido e gerar um comprovante (RN-05).

**RF-06 - Processar venda à vista ou parcelada**  
O sistema deve permitir venda à vista ou parcelada em cartão de crédito (até 12x), calculando automaticamente o valor de cada parcela (RN-06, RN-10).

**RF-07 - Calcular valor final da venda**  
O sistema deve calcular o valor final como valor do produto menos desconto mais taxas, sem permitir desconto manual por vendedor (RN-07).

**RF-08 - Aplicar desconto por Pix**  
O sistema deve aplicar automaticamente o desconto (5%, 7% ou 10%, conforme faixa de valor) quando o pagamento for via Pix e o produto for elegível, registrando o percentual e valor do desconto na venda (RN-08).

**RF-09 - Processar formas de pagamento**  
O sistema deve aceitar Pix, cartão de crédito e boleto (não aceitando cartão de débito), registrando o status do pagamento e só finalizando a venda após a confirmação (RN-09).

**RF-10 - Processar cancelamento de venda**  
O sistema deve permitir o cancelamento da venda em até 7 dias corridos, apenas enquanto o status de entrega for "Aguardando envio", registrando o motivo, abrindo o estorno quando já houver pagamento, e reenviando o aparelho para avaliação de estoque (RN-11).

**RF-11 - Processar troca por defeito coberto pela garantia**  
O sistema deve permitir a troca do aparelho por um equivalente em até 30 dias, mediante avaliação técnica e confirmação de que o defeito está coberto pela garantia (RN-12).

**RF-12 - Processar devolução por arrependimento**  
O sistema deve permitir a devolução em até 7 dias corridos do recebimento, sem exigência de defeito, com restituição integral do valor pago após avaliação do aparelho (RN-13).

**RF-13 - Processar devolução por defeito**  
O sistema deve permitir a devolução com reembolso quando a troca não for possível ou o aparelho já tiver sido entregue, mediante avaliação técnica que confirme a cobertura da garantia (RN-14).

**RF-14 - Controlar garantia do aparelho**  
O sistema deve calcular e controlar o prazo de garantia de cada aparelho (30 dias loja + 1 ano fabricante para novos; 30 dias loja para seminovos), permitindo consultar se está vigente (RN-15).

**RF-15 - Classificar avaliação de dano**  
O sistema deve registrar a avaliação técnica de cada aparelho danificado, classificando o dano como defeito de fabricação, mau uso, acidental ou outros, e bloquear troca/devolução em casos de mau uso (RN-16).

**RF-16 - Processar estorno e restituição**  
O sistema deve processar o estorno conforme a forma de pagamento original (Pix, cartão ou boleto), registrando valor, data de abertura, prazo-limite e status, e sinalizar como "Atrasado" quando ultrapassar 15 dias (RN-17).

**RF-17 - Emitir nota fiscal**  
O sistema deve emitir nota fiscal vinculada à venda, com tratamento fiscal específico para cancelamento (cancelamento direto ou nota de entrada, conforme prazo), devolução (nota de entrada) e troca (nota de entrada + nota de saída) (RN-18).

**RF-18 - Manter histórico do cliente**  
O sistema deve manter o histórico completo de cada cliente: compras, pagamentos, cancelamentos, trocas, devoluções, garantias e estornos concedidos (RN-20).

**RF-19 - Registrar auditoria das operações**  
O sistema deve registrar, para cada operação sensível, o usuário responsável, data/hora, operação realizada, venda e aparelho afetados, e valores antes/depois, quando aplicável (RN-21).

**RF-20 - Controlar perfis de acesso**  
O sistema deve restringir operações sensíveis conforme o perfil do usuário (Operacional por área ou Estratégico/Diretoria), impedindo que usuários sem permissão adequada executem ações fora de sua área ou nível de autorização (RN-22).

## 7. Requisitos Não Funcionais

**RNF-01 - Disponibilidade**  
O sistema deve estar disponível para o usuário na maior parte do tempo, minimizando indisponibilidades que impactem vendas e atendimento.

**RNF-02 - Segurança**  
O sistema deve ser seguro para evitar vazamento e roubo de dados, cumprindo a Lei Geral de Proteção de Dados (LGPD), especialmente no armazenamento de dados de clientes (CPF/CNPJ) e no controle de acesso por perfil (RN-22).

**RNF-03 - Usabilidade (intuitivo)**  
O sistema deve ser intuitivo, para que qualquer usuário do ERP consiga entender e operar cada funcionalidade sem dificuldade, independentemente do seu setor.

**RNF-04 - Desempenho**  
O sistema deve ter bom desempenho, respondendo rapidamente inclusive na validação de disponibilidade no fechamento da venda (RN-04), para não travar o checkout e evitar insatisfação do cliente.

**RNF-05 - Escalabilidade (flexível)**  
O sistema deve ser flexível e escalável, suportando um volume crescente de dados (clientes, aparelhos, vendas) sem perda de desempenho.

**RNF-06 - Confiabilidade**  
O sistema deve garantir consistência nas operações críticas, impedindo inconsistências como a venda simultânea do mesmo aparelho para dois clientes (RN-04).

**RNF-07 - Auditabilidade**  
Os registros de auditoria (RN-21) devem ser imutáveis após gravados, garantindo rastreabilidade confiável de todas as operações sensíveis do sistema.

## 8. Regras de Negócio

# Regras de Negócio - ERP de Venda de Aparelhos (E-commerce)

## Módulo 1 - Cadastro

### RN-01 - Cadastro de Cliente

**Módulo:** Cadastro

**Descrição:**  
O sistema deve permitir o cadastro dos clientes, mantendo os dados necessários para localizar vendas, emitir nota fiscal e processar solicitações de pós-venda. O cliente pode ser pessoa física ou jurídica.

**Regras:**
- Pessoa física: nome completo, CPF, e-mail, telefone e endereço (mínimo).
- Pessoa jurídica: nome/razão social, CNPJ, e-mail, telefone e endereço (mínimo).
- CPF ou CNPJ único por cliente.
- Localização de cliente e vendas por CPF/CNPJ, e-mail ou número da venda.
- Dados atualizáveis pelo próprio cliente ou por usuário autorizado.

- Pessoa física: nome completo, CPF, e-mail, telefone e endereço (mínimo).
- Pessoa jurídica: razão social, CNPJ, e-mail, telefone e endereço (mínimo).
- CPF ou CNPJ único por cliente.
- Localização do cliente e de suas vendas por CPF/CNPJ, e-mail ou número da venda.
- Dados atualizáveis pelo próprio cliente ou por usuário autorizado.

**Resultado esperado:**  
Garantir que todo cliente, pessoa física ou jurídica, tenha um cadastro completo o suficiente para viabilizar venda, nota fiscal, garantia e pós-venda.

## RN-02 — Cadastro de Aparelho/Produto

**Módulo:** Cadastro

**Descrição:**  
O sistema deve permitir o cadastro dos aparelhos disponíveis para venda. com as informações necessárias para estoque, garantia e nota fiscal.

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
- A condição obrigatória (Novo/Seminovo) determina o período de garantia (**RN-15**).
- A entrada no estoque registra data, c8usto e identificador do aparelho (**RN-03**).
- O cadastro restrito a funcionários autorizados, conforme nível de acesso(**RN-22**).

**Resultado esperado:**  
Garantir que todo aparelho tenha um cadastro completo, permitindo o correto funcionamento das regras de estoque, venda, garantia e nota fiscal que dependem desses dados, restrito a usuários autorizados.

## Módulo 2 - Estoque

### RN-03 - Controle de Estoque

**Módulo:** Estoque

**Descrição:**  
Controle da disponibilidade individual de cada aparelho. Não há reserva de aparelhos antes da confirmação do pagamento — a disponibilidade é validada no momento do fechamento da venda (RN-04). 

**Regras:**

- Um aparelho com status **Disponível** poderá ser vendido.
- Um aparelho com status **Vendido** não retorna automaticamente ao estoque.
- Toda alteração de status é registrada no histórico (data, hora e usuário responsável).
- É impedida a venda de aparelho inexistente, já vendido ou indisponível.
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
Validação da disponibilidade do aparelho, 2 dias antes da finalização da venda.

**Regras:**

- Cada aparelho é único. Por isso, o sistema precisa conferir se ele ainda está no estoque, antes do cliente confirma/fazer o pagamento.
- Se o aparelho já tiver sido comprado por outra pessoa, a venda não é concluída. O cliente recebe um aviso explicando que aquele aparelho ja foi  vendido, e nada é cobrado dele.
**Resultado esperado:**  
Evitar conflitos de estoque decorrentes da ausência de reserva prévia.

## Módulo 3 - Venda

### RN-05 - Venda de Aparelho

**Regras:**
- Só é possível vender aparelho com status **Disponível**.
- Venda deve conter: cliente, aparelho(s), data, valor do produto, desconto (quando aplicável), valor final, forma de pagamento, status.
- Após confirmação do pagamento, aparelho muda para **Vendido**.
- IMEI vinculado ao registro da venda.
- Venda registrada no histórico do cliente (**RN-20**).
- Geração de comprovante de venda.
- Status da venda: Aberta, Aguardando pagamento, Pago, Parcialmente pago, Finalizada, Cancelada.

### RN-06 - Forma de Venda: À Vista ou Parcelada

**Regras:**

- O cliente poderá optar por compra à vista ou parcelado.
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
- Valor Final = Valor do Produto − Desconto + Taxas (quando houver).
- Não há desconto discricionário manual; único desconto é o automático via Pix (RN-08).
- Valor final apresentado ao cliente antes da confirmação.
- Valor registrado no módulo financeiro após confirmação.

- **Valor Final = Valor do Produto − Desconto + Taxas (quando houver).**
-  Não há desconto discricionário manual; o único desconto possível é o automático via Pix  (**RN-08**).
- O valor final é apresentado ao cliente antes da confirmação e registrado no módulo financeiro após a conclusão da venda.

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

- Desconto aplicado somente com pagamento via Pix.
- Elegibilidade configurável por produto (RN-02).
- Sem desconto em cartão de crédito ou boleto.
- Apresentado ao cliente antes da confirmação, mesmo quando não elegível.
- Percentual e valor do desconto registrados na venda.

### RN-09 - Formas de Pagamento

**Regras:**
- Formas aceitas: Pix, cartão de crédito, boleto. **Sem cartão de débito.**
- Forma de pagamento obrigatória na venda.
- Cartão de crédito: número de parcelas (máx. 12).
- Registro do status do pagamento.
- Venda só é **Finalizada** após confirmação do pagamento.

### RN-10 - Parcelamento

**Regras:**
- Mínimo 1, máximo 12 parcelas.
- Cálculo automático do valor das parcelas.
- Valor total da venda permanece registrado independente da quantidade de parcelas.
- Juros/taxas apresentados antes da confirmação.

## Módulo 4 - Pós-venda: Cancelamento

### RN-11 - Cancelamento da Venda

**Descrição:** Cancelamento permitido em até 7 dias corridos a partir da venda, desde que o aparelho não tenha saído para entrega.

**Regras:**
- Verificação da data da venda antes do cancelamento.
- Permitido somente enquanto status de entrega for **Aguardando envio**.
- A partir de **Em transporte** ou **Entregue**, segue o fluxo de Devolução (RN-13/RN-14).
- Motivo do cancelamento registrado.
- Pagamento já realizado → abertura de processo de estorno (RN-17).
- Aparelho direcionado a **Em avaliação** antes de retornar como **Disponível**.
- Venda cancelada não é excluída; fica registrada no histórico para auditoria (RN-21).

## Módulo 5 - Pós-venda: Troca e Devolução

### RN-12 - Troca por Defeito Coberto pela Garantia

**Descrição:** Troca por outro aparelho equivalente quando identificado defeito coberto pela garantia da loja, dentro de 30 dias da compra.

**Regras:**
- Solicitação vinculada à venda original e ao IMEI.
- Aparelho passa por avaliação técnica (**Em avaliação**) antes da decisão.
- Troca autorizada apenas quando o defeito é coberto pela garantia (RN-15).
- Danos por mau uso não são elegíveis (RN-16).
- **"Aparelho equivalente":** (a) mesmo modelo, cor e capacidade; ou, na ausência, (b) aparelho disponível com especificação e valor igual ou superior, mais próximo do original.
- Novo aparelho deve estar **Disponível** no momento da troca - sem reserva ou espera por reposição (RN-03/RN-04).
- Sem aparelho equivalente → aplica-se imediatamente a devolução por defeito (RN-14), sem período de espera.
- Aparelho substituído direcionado para **Em manutenção** ou **Inativo**.
- Troca registrada no histórico do cliente e da venda.

**Política comercial de troca por defeito:**

| Situação | Aparelho equivalente? | Política comercial aplicada | Regras envolvidas |
|---|---|---|---|
| Existe mesmo modelo, cor e capacidade, status Disponível | Sim (idêntico) | Troca direta, sem custo adicional | RN-12 |
| Não existe idêntico, mas existe equivalente (especificação/valor igual ou superior), status Disponível | Sim (equivalente) | Troca direta, sem cobrança de diferença | RN-12 |
| Não existe nenhum aparelho idêntico nem equivalente Disponível | Não | Devolução imediata com restituição integral. Sem opção de aguardar reposição (equivaleria a reserva, vedada) | RN-14 + RN-17 + RN-18 |
| Existe equivalente, mas em Em avaliação/Em manutenção/Inativo | Não (indisponível) | Mesmo tratamento: devolução imediata com restituição integral | RN-14 + RN-17 + RN-18 |

### RN-13 - Devolução por Arrependimento

**Descrição:** Devolução em até 7 dias corridos a partir do recebimento, independentemente de defeito, conforme Art. 49 do CDC (compras fora do estabelecimento comercial).

**Regras:**
- Vinculada à venda original.
- Registro da data e motivo (quando informado).
- Aparelho devolvido em condições de revenda, passa por avaliação (**Em avaliação**).
- Valor pago integralmente restituído (RN-17), sem necessidade de comprovar defeito.
- Retorna ao estoque como **Disponível** apenas após aprovação; se danificado, vai para **Em manutenção** ou **Inativo**.

### RN-14 - Devolução por Defeito

**Descrição:** Devolução com reembolso quando há defeito coberto pela garantia sem solução por troca, ou quando o aparelho já foi entregue (ver RN-11).

**Regras:**
- Venda localizável por CPF/CNPJ, número da venda ou IMEI.
- Avaliação técnica (**Em avaliação**).
- Defeito coberto + sem equivalente para troca (RN-12) → procedimento de devolução com restituição (RN-17).
- Mau uso → devolução não autorizada (RN-16).
- Registro do diagnóstico e decisão.
- Processo registrado no histórico do cliente e do aparelho.

## Módulo 6 - Pós-venda: Garantia e Avaliação de Danos

### RN-15 - Garantia do Aparelho

**Regras:**

| Condição | Garantia |
|---|---|
| Novo | 30 dias de garantia da loja + 1 ano do fabricante |
| Seminovo | 30 dias de garantia da loja; sem garantia adicional do fabricante, salvo indicação expressa |

- Garantia da loja inicia na data da venda.
- Registro de início/término e consulta de vigência.
- IMEI identifica o aparelho.
- Danos por mau uso não cobertos (RN-16).
- Todas as solicitações de garantia são registradas.

### RN-16 - Avaliação de Dano e Elegibilidade para Cobertura

**Regras:**
- Avaliação técnica (**Em avaliação**).
- Classificação do dano: defeito de fabricação, dano por mau uso, dano acidental, outros.
- Exemplos de mau uso (não cobertos): tela quebrada por impacto, aparelho amassado, danos por líquido não cobertos, alterações não autorizadas, outros danos por uso inadequado.
- Defeito coberto → segue RN-15 e, conforme o caso, troca (RN-12) ou devolução (RN-14).
- Mau uso → troca/devolução não autorizada; sem reparo pela empresa; cliente informado do diagnóstico.

## Módulo 7 - Financeiro e Fiscal

### RN-17 - Estorno e Restituição

**Regras:**
- Estorno segue a forma de pagamento original.
- Pix → estorno direto para a chave/conta de origem.
- Cartão de crédito → estorno junto à operadora.
- Boleto → restituição por transferência bancária, com dados informados pelo cliente.
- Processo completo de estorno: **7 a 15 dias corridos** (Pix tende ao início da faixa; cartão/boleto podem levar até o limite superior).
- Registro de valor, data de abertura, prazo-limite (abertura + 15 dias) e status.
- Status do estorno: Pendente, Processado, Recusado.
- Prazo ultrapassado → sinalização de atraso e notificação ao perfil Financeiro/Administrativo (RN-22).
- Vendas parceladas canceladas após pagamento parcial → estorno considera apenas os valores já pagos.

### RN-18 - Emissão de Nota Fiscal

**Regras:**
- Nota vinculada à venda, usando dados do cliente (RN-01) e do aparelho (RN-02).
- Emissão inicia com status **Aguardando emissão**.
- Registro de número e chave de acesso; consulta de status (Aguardando emissão, Emitida, Pendente, Cancelada).
- Cancelamento (RN-11) dentro do prazo legal da SEFAZ (até 24h) → nota de venda vai para **Cancelada**. Fora do prazo → nota permanece **Emitida** e segue o procedimento fiscal da devolução.
- Devolução (RN-13 ou RN-14) → emissão de Nota Fiscal de Entrada (devolução), referenciando a NF-e original. Estorno (RN-17) só é liberado quando essa nota atinge **Emitida**.
- Troca por defeito (RN-12) → emissão de duas notas: (1) Entrada (devolução) para o aparelho defeituoso; (2) Saída para o aparelho de reposição. Sem cobrança adicional quando não há diferença de valor.
- Erro na emissão → nota fica **Pendente**; venda sinalizada como "nota fiscal pendente"; estorno ou saída de reposição ficam retidos até regularização.

### RN-19 - Comissão de Vendedores - Não Aplicável

**Regras:**
- Sem cálculo ou lançamento financeiro de comissão.
- Registro do usuário responsável por atendimentos de pós-venda apenas para auditoria (RN-21), sem gerar comissão.

## Módulo 8 - Histórico, Auditoria e Acesso

### RN-20 - Histórico do Cliente

**Regras:**
- Compras realizadas e aparelhos adquiridos (IMEI e valores).
- Pagamentos, cancelamentos, trocas por defeito e devoluções.
- Solicitações de garantia e diagnósticos.
- Créditos ou estornos concedidos.

### RN-21 - Auditoria das Operações

**Regras:**
- Registro de usuário responsável, data/hora, operação, venda afetada, aparelho afetado, valores anteriores e novos.
- Auditar principalmente: alterações de preço/desconto, cancelamentos, trocas, devoluções, estornos, alterações de pagamento e de estoque.

### RN-22 - Perfis de Acesso e Autorizações

**Descrição:** Perfis de acesso seguindo a estrutura organizacional (2 sócios + 8 colaboradores em 4 áreas).

**Regras:**
- 2 níveis: **Nível 1 - Operacional** (um perfil por área) e **Nível 2 - Estratégico** (Diretoria).
- Cada colaborador recebe o perfil da sua área; sócios recebem o perfil de Diretoria (acesso total).
- Diretoria é o único perfil autorizado a criar/editar/remover perfis e autorizar exceções fora do fluxo automático.
- Toda autorização registra usuário autorizador, perfil e área (RN-21).
- Sistema impede operações fora da área/nível de autorização do usuário.

**Matriz de Perfis de Acesso:**

| Perfil / Área | Colaboradores | Pode Realizar | Pode Autorizar / Aprovar |
|---|---:|---|---|
| Diretoria (Nível 2 - Estratégico) | 2 sócios | Todas as operações, em todas as áreas | Qualquer operação sensível; exceções fora do fluxo automático (ex.: cancelamento fora do prazo, troca sem equivalente - RN-12); ajustes financeiros extraordinários; criação/edição de perfis; elegibilidade de produtos ao desconto Pix (RN-08) |
| Vendas e Atendimento (Nível 1) | 2 | Registrar vendas (RN-05 a RN-10); abrir cancelamento dentro do prazo (RN-11); registrar e encaminhar solicitações de troca/devolução (RN-12/13/14); consultar histórico do cliente (RN-20) | Cancelamento dentro da janela padrão (fluxo automático). Não autoriza exceções |
| Estoque e Logística (Nível 1) | 2 | Cadastrar aparelhos (RN-02); controlar/validar estoque (RN-03/04); atualizar status de entrega | Retorno do aparelho a Disponível após avaliação da Assistência Técnica. Não autoriza troca, devolução ou estorno |
| Assistência Técnica (Nível 1) | 2 | Avaliação técnica de dano (RN-16); análise de garantia (RN-15); parecer técnico para troca (RN-12) e devolução por defeito (RN-14) | Troca por defeito (RN-12) e devolução por defeito (RN-14) dentro dos critérios definidos. Escalona à Diretoria quando não há equivalente |
| Financeiro/Administrativo (Nível 1) | 2 | Processar estornos (RN-17); emitir nota fiscal (RN-18); lançar valores financeiros; consultar auditoria financeira (RN-21) | Liberação de estornos e emissões de NF dentro dos valores/prazos definidos. Não autoriza mudanças de política comercial |



## 9. Restrições e Políticas Organizacionais

| **Política de Aquisição de Aparelhos**  |
- **Verificação de procedencia:** consultar o IMEI antes da compra.
- **Recusa de aparelhos irregulares:**  não aceitar celulares com IMEI irregulares ou com indicios de celulares clonados.
- **Identificação de vendedor:** exigir documentos com foto e CPF.
- **Limite de compras por CPF/dia:** o vendedor poderá vender X aparelhos por dia, para evitar lavagem de aparelhos de origem ilicita.
- **Documentação obrigatória:** emissão de nota fiscal ou termo de compra e venda, mesmo entre pessoas visicas.

| **Politica de Avaliação Tecnica** |
- **Checklist tecnico:**  avaliação de bataria, tela, cameras, botões, conectatividade, autenticidade das peças.
- **Verificação de bloqueios de contas:** checagem de bloqueio iCloud/Google (FRP); recusa de aparelho caso não seja possivel desbloquear.

| **Politica de Revenda:**  |
- **Reset de fábrica:** remoção de contas, dados pessoais e bloqueios (FRP/iCloud) antes de expor para venda.
- **Prazo de quarentena:** periodo em que o celulares recebidos em troca, para confirmar que não ira haver uma contestação de furto.
- **Restrição etária:** não fazer a venda para menores de 18 anos sem uma presença legal.

| **Politica Fiscal e Documental**  |
- **Emissão de nota fiscal**
- **Rastreabilidade por IMEI:** registro de garantia e historico do aparelho vinculado ao IMEI.
- **Retenção de comprovantes:** guarda de comprovantes por prazo minimo fical.

| **Politica de Proteção de Dados (LGPD)**  |
- **Termo de responsabilidade do cliente:** declaração de que o cliente removeu contas e dados pessoais antes da entrega.
- **Minimização de dados:** não armazenamento de dados pessoais extraidos alem do estritamente necessario.

| **Restrições Operacionais** |
- **Seguro de estoque:**  contratação de seguro contra roubo para estoque de alto valor.
- **Segregação de estoque:** definição de limite de itens expostos em vitrine versus estoque em cofre. 

## 10. Fluxogramas



## 11. Entidades



## 12. Atributos



## 13. Relacionamentos



## 14. Cardinalidades



## 15. Dicionário de Dados Conceitual



## 16. DER



## 17. Justificativas Técnicas



## 18. Conclusão
