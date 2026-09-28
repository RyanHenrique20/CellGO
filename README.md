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

**Processos de Venda em sequência**

Cliente → Login/Cadastro → Escolha do aparelho → Verificação de disponibilidade → Escolha da forma de pagamento (Pix, cartão de crédito em até 12x ou boleto) → Apresentação do valor final (desconto no Pix ou valor das parcelas) → Confirmação da compra e pagamento → Confirmação do pagamento e nova verificação de disponibilidade → Aparelho marcado como Vendido → Emissão da nota fiscal → Separação do pedido → Envio pela transportadora (Em transporte) → Rastreamento → Entrega ao cliente (Entregue)

**Se o aparelho estiver indisponível na escolha:**

Verificação de disponibilidade → Aparelho indisponível → Cliente é avisado → Escolha de outro aparelho

**Se o pagamento não for confirmado ou o aparelho já tiver sido vendido:**

Confirmação do pagamento e nova verificação de disponibilidade → Compra bloqueada → Cliente é avisado


**Processo de Pós-venda em sequência**

**Processo 1 — Cancelamento** (aparelho ainda não enviado, até 7 dias da compra):

Cliente → Solicitação (painel do cliente ou e-mail) → Identificação do motivo → Verificação de envio do aparelho → Aparelho não enviado → Registro do motivo → Cancelamento da nota fiscal ou emissão da nota de devolução → Estorno do valor → Avaliação do aparelho → Retorno ao estoque → Atualização do histórico do cliente → Encerramento do pós-venda

**Processo 2 — Arrependimento** (até 7 dias do recebimento):

Cliente → Solicitação (painel do cliente ou e-mail) → Identificação do motivo → Verificação de envio do aparelho → Aparelho enviado → Arrependimento → Coleta do aparelho → Recebimento (aparelho Em avaliação) → Análise técnica → Emissão da nota de devolução → Estorno do valor (7 a 15 dias) → Destino do aparelho (estoque, manutenção ou inativo) → Atualização do histórico do cliente → Encerramento do pós-venda

**Processo 3 — Troca por defeito** (até 30 dias da compra, com aparelho equivalente disponível):

Cliente → Solicitação (painel do cliente ou e-mail) → Identificação do motivo → Verificação de envio do aparelho → Aparelho enviado → Defeito → Coleta do aparelho → Recebimento (aparelho Em avaliação) → Análise técnica → Defeito confirmado, sem mau uso → Aparelho igual ou equivalente disponível → Nota de devolução do aparelho com defeito + nota do aparelho novo → Envio do aparelho novo sem custo → Destino do aparelho recebido (estoque, manutenção ou inativo) → Atualização do histórico do cliente → Encerramento do pós-venda

**Processo 4 — Devolução por defeito** (sem aparelho equivalente disponível):

Cliente → Solicitação (painel do cliente ou e-mail) → Identificação do motivo → Verificação de envio do aparelho → Aparelho enviado → Defeito → Coleta do aparelho → Recebimento (aparelho Em avaliação) → Análise técnica → Defeito confirmado, sem mau uso → Nenhum aparelho equivalente disponível → Emissão da nota de devolução → Estorno do valor (7 a 15 dias) → Destino do aparelho recebido (estoque, manutenção ou inativo) → Atualização do histórico do cliente → Encerramento do pós-venda

**Processo 5 — Recusa por mau uso:**

Cliente → Solicitação (painel do cliente ou e-mail) → Identificação do motivo → Verificação de envio do aparelho → Aparelho enviado → Defeito → Coleta do aparelho → Recebimento (aparelho Em avaliação) → Análise técnica → Mau uso identificado → Solicitação recusada → Cliente recebe o diagnóstico (sem troca e sem estorno) → Atualização do histórico do cliente → Encerramento do pós-venda


## 6. Requisitos Funcionais

**RF-01 – Cadastrar clientes** 

O sistema deve permitir o cadastro de clientes pessoa física ou pessoa jurídica.

- Pessoa física: nome completo, CPF, e-mail, telefone e endereço.
- Pessoa jurídica: nome ou razão social, CNPJ, e-mail, telefone e endereço.
- O CPF ou o CNPJ deve ser único para cada cliente.
- Deve ser possível localizar o cliente e suas vendas pelo CPF/CNPJ, pelo e-mail ou pelo número da venda.
- Os dados cadastrais podem ser atualizados pelo próprio cliente ou por um usuário autorizado.

**RF-02 – Cadastrar aparelhos** 

O sistema deve permitir o cadastro de cada aparelho, identificado individualmente pelo IMEI.

- Dados obrigatórios: modelo, marca, cor, capacidade de armazenamento, IMEI/número de série, condição (Novo ou Seminovo), preço de venda, custo de aquisição, data de entrada no estoque e status inicial.
- O IMEI/número de série deve ser único no sistema.
- A condição (Novo ou Seminovo) é obrigatória, pois define o prazo de garantia do aparelho.
- O cadastro deve indicar se o aparelho é elegível ao desconto por Pix; essa definição cabe à Diretoria.
- Para cada especificação (combinação de modelo, cor e capacidade), o sistema deve permitir configurar o Estoque Mínimo e os Limites de Dias de Giro (Atenção e Crítico). Esses parâmetros já vêm com valores padrão e só podem ser alterados pela Diretoria.
- O cadastro só pode ser feito por usuários autorizados, conforme o perfil de acesso.

**RF-03 - Controlar status do aparelho**  

O sistema deve controlar o estoque unidade por unidade, pelo IMEI, e nunca por quantidade total de um modelo.

- Cada aparelho tem seu próprio status: Disponível, Vendido, Em avaliação, Em manutenção ou Inativo.
- Somente aparelhos com status Disponível podem ser vendidos. O sistema deve impedir a venda de aparelhos inexistentes, já vendidos ou indisponíveis.
- Não há reserva de aparelhos antes da confirmação do pagamento.
- Um aparelho Vendido não volta automaticamente ao estoque.
- Toda mudança de status deve ser registrada no histórico do aparelho, com data, hora e usuário responsável.
- Contagens por modelo podem ser exibidas apenas para fins gerenciais, sem substituir o controle por IMEI.

**RF-04 - Validar disponibilidade no fechamento da venda**  

No momento da confirmação do pagamento, o sistema deve verificar novamente se o aparelho continua disponível.

- A verificação e a confirmação do pagamento devem acontecer em uma única operação, para que duas vendas nunca sejam concluídas para o mesmo aparelho.
- Se o aparelho já tiver sido vendido em outra compra, o sistema deve bloquear a nova compra e avisar o cliente.

**RF-05 - Registrar venda**  

O sistema deve registrar cada venda, ligando o cliente, o aparelho e o pagamento.

- Dados obrigatórios: cliente, aparelho(s) com IMEI/número de série, data da venda, valor do produto, desconto (quando houver), valor final, forma de pagamento e status da venda.
- Status da venda: Aberta, Aguardando pagamento, Pago, Parcialmente pago, Finalizada ou Cancelada.
- Após a confirmação do pagamento, o status do aparelho muda para Vendido.
- O sistema deve gerar um comprovante de venda.
- A venda deve ser registrada no histórico do cliente.

**RF-06 - Processar venda à vista ou parcelada** 

O sistema deve permitir que o cliente pague à vista ou parcelado.

- O parcelamento só é permitido no cartão de crédito, de 1 a 12 parcelas.
- O número de parcelas deve ser escolhido antes da confirmação da compra.
- O sistema deve calcular automaticamente o valor de cada parcela.
- Se houver juros ou taxas, eles devem ser mostrados ao cliente antes da confirmação.
- O valor total da venda deve ficar registrado, independentemente do número de parcelas.

**RF-07 - Calcular valor final da venda**  
O sistema deve calcular automaticamente o valor final da venda pela fórmula: Valor Final = Valor do Produto − Desconto + Taxas (quando houver).

- Não é permitido desconto manual. O único desconto existente é o desconto automático por Pix.
- O valor final deve ser mostrado ao cliente antes da confirmação da compra.
- Após a confirmação, o valor da venda deve ser lançado automaticamente no módulo financeiro.

**RF-08 - Aplicar desconto por Pix**  

O sistema deve aplicar o desconto automaticamente quando o pagamento for via Pix e o produto for elegível.

- Faixas de desconto: produto de até R$ 1.000,00 = 5%; de R$ 1.001,00 a R$ 2.500,00 = 7%; acima de R$ 2.500,00 = 10%.
- Não há desconto para pagamento com cartão de crédito ou boleto.
- O desconto deve ser mostrado antes da confirmação da compra. Se o produto não for elegível, o cliente também deve ser informado.
- O percentual e o valor do desconto devem ficar registrados na venda.

**RF-09 - Processar formas de pagamento** 

O sistema deve aceitar apenas Pix, cartão de crédito e boleto bancário. Cartão de débito e dinheiro não são aceitos.

- A forma de pagamento é obrigatória em toda venda.
- No cartão de crédito, deve ser informado o número de parcelas (no máximo 12).
- O sistema deve registrar o status do pagamento.
- A venda só é considerada Finalizada após a confirmação do pagamento.

**RF-10 - Processar cancelamento de venda**  

O sistema deve permitir o cancelamento da venda em até 7 dias corridos a partir da data da compra, desde que o aparelho ainda não tenha sido enviado.

- O sistema deve verificar a data da venda antes de permitir o cancelamento.
- O cancelamento só é permitido enquanto o status de entrega for Aguardando envio.
- Se o status de entrega já for Em transporte ou Entregue, a solicitação passa a ser tratada como devolução (RF-12 ou RF-13).
- O motivo do cancelamento deve ser registrado.
- Se o pagamento já tiver sido feito, o sistema deve abrir o estorno (RF-16).
- O aparelho vai para o status Em avaliação antes de voltar a ficar Disponível.
- A venda cancelada não pode ser excluída: ela permanece registrada no histórico do cliente e da venda.

**RF-11 - Processar troca por defeito coberto pela garantia**  

O sistema deve permitir a troca do aparelho por outro equivalente, em até 30 dias da compra, quando houver defeito coberto pela garantia da loja.

- A solicitação deve estar ligada à venda original e ao IMEI do aparelho.
- O aparelho deve passar por avaliação técnica (status Em avaliação) antes da decisão.
- A troca só é autorizada quando o defeito é coberto pela garantia. Danos por mau uso não dão direito à troca.
- Aparelho equivalente: (a) um aparelho do mesmo modelo, cor e capacidade; ou, se não houver, (b) o aparelho disponível mais próximo do original, com especificação e valor iguais ou superiores.
- O aparelho novo precisa estar com status Disponível no momento da troca. Não é permitido reservar aparelho nem esperar reposição de estoque.
- A troca é feita sem custo para o cliente e sem cobrança de diferença de valor.
- Se não houver aparelho equivalente disponível, o sistema deve seguir imediatamente para a devolução com restituição integral (RF-13).
- O aparelho com defeito vai para o status Em manutenção ou Inativo, conforme a avaliação.
- A troca deve ser registrada no histórico do cliente e da venda.

**RF-12 - Processar devolução por arrependimento**  

O sistema deve permitir a devolução do aparelho em até 7 dias corridos a partir do recebimento, sem necessidade de defeito, conforme o direito de arrependimento do Código de Defesa do Consumidor (art. 49).

- A devolução deve estar ligada à venda original.
- O sistema deve registrar a data e o motivo da devolução, quando o cliente informar.
- O cliente recebe a restituição integral do valor pago (RF-16), sem precisar comprovar defeito.
- O aparelho passa por avaliação (status Em avaliação), que define apenas o seu destino: volta a Disponível se estiver em boas condições, ou vai para Em manutenção ou Inativo se tiver algum dano.

**RF-13 - Processar devolução por defeito**  

O sistema deve permitir a devolução com reembolso quando houver defeito coberto pela garantia e a troca não for possível, ou quando o aparelho já tiver sido entregue no momento em que o cliente relata o problema.

- A venda pode ser localizada pelo CPF/CNPJ, pelo número da venda ou pelo IMEI.
- O aparelho deve passar por avaliação técnica (status Em avaliação).
- Se o dano for causado por mau uso, a devolução não é autorizada.
- O sistema deve registrar o diagnóstico e a decisão tomada.
- Quando aprovada, a devolução gera a restituição integral do valor pago (RF-16).
- O processo deve ficar registrado no histórico do cliente e do aparelho.

**RF-14 - Controlar garantia do aparelho**  

O sistema deve controlar a garantia de cada aparelho vendido, conforme sua condição.

- Aparelho Novo: 30 dias de garantia da loja + 1 ano de garantia do fabricante.
- Aparelho Seminovo: 30 dias de garantia da loja, sem garantia do fabricante (salvo quando o fabricante informar o contrário).
- A garantia da loja começa na data da venda.
- O sistema deve registrar as datas de início e de término da garantia e permitir consultar se ela está vigente ou encerrada.
- O aparelho deve ser identificado pelo IMEI/número de série.
- Danos por mau uso não são cobertos pela garantia da loja.
- Todas as solicitações de garantia devem ser registradas.

**RF-15 - Classificar avaliação de dano**  

O sistema deve registrar a avaliação técnica de todo aparelho com dano e definir se o caso é coberto pela garantia.

- Durante a avaliação, o aparelho fica com status Em avaliação.
- O dano deve ser classificado como: defeito de fabricação, mau uso, dano acidental ou outros.
- São exemplos de mau uso: tela quebrada por impacto, aparelho amassado, danos por líquido, alterações não autorizadas e outros danos por uso inadequado.
- Se o defeito for coberto e estiver dentro da garantia, o atendimento segue para troca (RF-11) ou devolução (RF-13).
- Se for mau uso, o sistema deve bloquear a troca e a devolução. A empresa não faz o reparo: o cliente é informado do diagnóstico e o atendimento é encerrado.

