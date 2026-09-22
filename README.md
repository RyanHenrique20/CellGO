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
| 10 | Sarah Casas Nicolielo Ponti |
| 11 | Victor Rodrigues da Costa |

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

### 1. Ausência de sistema único e integrado

**Situação atual:** Os cadastros de clientes, aparelhos, estoque e financeiro são feitos em várias planilhas separadas, sem uma base de dados centralizada. As vendas também não são integradas a um sistema único.

**Causa:** Cada setor (vendas, estoque, assistência técnica/pós-venda e financeiro) mantém seus próprios registros manuais, sem nenhuma conexão automática entre eles.

**Impacto no negócio:** Isso gera duplicidade de informações, obriga os funcionários a digitar os mesmos dados várias vezes (retrabalho) e deixa vendas, estoque e financeiro com informações desatualizadas, comprometendo a confiabilidade dos dados em toda a empresa.



### 2. Falta de atualização em tempo real do estoque

**Situação atual:** O estoque é controlado em planilhas, e o status do aparelho (Disponível, Vendido, Em avaliação, Em manutenção, Inativo) não é atualizado automaticamente após uma venda.

**Causa:** A ausência de integração entre o setor de vendas e o controle de estoque faz com que a atualização dependa de uma ação manual em vez de ocorrer automaticamente.

**Impacto no negócio:** Isso provoca erros na quantidade disponível e problemas de logística, além do risco real de um cliente comprar um aparelho que já foi vendido para outra pessoa.



### 3. Falta de histórico e controle de garantia dos aparelhos

**Situação atual:** Não existe um histórico centralizado por aparelho, nem acompanhamento dos prazos de garantia (30 dias loja para seminovos; 30 dias loja + 1 ano fabricante para novos).

**Causa:** Os dados de cada aparelho (data da venda, manutenções, trocas, devoluções) não são registrados de forma estruturada e centralizada.

**Impacto no negócio:** Fica difícil acompanhar manutenção, trocas e devoluções, saber se uma solicitação ainda está dentro do prazo de garantia, ou até aceitar por engano uma garantia já vencida — gerando prejuízo financeiro.



### 4. Falta de controle sobre estornos

**Situação atual:** Os pedidos de estorno não possuem acompanhamento de prazo.

**Causa:** Não existe um fluxo estruturado que registre a data de abertura do estorno e monitore automaticamente seu andamento.

**Impacto no negócio:** Fica difícil identificar quais estornos estão pendentes, em andamento ou atrasados, o que pode prejudicar o relacionamento com o cliente e atrasar o fechamento financeiro do período.



### 5. Financeiro desatualizado e desconectado das vendas

**Situação atual:** Os dados financeiros são mantidos separadamente dos demais setores, e o financeiro não recebe automaticamente as informações de vendas, cancelamentos, trocas e devoluções.

**Causa:** A comunicação entre o setor comercial e o financeiro depende de repasses manuais (planilhas, mensagens, anotações), em vez de uma integração direta entre os dados.

**Impacto no negócio:** Isso compromete a precisão dos dados financeiros e dificulta o acompanhamento dos resultados, o fechamento de caixa e a tomada de decisões estratégicas com base em números confiáveis.



### 6. Processos manuais

**Situação atual:** Grande parte das tarefas operacionais do dia a dia é realizada manualmente, sem apoio de automação.

**Causa:** A falta de um sistema integrado obriga os funcionários a repetir manualmente tarefas que poderiam ser automatizadas.

**Impacto no negócio:** Isso gera maior gasto de tempo dos funcionários com tarefas operacionais, reduzindo a produtividade e o tempo disponível para atividades estratégicas ou de atendimento ao cliente.



### 7. Ausência de backup

**Situação atual:** Não existe uma rotina estruturada de backup dos dados da empresa.

**Causa:** As informações ficam armazenadas em planilhas e arquivos locais, sem um processo automático de cópia de segurança.

**Impacto no negócio:** Isso gera o risco de dados importantes serem perdidos, duplicados ou ficarem desatualizados, comprometendo a continuidade das operações em caso de falha, exclusão acidental ou perda de um arquivo.



### 8. Ausência de relatórios

**Situação atual:** Não existem relatórios automáticos consolidados sobre vendas, estoque e resultados.

**Causa:** Como os dados estão espalhados em planilhas separadas e não integradas, não é possível gerar relatórios de forma automática e confiável.