**RF-16 - Processar estorno e restituição**  

O sistema deve processar a devolução de valores ao cliente em casos de cancelamento, devolução ou troca com diferença de valor a favor do cliente.

- O estorno segue a forma de pagamento original: Pix, para a chave ou conta de origem; cartão de crédito, junto à operadora do cartão; boleto, por transferência bancária para a conta informada pelo cliente.
- O processo completo deve ser concluído em 7 a 15 dias corridos.
- O sistema deve registrar o valor, a data de abertura, o prazo-limite (data de abertura + 15 dias) e o status do estorno: Pendente, Processado ou Recusado.
- Se o prazo de 15 dias for ultrapassado, o estorno deve ser sinalizado como Atrasado e o setor Financeiro/Administrativo deve ser notificado.
- Em vendas parceladas, o estorno considera apenas as parcelas já pagas.
- Em devoluções, o estorno só é liberado depois que a nota fiscal de devolução estiver com status Emitida.

**RF-17 - Emitir nota fiscal**  

O sistema deve emitir a nota fiscal eletrônica (NF-e) das vendas e das operações de pós-venda.

- A nota deve estar ligada à venda e usar os dados do cliente e do aparelho.
- Status da nota: Aguardando emissão, Emitida, Pendente ou Cancelada.
- O sistema deve registrar o número e a chave de acesso de cada nota.
- Venda: a nota de venda é emitida junto com a confirmação do pagamento.
- Cancelamento: em até 24 horas da emissão, a nota de venda é cancelada. Depois desse prazo, ela continua Emitida e o sistema emite uma nota de entrada (devolução).
- Devolução: o sistema emite uma nota de entrada que faz referência à nota de venda original.
- Troca: o sistema emite duas notas: uma de entrada, para o aparelho com defeito, e uma de saída, para o aparelho novo, sem cobrança adicional.
- As notas de entrada e de saída de reposição não podem ser canceladas depois de emitidas.
- Erro na emissão: a nota fica Pendente, o usuário é avisado e a venda é marcada como "nota fiscal pendente". O estorno ou o envio do aparelho de reposição ficam retidos até a nota ser emitida.

**RF-18 - Manter histórico do cliente**  

O sistema deve manter o histórico completo de cada cliente, reunindo em um só lugar:

- compras realizadas e aparelhos adquiridos, com IMEI e valores;
- pagamentos, cancelamentos, trocas e devoluções;
- solicitações de garantia e seus diagnósticos;
- estornos e créditos concedidos.

**RF-19 - Registrar auditoria das operações**  

O sistema deve registrar, em toda operação importante, o usuário responsável, a data e a hora, a operação realizada, a venda e o aparelho afetados e os valores anteriores e novos, quando houver.

- Operações auditadas: alterações de preço e de desconto, cancelamentos, trocas, devoluções, estornos, alterações de pagamento e alterações de estoque.
- Também devem ser auditados os alertas de aparelhos encalhados (RF-21) e todas as etapas das requisições de compra (RF-22).
- Toda atualização do status de entrega deve registrar sua origem: integração com a transportadora ou usuário responsável (RF-23).

**RF-20 - Controlar perfis de acesso**  

O sistema deve limitar as operações de cada usuário de acordo com o seu perfil.

- Nível 1 – Operacional: um perfil para cada área (Vendas e Atendimento, Estoque e Logística, Assistência Técnica e Financeiro/Administrativo), usado pelos 8 colaboradores.
- Nível 2 – Estratégico: perfil da Diretoria, usado pelos 2 sócios, com acesso a todas as áreas.
- Somente a Diretoria pode criar, editar ou remover perfis e autorizar exceções fora do fluxo automático.
- Também são exclusivos da Diretoria: aprovar requisições de compra, ajustar os parâmetros de estoque, definir a elegibilidade ao desconto Pix e autorizar a mudança de preço de aparelhos encalhados.
- Toda ação que exige autorização deve registrar o usuário que autorizou, o seu perfil e a área.
- O sistema deve impedir que um usuário execute operações fora da sua área ou do seu nível de autorização.

**RF-21 – Controlar o tempo de estoque de cada aparelho**

O sistema deve calcular, todos os dias, há quantos dias cada aparelho Disponível está parado no estoque.

- A contagem começa na data em que o aparelho passou a ficar Disponível. Se ele voltar ao estoque depois de uma troca ou devolução, a contagem recomeça do zero.
- Classificação: Giro Normal (0 a 30 dias), Atenção/Giro Lento (31 a 60 dias) e Crítico/Encalhado (acima de 60 dias). Esses limites podem ser ajustados pela Diretoria.
- O painel de estoque deve mostrar, para cada unidade: IMEI, modelo, condição e dias parados.
- A classificação deixa de ser exibida quando o aparelho sai do status Disponível.
- Quando houver mais de uma unidade do mesmo modelo, o sistema deve sugerir a saída da mais antiga primeiro (FIFO). Essa sugestão não cria reserva.
- Quando um aparelho chegar a Crítico, o sistema deve alertar a Diretoria e o setor de Estoque e Logística, recomendando incluir o aparelho em promoção ou no desconto Pix, ou rever o seu preço (mudança autorizada somente pela Diretoria).

**RF-22 – Gerar requisição de compra pelo ponto de pedido**

O sistema deve evitar que o estoque de um modelo acabe, gerando requisições de compra automaticamente.

- O sistema deve contar os aparelhos Disponíveis de cada especificação (modelo, cor e capacidade).
- Quando essa quantidade for igual ou menor que o Estoque Mínimo, o sistema gera uma Requisição de Compra com status Aguardando Análise Financeira.
- Enquanto houver uma requisição em aberto para a mesma especificação, nenhuma nova requisição é criada.
- O Financeiro/Administrativo anexa a previsão de fluxo de caixa ou o orçamento disponível, e a requisição passa para Aguardando Aprovação da Diretoria.
- Somente a Diretoria pode aprovar ou recusar a requisição. A recusa exige o registro do motivo e não impede a abertura de uma nova requisição em uma verificação posterior.
- Dados mínimos da requisição: especificação do aparelho, quantidade atual em estoque, Estoque Mínimo, quantidade sugerida para compra, data de abertura e status.
- A requisição não reserva aparelhos e não altera o status do estoque.
- Os aparelhos comprados entram no estoque pelo cadastro individual por IMEI (RF-02).

**RF-23 – Atualizar o status de entrega pela transportadora**

O sistema deve se integrar à transportadora para atualizar automaticamente o status de entrega da venda.

- Sequência de status: Aguardando envio → Em transporte → Entregue.
- Quando a transportadora confirmar a coleta, o status muda para Em transporte; quando confirmar a entrega, muda para Entregue.
- Se a transportadora não enviar a informação em até 48 horas após o prazo previsto de despacho, o setor de Estoque e Logística pode atualizar o status manualmente, depois de confirmar o código de rastreamento.
- Toda atualização deve registrar a data, a hora e a origem (automática ou manual, com o usuário responsável).

**RF-24 – Notificar o cliente**

O sistema deve avisar o cliente, por e-mail e pelo painel do cliente, sobre os principais acontecimentos:

- compra bloqueada por falta de disponibilidade do aparelho;
- confirmação do pagamento;
- mudanças no status de entrega;
- resultado da avaliação técnica (diagnóstico);
- andamento do estorno.


## 7. Requisitos Não Funcionais

**RNF-01 - Disponibilidade**  

O sistema deve ficar disponível pelo menos 99% do tempo a cada mês.

- Manutenções programadas devem ser avisadas com antecedência e feitas, de preferência, fora do horário de maior movimento.


**RNF-02 - Segurança**  

O sistema deve proteger os dados contra vazamento e acesso indevido, cumprindo a Lei Geral de Proteção de Dados (LGPD).

- As senhas devem ser armazenadas de forma criptografada.
- A comunicação entre o usuário e o sistema deve ser protegida (HTTPS).
- Os dados pessoais dos clientes, como CPF e CNPJ, só podem ser acessados pelos perfis autorizados.
- O sistema deve coletar apenas os dados pessoais estritamente necessários.

**RNF-03 - Usabilidade (intuitivo)** 

O sistema deve ser simples e intuitivo para usuários de todos os setores.

- Um usuário novo deve conseguir realizar as operações do seu setor após um treinamento de até 1 hora.
- As telas devem seguir um padrão visual único, em português.
- As mensagens de erro devem explicar o problema e indicar como resolvê-lo.

**RNF-04 - Desempenho**  

O sistema deve responder em até 3 segundos em pelo menos 95% das operações de consulta e de fechamento da compra, incluindo a validação de disponibilidade do aparelho.

**RNF-05 - Escalabilidade (flexível)** 

O sistema deve suportar o aumento do número de clientes, aparelhos, vendas e usuários sem ultrapassar os tempos de resposta definidos no RNF-04.

- A estrutura do sistema deve permitir ampliar a capacidade sem precisar reescrevê-lo.

**RNF-06 - Confiabilidade** 

As operações críticas (fechamento da venda, estorno e troca) devem ser feitas de forma completa ou não ser feitas: se ocorrer uma falha no meio, nada é gravado pela metade.

- O sistema deve impedir que o mesmo aparelho seja vendido para dois clientes ao mesmo tempo.

**RNF-07 - Auditabilidade**  

Os registros de auditoria não podem ser alterados nem excluídos depois de gravados, por nenhum perfil, nem mesmo pela Diretoria.


**RNF-08 – Integração com sistemas externos**

O sistema deve se comunicar com os seguintes serviços externos:

- SEFAZ, para emissão e cancelamento de notas fiscais eletrônicas;
- instituições de pagamento e operadoras de cartão, para Pix, cartão de crédito, boleto e estornos;
- transportadora, para o rastreamento das entregas.


**RNF-09 – Backup**

O sistema deve fazer cópias de segurança automáticas do banco de dados todos os dias.

- As cópias devem ser guardadas em local separado do servidor principal.
- A restauração dos dados deve ser testada periodicamente.


**RNF-11 – Precisão de cálculos e prazos**

O sistema deve garantir que valores e prazos sejam calculados corretamente.

- Os valores em dinheiro devem ter 2 casas decimais e seguir uma regra única de arredondamento.
- Os prazos (24 horas e 7, 15 e 30 dias) devem ser calculados pelo horário oficial de Brasília.




## 8. Regras de Negócio

## Módulo 1 — Cadastro

### RN-01 — Cadastro de Cliente


**Descrição:** O sistema deverá permitir o cadastro dos clientes que realizam compras, mantendo os dados necessários para localizar vendas, emitir nota fiscal e processar solicitações de pós-venda. O cadastro poderá ser de pessoa física ou pessoa jurídica.

**Regras:**
- Pessoa física: o cadastro deverá conter, no mínimo, nome completo, CPF, e-mail, telefone e endereço.
- Pessoa jurídica: o cadastro deverá conter, no mínimo, nome ou razão social, CNPJ, e-mail, telefone e endereço.
- O CPF ou CNPJ deverá ser único por cliente.
- O sistema deverá permitir localizar um cliente e suas vendas por CPF/CNPJ, e-mail ou número da venda.
- Os dados cadastrais deverão poder ser atualizados pelo próprio cliente ou por usuário autorizado.

**Resultado esperado:** Garantir que todo cliente, pessoa física ou jurídica, tenha um cadastro completo o suficiente para viabilizar venda, nota fiscal, garantia e pós-venda.



### RN-02 — Cadastro de Aparelho/Produto


**Descrição:** O sistema deverá permitir o cadastro dos aparelhos disponíveis para venda, com as informações necessárias para estoque, garantia, giro/reposição e nota fiscal.

**Regras:**
- O cadastro deverá conter, no mínimo: modelo, marca, IMEI/número de série, condição (Novo ou Seminovo), preço de venda, custo de aquisição e status inicial.
- O IMEI/número de série deverá ser único no sistema.
- A condição (Novo/Seminovo) é obrigatória e determina o período de garantia aplicável (ver RN-17).
- A entrada do aparelho no estoque deverá registrar data de entrada, custo e identificador, conforme já previsto no controle de estoque (RN-03); essa data de entrada é a base do cálculo de aging individual por IMEI (RN-05), ressalvado o caso de retorno ao estoque previsto na própria RN-05.
- O cadastro de aparelhos deverá ser realizado apenas por funcionários autorizados, de acordo com seu nível de acesso (permissão) no sistema (ver RN-24).
- O sistema deverá permitir configurar, por combinação de modelo, cor e capacidade de armazenamento (a mesma combinação de especificação utilizada para identificar "aparelho equivalente" na RN-14), dois parâmetros: Estoque Mínimo (quantidade), utilizado pela RN-06 (Ponto de Pedido), e dois Limites de Dias de Giro — um para Atenção/Giro Lento e outro para Crítico/Encalhado —, utilizados pela RN-05 (Aging por IMEI). Todos os parâmetros deverão ter valores padrão pré-configurados e poderão ser ajustados pelo perfil Diretoria (RN-24).

**Resultado esperado:** Garantir que todo aparelho tenha um cadastro completo, permitindo o correto funcionamento das regras de estoque, giro, reposição, venda, garantia e nota fiscal que dependem desses dados, restrito a usuários autorizados.



## Módulo 2 — Estoque