**Impacto no negócio:** Isso faz com que os gestores tenham dificuldade para analisar vendas, estoque e resultados, prejudicando a visão estratégica do negócio e a tomada de decisões baseada em dados.



### 9. Histórico do cliente fragmentado

**Situação atual:** As informações de cada cliente estão espalhadas entre os diferentes setores da empresa.

**Causa:** Não existe uma base de dados única que reúna compras, trocas, devoluções e acionamentos de garantia de um mesmo cliente em um só lugar.

**Impacto no negócio:** Isso dificulta o atendimento no pós-venda e na assistência técnica, pois o funcionário precisa consultar vários lugares diferentes para entender o histórico completo do cliente, tornando o atendimento mais lento e sujeito a falhas.



### 10. Histórico de funcionários fragmentado

**Situação atual:** As informações de cada funcionário (vendas realizadas, cargo, tempo de registro, salário, setor) também estão espalhadas entre os setores.

**Causa:** Assim como ocorre com os clientes, não há uma base de dados centralizada que reúna essas informações em um único cadastro por funcionário.

**Impacto no negócio:** Isso dificulta a gestão de pessoas, como avaliar desempenho de vendas, acompanhar o histórico profissional do colaborador dentro da empresa e tomar decisões sobre cargos, comissões e crescimento interno.



## 5. Processos de Negócios

Cliente ⭢ Login/Cadastro ⭢ Seleção de aparelho ⭢ Estoque ⭢ Método de pagamento ⭢ Emissão de nota fiscal ⭢ Envio do aparelho ⭢ Entrega ao destinatário ⭢ Pós-venda ⭢ Solicitação de contato ⭢ Análise ⭢ Definição do procedimento ⭢ Coleta do aparelho ⭢ Recebimento ⭢ Análise de danos ⭢ Aprovação/Recusa ⭢ Estorno/Restituição da troca ⭢ Atualização de estoque ⭢ Atualização do histórico do cliente ⭢ Encerramento do pós-venda.



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

## Módulo 1 — Cadastro

### RN-01 — Cadastro de Cliente
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



### RN-02 — Cadastro de Aparelho/Produto
**Módulo:** Cadastro

**Descrição:**
O sistema deverá permitir o cadastro dos aparelhos disponíveis para venda, com as informações necessárias para estoque, garantia e nota fiscal.

**Regras:**
- O cadastro deverá conter, no mínimo: modelo, marca, IMEI/número de série, condição (Novo ou Seminovo), preço de venda, custo de aquisição e status inicial.
- O IMEI/número de série deverá ser único no sistema.
- A condição (Novo/Seminovo) é obrigatória e determina o período de garantia aplicável (ver RN-15).
- A entrada do aparelho no estoque deverá registrar data de entrada, custo e identificador, conforme já previsto no controle de estoque (RN-03).
- O cadastro de aparelhos deverá ser realizado apenas por funcionários autorizados, de acordo com seu nível de acesso (permissão) no sistema (ver RN-22).

**Resultado esperado:**
Garantir que todo aparelho tenha um cadastro completo, permitindo o correto funcionamento das regras de estoque, venda, garantia e nota fiscal que dependem desses dados, restrito a usuários autorizados.



## Módulo 2 — Estoque

### RN-03 — Controle de Estoque

**Módulo:** Estoque

**Descrição:**
O sistema deverá controlar a disponibilidade individual de cada aparelho comercializado pela empresa, sem uso de reserva prévia à confirmação da venda.

**Regras:**
- Um aparelho com status Disponível poderá ser vendido.
- O sistema não realizará reserva de aparelhos antes da confirmação do pagamento da venda.
- Um aparelho com status Vendido não retorna automaticamente ao estoque.
- Toda alteração de status do aparelho deverá ser registrada no histórico do aparelho, com data, hora e usuário responsável quando aplicável.
- O sistema deverá impedir a venda de um aparelho inexistente, já vendido ou indisponível.
- Status possíveis: Disponível, Vendido, Em avaliação, Em manutenção, Inativo.

**Resultado esperado:**
Evitar vendas duplicadas e garantir rastreabilidade dos aparelhos comercializados, sem depender de um mecanismo de reserva.




### RN-04 — Validação de Disponibilidade no Fechamento da Venda

**Módulo:** Estoque

**Descrição:**
O sistema deverá validar novamente a disponibilidade do aparelho no exato momento da finalização da venda, para evitar que dois clientes concluam a compra do mesmo aparelho.