### RN-03 — Controle de Estoque

**Descrição:** O sistema deverá controlar a disponibilidade individual de cada aparelho comercializado pela empresa, unidade a unidade, identificada univocamente pelo IMEI/número de série (RN-02), sem uso de reserva prévia à confirmação da venda e sem controle por quantidade agregada de modelo.

**Regras:**
- O controle de estoque é feito por unidade física (por IMEI), nunca por saldo agregado de modelo: cada aparelho possui seu próprio status, histórico e tempo de permanência em estoque (ver RN-05), ainda que o sistema também exiba, apenas para fins gerenciais, contagens agregadas por modelo/especificação (ver RN-06).
- Um aparelho com status Disponível poderá ser vendido.
- O sistema não realizará reserva de aparelhos antes da confirmação do pagamento da venda.
- Um aparelho com status Vendido não retorna automaticamente ao estoque.
- Toda alteração de status do aparelho deverá ser registrada no histórico do aparelho, com data, hora e usuário responsável quando aplicável.
- O sistema deverá impedir a venda de um aparelho inexistente, já vendido ou indisponível.
- Status possíveis: Disponível, Vendido, Em avaliação, Em manutenção, Inativo.

**Resultado esperado:** Evitar vendas duplicadas e garantir rastreabilidade individual dos aparelhos comercializados, por IMEI, sem depender de um mecanismo de reserva, e servindo de base para as regras de giro (RN-05) e reposição (RN-06).




### RN-04 — Validação de Disponibilidade no Fechamento da Venda

**Módulo:** Estoque

**Descrição:**
O sistema deverá validar novamente a disponibilidade do aparelho no exato momento da finalização da venda, para evitar que dois clientes concluam a compra do mesmo aparelho.

**Regras:**
- A validação de disponibilidade deverá ocorrer de forma atômica junto com a confirmação do pagamento, de modo que duas vendas não possam ser concluídas simultaneamente para o mesmo aparelho.
- Caso o aparelho já tenha sido vendido por outra transação, a nova tentativa de compra deverá ser bloqueada e o cliente informado.

**Resultado esperado:**
Evitar conflitos de estoque decorrentes da ausência de reserva prévia.


### RN-05 — Gestão de Aging por IMEI e Identificação de Encalhe

**Descrição:** O sistema deverá controlar o tempo de permanência de cada aparelho individualmente (via IMEI/número de série) no estoque, identificando unidades específicas paradas e fornecendo dados para estratégias de giro de estoque (ex.: priorização de saída FIFO).

**Regras:**
- Cálculo da idade individual: cada aparelho com status Disponível terá seu tempo de estoque calculado individualmente como a diferença entre a data atual e a data em que aquele IMEI passou a constar como Disponível (RN-02); para aparelhos que retornam ao estoque após devolução ou troca (RN-14/RN-16), a contagem reinicia a partir da data em que o aparelho retorna ao status Disponível, e não da data de entrada original no estoque.
- Classificação por status de permanência: Giro Normal (0 a 30 dias de estoque); Atenção / Giro Lento (31 a 60 dias); Crítico / Encalhado (acima de 60 dias) — faixas parametrizáveis pelos Limites de Dias de Giro configurados na RN-02.
- Visualização por unidade física: o painel de estoque deverá listar explicitamente o IMEI, o modelo, a condição (Novo/Seminovo) e os dias exatos em que aquela unidade específica está parada. A classificação de giro deixa de ser calculada e exibida quando o aparelho sai do status Disponível (venda, avaliação, manutenção ou inativação).
- Priorização na saída (sugestão FIFO): quando houver mais de uma unidade do mesmo modelo Disponível para venda, o sistema indicará/sugerirá a expedição do IMEI com maior tempo de estoque, reduzindo o risco de encalhe crônico. Trata-se apenas de uma sugestão de priorização e não cria reserva de estoque (RN-03/RN-04).
- Ações para IMEIs críticos: ao atingir o status Crítico, o sistema envia alerta para a Diretoria e para o perfil Estoque e Logística (RN-24), recomendando: (a) vinculação daquele IMEI a promoções/Desconto Pix (RN-10); e (b) reavaliação de preço de venda daquele IMEI (RN-02/RN-09), sujeita a autorização da Diretoria (RN-24).

**Resultado esperado:** Permitir que o setor de Estoque/Logística e a Diretoria identifiquem, por unidade física, quais aparelhos estão parados há mais tempo, viabilizando estratégias de giro (FIFO, promoção ou reprecificação) antes que o encalhe se torne crônico.



### RN-06 — Ponto de Pedido e Requisição de Compra

**Descrição:** O sistema deverá monitorar a quantidade de aparelhos disponíveis por modelo/especificação e gerar requisições de compra que tramitam pelo setor Financeiro e pela Diretoria ao atingir o limite mínimo de segurança.

**Regras:**
- Disparo do alerta: quando a quantidade de aparelhos com status Disponível de um determinado modelo/especificação for menor ou igual ao Estoque Mínimo configurado no cadastro (RN-02), o sistema gerará automaticamente uma Requisição de Compra com status "Aguardando Análise Financeira". Esse cálculo é uma contagem agregada, feita apenas para fins de alerta, das unidades com status Disponível de um mesmo modelo/especificação; o controle individual de cada unidade por IMEI, conforme RN-03, não é alterado nem substituído por essa contagem.
- Prevenção de duplicidade: enquanto já existir uma Requisição de Compra em aberto (status "Aguardando Análise Financeira" ou "Aguardando Aprovação da Diretoria") para um mesmo modelo/especificação, o sistema não deverá abrir uma nova requisição para esse mesmo modelo/especificação, ainda que o estoque continue igual ou abaixo do mínimo.
- Análise de viabilidade financeira: o perfil Financeiro/Administrativo (RN-24) receberá a notificação para anexar a previsão de fluxo de caixa e/ou orçamento disponível.
- Aprovação da Diretoria: após a validação financeira, a requisição passa para o status "Aguardando Aprovação da Diretoria". Somente o perfil Diretoria (RN-24) poderá aprovar ou recusar a emissão do Pedido de Compra definitivo, resultando em status "Aprovada" ou "Recusada". Uma requisição Recusada deverá registrar o motivo da recusa e não impede que uma nova requisição seja aberta automaticamente caso o estoque daquele modelo/especificação continue igual ou abaixo do Estoque Mínimo em uma verificação posterior.
- Independência do estoque: a tramitação da Requisição de Compra não realiza reserva de estoque nem altera o status dos aparelhos restantes, preservando integralmente as regras RN-03 e RN-04.
- Dados mínimos da requisição: toda Requisição de Compra deverá conter, no mínimo: modelo/especificação, quantidade atual em estoque, Estoque Mínimo configurado, quantidade sugerida para compra, data de abertura e status.
- Encerramento do ciclo: uma Requisição de Compra Aprovada dá origem a um Pedido de Compra junto ao fornecedor, fora do escopo desta regra; a chegada dos aparelhos adquiridos segue o cadastro individual por IMEI já previsto na RN-02, sem necessidade de regra adicional.
- Toda abertura, análise e decisão sobre uma Requisição de Compra deverá ser registrada para fins de auditoria (RN-23).

**Resultado esperado:** Evitar ruptura de estoque (estoque zerado) por modelo, antecipando a necessidade de reposição por meio de um fluxo formal de análise financeira e aprovação da Diretoria, sem interferir no controle individual de estoque por IMEI e sem gerar requisições duplicadas para o mesmo modelo.

## Módulo 3 — Venda

### RN-07 — Venda de Aparelho

**Descrição:** O sistema deverá permitir a realização da venda de aparelhos cadastrados no estoque, vinculando o(s) produto(s) a um cliente e registrando todas as informações financeiras da operação.

**Regras:**
- Só poderá ser realizada uma venda para um aparelho com status Disponível.
- A venda deverá possuir obrigatoriamente: cliente, aparelho(s), data da venda, valor do produto, desconto quando aplicável, valor final, forma de pagamento e status da venda.
- Após a confirmação do pagamento, o aparelho deverá ter seu status alterado para Vendido.
- O IMEI/número de série deverá ficar vinculado ao registro da venda.
- A venda deverá ser registrada no histórico do cliente (ver RN-22).
- O sistema deverá gerar um comprovante de venda.
- Status da venda: Aberta, Aguardando pagamento, Pago, Parcialmente pago, Finalizada ou Cancelada.

**Resultado esperado:** Garantir que toda venda seja registrada corretamente, vinculando cliente, aparelho, estoque e financeiro.



### RN-08 — Forma de Venda — À Vista ou Parcelada

**Regras:**
- O cliente poderá optar por compra à vista ou parcelada.
- O parcelamento é permitido apenas para pagamento via cartão de crédito, em até 12 vezes.
- O número de parcelas deverá ser informado antes da confirmação da venda.
- O sistema deverá calcular automaticamente o valor de cada parcela.

**Resultado esperado:** Permitir vendas à vista e parceladas, mantendo o controle correto dos valores e parcelas.


### RN-09 — Cálculo do Valor da Venda

**Regras:**
- Valor Final = Valor do Produto − Desconto + Taxas (quando houver).
- No modelo de e-commerce, não há desconto discricionário aplicado manualmente por um vendedor: o único desconto previsto é o desconto automático por pagamento via Pix, aplicável apenas aos produtos elegíveis (ver RN-10).
- O valor final deverá ser apresentado ao cliente antes da confirmação da venda.
- Após a confirmação, o valor da venda deverá ser registrado no módulo financeiro.

**Resultado esperado:** Garantir que o valor cobrado seja calculado corretamente e de forma consistente com o modelo de e-commerce.



### RN-10 — Desconto para Pagamento via Pix

**Regras:**
- O desconto é aplicado somente quando a forma de pagamento é Pix.
- Faixas confirmadas: produto até R$ 1.000,00 = 5%; de R$ 1.001,00 a R$ 2.500,00 = 7%; acima de R$ 2.500,00 = 10%.
- Nem todos os produtos participarão do desconto Pix: a elegibilidade de cada produto ao desconto deverá ser configurável no cadastro do aparelho (RN-02).
- Não será aplicado desconto para pagamentos via cartão de crédito ou boleto.
- O desconto deverá ser apresentado ao cliente antes da confirmação da compra, incluindo os casos em que o produto não é elegível ao desconto.
- O sistema deverá registrar o percentual e o valor do desconto na venda.

**Resultado esperado:** Controlar os descontos concedidos para pagamentos via Pix, evitando descontos indevidos em outras formas de pagamento ou em produtos não elegíveis.


### RN-11 — Formas de Pagamento

**Regras:**
- A venda deverá informar obrigatoriamente a forma de pagamento.
- Para cartão de crédito, deverá ser informado o número de parcelas (máximo 12).
- O sistema deverá registrar o status do pagamento.
- Uma venda somente será considerada Finalizada após a confirmação do pagamento, conforme a forma utilizada.
- Cartão de débito não é uma forma de pagamento aceita nesta consolidação, por decisão do negócio.

**Resultado esperado:** Garantir o controle dos pagamentos e a correta vinculação entre venda e financeiro, com as formas de pagamento efetivamente aceitas pelo e-commerce.


### RN-12 — Parcelamento

**Regras:**
- Número mínimo de parcelas: 1. Número máximo: 12.
- O sistema deverá calcular automaticamente o valor das parcelas.
- O valor total da venda deverá permanecer registrado independentemente da quantidade de parcelas.
- Caso existam juros ou taxas, estes deverão ser apresentados antes da confirmação da venda.

**Resultado esperado:** Permitir o parcelamento das vendas de forma transparente e controlada.



## Módulo 4 — Pós-venda: Cancelamento

### RN-13 — Cancelamento da Venda

**Descrição:** O sistema deverá permitir o cancelamento de uma venda no prazo de até 7 dias corridos a partir da data da venda, desde que o aparelho ainda não tenha saído para entrega.

**Regras:**
- O sistema deverá verificar a data da venda antes de permitir o cancelamento.
- O cancelamento por esta regra somente será permitido enquanto o status de entrega da venda for "Aguardando envio". A atualização desse status é feita pela integração com a API da transportadora, conforme definido na Seção 1.3.
- A partir do momento em que o status de entrega passar para "Em transporte" ou "Entregue", a solicitação do cliente deixa de ser tratada como cancelamento e passa a seguir o fluxo do Módulo 5 — Devolução (RN-15/RN-16), conforme o caso.
- O motivo do cancelamento deverá ser registrado.
- Caso o pagamento já tenha sido realizado, deverá ser aberto o processo de estorno (ver RN-19).
- Como o aparelho ainda não foi enviado, ele deverá ser diretamente direcionado a nova avaliação de estoque (status Em avaliação) antes de retornar como Disponível.
- A venda cancelada não deverá ser excluída do sistema; o cancelamento fica registrado no histórico do cliente e da venda, para fins de auditoria (ver RN-23).

**Resultado esperado:** Permitir o cancelamento dentro do prazo estabelecido e apenas antes da saída do aparelho para entrega, mantendo o histórico financeiro e de estoque e direcionando corretamente os casos pós-envio para o fluxo de devolução.


## Módulo 5 — Pós-venda: Troca e Devolução

### RN-14 — Troca por Defeito Coberto pela Garantia

**Descrição:** O sistema deverá permitir a troca de um aparelho vendido por outro equivalente, quando for identificado defeito coberto pela garantia da loja, dentro do prazo de 30 dias da compra.