**Regras:**
- A validação de disponibilidade deverá ocorrer de forma atômica junto com a confirmação do pagamento, de modo que duas vendas não possam ser concluídas simultaneamente para o mesmo aparelho.
- Caso o aparelho já tenha sido vendido por outra transação, a nova tentativa de compra deverá ser bloqueada e o cliente informado.

**Resultado esperado:**
Evitar conflitos de estoque decorrentes da ausência de reserva prévia.



## Módulo 3 — Venda

### RN-05 — Venda de Aparelho

**Módulo:** Venda

**Descrição:**
O sistema deverá permitir a realização da venda de aparelhos cadastrados no estoque, vinculando o(s) produto(s) a um cliente e registrando todas as informações financeiras da operação.

**Regras:**
- Só poderá ser realizada uma venda para um aparelho com status Disponível.
- A venda deverá possuir obrigatoriamente: cliente, aparelho(s), data da venda, valor do produto, desconto quando aplicável, valor final, forma de pagamento e status da venda.
- Após a confirmação do pagamento, o aparelho deverá ter seu status alterado para Vendido.
- O IMEI/número de série deverá ficar vinculado ao registro da venda.
- A venda deverá ser registrada no histórico do cliente (ver RN-20).
- O sistema deverá gerar um comprovante de venda.
- Status da venda: Aberta, Aguardando pagamento, Pago, Parcialmente pago, Finalizada ou Cancelada.

**Resultado esperado:**
Garantir que toda venda seja registrada corretamente, vinculando cliente, aparelho, estoque e financeiro.


### RN-06 — Forma de Venda — À Vista ou Parcelada

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



### RN-07 — Cálculo do Valor da Venda

**Módulo:** Venda

**Descrição:**
O sistema deverá calcular automaticamente o valor final da venda considerando o preço do aparelho e os descontos aplicáveis.

**Regras:**
- Valor Final = Valor do Produto − Desconto + Taxas (quando houver).
- No modelo de e-commerce, não há desconto discricionário aplicado manualmente por um vendedor: o único desconto previsto é o desconto automático por pagamento via Pix, aplicável apenas aos produtos elegíveis (ver RN-08).
- O valor final deverá ser apresentado ao cliente antes da confirmação da venda.
- Após a confirmação, o valor da venda deverá ser registrado no módulo financeiro.

**Resultado esperado:**
Garantir que o valor cobrado seja calculado corretamente e de forma consistente com o modelo de e-commerce.



### RN-08 — Desconto para Pagamento via Pix

**Módulo:** Venda

**Descrição:**
O sistema deverá aplicar desconto exclusivamente para pagamentos realizados via Pix, conforme faixa de valor do produto, e apenas para os produtos elegíveis.

**Regras:**
- O desconto é aplicado somente quando a forma de pagamento é Pix.
- Faixas confirmadas: produto até R$ 1.000,00 = 5%; de R$ 1.001,00 a R$ 2.500,00 = 7%; acima de R$ 2.500,00 = 10%.
- Nem todos os produtos participarão do desconto Pix: a elegibilidade de cada produto ao desconto deverá ser configurável no cadastro do aparelho (RN-02).
- Não será aplicado desconto para pagamentos via cartão de crédito ou boleto.
- O desconto deverá ser apresentado ao cliente antes da confirmação da compra, incluindo os casos em que o produto não é elegível ao desconto.
- O sistema deverá registrar o percentual e o valor do desconto na venda.

**Resultado esperado:**
Controlar os descontos concedidos para pagamentos via Pix, evitando descontos indevidos em outras formas de pagamento ou em produtos não elegíveis.



### RN-09 — Formas de Pagamento

**Módulo:** Venda

**Descrição:**
O sistema deverá aceitar pagamentos via Pix, cartão de crédito e boleto bancário. Não haverá aceitação de cartão de débito como forma de pagamento.

**Regras:**
- A venda deverá informar obrigatoriamente a forma de pagamento.
- Para cartão de crédito, deverá ser informado o número de parcelas (máximo 12).
- O sistema deverá registrar o status do pagamento.
- Uma venda somente será considerada Finalizada após a confirmação do pagamento, conforme a forma utilizada.
- Cartão de débito não é uma forma de pagamento aceita nesta consolidação, por decisão do negócio.