**Regras:**
- A solicitação deverá estar vinculada à venda original e ao IMEI/número de série do aparelho.
- O aparelho deverá passar por avaliação técnica (status Em avaliação) antes da decisão.
- A troca somente será autorizada quando o defeito estiver coberto pela garantia da loja (RN-17).
- Danos causados por mau uso não são elegíveis para esta troca (ver RN-18).
- Considera-se "aparelho equivalente": (a) o aparelho do mesmo modelo, cor e capacidade de armazenamento do aparelho trocado; ou, na ausência deste, (b) o aparelho disponível em estoque, com especificação e valor igual ou superior, mais próximo do aparelho original.
- O novo aparelho deverá estar com status Disponível no estoque no momento da troca — não é permitido reservar ou aguardar reposição futura de estoque, em conformidade com a política de não realizar reserva de aparelhos (RN-03/RN-04).
- Caso não exista aparelho equivalente disponível, aplica-se imediatamente a política de devolução por defeito (RN-16) como alternativa, sem período de espera — ver tabela de política comercial nesta seção.
- O aparelho substituído deverá ser direcionado para Em manutenção ou Inativo, conforme avaliação.
- A troca deverá ser registrada no histórico do cliente e da venda.

**Resultado esperado:** Permitir trocas por defeito dentro do período de garantia da loja, evitando trocas decorrentes de mau uso e definindo com clareza o que fazer quando não há aparelho equivalente em estoque.

**Política comercial de troca por defeito (detalhamento da RN-14)**

| Situação | Equivalente? | Política comercial aplicada | Regras |
|---|---|---|---|
| Existe o mesmo modelo, cor e capacidade do aparelho trocado, com status Disponível. | Sim (idêntico) | Troca direta pelo aparelho idêntico, sem custo adicional ao cliente. | RN-14 |
| Não existe o mesmo modelo/cor/capacidade, mas existe aparelho de especificação e valor igual ou superior, com status Disponível. | Sim (equivalente) | Troca direta pelo aparelho equivalente disponível, sem cobrança de diferença de valor ao cliente. | RN-14 |
| Não existe nenhum aparelho idêntico nem equivalente com status Disponível no momento da solicitação. | Não | Devolução imediata com restituição integral do valor pago. Não é oferecida a opção de aguardar reposição de estoque, pois equivaleria a uma reserva de aparelho, vedada pela política de estoque (RN-03/RN-04). | RN-16 + RN-19 + RN-20 |
| Existe um aparelho equivalente, porém com status Em avaliação, Em manutenção ou Inativo (não Disponível) no momento da solicitação. | Não (indisponível) | Mesmo tratamento da situação anterior: devolução imediata com restituição integral, sem espera pela liberação desse aparelho. | RN-16 + RN-19 + RN-20 |


### RN-15 — Devolução por Arrependimento

**Descrição:** O sistema deverá permitir a devolução de um aparelho no prazo de até 7 dias corridos a partir do recebimento, independentemente de defeito, em conformidade com o direito de arrependimento previsto no Art. 49 do Código de Defesa do Consumidor para compras realizadas fora do estabelecimento comercial (e-commerce).

**Regras:**
- A devolução deverá estar vinculada à venda original.
- O sistema deverá registrar a data e o motivo da devolução, quando informado pelo cliente.
- O aparelho deverá ser devolvido em condições de revenda e passar por avaliação (status Em avaliação).
- O valor pago deverá ser integralmente restituído ao cliente (ver RN-19), sem necessidade de comprovação de defeito.
- O aparelho somente retorna ao estoque como Disponível após avaliação e aprovação; caso apresente dano, é direcionado para Em manutenção ou Inativo.

**Resultado esperado:** Garantir o cumprimento do direito de arrependimento do consumidor em compras de e-commerce, controlando devoluções sem perder o histórico da venda.


### RN-16 — Devolução por Defeito

**Descrição:** O sistema deverá permitir a devolução (com reembolso) do aparelho quando for identificado defeito coberto pela garantia, sem solução adequada por troca, ou quando o aparelho já tiver sido entregue no momento em que o cliente reporta o problema (ver RN-13).

**Regras:**
- O cliente deverá apresentar o aparelho para avaliação; a venda pode ser localizada por CPF/CNPJ, número da venda ou IMEI.
- O aparelho deverá ser submetido a avaliação técnica (status Em avaliação).
- Se o defeito for coberto pela garantia e não houver aparelho equivalente para troca (RN-14), a empresa deverá seguir o procedimento de devolução com restituição (RN-19).
- Se o problema for causado por mau uso, a devolução por esta regra não é autorizada (ver RN-18).
- O sistema deverá registrar o diagnóstico e a decisão tomada.
- O processo deverá ficar registrado no histórico do cliente e do aparelho.

**Resultado esperado:** Garantir que devoluções por defeito sejam realizadas somente quando a troca não for uma alternativa viável, mantendo a cobertura de garantia como critério central.


## Módulo 6 — Pós-venda: Garantia e Avaliação de Danos

### RN-17 — Garantia do Aparelho

**Descrição:** Todo aparelho vendido possui garantia da loja e, quando aplicável, garantia adicional do fabricante, conforme sua condição de cadastro (Novo ou Seminovo).

**Regras:**
- Aparelhos Novos: 30 dias de garantia da loja + 1 ano de garantia do fabricante, conforme condições estabelecidas pelo fabricante.
- Aparelhos Seminovos: 30 dias de garantia da loja; sem garantia adicional do fabricante, salvo quando expressamente informado pelo fabricante.
- A garantia da loja tem início na data da venda.
- O sistema deverá registrar a data de início e término da garantia e permitir consultar se está vigente ou encerrada.
- O IMEI/número de série deverá ser utilizado para identificar o aparelho.
- Danos decorrentes de mau uso não são cobertos pela garantia da loja (ver RN-18).
- O sistema deverá registrar todas as solicitações de garantia.

**Resultado esperado:** Controlar os diferentes períodos de garantia e diferenciar claramente a cobertura da loja da cobertura do fabricante.


### RN-18 — Avaliação de Dano e Elegibilidade para Cobertura

**Descrição:** Quando o aparelho apresentar dano, o sistema deverá registrar a ocorrência e determinar se o caso é coberto pela garantia ou se é caracterizado como mau uso, sem cobertura da empresa.

**Regras:**
- O aparelho deverá ser avaliado tecnicamente (status Em avaliação).
- O sistema deverá registrar o tipo de dano e classificá-lo como: defeito de fabricação, dano por mau uso, dano acidental ou outros.
- Exemplos de mau uso (não cobertos pela garantia): tela quebrada por impacto, aparelho amassado, danos por líquido não cobertos, alterações não autorizadas, outros danos por uso inadequado.
- Caso esteja dentro da garantia e seja defeito coberto, o atendimento segue as regras de garantia (RN-17) e, conforme o caso, troca (RN-14) ou devolução (RN-16).
- Caso o dano seja caracterizado como mau uso, a solicitação de troca ou devolução não será autorizada e o aparelho não será reparado pela empresa; o cliente deverá ser informado do diagnóstico e o atendimento é encerrado sem custo para a empresa.

**Resultado esperado:** Diferenciar de forma clara problemas cobertos pela garantia de danos causados por mau uso, sem que a empresa assuma qualquer serviço de reparo nesses casos.


## Módulo 7 — Financeiro e Fiscal

### RN-19 — Estorno e Restituição

**Descrição:** O sistema deverá processar estornos e restituições decorrentes de cancelamento, devolução ou troca com diferença de valor a favor do cliente.

**Regras:**
- O estorno deverá seguir a forma de pagamento original utilizada na venda.
- Pagamentos via Pix deverão ser estornados diretamente para a chave/conta de origem.
- Pagamentos via cartão de crédito deverão ser estornados junto à operadora do cartão.
- Pagamentos via boleto deverão gerar restituição por transferência bancária, mediante dados informados pelo cliente.
- O processo completo de estorno, da abertura da solicitação até a efetiva liberação do valor ao cliente, deverá ocorrer dentro do prazo de 7 a 15 dias corridos, podendo variar conforme a forma de pagamento.
- O sistema deverá registrar valor, data de abertura, prazo-limite (data de abertura + 15 dias) e status do estorno (Pendente, Processado, Recusado).
- Caso o prazo de 15 dias seja ultrapassado sem conclusão, o sistema deverá sinalizar o estorno como atrasado e notificar o perfil Financeiro/Administrativo (RN-24) para tratamento manual.
- Em vendas parceladas canceladas após pagamento de parte das parcelas, o estorno deverá considerar apenas os valores já pagos.

**Resultado esperado:** Garantir que todo valor devido ao cliente em cancelamentos, devoluções ou trocas seja restituído de forma rastreável e dentro de um prazo definido.


### RN-20 — Emissão de Nota Fiscal

**Descrição:** O sistema deverá possuir integração ou funcionalidade para emissão de nota fiscal eletrônica referente às vendas realizadas, incluindo tratamento fiscal específico para cancelamento, troca e devolução. Os status possíveis da nota fiscal e suas regras de transição estão padronizados na Seção 1.

**Regras:**
- A nota fiscal deverá estar vinculada à venda, utilizando os dados cadastrados do cliente (RN-01) e do aparelho (RN-02).
- A emissão deverá ocorrer conforme as regras fiscais aplicáveis, iniciando com status Aguardando emissão.
- O sistema deverá registrar o número e a chave de acesso da nota fiscal, quando disponíveis, e permitir consultar seu status (Aguardando emissão, Emitida, Pendente ou Cancelada).
- Em caso de cancelamento (RN-13) dentro do prazo legal da SEFAZ para cancelamento direto (via de regra, até 24 horas da emissão), a nota fiscal de venda deverá passar para o status Cancelada. Fora desse prazo, a nota de venda permanece Emitida e o cancelamento segue o mesmo procedimento fiscal da devolução (nota de entrada).
- Em caso de devolução (RN-15 — arrependimento, ou RN-16 — defeito), o sistema deverá emitir uma Nota Fiscal de Entrada (devolução), referenciando a NF-e de venda original, para desfazer fiscalmente a operação. A liberação do estorno (RN-19) só deverá ocorrer quando essa nota de devolução atingir o status Emitida.
- Em caso de troca por defeito (RN-14), o sistema deverá emitir duas notas: (1) uma Nota Fiscal de Entrada (devolução), referenciando a NF-e original, para o aparelho defeituoso devolvido; e (2) uma nova Nota Fiscal de Saída para o aparelho de reposição. Quando não houver diferença de valor entre os aparelhos, a nova nota é emitida sem cobrança adicional ao cliente.
- Caso ocorra erro na emissão de qualquer nota (venda, devolução ou reposição), ela permanece com status Pendente, o usuário deverá ser informado, e a venda correspondente fica sinalizada como "nota fiscal pendente" até a regularização.

**Resultado esperado:** Garantir que todas as vendas e movimentações de pós-venda sejam devidamente documentadas fiscalmente antes da liberação do respectivo estorno ou da saída do aparelho de reposição.


### RN-21 — Comissão de Vendedores — Não Aplicável

**Descrição:** O sistema não possuirá controle de comissão de vendedores, pois o modelo de negócio é de e-commerce, sem vendedor associado à venda.

**Regras:**
- Não haverá cálculo nem lançamento financeiro de comissão.
- O sistema poderá registrar o usuário responsável por atendimentos de pós-venda apenas para fins de auditoria (ver RN-23), sem gerar comissão.

**Resultado esperado:** Manter o módulo financeiro simplificado, coerente com a ausência de vendedores no modelo de e-commerce.


## Módulo 8 — Histórico, Auditoria e Acesso

### RN-22 — Histórico do Cliente

**Descrição:** O sistema deverá manter o histórico comercial completo de cada cliente.

**Regras:**
- Compras realizadas e aparelhos adquiridos, com IMEI/número de série e valores.
- Pagamentos, cancelamentos, trocas por defeito e devoluções.
- Solicitações de garantia e respectivos diagnósticos.
- Créditos ou estornos concedidos.

**Resultado esperado:** Permitir que a empresa tenha uma visão completa do relacionamento comercial com o cliente.


### RN-23 — Auditoria das Operações

**Descrição:** Operações importantes realizadas no sistema deverão possuir registro para auditoria.

**Regras:**
- Registrar usuário responsável, data e hora, operação realizada, venda afetada, aparelho afetado e valores anteriores e novos, quando aplicável.
- Auditar principalmente: alterações de preço/desconto, cancelamentos, trocas, devoluções, estornos, alterações de pagamento e alterações de estoque.
- Auditar também: alertas de encalhe/aging crítico por IMEI (RN-05) e o ciclo completo das Requisições de Compra (RN-06), incluindo abertura, análise financeira e decisão da Diretoria.

**Resultado esperado:** Garantir rastreabilidade de todas as operações relevantes realizadas no ERP, incluindo as novas rotinas de gestão de estoque desta revisão.


### RN-24 — Perfis de Acesso e Autorizações

**Descrição:** O sistema deverá definir perfis de acesso que determinam quais usuários podem executar operações sensíveis, como cancelamentos, aprovações de troca/devolução, cadastro de aparelhos, ajustes financeiros, alertas de gestão de estoque (aging e ponto de pedido) e requisições de compra. Os perfis seguem a estrutura organizacional do negócio (ver Seção 1.1): Diretoria (2 sócios) e 4 áreas operacionais com 8 colaboradores (Vendas e Atendimento, Estoque e Logística, Assistência Técnica e Financeiro/Administrativo).

**Regras:**
- São definidos 2 níveis hierárquicos de acesso: Nível 1 — Operacional (um perfil por área, para os 8 colaboradores) e Nível 2 — Estratégico (perfil único da Diretoria, para os 2 sócios).
- Cada colaborador recebe o perfil operacional correspondente à sua área; os sócios recebem o perfil de Diretoria, com acesso a todas as áreas.
- O perfil de Diretoria é o único autorizado a criar, editar ou remover perfis de acesso (esta própria regra) e a autorizar exceções fora do fluxo automático em qualquer área.
- Toda ação que exigir autorização deverá registrar o usuário autorizador, seu perfil e a área correspondente (ver RN-23).
- O sistema deverá impedir que usuários sem o perfil adequado executem operações fora de sua área ou nível de autorização.

**Resultado esperado:** Fechar a lacuna de definição de quem é o "usuário autorizado"/"usuário responsável" citado em várias regras do documento, com uma estrutura de perfis compatível com o tamanho da empresa (2 sócios e 8 colaboradores), agora incluindo também as novas rotinas de gestão de estoque (RN-05/RN-06).



## 9. Restrições e Políticas Organizacionais

### Política de Aquisição de Aparelhos

- **Verificação de procedência:** consultar o IMEI antes da compra, confirmando que o aparelho não consta como roubado, furtado ou com restrição.
- **Recusa de aparelhos irregulares:** não aceitar celulares com IMEI adulterado, bloqueado ou com indícios de clonagem.
- **Identificação do vendedor:** exigir documento oficial com foto e CPF de quem está vendendo o aparelho para a loja.
- **Limite de compras por CPF/dia:** cada CPF pode vender no máximo X aparelhos por dia à loja.
- **Documentação obrigatória:** emissão de nota fiscal ou termo de compra e venda, mesmo em transações entre pessoas físicas.

### Política de Avaliação Técnica

- **Checklist técnico:** avaliação obrigatória de bateria, tela, câmeras, botões, autofalante, som, conectividade e autenticidade das peças.
- **Verificação de bloqueios de conta:** checagem de bloqueio iCloud/Google (FRP), com recusa do aparelho caso não seja possível desbloquear.

### Política de Revenda

- **Reset de fábrica:** remoção de contas, dados pessoais e bloqueios (FRP/iCloud) antes de expor o aparelho para venda.
- **Prazo de quarentena:** período em que os aparelhos recebidos em troca ficam retidos, para confirmar que não haverá contestação de furto.
- **Restrição etária:** proibida a venda a menores de 18 anos sem a presença de um responsável legal.
- A comprovação da condição de responsável legal deve ser feita mediante apresentação de documento oficial com foto, como RG ou CNH, e documento que comprove o vínculo legal com o menor, como certidão de nascimento ou tutela judicial.

### Política Fiscal e Documental

- **Emissão de nota fiscal:** obrigatória para toda venda realizada.
- **Rastreabilidade por IMEI:** registro de garantia e histórico do aparelho vinculado ao número de IMEI.
- **Retenção de comprovantes:** guarda de comprovantes pelo prazo mínimo exigido pela legislação fiscal.

### Política de Proteção de Dados (LGPD)

- **Termo de responsabilidade do cliente:** declaração de que o cliente removeu contas e dados pessoais do aparelho antes da entrega à loja.
- **Minimização de dados:** não armazenamento de dados pessoais extraídos além do estritamente necessário.

### Restrições Operacionais

- **Seguro de estoque:** contratação de seguro patrimonial adequado ao valor e ao perfil do estoque, com cobertura para riscos como roubo, furto qualificado, incêndio e outros eventos previstos na apólice.
- **Controle e segregação de estoque:** os aparelhos deverão permanecer armazenados em local seguro e com acesso restrito. O estoque será dividido entre estoque disponível para venda, estoque reservado para pedidos aprovados e estoque destinado à expedição, garantindo maior controle sobre os produtos.
- **Limite de exposição do estoque:** devido ao alto valor dos aparelhos, será mantida a quantidade mínima necessária de produtos fora do local de armazenamento seguro. A movimentação dos aparelhos deverá ser registrada no sistema ou controle interno.
- **Controle de acesso:** o acesso ao estoque será restrito a colaboradores previamente autorizados, com registro das movimentações de entrada, saída e transferência dos aparelhos.
- **Conferência na expedição:** todo pedido deverá passar por conferência do modelo, cor, capacidade, número de série/IMEI e integridade do produto antes do envio ao cliente.
- **Rastreabilidade:** cada aparelho deverá ser identificado e vinculado ao respectivo registro de estoque e, quando aplicável, ao pedido realizado pelo cliente, permitindo o acompanhamento desde a entrada do produto até a entrega.

### Quem Pode Aprovar uma Operação

- **Aprovação de exceções:** qualquer operação fora do fluxo automático (cancelamento fora do prazo, troca sem aparelho equivalente, ajuste financeiro extraordinário) só pode ser autorizada pela Diretoria.
- **Aprovação de cancelamento padrão:** Vendas e Atendimento aprova cancelamento apenas dentro da janela de 7 dias corridos.
- **Aprovação de retorno ao estoque:** Estoque e Logística aprova o retorno do aparelho a "Disponível" após avaliação técnica.
- **Aprovação de troca/devolução técnica:** Assistência Técnica aprova troca ou devolução por defeito, dentro dos critérios técnicos definidos.
- **Aprovação financeira:** Financeiro/Administrativo aprova liberação de estornos e emissão de nota fiscal, dentro dos valores e prazos definidos.

### Quem Pode Alterar Cadastros

- **Cadastro de aparelho:** alteração restrita a funcionários autorizados.
- **Cadastro de cliente:** alteração permitida ao próprio cliente ou a usuário autorizado.
- **Perfis de acesso:** criação, edição ou remoção exclusiva da Diretoria.
- **Elegibilidade ao desconto Pix:** definição exclusiva da Diretoria.

### Limites de Desconto

- **Desconto manual:** não é permitido desconto discricionário aplicado por vendedor.
- **Desconto automático via Pix:** único desconto existente, calculado por faixa de valor do produto (5%, 7% ou 10%).
- 5% de desconto: produtos até R$ 1.000,00;
- 7% de desconto: produtos de R$ 1.001,00 a R$ 2.500,00;
- 10% de desconto: produtos acima de R$ 2.500,00.

### Condições de Pagamento

- **Formas aceitas:** Pix, cartão de crédito e boleto.
- **Forma não aceita:** cartão de débito.
- **Parcelamento:** permitido somente no cartão de crédito, em até 12 vezes.
- **Taxas do parcelamento:** os juros e encargos cobrados pela operadora da maquininha, quando aplicáveis, são de responsabilidade do cliente.
- **Confirmação:** venda só é finalizada após confirmação do pagamento.

## 10. Fluxogramas

### Fluxo de Venda

```mermaid
flowchart TD
    A1(["Cliente acessa a loja on-line"]):::startEnd
    B1["Faz login ou cadastro"]
    C1["Escolhe o aparelho"]
    D1{"Aparelho disponível?"}
    E1["Aparelho indisponível:<br/>cliente é avisado"]:::red
    F1["Escolhe a forma de pagamento<br/>(Pix, cartão de crédito em até 12x ou boleto)"]
    G1["Sistema mostra o valor final<br/>(desconto no Pix ou valor das parcelas)"]
    H1["Cliente confirma a compra e paga"]
    I1{"Pagamento confirmado e<br/>aparelho ainda disponível?"}
    J1["Compra bloqueada:<br/>cliente é avisado"]:::red
    K1["Aparelho é marcado como Vendido"]
    L1["Emissão da nota fiscal"]
    M1["Separação do pedido<br/>(prioriza o aparelho há mais tempo no estoque)"]
    N1["Envio pela transportadora<br/>(status: Em transporte)"]
    O1["Cliente acompanha o rastreamento"]
    P1(["Entrega ao cliente<br/>(status: Entregue)"]):::startEnd

    A1 --> B1 --> C1 --> D1
    D1 -- Não --> E1
    E1 -. escolhe outro .-> C1
    D1 -- Sim --> F1 --> G1 --> H1 --> I1
    I1 -- Não --> J1
    I1 -- Sim --> K1 --> L1 --> M1 --> N1 --> O1 --> P1

    classDef startEnd fill:#d5f5d5,stroke:#4caf50,color:#1b5e20;
    classDef red fill:#fbe0df,stroke:#e57373,color:#7a1f1f;
```


### Fluxo de Pós-venda

```mermaid
flowchart TD
    A2(["Cliente abre uma solicitação<br/>(painel do cliente ou e-mail)"]):::startEnd
    B2["Atendimento identifica o motivo"]
    C2{"O aparelho já foi enviado?"}
    D2["CANCELAMENTO<br/>(até 7 dias da compra)<br/>Registra o motivo"]:::purple
    E2["Cancela a nota fiscal<br/>ou emite nota de devolução"]
    F2["Estorno do valor ao cliente"]
    G2["Aparelho vai para avaliação<br/>e volta ao estoque"]
    H2{"Qual o motivo?"}
    I2["ARREPENDIMENTO<br/>(até 7 dias do recebimento)"]:::purple
    J2["DEFEITO<br/>(até 30 dias da compra)"]:::purple
    K2["Coleta do aparelho"]
    L2["Recebimento<br/>(aparelho fica Em avaliação)"]
    M2["Análise técnica do aparelho"]
    N2{"Arrependimento ou defeito?"}
    O2{"Foi mau uso?"}
    P2{"Há aparelho igual<br/>ou equivalente disponível?"}
    Q2["Solicitação recusada:<br/>cliente recebe o diagnóstico<br/>(sem troca e sem estorno)"]:::red
    R2["TROCA<br/>Nota de devolução do aparelho<br/>com defeito + nota do novo"]:::green2
    S2["DEVOLUÇÃO<br/>Emissão da nota de devolução"]:::green2
    T2["Envio do aparelho novo<br/>ao cliente (sem custo)"]
    U2["Estorno do valor ao cliente<br/>(de 7 a 15 dias)"]
    V2["Destino do aparelho recebido:<br/>volta ao estoque, manutenção ou inativo"]
    W2["Atualiza o histórico do cliente"]
    X2(["Encerramento do pós-venda"]):::startEnd

    A2 --> B2 --> C2
    C2 -- Não --> D2 --> E2 --> F2 --> G2 --> W2
    C2 -- Sim --> H2
    H2 --> I2 --> K2
    H2 --> J2 --> K2
    K2 --> L2 --> M2 --> N2
    N2 -- Arrependimento --> S2
    N2 -- Defeito --> O2
    O2 -- Sim --> Q2 --> W2
    O2 -- Não --> P2
    P2 -- Sim --> R2 --> T2 --> V2 --> W2
    P2 -- Não --> S2
    S2 --> U2 --> V2
    W2 --> X2

    classDef startEnd fill:#d5f5d5,stroke:#4caf50,color:#1b5e20;
    classDef purple fill:#e8dff5,stroke:#9c6ade,color:#4a2c73;
    classDef red fill:#fbe0df,stroke:#e57373,color:#7a1f1f;
    classDef green2 fill:#d9f2e1,stroke:#4caf50,color:#1b5e20;
```


## 11. Entidades

| Entidade | Relação | Entidade |
|---|---|---|
| **CLIENTE** | REALIZA | **PEDIDO** |
| **CLIENTE** | DISPÕE DE |**TELEFONE**| 
| **PEDIDO** | GERA |**PAGAMENTO** |
| **PAGAMENTO** | ORIGINA | **NOTA_FISCAL** |
| **PEDIDO** | SOFRE | **CANCELAMENTO** |
| **CANCELAMENTO** | EXIGE | **NOTA_FISCAL** |
| **CANCELAMENTO** | VIABILIZA | **ESTORNO** |
| **NOTA_FISCAL (original)** | REFERENCIA | **NOTA_FISCAL (derivada)** |
| **PEDIDO** | POSSUI | **ENTREGA** |
| **PEDIDO*** | CONTÉM | **ITEM_PEDIDO** |
| **ITEM_PEDIDO** | RECEBE | **POS_VENDA** |
| **NOTA_FISCAL** | DOCUMENTA | **POS_VENDA** |
| **POS_VENDA** | OCASIONA | **DEVOLUCAO** |
| **DEVOLUCAO** | RESULTA EM | **ESTORNO** |
| **POS_VENDA** | DESENCADEIA | **TROCA** |
| **POS_VENDA** | PASSA POR | **AVALIACAO_DANO** |
| **ITEM_PEDIDO** | CORRESPONDE A | **APARELHO** |
| **TROCA** | REPÕE | **APARELHO** |
| **TROCA** | REQUER | **ENTREGA** |
| **APARELHO** | DETÉM | **IMAGEM_APARELHO** |
| **ESPECIFICACAO_APARELHO** | CLASSIFICA | **APARELHO** |
| **MOVIMENTACAO** | MUDA | **APARELHO** |
| **ESPECIFICACAO_APARELHO** | DISPARA | **REQUISICAO_COMPRA** |
| **FUNCIONARIO** | DECIDE | **REQUISICAO_COMPRA** |
| **FUNCIONARIO** | CADASTRA | **APARELHO** |
| **FUNCIONARIO** | AVALIA | **AVALIACAO_DANO** |
| **AUDITORIA** | RASTREIA | **FUNCIONARIO** |
| **FUNCIONARIO** | AUTORIZA | **AUDITORIA** |
| **FUNCIONARIO** | EXECUTA | **MOVIMENTACAO** |



## 12. Atributos