**Resultado esperado:**
Garantir o controle dos pagamentos e a correta vinculação entre venda e financeiro, com as formas de pagamento efetivamente aceitas pelo e-commerce.



### RN-10 — Parcelamento

**Módulo:** Venda

**Descrição:**
O sistema deverá permitir o parcelamento de vendas pagas por cartão de crédito em até 12 parcelas.

**Regras:**
- Número mínimo de parcelas: 1. Número máximo: 12.
- O sistema deverá calcular automaticamente o valor das parcelas.
- O valor total da venda deverá permanecer registrado independentemente da quantidade de parcelas.
- Caso existam juros ou taxas, estes deverão ser apresentados antes da confirmação da venda.

**Resultado esperado:**
Permitir o parcelamento das vendas de forma transparente e controlada.



## Módulo 4 — Pós-venda: Cancelamento

### RN-11 — Cancelamento da Venda

**Módulo:** Pós-venda

**Descrição:**
O sistema deverá permitir o cancelamento de uma venda no prazo de até 7 dias corridos a partir da data da venda, desde que o aparelho ainda não tenha saído para entrega.

**Regras:**
- O sistema deverá verificar a data da venda antes de permitir o cancelamento.
- O cancelamento por esta regra somente será permitido enquanto o status de entrega da venda for "Aguardando envio". A atualização desse status é feita pela integração com a API da transportadora, conforme definido na Seção 1.3.
- A partir do momento em que o status de entrega passar para "Em transporte" ou "Entregue", a solicitação do cliente deixa de ser tratada como cancelamento e passa a seguir o fluxo do Módulo 5 — Devolução (RN-13/RN-14), conforme o caso.
- O motivo do cancelamento deverá ser registrado.
- Caso o pagamento já tenha sido realizado, deverá ser aberto o processo de estorno (ver RN-17).
- Como o aparelho ainda não foi enviado, ele deverá ser diretamente direcionado a nova avaliação de estoque (status Em avaliação) antes de retornar como Disponível.
- A venda cancelada não deverá ser excluída do sistema; o cancelamento fica registrado no histórico do cliente e da venda, para fins de auditoria (ver RN-21).

**Resultado esperado:**
Permitir o cancelamento dentro do prazo estabelecido e apenas antes da saída do aparelho para entrega, mantendo o histórico financeiro e de estoque e direcionando corretamente os casos pós-envio para o fluxo de devolução.


## Módulo 5 — Pós-venda: Troca e Devolução

### RN-12 — Troca por Defeito Coberto pela Garantia

**Módulo:** Pós-venda

**Descrição:**
O sistema deverá permitir a troca de um aparelho vendido por outro equivalente, quando for identificado defeito coberto pela garantia da loja, dentro do prazo de 30 dias da compra. A definição de "aparelho equivalente" e a política comercial aplicável em cada cenário estão detalhadas na tabela desta seção.

**Regras:**
- A solicitação deverá estar vinculada à venda original e ao IMEI/número de série do aparelho.
- O aparelho deverá passar por avaliação técnica (status Em avaliação) antes da decisão.
- A troca somente será autorizada quando o defeito estiver coberto pela garantia da loja (RN-15).
- Danos causados por mau uso não são elegíveis para esta troca (ver RN-16).
- Considera-se "aparelho equivalente": (a) o aparelho do mesmo modelo, cor e capacidade de armazenamento do aparelho trocado; ou, na ausência deste, (b) o aparelho disponível em estoque, com especificação e valor igual ou superior, mais próximo do aparelho original.
- O novo aparelho deverá estar com status Disponível no estoque no momento da troca — não é permitido reservar ou aguardar reposição futura de estoque, em conformidade com a política de não realizar reserva de aparelhos (RN-03/RN-04).
- Caso não exista aparelho equivalente disponível, aplica-se imediatamente a política de devolução por defeito (RN-14) como alternativa, sem período de espera — ver tabela de política comercial nesta seção.
- O aparelho substituído deverá ser direcionado para Em manutenção ou Inativo, conforme avaliação.
- A troca deverá ser registrada no histórico do cliente e da venda.

**Resultado esperado:**
Permitir trocas por defeito dentro do período de garantia da loja, evitando trocas decorrentes de mau uso e definindo com clareza o que fazer quando não há aparelho equivalente em estoque.

**Política comercial de troca por defeito (detalhamento da RN-12):**