### CLIENTE
- Cpf_Cnpj (PK)
- Nome 
- Email
- Tipo_Pessoa 
- Tipo_Endereco
- Logradouro
- Numero
- Complemento
- Bairro
- Cidade
- CEP
- Telefone(s)

### TELEFONE
- Cpf_Cnpj (PK, FK)
- ddd (PK)
- numero_telefone (PK)


### NOTA_FISCAL
- Chave nota fiscal (PK)
- Id_Pagamento (FK)
- Código_Cancelamento (FK)
- Id_PosVenda (FK)
- Chave_Nota_Referencia (FK)
- Tipo_Nota
- Natureza
- Status
- Data_Emissao

### PEDIDO (VENDA)
- Id_Pedido (PK)
- Cpf_Cnpj (FK)
- Data_Pedido
- Status_Pedido
- Forma_Pagamento 
- Numero_Parcelas 
- Valor_Produtos
- Percentual_Desconto_Pix
- Valor_Desconto
- Valor_Taxas
- Valor_Final 

### ESTORNO
- Id_Estorno (PK)
- Código_Cancelamento (FK)
- Código_Devolucao (FK)
- Valor
- Forma_Restituicao
- Dados_Bancarios 
- Data_Abertura
- Prazo_Limite 
- Data_Conclusao
- Status

### PAGAMENTO
- Id_Pagamento (PK)
- Id_Pedido (FK)
- Forma_Pagamento 
- Numero_Parcelas 
- Data_Pagamento
- Valor
- Status
- Comprovante

### CANCELAMENTO
- Código_Cancelamento (PK)
- Id_Pedido (FK)
- Data_Solicitacao
- Motivo
- Status

### ENTREGA
- Código_Rastreio (PK)
- Id_Pedido (FK)
- Código_Troca (FK) 
- Transportadora
- Status_Entrega
- Data_Despacho
- Data_Entrega
- Tipo_Envio 
- Origem_Atualizacao 

### POS_VENDA
- Id_PosVenda (PK)
- Id_Pedido (FK)
- Imei (FK)
- Tipo_Solicitacao 
- Data_Abertura
- Descricao
- Status

### ITEM_PEDIDO 
- Id_Pedido (PK, FK)
- Imei (PK, FK)
- Preco_Unitario
- Data_Inicio_Garantia
- Data_Fim_Garantia_Loja
- Data_Fim_Garantia_Fabricante

### DEVOLUCAO
- Código_Devolucao (PK)
- Id_PosVenda (FK)
- Tipo_Devolucao 
- Data_Devolucao
- Motivo
- Status

### APARELHO
- Imei (PK)
- Id_Especificacao (FK)
- Código_Funcionario (FK) 
- Condicao 
- Preco_Venda
- Custo_Aquisicao
- Status
- Data_Entrada
- Data_Disponivel
- Elegivel_Desconto_Pix

### AVALIACAO_DANO
- Código_Avaliacao (PK)
- Id_PosVenda (FK)
- Código_Funcionario (FK)
- Classificacao_Dano
- Descricao_Dano
- Cobertura_Garantia 
- Destino_Aparelho
- Data_Avaliacao

### TROCA
- Código_Troca (PK)
- Id_PosVenda (FK)
- Imei_Reposicao (FK)
- Data_Troca
- Status

### IMAGEM_APARELHO
- Id_Imagem (PK)
- Imei (FK)
- URL

### REQUISICAO_COMPRA
- Id_Requisicao (PK)
- Id_Especificacao (FK)
- Código_Funcionario (FK) 
- Qtd_Atual_Estoque
- Estoque_Minimo
- Qtd_Sugerida
- Parecer_Financeiro
- Data_Abertura
- Data_Decisao
- Motivo_Recusa
- Status

### AUDITORIA
- Id_Auditoria (PK)
- Código_Funcionario (FK)
- Key_Autorizador (FK)
- Acao
- Tabela_Afetada
- Registro_Id
- Valor_Anterior
- Valor_Novo
- Data_Hora
- Descricao

### ESPECIFICACAO_APARELHO
- Id_Especificacao (PK)
- Modelo
- Marca
- Cor
- Capacidade
- Estoque_Minimo
- Limite_Dias_Atencao
- Limite_Dias_Critico

### MOVIMENTACAO
- Número_Movimentacao (PK)
- Imei (FK)
- Código_Funcionario (FK)
- Tipo_Movimento
- Status_Anterior
- Status_Novo
- Data_Hora

### FUNCIONARIO
- Código_Funcionario (PK)
- Nome
- Cargo
- Login
- Perfil_Acesso
- Nivel_Acesso 
- Ativo

## 13. Relacionamentos

| # | Entidade | Relação | Entidade |
|---|---|---|---|
| 1 | CLIENTE | **REALIZA** | PEDIDO |
| 2  |CLIENTE| **DISPÕE DE**| TELEFONE |
| 3 | PEDIDO | **GERA** | PAGAMENTO |
| 4 | PAGAMENTO | **ORIGINA** | NOTA_FISCAL |
| 5 | PEDIDO | **SOFRE** | CANCELAMENTO |
| 6 | CANCELAMENTO | **EXIGE** | NOTA_FISCAL |
| 7 | CANCELAMENTO | **VIABILIZA** | ESTORNO |
| 8 | NOTA_FISCAL (original) | **REFERENCIA** | NOTA_FISCAL (derivada) |
| 9 | PEDIDO | **POSSUI** | ENTREGA |
| 10 | PEDIDO | **CONTÉM** | ITEM_PEDIDO |
| 11 | ITEM_PEDIDO | **RECEBE** | POS_VENDA |
| 12 | NOTA_FISCAL | **DOCUMENTA** | POS_VENDA |
| 13 | POS_VENDA | **OCASIONA** | DEVOLUCAO |
| 14 | DEVOLUCAO | **RESULTA EM** | ESTORNO |
| 15 | POS_VENDA | **DESENCADEIA** | TROCA |
| 16 | POS_VENDA | **PASSA POR** | AVALIACAO_DANO |
| 17 | ITEM_PEDIDO | **CORRESPONDE A** | APARELHO |
| 18 | TROCA | **REPÕE** | APARELHO |
| 19 | TROCA | **REQUER** | ENTREGA |
| 20 | APARELHO | **DETÉM** | IMAGEM_APARELHO |
| 21 | ESPECIFICACAO_APARELHO | **CLASSIFICA** | APARELHO |
| 22 | MOVIMENTACAO | **MUDA** | APARELHO |
| 23 | ESPECIFICACAO_APARELHO | **DISPARA** | REQUISICAO_COMPRA |
| 24 | FUNCIONARIO | **DECIDE** | REQUISICAO_COMPRA |
| 25 | FUNCIONARIO | **CADASTRA** | APARELHO |
| 26 | FUNCIONARIO | **AVALIA** | AVALIACAO_DANO |
| 27 | AUDITORIA | **RASTREIA** | FUNCIONARIO |
| 28 | FUNCIONARIO | **AUTORIZA** | AUDITORIA |
| 29 | FUNCIONARIO | **EXECUTA** | MOVIMENTACAO |


## 14. Cardinalidades

**1. Cliente – Pedido**
 - Descrição: 1 CLIENTE realiza N PEDIDOs (cada pedido pertence a exatamente 1 cliente)
 - Notação: CLIENTE (1,1) — realiza — PEDIDO (0,N)

**2.Cliente — Telefone**
 - Descrição: 1 CLIENTE dispõe de N TELEFONE (cada cliente pode ter mais de um telefone)
 - Notação: CLIENTE (1,1) — dispõe de — TELEFONE (0,N) 
 
**3. Pedido – Pagamento**
 - Descrição: 1 PEDIDO gera N PAGAMENTOs
 - Notação: PEDIDO (1,1) — gera — PAGAMENTO (0,N)
 
**4. Pagamento – Nota Fiscal**
 - Descrição: 1 PAGAMENTO origina no máximo 1 NOTA_FISCAL, e cada NOTA_FISCAL desse tipo vem de no máximo 1 PAGAMENTO
 - Notação: PAGAMENTO (0,1) — origina — NOTA_FISCAL (0,1)
 
**5. Pedido – Cancelamento**
 - Descrição: 1 PEDIDO sofre no máximo 1 CANCELAMENTO
 - Notação: PEDIDO (1,1) — sofre — CANCELAMENTO (0,1)
 
**6. Cancelamento – Nota Fiscal**
 - Descrição: 1 CANCELAMENTO exige no máximo 1 NOTA_FISCAL
 - Notação: CANCELAMENTO (0,1) — exige — NOTA_FISCAL (0,1)
 
**7. Cancelamento – Estorno**
 - Descrição: 1 CANCELAMENTO viabiliza no máximo 1 ESTORNO
 - Notação: CANCELAMENTO (0,1) — viabiliza — ESTORNO (0,1)
 
**8. Nota Fiscal (original) – Nota Fiscal (derivada)**
 - Descrição: 1 NOTA_FISCAL original referencia N NOTA_FISCAL derivadas (autorrelacionamento)
 - Notação: NOTA_FISCAL original (1,1) — referencia — NOTA_FISCAL derivada (0,N)
 
**9. Pedido – Entrega**
 - Descrição: 1 PEDIDO possui N ENTREGAs
 - Notação: PEDIDO (1,1) — possui — ENTREGA (0,N)
 
**10. Pedido – Item do Pedido**
 - Descrição: 1 PEDIDO contém N ITEM_PEDIDO (mínimo 1 item por pedido)
 - Notação: PEDIDO (1,1) — contém — ITEM_PEDIDO (1,N)
 
**11. Item do Pedido – Pós-Venda**
 - Descrição: 1 ITEM_PEDIDO recebe N solicitações de POS_VENDA
 - Notação: ITEM_PEDIDO (1,1) — recebe — POS_VENDA (0,N)
 
**12. Nota Fiscal – Pós-Venda**
 - Descrição: N NOTA_FISCAL documentam no máximo 1 POS_VENDA cada
 - Notação: NOTA_FISCAL (0,N) — documenta — POS_VENDA (0,1)
 
**13. Pós-Venda – Devolução**
 - Descrição: 1 POS_VENDA ocasiona no máximo 1 DEVOLUCAO
 - Notação: POS_VENDA (1,1) — ocasiona — DEVOLUCAO (0,1)
 
**14. Devolução – Estorno**
 - Descrição: 1 DEVOLUCAO resulta em no máximo 1 ESTORNO
 - Notação: DEVOLUCAO (0,1) — resulta em — ESTORNO (0,1)
 
**15. Pós-Venda – Troca**
 - Descrição: 1 POS_VENDA desencadeia no máximo 1 TROCA
 - Notação: POS_VENDA (1,1) — desencadeia — TROCA (0,1)
 
**16. Pós-Venda – Avaliação de Dano**
 - Descrição: 1 POS_VENDA passa por no máximo 1 AVALIACAO_DANO
 - Notação: POS_VENDA (1,1) — passa por — AVALIACAO_DANO (0,1)
 
**17. Item do Pedido – Aparelho**
 - Descrição: N ITEM_PEDIDO correspondem a exatamente 1 APARELHO cada
 - Notação: ITEM_PEDIDO (0,N) — corresponde a — APARELHO (1,1)
 
**18. Troca – Aparelho**
 - Descrição: N TROCA repõem exatamente 1 APARELHO cada (aparelho de reposição)
 - Notação: TROCA (0,N) — repõe — APARELHO (1,1)
 
**19. Troca – Entrega**
 - Descrição: 1 TROCA requer no máximo 1 ENTREGA
 - Notação: TROCA (0,1) — requer — ENTREGA (0,1)
 
**20. Aparelho – Imagem do Aparelho**
 - Descrição: 1 APARELHO detém N IMAGEM_APARELHO
 - Notação: APARELHO (1,1) — detém — IMAGEM_APARELHO (0,N)
 
**21. Especificação do Aparelho – Aparelho**
 - Descrição: 1 ESPECIFICACAO_APARELHO classifica N APARELHOs
 - Notação: ESPECIFICACAO_APARELHO (1,1) — classifica — APARELHO (0,N)
 
**22. Movimentação – Aparelho**
 - Descrição: N MOVIMENTACAO mudam exatamente 1 APARELHO cada (mínimo 1 movimentação por aparelho)
 - Notação: MOVIMENTACAO (1,N) — muda — APARELHO (1,1)
 
**23. Especificação do Aparelho – Requisição de Compra**
 - Descrição: 1 ESPECIFICACAO_APARELHO dispara N REQUISICAO_COMPRA
 - Notação: ESPECIFICACAO_APARELHO (1,1) — dispara — REQUISICAO_COMPRA (0,N)
 
**24. Funcionário – Requisição de Compra**
 - Descrição: 1 FUNCIONARIO (aprovador) decide N REQUISICAO_COMPRA
 - Notação: FUNCIONARIO (0,1) — decide — REQUISICAO_COMPRA (0,N)
 
**25. Funcionário – Aparelho**
 - Descrição: 1 FUNCIONARIO cadastra N APARELHOs
 - Notação: FUNCIONARIO (1,1) — cadastra — APARELHO (0,N)
 
**26. Funcionário – Avaliação de Dano**
 - Descrição: 1 FUNCIONARIO avalia N AVALIACAO_DANO
 - Notação: FUNCIONARIO (1,1) — avalia — AVALIACAO_DANO (0,N)
 
**27. Auditoria – Funcionário**
 - Descrição: N AUDITORIA rastreiam no máximo 1 FUNCIONARIO cada
 - Notação: AUDITORIA (0,N) — rastreia — FUNCIONARIO (0,1)
 