| Situação | Aparelho equivalente? | Política comercial aplicada | Regras envolvidas |
|---|---|---|---|
| Existe o mesmo modelo, cor e capacidade do aparelho trocado, com status Disponível. | Sim (idêntico) | Troca direta pelo aparelho idêntico, sem custo adicional ao cliente. | RN-12 |
| Não existe o mesmo modelo/cor/capacidade, mas existe aparelho de especificação e valor igual ou superior, com status Disponível. | Sim (equivalente) | Troca direta pelo aparelho equivalente disponível, sem cobrança de diferença de valor ao cliente. | RN-12 |
| Não existe nenhum aparelho idêntico nem equivalente com status Disponível no momento da solicitação. | Não | Devolução imediata com restituição integral do valor pago. Não é oferecida a opção de aguardar reposição de estoque, pois isso equivaleria a uma reserva de aparelho, o que é vedado pela política de estoque do negócio (RN-03/RN-04). | RN-14 + RN-17 + RN-18 |
| Existe um aparelho equivalente, porém com status Em avaliação, Em manutenção ou Inativo (não Disponível) no momento da solicitação. | Não (indisponível) | Mesmo tratamento da situação anterior: devolução imediata com restituição integral, sem espera pela liberação desse aparelho. | RN-14 + RN-17 + RN-18 |


### RN-13 — Devolução por Arrependimento

**Módulo:** Pós-venda

**Descrição:**
O sistema deverá permitir a devolução de um aparelho no prazo de até 7 dias corridos a partir do recebimento, independentemente de defeito, em conformidade com o direito de arrependimento previsto no Art. 49 do Código de Defesa do Consumidor para compras realizadas fora do estabelecimento comercial (e-commerce).

**Regras:**
- A devolução deverá estar vinculada à venda original.
- O sistema deverá registrar a data e o motivo da devolução, quando informado pelo cliente.
- O aparelho deverá ser devolvido em condições de revenda e passar por avaliação (status Em avaliação).
- O valor pago deverá ser integralmente restituído ao cliente (ver RN-17), sem necessidade de comprovação de defeito.
- O aparelho somente retorna ao estoque como Disponível após avaliação e aprovação; caso apresente dano, é direcionado para Em manutenção ou Inativo.

**Resultado esperado:**
Garantir o cumprimento do direito de arrependimento do consumidor em compras de e-commerce, controlando devoluções sem perder o histórico da venda.


### RN-14 — Devolução por Defeito

**Módulo:** Pós-venda

**Descrição:**
O sistema deverá permitir a devolução (com reembolso) do aparelho quando for identificado defeito coberto pela garantia, sem solução adequada por troca, ou quando o aparelho já tiver sido entregue no momento em que o cliente reporta o problema (ver RN-11).

**Regras:**
- O cliente deverá apresentar o aparelho para avaliação; a venda pode ser localizada por CPF/CNPJ, número da venda ou IMEI.
- O aparelho deverá ser submetido a avaliação técnica (status Em avaliação).
- Se o defeito for coberto pela garantia e não houver aparelho equivalente para troca (RN-12), a empresa deverá seguir o procedimento de devolução com restituição (RN-17).
- Se o problema for causado por mau uso, a devolução por esta regra não é autorizada (ver RN-16).
- O sistema deverá registrar o diagnóstico e a decisão tomada.
- O processo deverá ficar registrado no histórico do cliente e do aparelho.

**Resultado esperado:**
Garantir que devoluções por defeito sejam realizadas somente quando a troca não for uma alternativa viável, mantendo a cobertura de garantia como critério central — inclusive para os casos em que o aparelho já foi enviado e o cliente precisa acionar o pós-venda em vez do cancelamento.



## Módulo 6 — Pós-venda: Garantia e Avaliação de Danos

### RN-15 — Garantia do Aparelho

**Módulo:** Pós-venda

**Descrição:**
Todo aparelho vendido possui garantia da loja e, quando aplicável, garantia adicional do fabricante, conforme sua condição de cadastro (Novo ou Seminovo).

**Regras:**
- Aparelhos Novos: 30 dias de garantia da loja + 1 ano de garantia do fabricante, conforme condições estabelecidas pelo fabricante.
- Aparelhos Seminovos: 30 dias de garantia da loja; sem garantia adicional do fabricante, salvo quando expressamente informado pelo fabricante.
- A garantia da loja tem início na data da venda.
- O sistema deverá registrar a data de início e término da garantia e permitir consultar se está vigente ou encerrada.
- O IMEI/número de série deverá ser utilizado para identificar o aparelho.
- Danos decorrentes de mau uso não são cobertos pela garantia da loja (ver RN-16).
- O sistema deverá registrar todas as solicitações de garantia.

**Resultado esperado:**
Controlar os diferentes períodos de garantia e diferenciar claramente a cobertura da loja da cobertura do fabricante.



### RN-16 — Avaliação de Dano e Elegibilidade para Cobertura
**Módulo:** Pós-venda

**Descrição:**
Quando o aparelho apresentar dano, o sistema deverá registrar a ocorrência e determinar se o caso é coberto pela garantia ou se é caracterizado como mau uso, sem cobertura da empresa.

**Regras:**
- O aparelho deverá ser avaliado tecnicamente (status Em avaliação).
- O sistema deverá registrar o tipo de dano e classificá-lo como: defeito de fabricação, dano por mau uso, dano acidental ou outros.
- Exemplos de mau uso (não cobertos pela garantia): tela quebrada por impacto, aparelho amassado, danos por líquido não cobertos, alterações não autorizadas, outros danos por uso inadequado.
- Caso esteja dentro da garantia e seja defeito coberto, o atendimento segue as regras de garantia (RN-15) e, conforme o caso, troca (RN-12) ou devolução (RN-14).
- Caso o dano seja caracterizado como mau uso, a solicitação de troca ou devolução não será autorizada e o aparelho não será reparado pela empresa; o cliente deverá ser informado do diagnóstico e o atendimento é encerrado sem custo para a empresa.

**Resultado esperado:**
Diferenciar de forma clara problemas cobertos pela garantia de danos causados por mau uso, sem que a empresa assuma qualquer serviço de reparo nesses casos.



## Módulo 7 — Financeiro e Fiscal

### RN-17 — Estorno e Restituição

**Módulo:** Financeiro

**Descrição:**
O sistema deverá processar estornos e restituições decorrentes de cancelamento, devolução ou troca com diferença de valor a favor do cliente.

**Regras:**
- O estorno deverá seguir a forma de pagamento original utilizada na venda.
- Pagamentos via Pix deverão ser estornados diretamente para a chave/conta de origem.
- Pagamentos via cartão de crédito deverão ser estornados junto à operadora do cartão.
- Pagamentos via boleto deverão gerar restituição por transferência bancária, mediante dados informados pelo cliente.
- O processo completo de estorno, da abertura da solicitação até a efetiva liberação do valor ao cliente, deverá ocorrer dentro do prazo de 7 a 15 dias corridos, podendo variar conforme a forma de pagamento (Pix tende ao início da faixa; cartão de crédito e boleto podem levar até o limite superior, por dependerem de prazos de operadoras e instituições financeiras).
- O sistema deverá registrar valor, data de abertura, prazo-limite (data de abertura + 15 dias) e status do estorno (Pendente, Processado, Recusado).
- Caso o prazo de 15 dias seja ultrapassado sem conclusão, o sistema deverá sinalizar o estorno como atrasado e notificar o perfil Financeiro/Administrativo (RN-22) para tratamento manual.
- Em vendas parceladas canceladas após pagamento de parte das parcelas, o estorno deverá considerar apenas os valores já pagos.

**Resultado esperado:**
Garantir que todo valor devido ao cliente em cancelamentos, devoluções ou trocas seja restituído de forma rastreável e dentro de um prazo definido.


### RN-18 — Emissão de Nota Fiscal

**Módulo:** Fiscal

**Descrição:**
O sistema deverá possuir integração ou funcionalidade para emissão de nota fiscal eletrônica referente às vendas realizadas, incluindo tratamento fiscal específico para cancelamento, troca e devolução. Os status possíveis da nota fiscal e suas regras de transição estão padronizados na Seção 1.