**28. Funcionário – Auditoria**
 - Descrição: 1 FUNCIONARIO (autorizador) autoriza N AUDITORIA
 - Notação: FUNCIONARIO (0,1) — autoriza — AUDITORIA (0,N)
 
**29. Funcionário – Movimentação**
 - Descrição: 1 FUNCIONARIO executa N MOVIMENTACAO
 - Notação: FUNCIONARIO (0,1) — executa — MOVIMENTACAO (0,N)


## 15. Dicionário de Dados Conceitual 

## 1. CLIENTE
 
Pessoa física ou jurídica que adquire aparelhos junto à loja.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Cpf_Cnpj | PK | VARCHAR | Identificador único do cliente: CPF para pessoa física ou CNPJ para pessoa jurídica. | 14 | NÃO |
| Nome | — | VARCHAR | Nome completo do cliente ou razão social, quando pessoa jurídica. | 150 | NÃO |
| Email | — | VARCHAR | Endereço de e-mail de contato do cliente. | 254 | NÃO |
| Tipo_Pessoa | — | CHAR | Indica se o cliente é pessoa física ou pessoa jurídica. | 2 | NÃO |
| Tipo_Endereco | — | VARCHAR | Classificação do endereço informado (ex.: residencial, comercial, entrega). | 20 | NÃO |
| Logradouro | — | VARCHAR | Nome da rua ou avenida do endereço do cliente. | 150 | NÃO |
| Numero | — | VARCHAR | Número do imóvel no endereço do cliente. | 10 | NÃO |
| Complemento | — | VARCHAR | Informação complementar do endereço (apartamento, bloco, etc.). | 100 | SIM |
| Bairro | — | VARCHAR | Bairro do endereço do cliente. | 100 | NÃO |
| Cidade | — | VARCHAR | Cidade do endereço do cliente. | 100 | NÃO |
| CEP | — | CHAR | Código de Endereçamento Postal do endereço do cliente. | 8 | NÃO |
 
---
 
## 2. TELEFONE
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Cpf_Cnpj | PK, FK | VARCHAR | Identifica o cliente titular do telefone | 14 | NÃO |
| DDD | PK | CHAR | Código de área do telefone, apenas dois números identificadores | 2 | NÃO |
| Número_Telefônico | PK | VARCHAR | Número de telefone apenas sem nenhum caracter especial | — | NÃO |
 

 
## 3. PEDIDO (VENDA)
 
Registra a solicitação de compra feita por um cliente, reunindo os aparelhos adquiridos e as condições comerciais da venda.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Pedido | PK | Inteiro | Identificador único do pedido. | 10 | NÃO |
| Cpf_Cnpj | FK | VARCHAR | Referencia ao cliente que realizou o pedido. | 14 | NÃO |
| Data_Pedido | — | DATETIME | Data em que o pedido foi realizado. | — | NÃO |
| Status_Pedido | — | VARCHAR | Situação atual do pedido (ex.: em andamento, concluído, cancelado). | 20 | NÃO |
| Forma_Pagamento | — | VARCHAR | Meio de pagamento escolhido para o pedido. | 10 | NÃO |
| Numero_Parcelas | — | Inteiro | Quantidade de parcelas definida para o pagamento do pedido. | 2 | NÃO |
| Valor_Produtos | — | DECIMAL | Soma dos valores dos aparelhos incluídos no pedido. | (10,2) | NÃO |
| Percentual_Desconto_Pix | — | DECIMAL | Percentual de desconto concedido para pagamento via Pix. | (5,2) | SIM |
| Valor_Desconto | — | DECIMAL | Valor total de desconto aplicado ao pedido. | (10,2) | SIM |
| Valor_Taxas | — | DECIMAL | Valor total de taxas incidentes sobre o pedido. | (10,2) | SIM |
| Valor_Final | Derivado | DECIMAL | Valor total do pedido após aplicação de descontos e taxas. | (10,2) | NÃO |
 

 
## 4. ITEM_PEDIDO
 
Associa um pedido a um aparelho específico vendido, registrando o preço praticado e a garantia daquele item.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Pedido | PK, FK | Inteiro | Referencia o PEDIDO ao qual o item pertence. | 10 | NÃO |
| Imei | PK, FK | CHAR | Referencia o APARELHO vendido nesse item do pedido. | 15 | NÃO |
| Preco_Unitario | — | DECIMAL | Preço de venda do aparelho praticado naquele pedido. | (10,2) | NÃO |
| Data_Inicio_Garantia | — | DATETIME | Data de início da garantia do aparelho vendido. | — | NÃO |
| Data_Fim_Garantia_Loja | — | DATETIME | Data de término da garantia oferecida pela loja. | — | NÃO |
| Data_Fim_Garantia_Fabric | — | DATETIME | Data de término da garantia oferecida pelo fabricante. | — | NÃO |
 

 
## 5. PAGAMENTO
 
Registra a efetivação do pagamento referente a um pedido.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Pagamento | PK | Inteiro | Identificador único do pagamento. | 10 | NÃO |
| Id_Pedido | FK | Inteiro | Referencia o PEDIDO ao qual o pagamento se refere. | 10 | NÃO |
| Forma_Pagamento | — | VARCHAR | Meio efetivamente utilizado para o pagamento. | 10 | NÃO |
| Numero_Parcelas | — | Inteiro | Quantidade de parcelas efetivamente praticadas no pagamento. | 2 | NÃO |
| Data_Pagamento | — | DATETIME | Data em que o pagamento foi efetuado. | — | SIM |
| Valor | — | DECIMAL | Valor monetário pago. | (10,2) | NÃO |
| Status | — | VARCHAR | Situação do pagamento (ex.: aprovado, pendente, recusado). | 20 | NÃO |
| Comprovante | — | VARCHAR | Referência ou identificação do comprovante de pagamento. | 100 | SIM |
 

 
## 6. NOTA_FISCAL
 
Documento fiscal emitido em decorrência de um pagamento, cancelamento ou atendimento pós-venda.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Chave_Nota_Fiscal | PK | CHAR | Chave de acesso única da nota fiscal. | 44 | NÃO |
| Id_Pagamento | FK | Inteiro | Referencia o PAGAMENTO associado à nota fiscal. | 10 | SIM |
| Codigo_Cancelamento | FK | VARCHAR | Referencia o CANCELAMENTO associado à nota fiscal, quando houver. | 20 | SIM |
| Id_PosVenda | FK | Inteiro | Referencia o POS_VENDA associado à nota fiscal, quando houver. | 10 | SIM |
| Chave_Nota_Referencia | FK | CHAR | Referencia a própria NOTA_FISCAL original, quando a nota emitida for de devolução ou complementar. | 44 | SIM |
| Tipo_Nota | — | VARCHAR | Classificação da nota fiscal (ex.: venda, devolução). | 20 | NÃO |
| Natureza | — | VARCHAR | Natureza da operação fiscal registrada. | 60 | NÃO |
| Status | — | VARCHAR | Situação atual da nota fiscal. | 20 | NÃO |
| Data_Emissao | — | DATETIME | Data de emissão da nota fiscal. | — | NÃO |
 

 
## 7. CANCELAMENTO
 
Registra a solicitação de cancelamento de um pedido.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Cancelamento | PK | VARCHAR | Identificador único do cancelamento. | 20 | NÃO |
| Id_Pedido | FK | Inteiro | Referencia o PEDIDO cancelado. | 10 | NÃO |
| Data_Solicitacao | — | DATETIME | Data em que o cancelamento foi solicitado. | — | NÃO |
| Motivo | — | VARCHAR | Justificativa apresentada para o cancelamento. | 255 | NÃO |
| Status | — | VARCHAR | Situação atual do cancelamento. | 20 | NÃO |
 

 
## 8. ESTORNO
 
Registra a devolução de valores ao cliente decorrente de um cancelamento de pedido ou de uma devolução de aparelho.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Estorno | PK | Inteiro | Identificador único do estorno. | 10 | NÃO |
| Codigo_Cancelamento | FK | VARCHAR | Referencia o CANCELAMENTO que originou o estorno, quando aplicável. | 20 | SIM |
| Codigo_Devolucao | FK | VARCHAR | Referencia a DEVOLUCAO que originou o estorno, quando aplicável. | 20 | SIM |
| Valor | — | DECIMAL | Valor a ser restituído ao cliente. | (10,2) | NÃO |
| Forma_Restituicao | — | VARCHAR | Meio pelo qual o valor será devolvido ao cliente. | 20 | NÃO |
| Dados_Bancarios | — | VARCHAR | Informações bancárias necessárias quando a restituição for realizada por meio que exija dados bancários. | 255 | SIM |
| Data_Abertura | — | DATETIME | Data de abertura do processo de estorno. | — | NÃO |
| Prazo_Limite | Derivado | DATETIME | Data limite calculada para conclusão do estorno. | — | NÃO |
| Data_Conclusao | — | DATETIME | Data em que o estorno foi efetivamente concluído. | — | SIM |
| Status | — | VARCHAR | Situação atual do estorno. | 20 | NÃO |
 

 
## 9. ENTREGA
 
Registra o envio e o rastreamento de um pedido ou de uma reposição decorrente de uma troca.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Rastreio | PK | VARCHAR | Identificador único de rastreamento da entrega. | 30 | NÃO |
| Id_Pedido | FK | Inteiro | Referencia o PEDIDO ao qual a entrega se refere. | 10 | NÃO |
| Codigo_Troca | FK | VARCHAR | Referencia a TROCA que originou uma entrega de reposição, quando aplicável. | 20 | SIM |
| Transportadora | — | VARCHAR | Empresa responsável pelo transporte da entrega. | 100 | NÃO |
| Status_Entrega | — | VARCHAR | Situação atual da entrega. | 20 | NÃO |
| Data_Despacho | — | DATETIME | Data em que a entrega foi despachada. | — | SIM |
| Data_Entrega | — | DATETIME | Data em que a entrega foi efetivamente concluída. | — | SIM |
| Tipo_Envio | — | VARCHAR | Indica se a entrega refere-se a uma venda ou a uma reposição de troca. | 10 | NÃO |
| Origem_Atualizacao | — | VARCHAR | Indica se a atualização do status da entrega foi feita automaticamente (API) ou manualmente. | 10 | NÃO |
 
 
## 10. POS_VENDA
 
Registra uma solicitação de atendimento pós-venda relacionada a um item comprado, como garantia ou arrependimento.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_PosVenda | PK | Inteiro | Identificador único da solicitação de pós-venda. | 10 | NÃO |
| Id_Pedido | FK | Inteiro | Referencia o PEDIDO relacionado à solicitação. | 10 | NÃO |
| Imei | FK | CHAR | Referencia o APARELHO objeto da solicitação. | 15 | NÃO |
| Tipo_Solicitacao | — | VARCHAR | Natureza da solicitação de pós-venda registrada. | 15 | NÃO |
| Data_Abertura | — | DATETIME | Data de abertura da solicitação. | — | NÃO |
| Descricao | — | VARCHAR | Detalhamento da solicitação registrada pelo cliente. | 500 | NÃO |
| Status | — | VARCHAR | Situação atual da solicitação. | 20 | NÃO |
 

 
## 11. DEVOLUCAO
 
Registra a devolução de um aparelho decorrente de uma solicitação de pós-venda.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Devolucao | PK | VARCHAR | Identificador único da devolução. | 20 | NÃO |
| Id_PosVenda | FK | Inteiro | Referencia o POS_VENDA que originou a devolução. | 10 | NÃO |
| Tipo_Devolucao | — | VARCHAR | Motivo classificatório da devolução. | 15 | NÃO |
| Data_Devolucao | — | DATETIME | Data em que a devolução foi realizada. | — | NÃO |
| Motivo | — | VARCHAR | Justificativa detalhada da devolução. | 255 | NÃO |
| Status | — | VARCHAR | Situação atual da devolução. | 20 | NÃO |
 

 
## 12. AVALIACAO_DANO
 
Registra a avaliação técnica realizada sobre um aparelho no contexto de uma solicitação de pós-venda.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Avaliacao | PK | VARCHAR | Identificador único da avaliação de dano. | 20 | NÃO |
| Id_PosVenda | FK | Inteiro | Referencia o POS_VENDA ao qual a avaliação se refere. | 10 | NÃO |
| Codigo_Funcionario | FK | VARCHAR | Referencia o FUNCIONARIO responsável pela avaliação. | 20 | NÃO |
| Classificacao_Dano | — | VARCHAR | Classificação do dano identificado no aparelho. | 50 | NÃO |
| Descricao_Dano | — | VARCHAR | Detalhamento textual do dano constatado. | 500 | NÃO |
| Cobertura_Garantia | — | CHAR | Indica se o dano está coberto pela garantia. | 03 | NÃO |
| Destino_Aparelho | — | VARCHAR | Encaminhamento definido para o aparelho após a avaliação. | 50 | NÃO |
| Data_Avaliacao | — | DATETIME | Data em que a avaliação foi realizada. | — | NÃO |
 

 
## 13. TROCA
 
Registra a troca de um aparelho por outro em decorrência de uma solicitação de pós-venda.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Troca | PK | VARCHAR | Identificador único da troca. | 20 | NÃO |
| Id_PosVenda | FK | Inteiro | Referencia o POS_VENDA que originou a troca. | 10 | NÃO |
| Imei_Reposicao | FK | CHAR | Referencia o APARELHO utilizado como reposição na troca. | 15 | NÃO |
| Data_Troca | — | DATETIME | Data em que a troca foi realizada. | — | NÃO |
| Status | — | VARCHAR | Situação atual da troca. | 20 | NÃO |
 

 
## 14. APARELHO
 