**Regras:**
- A nota fiscal deverá estar vinculada à venda, utilizando os dados cadastrados do cliente (RN-01) e do aparelho (RN-02).
- A emissão deverá ocorrer conforme as regras fiscais aplicáveis, iniciando com status Aguardando emissão.
- O sistema deverá registrar o número e a chave de acesso da nota fiscal, quando disponíveis, e permitir consultar seu status (Aguardando emissão, Emitida, Pendente ou Cancelada — ver Seção 1).
- Em caso de cancelamento (RN-11) dentro do prazo legal da SEFAZ para cancelamento direto (via de regra, até 24 horas da emissão), a nota fiscal de venda deverá passar para o status Cancelada. Fora desse prazo, a nota de venda permanece Emitida e o cancelamento segue o mesmo procedimento fiscal da devolução (nota de entrada).
- Em caso de devolução (RN-13 — arrependimento, ou RN-14 — defeito), o sistema deverá emitir uma Nota Fiscal de Entrada (devolução), referenciando a NF-e de venda original, para desfazer fiscalmente a operação. A liberação do estorno (RN-17) só deverá ocorrer quando essa nota de devolução atingir o status Emitida.
- Em caso de troca por defeito (RN-12), o sistema deverá emitir duas notas: (1) uma Nota Fiscal de Entrada (devolução), referenciando a NF-e original, para o aparelho defeituoso devolvido; e (2) uma nova Nota Fiscal de Saída para o aparelho de reposição. Quando não houver diferença de valor entre os aparelhos, a nova nota é emitida sem cobrança adicional ao cliente.
- Caso ocorra erro na emissão de qualquer nota (venda, devolução ou reposição), ela permanece com status Pendente, o usuário deverá ser informado, e a venda correspondente fica sinalizada como "nota fiscal pendente" até a regularização; nesse caso, o estorno ou a saída do aparelho de reposição também ficam retidos até que a nota atinja o status Emitida.

**Resultado esperado:**
Garantir que todas as vendas e movimentações de pós-venda — incluindo cancelamento, troca e devolução — sejam devidamente documentadas fiscalmente antes da liberação do respectivo estorno ou da saída do aparelho de reposição.



### RN-19 — Comissão de Vendedores — Não Aplicável

**Módulo:** Financeiro

**Descrição:**
O sistema não possuirá controle de comissão de vendedores, pois o modelo de negócio é de e-commerce, sem vendedor associado à venda.

**Regras:**
- Não haverá cálculo nem lançamento financeiro de comissão.
- O sistema poderá registrar o usuário responsável por atendimentos de pós-venda apenas para fins de auditoria (ver RN-21), sem gerar comissão.

**Resultado esperado:**
Manter o módulo financeiro simplificado, coerente com a ausência de vendedores no modelo de e-commerce.



## Módulo 8 — Histórico, Auditoria e Acesso

### RN-20 — Histórico do Cliente

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



### RN-21 — Auditoria das Operações

**Módulo:** Histórico

**Descrição:**
Operações importantes realizadas no sistema deverão possuir registro para auditoria.

**Regras:**
- Registrar usuário responsável, data e hora, operação realizada, venda afetada, aparelho afetado e valores anteriores e novos, quando aplicável.
- Auditar principalmente: alterações de preço/desconto, cancelamentos, trocas, devoluções, estornos, alterações de pagamento e alterações de estoque.

**Resultado esperado:**
Garantir rastreabilidade de todas as operações relevantes realizadas no ERP.




### RN-22 — Perfis de Acesso e Autorizações

**Módulo:** Histórico

**Descrição:**
O sistema deverá definir perfis de acesso que determinam quais usuários podem executar operações sensíveis, como cancelamentos, aprovações de troca/devolução, cadastro de aparelhos e ajustes financeiros. Os perfis seguem a estrutura organizacional do negócio (ver Seção 1.1): Diretoria (2 sócios) e 4 áreas operacionais com 8 colaboradores (Vendas e Atendimento, Estoque e Logística, Assistência Técnica e Financeiro/Administrativo).

**Regras:**
- São definidos 2 níveis hierárquicos de acesso: Nível 1 — Operacional (um perfil por área, para os 8 colaboradores) e Nível 2 — Estratégico (perfil único da Diretoria, para os 2 sócios).
- Cada colaborador recebe o perfil operacional correspondente à sua área; os sócios recebem o perfil de Diretoria, com acesso a todas as áreas.
- O perfil de Diretoria é o único autorizado a criar, editar ou remover perfis de acesso (esta própria regra) e a autorizar exceções fora do fluxo automático em qualquer área.
- Toda ação que exigir autorização deverá registrar o usuário autorizador, seu perfil e a área correspondente (ver RN-21).
- O sistema deverá impedir que usuários sem o perfil adequado executem operações fora de sua área ou nível de autorização.