Representa uma unidade física de celular controlada pela loja, desde a entrada em estoque até a venda.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Imei | PK | CHAR | Identificador único internacional do aparelho. | 15 | NÃO |
| Id_Especificacao | FK | Inteiro | Referencia a ESPECIFICACAO_APARELHO correspondente ao modelo do aparelho. | 10 | NÃO |
| Codigo_Funcionario | FK | VARCHAR | Referencia o FUNCIONARIO responsável pelo cadastro do aparelho. | 20 | NÃO |
| Condicao | — | VARCHAR | Estado de conservação do aparelho. | 10 | NÃO |
| Preco_Venda | — | DECIMAL | Preço de venda estabelecido para o aparelho. | (10,2) | NÃO |
| Custo_Aquisicao | — | DECIMAL | Custo de aquisição do aparelho pela loja. | (10,2) | NÃO |
| Status | — | VARCHAR | Situação atual do aparelho (ex.: disponível, vendido, em avaliação). | 20 | NÃO |
| Data_Entrada | — | DATETIME | Data de entrada do aparelho no estoque. | — | NÃO |
| Data_Disponivel | — | DATETIME | Data em que o aparelho ficou disponível para venda. | — | SIM |
| Elegivel_Desconto_Pix | — | CHAR | Indica se o aparelho é elegível ao desconto por pagamento via Pix. | 03 | NÃO |
 

 
## 15. IMAGEM_APARELHO
 
Armazena as fotografias associadas a um aparelho cadastrado.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Imagem | PK | Inteiro | Identificador único da imagem. | 10 | NÃO |
| Imei | FK | CHAR | Referencia o APARELHO fotografado. | 15 | NÃO |
| URL | — | VARCHAR | Endereço eletrônico onde a imagem está armazenada. | 500 | NÃO |
 

 
## 16. ESPECIFICACAO_APARELHO
 
Descreve o modelo de referência dos aparelhos, com suas características técnicas e parâmetros de controle de estoque.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Especificacao | PK | Inteiro | Identificador único da especificação de aparelho. | 10 | NÃO |
| Modelo | — | VARCHAR | Nome do modelo do aparelho. | 100 | NÃO |
| Marca | — | VARCHAR | Fabricante do aparelho. | 50 | NÃO |
| Cor | — | VARCHAR | Cor do aparelho. | 30 | NÃO |
| Capacidade | — | VARCHAR | Capacidade de armazenamento do aparelho. | 20 | NÃO |
| Estoque_Minimo | — | Inteiro | Quantidade mínima definida em estoque para esse modelo. | 5 | NÃO |
| Limite_Dias_Atencao | — | Inteiro | Prazo, em dias, que caracteriza nível de atenção quanto ao estoque do modelo. | 5 | NÃO |
| Limite_Dias_Critico | — | Inteiro | Prazo, em dias, que caracteriza nível crítico quanto ao estoque do modelo. | 5 | NÃO |
 

 
## 17. REQUISICAO_COMPRA
 
Registra a solicitação de reposição de estoque para um determinado modelo de aparelho.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Requisicao | PK | Inteiro | Identificador único da requisição de compra. | 10 | NÃO |
| Id_Especificacao | FK | Inteiro | Referencia a ESPECIFICACAO_APARELHO cujo estoque está sendo requisitado. | 10 | NÃO |
| Codigo_Funcionario | FK | VARCHAR | Referencia o FUNCIONARIO responsável pela aprovação da requisição. | 20 | SIM |
| Qtd_Atual_Estoque | — | Inteiro | Quantidade em estoque no momento da abertura da requisição. | 5 | NÃO |
| Estoque_Minimo | — | Inteiro | Quantidade mínima de referência considerada na requisição. | 5 | NÃO |
| Qtd_Sugerida | — | Inteiro | Quantidade sugerida para reposição de estoque. | 5 | NÃO |
| Parecer_Financeiro | — | VARCHAR | Avaliação do setor financeiro sobre a requisição. | 500 | SIM |
| Data_Abertura | — | DATETIME | Data de abertura da requisição. | — | NÃO |
| Data_Decisao | — | DATETIME | Data em que a requisição foi decidida (aprovada ou recusada). | — | SIM |
| Motivo_Recusa | — | VARCHAR | Justificativa registrada em caso de recusa da requisição. | 255 | SIM |
| Status | — | VARCHAR | Situação atual da requisição. | 20 | NÃO |
 

 
## 18. MOVIMENTACAO
 
Registra o histórico de mudanças de status de um aparelho.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Numero_Movimentacao | PK | Inteiro | Identificador único da movimentação. | 10 | NÃO |
| Imei | FK | CHAR | Referencia o APARELHO ao qual a movimentação se refere. | 15 | NÃO |
| Codigo_Funcionario | FK | VARCHAR | Referencia o FUNCIONARIO que realizou a movimentação. | 20 | NÃO |
| Tipo_Movimento | — | VARCHAR | Classificação do tipo de movimentação registrada. | 30 | NÃO |
| Status_Anterior | — | VARCHAR | Status do aparelho antes da movimentação. | 20 | NÃO |
| Status_Novo | — | VARCHAR | Status do aparelho após a movimentação. | 20 | NÃO |
| Data_Hora | — | DATETIME | Data e hora em que a movimentação ocorreu. | — | NÃO |
 
 
## 19. AUDITORIA
 
Registra as ações realizadas no sistema para fins de rastreabilidade e controle.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Id_Auditoria | PK | Inteiro | Identificador único do registro de auditoria. | 10 | NÃO |
| Codigo_Funcionario | FK | VARCHAR | Referencia o FUNCIONARIO que executou a ação registrada. | 20 | NÃO |
| Key_Autorizador | FK | VARCHAR | Referencia o FUNCIONARIO que autorizou a ação registrada. | 20 | SIM |
| Acao | — | VARCHAR | Tipo de ação realizada no sistema. | 50 | NÃO |
| Tabela_Afetada | — | VARCHAR | Nome da entidade/tabela afetada pela ação. | 50 | NÃO |
| Registro_Id | — | VARCHAR | Identificador do registro afetado pela ação. | 50 | NÃO |
| Valor_Anterior | — | VARCHAR | Valor do dado antes da alteração registrada. | 500 | SIM |
| Valor_Novo | — | VARCHAR | Valor do dado após a alteração registrada. | 500 | SIM |
| Data_Hora | — | DATETIME | Data e hora em que a ação foi registrada. | — | NÃO |
| Descricao | — | VARCHAR | Detalhamento textual da ação registrada. | 500 | SIM |
 

 
## 20. FUNCIONARIO
 
Representa o colaborador da empresa que executa operações e atendimentos registrados no sistema.
 
| Nome do campo | Chave | Tipo do dado | Descrição/Regra de negócio | Tamanho/precisão | Nulo? |
|---|---|---|---|---|---|
| Codigo_Funcionario | PK | VARCHAR | Identificador único do funcionário. | 20 | NÃO |
| Nome | — | VARCHAR | Nome completo do funcionário. | 150 | NÃO |
| Cargo | — | VARCHAR | Cargo ou função ocupada pelo funcionário na empresa. | 50 | NÃO |
| Login | Único | VARCHAR | Identificação de acesso do funcionário ao sistema. | 50 | NÃO |
| Perfil_Acesso | — | VARCHAR | Perfil de permissões associado ao funcionário no sistema. | 30 | NÃO |
| Nivel_Acesso | — | Inteiro | Nível de permissão de acesso do funcionário. | 1 ou 2 | NÃO |
| Ativo | — | CHAR | Indica se o funcionário está atualmente ativo na empresa. | 3 | NÃO |



## 16. DER

```mermaid
flowchart TD
    classDef entity fill:#e6f1fb,stroke:#185fa5,stroke-width:1px;
    classDef weak fill:#e6f1fb,stroke:#185fa5,stroke-width:3px;
    classDef rel fill:#ffffff,stroke:#555555,stroke-width:1px;
    classDef relid fill:#ffffff,stroke:#555555,stroke-width:3px;
 
    CLIENTE[CLIENTE]
    TELEFONE[TELEFONE]
    PEDIDO[PEDIDO]
    ENTREGA[ENTREGA]
    PAGAMENTO[PAGAMENTO]
    NOTA_FISCAL[NOTA_FISCAL]
    CANCELAMENTO[CANCELAMENTO]
    ESTORNO[ESTORNO]
    ITEM_PEDIDO[ITEM_PEDIDO]:::weak
    POS_VENDA[POS_VENDA]
    DEVOLUCAO[DEVOLUCAO]
    TROCA[TROCA]
    AVALIACAO_DANO[AVALIACAO_DANO]
    APARELHO[APARELHO]
    IMAGEM_APARELHO[IMAGEM_APARELHO]
    ESPECIFICACAO_APARELHO[ESPECIFICACAO_APARELHO]
    REQUISICAO_COMPRA[REQUISICAO_COMPRA]
    MOVIMENTACAO[MOVIMENTACAO]
    FUNCIONARIO[FUNCIONARIO]
    AUDITORIA[AUDITORIA]
 
    class CLIENTE,TELEFONE,PEDIDO,ENTREGA,PAGAMENTO,NOTA_FISCAL,CANCELAMENTO,ESTORNO,POS_VENDA,DEVOLUCAO,TROCA,AVALIACAO_DANO,APARELHO,IMAGEM_APARELHO,ESPECIFICACAO_APARELHO,REQUISICAO_COMPRA,MOVIMENTACAO,FUNCIONARIO,AUDITORIA entity
 
    CLIENTE -->|1| R1{"realiza"}
    R1 -->|0..N| PEDIDO
 
    CLIENTE -->|1| R29{"dispõe de"}
    R29 -->|0..N| TELEFONE
 
    PEDIDO -->|1| R2{"gera"}
    R2 -->|0..N| PAGAMENTO
 
    PAGAMENTO -->|0..1| R3{"origina"}
    R3 -->|0..1| NOTA_FISCAL
 
    PEDIDO -->|1| R4{"sofre"}
    R4 -->|0..1| CANCELAMENTO
 
    CANCELAMENTO -->|0..1| R5{"exige"}
    R5 -->|0..1| NOTA_FISCAL
 
    CANCELAMENTO -->|0..1| R6{"viabiliza"}
    R6 -->|0..1| ESTORNO
 
    NOTA_FISCAL -->|1| R7{"referencia"}
    R7 -->|0..N| NOTA_FISCAL
 
    PEDIDO -->|1| R8{"possui"}
    R8 -->|0..N| ENTREGA
 
    PEDIDO -->|1| R9{"contem"}
    class R9 relid
    R9 -->|1..N| ITEM_PEDIDO
 
    ITEM_PEDIDO -->|1| R10{"recebe"}
    R10 -->|0..N| POS_VENDA
 
    NOTA_FISCAL -->|0..N| R11{"documenta"}
    R11 -->|0..1| POS_VENDA
 
    POS_VENDA -->|1| R12{"ocasiona"}
    R12 -->|0..1| DEVOLUCAO
 
    DEVOLUCAO -->|0..1| R13{"resulta em"}
    R13 -->|0..1| ESTORNO
 
    POS_VENDA -->|1| R14{"desencadeia"}
    R14 -->|0..1| TROCA
 
    POS_VENDA -->|1| R15{"passa por"}
    R15 -->|0..1| AVALIACAO_DANO
 
    ITEM_PEDIDO -->|0..N| R16{"corresponde a"}
    R16 -->|1| APARELHO
 
    TROCA -->|0..N| R17{"repoe"}
    R17 -->|1| APARELHO
 
    TROCA -->|0..1| R18{"requer"}
    R18 -->|0..1| ENTREGA
 
    APARELHO -->|1| R19{"detem"}
    R19 -->|0..N| IMAGEM_APARELHO
 
    ESPECIFICACAO_APARELHO -->|1| R20{"classifica"}
    R20 -->|0..N| APARELHO
 
    MOVIMENTACAO -->|1..N| R21{"muda"}
    R21 -->|1| APARELHO
 
    ESPECIFICACAO_APARELHO -->|1| R22{"dispara"}
    R22 -->|0..N| REQUISICAO_COMPRA
 
    FUNCIONARIO -->|0..1| R23{"decide"}
    R23 -->|0..N| REQUISICAO_COMPRA
 
    FUNCIONARIO -->|1| R24{"cadastra"}
    R24 -->|0..N| APARELHO
 
    FUNCIONARIO -->|1| R25{"avalia"}
    R25 -->|0..N| AVALIACAO_DANO
 
    AUDITORIA -->|0..N| R26{"rastreia"}
    R26 -->|0..1| FUNCIONARIO
 
    FUNCIONARIO -->|0..1| R27{"autoriza"}
    R27 -->|0..N| AUDITORIA
 
    FUNCIONARIO -->|0..1| R28{"executa"}
    R28 -->|0..N| MOVIMENTACAO
 
    class R1,R2,R3,R4,R5,R6,R7,R8,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R27,R28,R29 rel
```
 
### Legenda
 
| Forma | Significado |
|---|---|
| Retângulo | Entidade |
| Retângulo de borda mais grossa | Entidade fraca (`ITEM_PEDIDO`) |
| Losango | Relacionamento |
| Losango de borda mais grossa | Relacionamento identificador (`contém`, entre `PEDIDO` e `ITEM_PEDIDO`) |
| Número na linha | Cardinalidade (`1`, `0..1`, `0..N`, `1..N`) |


## 17. Justificativas Técnicas



## 18. Conclusão