**Resultado esperado:**
Fechar a lacuna de definição de quem é o "usuário autorizado"/"usuário responsável" citado em várias regras do documento original, com uma estrutura de perfis compatível com o tamanho da empresa (2 sócios e 8 colaboradores).



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

| Entidade | Relação | Entidade |
|---|---|---|
| **CLIENTE** | POSSUI | **ENDEREÇO** |
| **CLIENTE** | EFETUA | **PEDIDO** |
| **PEDIDO** | EMITE | **NOTA FISCAL** |
| **PEDIDO** | RECEBE | **PAGAMENTO** |
| **PEDIDO** | CONTEM | **ITEM_PEDIDO** |
| **PEDIDO** | SEPARA | **SEPARAÇÃO** |
| **SEPARAÇÃO** | ENVIA | **ENTREGA** |
| **ITEM_PEDIDO** | IDENTICA | **APARELHO** |
| **APARELHO** | MOVIMENTA | **ESTOQUE** |
| **ESTOQUE** | REGISTRA | **USUARIO** |
| **USUARIO** | AUDITA | **LOG_AUDITORIA** |



## 12. Atributos



## 13. Relacionamentos

| # | Entidade | Relação | Entidade |
|---|---|---|---|
| 1 | CLIENTE | **POSSUI** | ENDEREÇO |
| 2 | CLIENTE | **EFETUA** | PEDIDO |
| 3 | PEDIDO | **EMITE** | NOTA FISCAL |
| 4 | PEDIDO | **RECEBE** | PAGAMENTO |
| 5 | PEDIDO | **CONTEM** | ITEM_PEDIDO |
| 6 | PEDIDO | **SEPARA** | SEPARAÇÃO |
| 7 | SEPARAÇÃO | **ENVIA** | ENTREGA |
| 8 | ITEM_PEDIDO | **IDENTICA** | APARELHO |
| 9 | APARELHO | **MOVIMENTA** | ESTOQUE |
| 10 | ESTOQUE | **REGISTRA** | USUARIO |
| 11 | USUARIO | **AUDITA** | LOG_AUDITORIA |


## 14. Cardinalidades

### 1. Cliente – Endereço
- **Descrição:** 1 Cliente **possui** N endereços
- **Notação:** CLIENTE (1,N) — possui — ENDEREÇO (1,1)

### 2. Cliente – Pedido
- **Descrição:** 1 Cliente **efetua** N pedidos
- **Notação:** CLIENTE (1,N) — efetua — PEDIDO (1,1)

### 3. Pedido – Pagamento
- **Descrição:** 1 Pedido **recebe** 1 pagamento
- **Notação:** PEDIDO (1,1) — recebe — PAGAMENTO (1,1)

### 4. Pedido – Nota Fiscal
- **Descrição:** 1 Pedido **emite** 1 nota fiscal
- **Notação:** PEDIDO (1,1) — emite — NOTA FISCAL (1,1)

### 5. Pedido – Separação
- **Descrição:** 1 Pedido **direcionado** 1 separação
- **Notação:** PEDIDO (1,1) — direcionado — SEPARAÇÃO (1,1)

### 6. Separação – Entrega
- **Descrição:** 1 Separação **envia** 1 entrega
- **Notação:** SEPARAÇÃO (1,1) — envia — ENTREGA (1,1)

### 7. Pedido – Item do Pedido
- **Descrição:** 1 Pedido **contém** N itens pedido
- **Notação:** PEDIDO (1,N) — contém — ITEM_PEDIDO (1,1)

### 8. Item do Pedido – Aparelho
- **Descrição:** N itens pedido **identifica** 1 aparelho
- **Notação:** ITEM_PEDIDO (1,1) — identifica — APARELHO (1,1)

### 9. Aparelho – Estoque
- **Descrição:** 1 aparelho **movimenta** N estoque
- **Notação:** APARELHO (1,N) — movimenta — ESTOQUE (1,1)

### 10. Estoque – Usuário
- **Descrição:** N estoque **registra** 1 usuário
- **Notação:** ESTOQUE (N,1) — registra — USUÁRIO (1,N)

### 11. Usuário – Log de Auditoria
- **Descrição:** 1 usuário **audita** N log auditoria
- **Notação:** USUÁRIO (1,N) — audita — LOG_AUDITORIA (1,1)


## 15. Dicionário de Dados Conceitual



## 16. DER



## 17. Justificativas Técnicas



## 18. Conclusão
