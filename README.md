# Projeto ERP - CellGO

## 1. Identificação do Projeto

**CellGO** é o projeto de modelagem e implementação do banco de dados de um ERP para a CellGo Comércio de Celulares Ltda., empresa fictícia que vende celulares novos e seminovos pela internet.

| Item | Informação |
|---|---|
| Projeto | ERP CellGO |
| Curso | Análise e Desenvolvimento de Sistemas |
| Disciplina | Modelagem de Banco de Dados |
| Instituição | Universidade Cidade de São Paulo |
| Professor | Clovis Jose Ramos Ferraro |
| Semestre | 1º Semestre |
| SGBD | MySQL 8 |

### Organização do repositório

```
CellGO/
├── README.md                  ← este documento (porta de entrada do projeto)
├── docs/
│   ├── requisitos/            ← requisitos funcionais e não funcionais, regras de negócio e políticas
│   ├── diagramas/             ← fluxogramas, DER e modelo lógico (imagem)
│   ├── dicionario-dados/      ← dicionário de dados das 27 tabelas
│   └── normalizacao/          ← 1FN, 2FN, 3FN e campos calculados mantidos
├── sql/
│   ├── ddl/                   ← tabelas.sql e trigger.sql (estrutura do banco)
│   ├── dados/                 ← insert_validos.sql, update.sql e delete.sql
│   ├── consultas/             ← select.sql, join.sql e consultas_gerenciais.sql
│   └── auditoria/             ← auditoria.sql
├── evidencias/                ← testes das regras (triggers e validações) e documentos da Etapa 8
└── apresentacao/              ← material da apresentação final
```

Os arquivos em `docs/` são cópias das seções correspondentes deste README, separadas para facilitar a consulta. A ordem de execução dos scripts está na seção 10.

## 2. Integrantes

| Nº | Integrante |
|---:|---|
| 01 | Bernardo Farias de Jesus |
| 02 | Bruno Ferreira Gonçalves |
| 03 | Gabriely Moreira Manna |
| 04 | Henry Gonçalves dos Santos |
| 05 | João Wyctor França dos Santos |
| 06 | Murilo Alves de Sousa |
| 07 | Rafaela Teresa de Oliveira Corrente |
| 08 | Ryan Henrique de Aguiar dos Santos |
| 09 | Sarah Casas Nicolielo Ponti |
| 10 | Victor Rodrigues da Costa |

## 3. Empresa e Problema

### 3.1 Caracterização da Empresa

**Qual é o nome da empresa?**  
CellGo Comércio de Celulares Ltda.

**Qual é o segmento?**  
E-commerce de celulares novos e seminovos.

**O que ela vende ou oferece?**  
Smartphones novos, lacrados e com garantia de fábrica; smartphones seminovos, revisados e certificados, com garantia própria da loja; pagamento somente por Pix (à vista) ou cartão de crédito (de 1 a 12 parcelas); e vendas somente pelo canal on-line.

**Quem são seus principais clientes?**  
Consumidores finais (pessoa física) que buscam smartphones com procedência garantida e preço mais acessível do que o de aparelhos novos — tanto quem quer um aparelho novo quanto quem prefere um seminovo confiável em vez de comprar no mercado informal. A empresa também atende pessoa jurídica, já que o cadastro de clientes contempla CNPJ além de CPF.

**Quais são seus principais setores?**  
A empresa é organizada em cinco áreas: Diretoria (2 sócios, decisão estratégica e autorização de exceções); Vendas e Atendimento (registro de vendas e contato com o cliente); Estoque e Logística (cadastro de aparelhos, controle de disponibilidade e envio); Assistência Técnica (avaliação de aparelhos, diagnóstico de defeitos e garantia); e Financeiro/Administrativo (estornos, nota fiscal e controle de pagamentos).

**Como funciona atualmente?**  
Hoje a operação depende de controles manuais e dispersos: o cadastro de clientes e aparelhos, o controle de estoque e o acompanhamento financeiro não estão centralizados em um único sistema. Isso significa que informações como status do aparelho (disponível, vendido, em avaliação), histórico de vendas de cada cliente, prazos de garantia e pedidos de estorno acabam sendo controlados separadamente, o que dificulta saber rapidamente se um aparelho já foi vendido, se uma garantia ainda está no prazo ou se um estorno está atrasado. É justamente essa falta de integração entre vendas, estoque, pós-venda e financeiro que motiva o desenvolvimento do ERP.

**Quais informações são importantes para o negócio?**  
Dados completos do cliente (CPF/CNPJ, contato, histórico de compras); identificação única de cada aparelho por IMEI/número de série, com sua condição (novo/seminovo) e status atual; dados de cada venda (valor, forma de pagamento, parcelas, status); prazos e cobertura de garantia por aparelho; registros de trocas, devoluções e estornos com seus prazos; e trilha de auditoria de quem realizou cada operação sensível no sistema.

### 3.2 Justificativa da Escolha

Escolhemos a CellGo porque vários processos da empresa são manuais, estão espalhados e não ficam guardados em um único sistema. Isso atrapalha a atualização de informações que precisam mudar assim que um evento acontece, como, por exemplo, a venda de um aparelho e o status do estoque, o acompanhamento financeiro, os prazos de garantia, os pedidos de estorno e o histórico de compras de cada cliente.

Falta integração entre vendas, estoque, assistência técnica/pós-venda e financeiro. Isso motiva a criação de um ERP que reúna tudo em um só sistema e atualize os dados automaticamente após a venda do aparelho, evitando que um cliente compre um aparelho que não está mais em estoque, que uma garantia vencida seja aceita por engano ou que um pedido de estorno fique parado sem controle.

Esse caso é adequado para um projeto de modelagem de dados porque, além de partir de um problema real e propor uma solução para ele, permite aplicar na prática os conceitos da modelagem, como entidades, atributos, relacionamentos, cardinalidades e normalização.

### 3.3 Problemas Identificados

#### 1. Ausência de sistema único e integrado

**Situação atual:** Os cadastros de clientes, aparelhos, estoque e financeiro são feitos em várias planilhas separadas, sem uma base de dados centralizada. As vendas também não são integradas a um sistema único.

**Causa:** Cada setor (vendas, estoque, assistência técnica/pós-venda e financeiro) mantém seus próprios registros manuais, sem nenhuma conexão automática entre eles.

**Impacto no negócio:** Isso gera duplicidade de informações, obriga os funcionários a digitar os mesmos dados várias vezes (retrabalho) e deixa vendas, estoque e financeiro com informações desatualizadas, comprometendo a confiabilidade dos dados em toda a empresa.

#### 2. Falta de atualização em tempo real do estoque

**Situação atual:** O estoque é controlado em planilhas, e o status do aparelho (Disponível, Vendido, Em avaliação, Em manutenção, Inativo) não é atualizado automaticamente após uma venda.

**Causa:** A ausência de integração entre o setor de vendas e o controle de estoque faz com que a atualização dependa de uma ação manual em vez de ocorrer automaticamente.

**Impacto no negócio:** Isso provoca erros na quantidade disponível e problemas de logística, além do risco real de um cliente comprar um aparelho que já foi vendido para outra pessoa.

#### 3. Falta de histórico e controle de garantia dos aparelhos

**Situação atual:** Não existe um histórico centralizado por aparelho, nem acompanhamento dos prazos de garantia (30 dias de garantia da loja para seminovos; 30 dias da loja + 1 ano do fabricante para novos).

**Causa:** Os dados de cada aparelho (data da venda, manutenções, trocas, devoluções) não são registrados de forma estruturada e centralizada.

**Impacto no negócio:** Fica difícil acompanhar manutenções, trocas e devoluções e saber se uma solicitação ainda está dentro do prazo de garantia. Há ainda o risco de aceitar por engano uma garantia já vencida, o que gera prejuízo financeiro.

#### 4. Falta de controle sobre estornos

**Situação atual:** Os pedidos de estorno não possuem acompanhamento de prazo.

**Causa:** Não existe um fluxo estruturado que registre a data de abertura do estorno e monitore automaticamente seu andamento.

**Impacto no negócio:** Fica difícil identificar quais estornos estão pendentes, em andamento ou atrasados, o que pode prejudicar o relacionamento com o cliente e atrasar o fechamento financeiro do período.

#### 5. Financeiro desatualizado e desconectado das vendas

**Situação atual:** Os dados financeiros são mantidos separadamente dos demais setores, e o financeiro não recebe automaticamente as informações de vendas, cancelamentos, trocas e devoluções.

**Causa:** A comunicação entre o setor comercial e o financeiro depende de repasses manuais (planilhas, mensagens, anotações), em vez de uma integração direta entre os dados.

**Impacto no negócio:** Isso compromete a precisão dos dados financeiros e dificulta o acompanhamento dos resultados, o fechamento de caixa e a tomada de decisões estratégicas com base em números confiáveis.

#### 6. Processos manuais

**Situação atual:** Grande parte das tarefas operacionais do dia a dia é feita manualmente, sem apoio de automação.

**Causa:** A falta de um sistema integrado obriga os funcionários a repetir manualmente tarefas que poderiam ser automatizadas.

**Impacto no negócio:** Isso gera maior gasto de tempo dos funcionários com tarefas operacionais, reduzindo a produtividade e o tempo disponível para atividades estratégicas ou de atendimento ao cliente.

#### 7. Ausência de backup

**Situação atual:** Não existe uma rotina estruturada de backup dos dados da empresa.

**Causa:** As informações ficam armazenadas em planilhas e arquivos locais, sem um processo automático de cópia de segurança.

**Impacto no negócio:** Isso gera o risco de dados importantes serem perdidos, duplicados ou ficarem desatualizados, comprometendo a continuidade das operações em caso de falha, exclusão acidental ou perda de um arquivo.

#### 8. Ausência de relatórios

**Situação atual:** Não existem relatórios automáticos consolidados sobre vendas, estoque e resultados.

**Causa:** Como os dados estão espalhados em planilhas separadas e não integradas, não é possível gerar relatórios de forma automática e confiável.

**Impacto no negócio:** Isso faz com que os gestores tenham dificuldade para analisar vendas, estoque e resultados, prejudicando a visão estratégica do negócio e a tomada de decisões baseada em dados.

#### 9. Histórico do cliente fragmentado

**Situação atual:** As informações de cada cliente estão espalhadas entre os diferentes setores da empresa.

**Causa:** Não existe uma base de dados única que reúna compras, trocas, devoluções e acionamentos de garantia de um mesmo cliente em um só lugar.

**Impacto no negócio:** Isso dificulta o atendimento no pós-venda e na assistência técnica, pois o funcionário precisa consultar vários lugares diferentes para entender o histórico completo do cliente, tornando o atendimento mais lento e sujeito a falhas.

#### 10. Histórico de funcionários fragmentado

**Situação atual:** As informações de cada funcionário (cargo, área de atuação, permissões e operações que realizou ou autorizou) estão espalhadas entre os setores.

**Causa:** Assim como ocorre com os clientes, não há uma base de dados centralizada que reúna essas informações em um único cadastro por funcionário.

**Impacto no negócio:** Isso dificulta saber quem pode executar cada operação, quem realizou ou autorizou uma alteração sensível (preço, estorno, troca, mudança de estoque) e controlar o acesso de cada colaborador às informações da empresa.

#### 11. Falta de controle sobre a procedência dos aparelhos adquiridos

**Situação atual:** Os aparelhos seminovos comprados de pessoas físicas e os aparelhos comprados de distribuidores entram no estoque sem um registro estruturado de quem os vendeu, da consulta do IMEI, da avaliação técnica de entrada e do prazo de quarentena.

**Causa:** As políticas de aquisição (Seção 5.4) existem apenas como orientação, sem um registro no sistema que comprove que cada etapa foi cumprida.

**Impacto no negócio:** A empresa corre o risco de revender um aparelho roubado, bloqueado ou com peças adulteradas, sem conseguir provar a origem lícita do aparelho nem identificar quem o vendeu à loja.

## 4. Solução Proposta

### 4.1 Processos de Negócios

**Processo de venda em sequência**

Cliente → Login/Cadastro → Escolha do aparelho → Verificação de disponibilidade → Escolha da forma de pagamento (Pix à vista ou cartão de crédito em até 12x) → Apresentação do valor final (desconto no Pix ou valor das parcelas) → Confirmação da compra e pagamento → Confirmação do pagamento e nova verificação de disponibilidade → Aparelho marcado como Vendido → Emissão da nota fiscal → Separação do pedido → Envio pela transportadora (Em transporte) → Rastreamento → Entrega ao cliente (Entregue)

**Se o aparelho estiver indisponível na escolha:**

Verificação de disponibilidade → Aparelho indisponível → Cliente é avisado → Escolha de outro aparelho

**Se o pagamento não for confirmado ou o aparelho já tiver sido vendido:**

Confirmação do pagamento e nova verificação de disponibilidade → Compra bloqueada → Cliente é avisado

**Processos de pós-venda em sequência**

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

**Processo de aquisição de aparelhos em sequência**

Fornecedor (pessoa física ou distribuidor) oferece aparelho(s) → Identificação do fornecedor (CPF/CNPJ e documento com foto, quando pessoa física) → Verificação do limite diário por CPF (pessoa física) → Consulta do IMEI de cada aparelho → Checklist técnico de entrada e verificação de bloqueio de conta (iCloud/FRP) → Aparelho aprovado → Registro da nota fiscal ou do termo de compra e venda (e do termo de responsabilidade, quando pessoa física) → Cadastro do aparelho por IMEI → Reset de fábrica → Quarentena (somente seminovos de pessoa física) → Nova consulta do IMEI ao fim da quarentena → Aparelho Disponível

**Se o IMEI estiver irregular, o checklist reprovar ou o bloqueio de conta não puder ser removido:**

Avaliação de entrada → Aparelho recusado → Motivo da recusa registrado → Aparelho não é comprado nem cadastrado no estoque

**Se a nova consulta ao fim da quarentena apontar restrição:**

Fim da quarentena → IMEI com restrição → Aparelho Inativo → Diretoria é notificada

### 4.2 Fluxogramas

#### Fluxo de Venda

```mermaid
flowchart TD
    A1(["Cliente acessa a loja on-line"]):::startEnd
    B1["Faz login ou cadastro"]
    C1["Escolhe o aparelho"]
    D1{"Aparelho disponível?"}
    E1["Aparelho indisponível:<br/>cliente é avisado"]:::red
    F1["Escolhe a forma de pagamento<br/>(Pix à vista ou cartão de crédito em até 12x)"]
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

#### Fluxo de Pós-venda

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

#### Fluxo de Aquisição de Aparelhos

```mermaid
flowchart TD
    A3(["Fornecedor oferece aparelho(s) à loja"]):::startEnd
    B3["Identificação do fornecedor<br/>(CPF/CNPJ e documento com foto, se pessoa física)"]
    C3{"Pessoa física que já vendeu<br/>3 aparelhos hoje?"}
    D3["Compra recusada:<br/>limite diário atingido"]:::red
    E3["Consulta do IMEI"]
    F3["Checklist técnico e verificação de bloqueio iCloud/FRP<br/>(checklist não se aplica a aparelho lacrado)"]
    G3{"IMEI regular, checklist aprovado<br/>e sem bloqueio de conta?"}
    H3["Aparelho recusado:<br/>motivo registrado na avaliação de entrada"]:::red
    I3["Registro da nota fiscal ou do termo de compra e venda<br/>(e do termo de responsabilidade, se pessoa física)"]
    J3["Cadastro do aparelho por IMEI<br/>e registro do reset de fábrica"]
    K3{"Seminovo comprado<br/>de pessoa física?"}
    L3["Quarentena de 15 dias<br/>(status: Em quarentena)"]:::purple
    M3{"Nova consulta do IMEI<br/>está regular?"}
    N3["Aparelho Inativo:<br/>Diretoria é notificada"]:::red
    O3(["Aparelho Disponível para venda"]):::startEnd

    A3 --> B3 --> C3
    C3 -- Sim --> D3
    C3 -- Não --> E3 --> F3 --> G3
    G3 -- Não --> H3
    G3 -- Sim --> I3 --> J3 --> K3
    K3 -- Não --> O3
    K3 -- Sim --> L3 --> M3
    M3 -- Sim --> O3
    M3 -- Não --> N3

    classDef startEnd fill:#d5f5d5,stroke:#4caf50,color:#1b5e20;
    classDef purple fill:#e8dff5,stroke:#9c6ade,color:#4a2c73;
    classDef red fill:#fbe0df,stroke:#e57373,color:#7a1f1f;
```

## 5. Requisitos e Regras de Negócio

### 5.1 Requisitos Funcionais

**RF-01 – Cadastrar clientes** 

O sistema deve permitir o cadastro de clientes pessoa física ou pessoa jurídica.

- Pessoa física: nome completo, CPF, data de nascimento, e-mail, telefone e endereço.
- Pessoa jurídica: nome ou razão social, CNPJ, e-mail, telefone e endereço.
- O cliente pode ter mais de um telefone, e pelo menos um é obrigatório.
- Somente pessoas físicas maiores de 18 anos podem comprar (Seção 5.4).
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
- Todo aparelho deve estar ligado à aquisição de origem e à avaliação de entrada aprovada (RF-25). Não é possível cadastrar um aparelho sem procedência registrada.

**RF-03 – Controlar status do aparelho**  

O sistema deve controlar o estoque unidade por unidade, pelo IMEI, e nunca por quantidade total de um modelo.

- Cada aparelho tem seu próprio status: Em quarentena, Disponível, Vendido, Em avaliação, Em manutenção ou Inativo.
- Somente aparelhos com status Disponível podem ser vendidos. O sistema deve impedir a venda de aparelhos inexistentes, já vendidos ou indisponíveis.
- Não há reserva de aparelhos antes da confirmação do pagamento.
- Um aparelho Vendido não volta automaticamente ao estoque.
- Toda mudança de status deve ser registrada no histórico do aparelho, com data, hora e usuário responsável.
- Contagens por modelo podem ser exibidas apenas para fins gerenciais, sem substituir o controle por IMEI.

**RF-04 – Validar disponibilidade no fechamento da venda**  

No momento da confirmação do pagamento, o sistema deve verificar novamente se o aparelho continua disponível.

- A verificação e a confirmação do pagamento devem acontecer em uma única operação, para que duas vendas nunca sejam concluídas para o mesmo aparelho.
- Se o aparelho já tiver sido vendido em outra compra, o sistema deve bloquear a nova compra e avisar o cliente.

**RF-05 – Registrar venda**  

O sistema deve registrar cada venda, ligando o cliente, o aparelho e o pagamento.

- Dados obrigatórios: cliente, aparelho(s) com IMEI/número de série, data da venda, valor do produto, desconto (quando houver), valor final, forma de pagamento escolhida, número de parcelas e status da venda.
- O pedido guarda as condições comerciais da venda (o que foi vendido, por qual valor e em qual forma de pagamento). As cobranças efetivamente realizadas ficam registradas no pagamento (RF-09).
- Status da venda: Aberto, Aguardando pagamento, Pago, Finalizado ou Cancelado. "Pago" indica que o pagamento foi aprovado; "Finalizado" indica que o pedido foi entregue ao cliente.
- Após a confirmação do pagamento, o status do aparelho muda para Vendido.
- O sistema deve gerar um comprovante de venda.
- A venda deve ser registrada no histórico do cliente.

**RF-06 – Processar venda à vista ou parcelada** 

O sistema deve permitir que o cliente pague à vista ou de forma parcelada.

- O parcelamento só é permitido no cartão de crédito, de 1 a 12 parcelas.
- O número de parcelas deve ser escolhido antes da confirmação da compra.
- O sistema deve calcular automaticamente o valor de cada parcela.
- Se houver juros ou taxas, eles devem ser mostrados ao cliente antes da confirmação.
- O valor total da venda deve ficar registrado, independentemente do número de parcelas.

**RF-07 – Calcular valor final da venda**

O sistema deve calcular automaticamente o valor final da venda pela fórmula: Valor Final = Valor do Produto − Desconto + Taxas (quando houver).

- Não é permitido desconto manual. O único desconto existente é o desconto automático por Pix.
- O valor final deve ser mostrado ao cliente antes da confirmação da compra.
- Após a confirmação, o valor da venda deve ser lançado automaticamente no módulo financeiro.

**RF-08 – Aplicar desconto por Pix**  

O sistema deve aplicar o desconto automaticamente quando o pagamento for via Pix e o produto for elegível.

- Faixas de desconto: produto de até R$ 1.000,00 = 5%; de R$ 1.001,00 a R$ 2.500,00 = 7%; acima de R$ 2.500,00 = 10%.
- Não há desconto para pagamento com cartão de crédito.
- O desconto deve ser mostrado antes da confirmação da compra. Se o produto não for elegível, o cliente também deve ser informado.
- O percentual e o valor do desconto devem ficar registrados na venda.

**RF-09 – Processar formas de pagamento** 

O sistema deve aceitar apenas duas formas de pagamento: **Pix** e **cartão de crédito**. Boleto bancário, cartão de débito e dinheiro não são aceitos.

- A forma de pagamento é obrigatória em toda venda e é escolhida no pedido, junto com o número de parcelas.
- Pix: pagamento sempre à vista (1 parcela), com desconto quando o produto for elegível (RF-08) e sem juros.
- Cartão de crédito: de 1 a 12 parcelas, sem desconto Pix; juros ou taxas do parcelamento, quando houver, são mostrados antes da confirmação (RF-06).
- Cada pedido é pago com uma única forma de pagamento. Não é permitido dividir o valor entre formas diferentes.
- Cada cobrança enviada à instituição de pagamento é registrada como um pagamento (uma tentativa), com data, valor, código da transação e status: Pendente, Aprovado, Recusado, Expirado ou Estornado.
- Um pedido pode ter várias tentativas (por exemplo, um Pix expirado seguido de um novo Pix), mas no máximo um pagamento Aprovado.
- Se o cliente quiser trocar a forma de pagamento depois de uma tentativa recusada ou expirada, o pedido é recalculado (desconto Pix e taxas) antes da nova tentativa, enquanto estiver Aguardando pagamento.
- A venda só passa para o status Pago após a aprovação do pagamento.

**RF-10 – Processar cancelamento de venda**  

O sistema deve permitir o cancelamento da venda em até 7 dias corridos a partir da data da compra, desde que o aparelho ainda não tenha sido enviado.

- O sistema deve verificar a data da venda antes de permitir o cancelamento.
- O cancelamento só é permitido enquanto o status de entrega for Aguardando envio.
- Se o status de entrega já for Em transporte ou Entregue, a solicitação passa a ser tratada como devolução (RF-12 ou RF-13).
- O motivo do cancelamento deve ser registrado.
- Se o pagamento já tiver sido feito, o sistema deve abrir o estorno (RF-16).
- O aparelho vai para o status Em avaliação antes de voltar a ficar Disponível.
- A venda cancelada não pode ser excluída: ela permanece registrada no histórico do cliente e da venda.

**RF-11 – Processar troca por defeito coberto pela garantia**  

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

**RF-12 – Processar devolução por arrependimento**  

O sistema deve permitir a devolução do aparelho em até 7 dias corridos a partir do recebimento, sem necessidade de defeito, conforme o direito de arrependimento do Código de Defesa do Consumidor (art. 49).

- A devolução deve estar ligada à venda original.
- O sistema deve registrar a data e o motivo da devolução, quando o cliente informar.
- O cliente recebe a restituição integral do valor pago (RF-16), sem precisar comprovar defeito.
- O aparelho passa por avaliação (status Em avaliação), que define apenas o seu destino: volta a Disponível se estiver em boas condições ou vai para Em manutenção ou Inativo se tiver algum dano.

**RF-13 – Processar devolução por defeito**  

O sistema deve permitir a devolução com reembolso quando houver defeito coberto pela garantia e a troca não for possível, ou quando o aparelho já tiver sido entregue no momento em que o cliente relata o problema.

- A venda pode ser localizada pelo CPF/CNPJ, pelo número da venda ou pelo IMEI.
- O aparelho deve passar por avaliação técnica (status Em avaliação).
- Se o dano for causado por mau uso, a devolução não é autorizada.
- O sistema deve registrar o diagnóstico e a decisão tomada.
- Quando aprovada, a devolução gera a restituição integral do valor pago (RF-16).
- O processo deve ficar registrado no histórico do cliente e do aparelho.

**RF-14 – Controlar garantia do aparelho**  

O sistema deve controlar a garantia de cada aparelho vendido, conforme sua condição.

- Aparelho Novo: 30 dias de garantia da loja + 1 ano de garantia do fabricante.
- Aparelho Seminovo: 30 dias de garantia da loja, sem garantia do fabricante (salvo quando o fabricante informar o contrário).
- A garantia da loja começa na data da venda.
- O sistema deve registrar as datas de início e de término da garantia e permitir consultar se ela está vigente ou encerrada.
- O aparelho deve ser identificado pelo IMEI/número de série.
- Danos por mau uso não são cobertos pela garantia da loja.
- Todas as solicitações de garantia devem ser registradas.

**RF-15 – Classificar avaliação de dano**  

O sistema deve registrar a avaliação técnica de todo aparelho com dano e definir se o caso é coberto pela garantia.

- Durante a avaliação, o aparelho fica com status Em avaliação.
- O dano deve ser classificado como: defeito de fabricação, mau uso, dano acidental ou outros.
- São exemplos de mau uso: tela quebrada por impacto, aparelho amassado, danos por líquido, alterações não autorizadas e outros danos por uso inadequado.
- Se o defeito for coberto e estiver dentro da garantia, o atendimento segue para troca (RF-11) ou devolução (RF-13).
- Se for mau uso, o sistema deve bloquear a troca e a devolução. A empresa não faz o reparo: o cliente é informado do diagnóstico e o atendimento é encerrado.

**RF-16 – Processar estorno e restituição**  

O sistema deve processar a devolução de valores ao cliente em casos de cancelamento ou devolução. A troca não gera estorno, pois o aparelho de reposição tem valor igual ou superior e não há cobrança nem devolução de diferença (RF-11).

- Todo estorno é ligado ao pagamento Aprovado que está sendo revertido.
- O estorno segue a forma de pagamento original: Pix, por devolução para a conta de origem do pagamento; cartão de crédito, por estorno solicitado à operadora do cartão. Como não há boleto, o sistema não precisa pedir nem guardar dados bancários do cliente.
- O processo completo deve ser concluído em 7 a 15 dias corridos.
- O sistema deve registrar o valor, a data de abertura, o prazo-limite (data de abertura + 15 dias) e o status do estorno: Pendente, Processado ou Recusado.
- Se o prazo-limite for ultrapassado com o estorno ainda Pendente, o sistema deve sinalizá-lo como Atrasado (situação calculada, não um status gravado) e notificar o setor Financeiro/Administrativo.
- No cartão de crédito, mesmo em compras parceladas, o estorno é solicitado à operadora pelo valor a restituir; a operadora ajusta as parcelas na fatura do cliente.
- Em devoluções, o estorno só é liberado depois que a nota fiscal de devolução estiver com status Emitida.

**RF-17 – Emitir nota fiscal**  

O sistema deve emitir a nota fiscal eletrônica (NF-e) das vendas e das operações de pós-venda.

- A nota documenta a operação com a mercadoria (venda, devolução ou reposição), e não o pagamento. A nota de venda fica ligada ao pedido e lista cada aparelho (IMEI) que ela documenta, usando os dados do cliente e do aparelho.
- Status da nota: Aguardando emissão, Emitida, Pendente ou Cancelada.
- O sistema deve registrar o número e a chave de acesso de cada nota. Esses dados só existem depois que a SEFAZ autoriza a nota; enquanto ela estiver Aguardando emissão ou Pendente, ficam vazios.
- Venda: a aprovação do pagamento é o gatilho para a emissão da nota de venda do pedido.
- Cancelamento: em até 24 horas da emissão, a nota de venda é cancelada. Depois desse prazo, ela continua Emitida e o sistema emite uma nota de entrada (devolução).
- Devolução: o sistema emite uma nota de entrada que faz referência à nota de venda original.
- Troca: o sistema emite duas notas: uma de entrada, para o aparelho com defeito, e uma de saída, para o aparelho novo, sem cobrança adicional.
- As notas de entrada e de saída de reposição não podem ser canceladas depois de emitidas.
- Erro na emissão: a nota fica Pendente, o usuário é avisado e a venda é marcada como "nota fiscal pendente". O estorno ou o envio do aparelho de reposição ficam retidos até a nota ser emitida.

**RF-18 – Manter histórico do cliente**  

O sistema deve manter o histórico completo de cada cliente, reunindo em um só lugar:

- compras realizadas e aparelhos adquiridos, com IMEI e valores;
- pagamentos, cancelamentos, trocas e devoluções;
- solicitações de garantia e seus diagnósticos;
- estornos e créditos concedidos.

**RF-19 – Registrar auditoria das operações**  

O sistema deve registrar, em toda operação importante, o usuário responsável, a data e a hora, a operação realizada, a venda e o aparelho afetados e os valores anteriores e novos, quando houver.

- Operações auditadas: alterações de preço e de desconto, cancelamentos, trocas, devoluções, estornos, alterações de pagamento e alterações de estoque.
- Também devem ser auditados os alertas de aparelhos encalhados (RF-21), todas as etapas das requisições de compra (RF-22) e as aquisições, avaliações de entrada e fins de quarentena (RF-25).
- Toda atualização do status de entrega deve registrar sua origem: integração com a transportadora ou usuário responsável (RF-23).

**RF-20 – Controlar perfis de acesso**  

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

**RF-25 – Registrar aquisição e avaliação de entrada dos aparelhos**

O sistema deve registrar a origem de todo aparelho que entra no estoque, cumprindo a Política de Aquisição (Seção 5.4).

- Cada aquisição registra o fornecedor (pessoa física ou jurídica), a data, o funcionário que a recebeu e o documento da compra: nota fiscal do fornecedor ou termo de compra e venda.
- Fornecedor pessoa física: CPF, nome, tipo e número do documento oficial com foto, e aceite do termo de responsabilidade (remoção de contas e dados pessoais).
- O sistema deve impedir que um mesmo CPF venda mais de 3 aparelhos por dia à loja.
- Cada aparelho oferecido passa por uma avaliação de entrada, registrada mesmo quando o aparelho é recusado: IMEI consultado, base consultada, resultado da consulta (Regular, Roubado/Furtado, Bloqueado ou Adulterado), checklist técnico (bateria, tela, câmeras, botões, som, conectividade e originalidade das peças), resultado da verificação de bloqueio iCloud/FRP, resultado (Aprovado ou Recusado) e motivo da recusa.
- Somente aparelhos com avaliação de entrada Aprovada podem ser cadastrados no estoque (RF-02).
- Seminovos comprados de pessoa física entram com status Em quarentena por 15 dias. Ao fim do prazo, o IMEI é consultado novamente: se estiver regular, o aparelho passa a Disponível; se houver restrição, passa a Inativo e a Diretoria é notificada.
- O reset de fábrica deve ser registrado antes de o aparelho ficar Disponível.

**RF-26 – Gerar relatórios gerenciais**

O sistema deve gerar relatórios consolidados a partir dos dados registrados, sem depender de planilhas paralelas.

- Vendas por período, por forma de pagamento e por especificação de aparelho.
- Estoque atual por especificação e por classificação de giro (RF-21).
- Cancelamentos, trocas, devoluções e estornos por período, incluindo estornos atrasados.
- Aquisições por período e por fornecedor, com o total de aparelhos aprovados e recusados.

### 5.2 Requisitos Não Funcionais

**RNF-01 – Disponibilidade**  

O sistema deve ficar disponível pelo menos 99% do tempo a cada mês.

- Manutenções programadas devem ser avisadas com antecedência e feitas, de preferência, fora do horário de maior movimento.

**RNF-02 – Segurança**  

O sistema deve proteger os dados contra vazamento e acesso indevido, cumprindo a Lei Geral de Proteção de Dados (LGPD).

- As senhas devem ser armazenadas de forma criptografada.
- A comunicação entre o usuário e o sistema deve ser protegida (HTTPS).
- Os dados pessoais dos clientes, como CPF e CNPJ, só podem ser acessados pelos perfis autorizados.
- O sistema deve coletar apenas os dados pessoais estritamente necessários.

**RNF-03 – Usabilidade** 

O sistema deve ser simples e intuitivo para usuários de todos os setores.

- Um usuário novo deve conseguir realizar as operações do seu setor após um treinamento de até 1 hora.
- As telas devem seguir um padrão visual único, em português.
- As mensagens de erro devem explicar o problema e indicar como resolvê-lo.

**RNF-04 – Desempenho**  

O sistema deve responder em até 3 segundos em pelo menos 95% das operações de consulta e de fechamento da compra, incluindo a validação de disponibilidade do aparelho.

**RNF-05 – Escalabilidade** 

O sistema deve suportar o aumento do número de clientes, aparelhos, vendas e usuários sem ultrapassar os tempos de resposta definidos no RNF-04.

- A estrutura do sistema deve permitir ampliar a capacidade sem precisar reescrevê-lo.

**RNF-06 – Confiabilidade** 

As operações críticas (fechamento da venda, estorno e troca) devem ser feitas de forma completa ou não ser feitas: se ocorrer uma falha no meio, nada é gravado pela metade.

- O sistema deve impedir que o mesmo aparelho seja vendido para dois clientes ao mesmo tempo.

**RNF-07 – Auditabilidade**  

Os registros de auditoria não podem ser alterados nem excluídos depois de gravados, por nenhum perfil, nem mesmo pela Diretoria.

**RNF-08 – Integração com sistemas externos**

O sistema deve se comunicar com os seguintes serviços externos:

- SEFAZ, para emissão e cancelamento de notas fiscais eletrônicas;
- instituições de pagamento e operadoras de cartão, para cobranças por Pix e cartão de crédito e para os estornos;
- transportadora, para o rastreamento das entregas.

**RNF-09 – Backup**

O sistema deve fazer cópias de segurança automáticas do banco de dados todos os dias.

- As cópias devem ser guardadas em local separado do servidor principal.
- A restauração dos dados deve ser testada periodicamente.

**RNF-10 – Precisão de cálculos e prazos**

O sistema deve garantir que valores e prazos sejam calculados corretamente.

- Os valores em dinheiro devem ter 2 casas decimais e seguir uma regra única de arredondamento.
- Os prazos (24 horas e 7, 15 e 30 dias) devem ser calculados pelo horário oficial de Brasília.

### 5.3 Regras de Negócio

#### Módulo 1 — Cadastro

##### RN-01 — Cadastro de Cliente

**Descrição:** O sistema deverá permitir o cadastro dos clientes que realizam compras, mantendo os dados necessários para localizar vendas, emitir nota fiscal e processar solicitações de pós-venda. O cadastro poderá ser de pessoa física ou pessoa jurídica.

**Regras:**
- Pessoa física: o cadastro deverá conter, no mínimo, nome completo, CPF, data de nascimento, e-mail, telefone e endereço.
- Pessoa jurídica: o cadastro deverá conter, no mínimo, nome ou razão social, CNPJ, e-mail, telefone e endereço.
- O cliente poderá informar mais de um telefone, sendo obrigatório pelo menos um.
- O sistema deverá impedir a compra por pessoa física menor de 18 anos (ver Seção 5.4 — Política de Revenda).
- O CPF ou CNPJ deverá ser único por cliente.
- O sistema deverá permitir localizar um cliente e suas vendas por CPF/CNPJ, e-mail ou número da venda.
- Os dados cadastrais deverão poder ser atualizados pelo próprio cliente ou por usuário autorizado.

**Resultado esperado:** Garantir que todo cliente, pessoa física ou jurídica, tenha um cadastro completo o suficiente para viabilizar venda, nota fiscal, garantia e pós-venda.

##### RN-02 — Cadastro de Aparelho/Produto

**Descrição:** O sistema deverá permitir o cadastro dos aparelhos disponíveis para venda, com as informações necessárias para estoque, garantia, giro/reposição e nota fiscal.

**Regras:**
- O cadastro deverá conter, no mínimo: modelo, marca, IMEI/número de série, condição (Novo ou Seminovo), preço de venda, custo de aquisição e status inicial.
- O IMEI/número de série deverá ser único no sistema.
- A condição (Novo/Seminovo) é obrigatória e determina o período de garantia aplicável (ver RN-17).
- A entrada do aparelho no estoque deverá registrar data de entrada, custo e identificador, conforme já previsto no controle de estoque (RN-03); o tempo em estoque de cada IMEI (RN-05) é contado a partir da data em que o aparelho passa a Disponível.
- O cadastro de aparelhos deverá ser realizado apenas por funcionários autorizados, de acordo com seu nível de acesso (permissão) no sistema (ver RN-24).
- Todo aparelho cadastrado deverá estar vinculado à aquisição de origem e a uma avaliação de entrada com resultado Aprovado (ver RN-25).
- O sistema deverá permitir configurar, por combinação de modelo, cor e capacidade de armazenamento (a mesma combinação de especificação utilizada para identificar "aparelho equivalente" na RN-14), os seguintes parâmetros: o Estoque Mínimo (quantidade), usado pela RN-06 (Ponto de Pedido), e os dois Limites de Dias de Giro — um para Atenção/Giro Lento e outro para Crítico/Encalhado —, usados pela RN-05 (tempo em estoque por IMEI). Todos os parâmetros deverão ter valores padrão pré-configurados e poderão ser ajustados pelo perfil Diretoria (RN-24).

**Resultado esperado:** Garantir que todo aparelho tenha um cadastro completo, permitindo o correto funcionamento das regras de estoque, giro, reposição, venda, garantia e nota fiscal que dependem desses dados, restrito a usuários autorizados.

#### Módulo 2 — Estoque

##### RN-03 — Controle de Estoque

**Descrição:** O sistema deverá controlar a disponibilidade individual de cada aparelho comercializado pela empresa, unidade a unidade, identificada univocamente pelo IMEI/número de série (RN-02), sem uso de reserva prévia à confirmação da venda e sem controle por quantidade agregada de modelo.

**Regras:**
- O controle de estoque é feito por unidade física (por IMEI), nunca por saldo agregado de modelo: cada aparelho possui seu próprio status, histórico e tempo de permanência em estoque (ver RN-05), ainda que o sistema também exiba, apenas para fins gerenciais, contagens agregadas por modelo/especificação (ver RN-06).
- Um aparelho com status Disponível poderá ser vendido.
- O sistema não realizará reserva de aparelhos antes da confirmação do pagamento da venda.
- Um aparelho com status Vendido não retorna automaticamente ao estoque.
- Toda alteração de status do aparelho deverá ser registrada no histórico do aparelho, com data, hora e usuário responsável quando aplicável.
- O sistema deverá impedir a venda de um aparelho inexistente, já vendido ou indisponível.
- Status possíveis: Em quarentena, Disponível, Vendido, Em avaliação, Em manutenção, Inativo. O status Em quarentena se aplica aos seminovos comprados de pessoa física (ver RN-25).

**Resultado esperado:** Evitar vendas duplicadas e garantir rastreabilidade individual dos aparelhos comercializados, por IMEI, sem depender de um mecanismo de reserva, e servindo de base para as regras de giro (RN-05) e reposição (RN-06).

##### RN-04 — Validação de Disponibilidade no Fechamento da Venda

**Descrição:** O sistema deverá validar novamente a disponibilidade do aparelho no exato momento da finalização da venda, para evitar que dois clientes concluam a compra do mesmo aparelho.

**Regras:**
- A validação de disponibilidade deverá ocorrer de forma atômica junto com a confirmação do pagamento, de modo que duas vendas não possam ser concluídas simultaneamente para o mesmo aparelho.
- Caso o aparelho já tenha sido vendido por outra transação, a nova tentativa de compra deverá ser bloqueada e o cliente informado.

**Resultado esperado:** Evitar conflitos de estoque decorrentes da ausência de reserva prévia.

##### RN-05 — Tempo em Estoque (Aging) por IMEI e Identificação de Encalhe

**Descrição:** O sistema deverá controlar o tempo de permanência de cada aparelho individualmente (via IMEI/número de série) no estoque, identificando unidades específicas paradas e fornecendo dados para estratégias de giro de estoque (ex.: priorização de saída FIFO).

**Regras:**
- Cálculo da idade individual: cada aparelho com status Disponível terá seu tempo de estoque calculado individualmente como a diferença entre a data atual e a data em que aquele IMEI passou a constar como Disponível (RN-02); para aparelhos que retornam ao estoque após devolução ou troca (RN-14/RN-16), a contagem reinicia a partir da data em que o aparelho retorna ao status Disponível, e não da data de entrada original no estoque.
- Classificação por status de permanência: Giro Normal (0 a 30 dias de estoque); Atenção / Giro Lento (31 a 60 dias); Crítico / Encalhado (acima de 60 dias) — faixas parametrizáveis pelos Limites de Dias de Giro configurados na RN-02.
- Visualização por unidade física: o painel de estoque deverá listar explicitamente o IMEI, o modelo, a condição (Novo/Seminovo) e os dias exatos em que aquela unidade específica está parada. A classificação de giro deixa de ser calculada e exibida quando o aparelho sai do status Disponível (venda, avaliação, manutenção ou inativação).
- Priorização na saída (sugestão FIFO): quando houver mais de uma unidade do mesmo modelo Disponível para venda, o sistema sugerirá a expedição do IMEI com maior tempo de estoque, reduzindo o risco de encalhe crônico. Trata-se apenas de uma sugestão de priorização e não cria reserva de estoque (RN-03/RN-04).
- Ações para IMEIs críticos: ao atingir o status Crítico, o sistema envia alerta para a Diretoria e para o perfil Estoque e Logística (RN-24), recomendando: (a) vinculação daquele IMEI a promoções/Desconto Pix (RN-10); e (b) reavaliação de preço de venda daquele IMEI (RN-02/RN-09), sujeita a autorização da Diretoria (RN-24).

**Resultado esperado:** Permitir que o setor de Estoque/Logística e a Diretoria identifiquem, por unidade física, quais aparelhos estão parados há mais tempo, viabilizando estratégias de giro (FIFO, promoção ou reprecificação) antes que o encalhe se torne crônico.

##### RN-06 — Ponto de Pedido e Requisição de Compra

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

#### Módulo 3 — Venda

##### RN-07 — Venda de Aparelho

**Descrição:** O sistema deverá permitir a realização da venda de aparelhos cadastrados no estoque, vinculando o(s) produto(s) a um cliente e registrando todas as informações financeiras da operação.

**Regras:**
- Só poderá ser realizada uma venda para um aparelho com status Disponível.
- A venda deverá possuir obrigatoriamente: cliente, aparelho(s), data da venda, valor do produto, desconto quando aplicável, valor final, forma de pagamento escolhida, número de parcelas e status da venda.
- O pedido registra as condições comerciais da venda; cada cobrança efetivamente enviada à instituição de pagamento é registrada separadamente como pagamento (ver RN-11).
- Após a aprovação do pagamento, o aparelho deverá ter seu status alterado para Vendido.
- O IMEI/número de série deverá ficar vinculado ao registro da venda.
- A venda deverá ser registrada no histórico do cliente (ver RN-22).
- O sistema deverá gerar um comprovante de venda.
- Status da venda: Aberto, Aguardando pagamento, Pago (pagamento aprovado), Finalizado (pedido entregue ao cliente) ou Cancelado.

**Resultado esperado:** Garantir que toda venda seja registrada corretamente, vinculando cliente, aparelho, estoque e financeiro.

##### RN-08 — Venda à Vista ou Parcelada

**Regras:**
- O cliente poderá optar por compra à vista ou parcelada.
- O parcelamento é permitido apenas para pagamento via cartão de crédito, em até 12 vezes.
- O número de parcelas deverá ser informado antes da confirmação da venda.
- O sistema deverá calcular automaticamente o valor de cada parcela.

**Resultado esperado:** Permitir vendas à vista e parceladas, mantendo o controle correto dos valores e parcelas.

##### RN-09 — Cálculo do Valor da Venda

**Regras:**
- Valor Final = Valor do Produto − Desconto + Taxas (quando houver).
- No modelo de e-commerce, não há desconto discricionário aplicado manualmente por um vendedor: o único desconto previsto é o desconto automático por pagamento via Pix, aplicável apenas aos produtos elegíveis (ver RN-10).
- O valor final deverá ser apresentado ao cliente antes da confirmação da venda.
- Após a confirmação, o valor da venda deverá ser registrado no módulo financeiro.

**Resultado esperado:** Garantir que o valor cobrado seja calculado corretamente e de forma consistente com o modelo de e-commerce.

##### RN-10 — Desconto para Pagamento via Pix

**Regras:**
- O desconto é aplicado somente quando a forma de pagamento é Pix.
- Faixas confirmadas: produto até R$ 1.000,00 = 5%; de R$ 1.001,00 a R$ 2.500,00 = 7%; acima de R$ 2.500,00 = 10%.
- Nem todos os produtos participarão do desconto Pix: a elegibilidade de cada produto ao desconto deverá ser configurável no cadastro do aparelho (RN-02).
- Não será aplicado desconto para pagamentos via cartão de crédito.
- O desconto deverá ser apresentado ao cliente antes da confirmação da compra, incluindo os casos em que o produto não é elegível ao desconto.
- O sistema deverá registrar o percentual e o valor do desconto na venda.

**Resultado esperado:** Controlar os descontos concedidos para pagamentos via Pix, evitando descontos indevidos em outras formas de pagamento ou em produtos não elegíveis.

##### RN-11 — Formas de Pagamento

**Regras:**
- A venda deverá informar obrigatoriamente a forma de pagamento, escolhida no pedido.
- Formas aceitas: somente Pix e cartão de crédito.
- No Pix, o pagamento é sempre à vista (Numero_Parcelas = 1).
- No cartão de crédito, deverá ser informado o número de parcelas (de 1 a 12).
- Cada pedido é pago com uma única forma de pagamento; não é permitido dividir o valor entre formas diferentes.
- Cada cobrança enviada à instituição de pagamento é registrada como um pagamento (tentativa), com status Pendente, Aprovado, Recusado, Expirado ou Estornado.
- Um pedido pode ter várias tentativas de pagamento, mas no máximo um pagamento Aprovado.
- Se o cliente trocar a forma de pagamento após uma tentativa recusada ou expirada, o pedido deverá ser recalculado (RN-09/RN-10) antes da nova tentativa, enquanto estiver Aguardando pagamento.
- Uma venda somente passa para o status Pago após a aprovação do pagamento.
- Boleto bancário e cartão de débito não são aceitos, por decisão do negócio.

**Resultado esperado:** Garantir o controle dos pagamentos e a correta vinculação entre venda e financeiro, com as formas de pagamento efetivamente aceitas pelo e-commerce.

##### RN-12 — Parcelamento

**Regras:**
- Número mínimo de parcelas: 1. Número máximo: 12.
- O sistema deverá calcular automaticamente o valor das parcelas.
- O valor total da venda deverá permanecer registrado independentemente da quantidade de parcelas.
- Caso existam juros ou taxas, estes deverão ser apresentados antes da confirmação da venda.

**Resultado esperado:** Permitir o parcelamento das vendas de forma transparente e controlada.

#### Módulo 4 — Pós-venda: Cancelamento

##### RN-13 — Cancelamento da Venda

**Descrição:** O sistema deverá permitir o cancelamento de uma venda no prazo de até 7 dias corridos a partir da data da venda, desde que o aparelho ainda não tenha saído para entrega.

**Regras:**
- O sistema deverá verificar a data da venda antes de permitir o cancelamento.
- O cancelamento por esta regra somente será permitido enquanto o status de entrega da venda for "Aguardando envio". A atualização desse status é feita pela integração com a API da transportadora.
- A partir do momento em que o status de entrega passar para "Em transporte" ou "Entregue", a solicitação do cliente deixa de ser tratada como cancelamento e passa a seguir o fluxo do Módulo 5 — Devolução (RN-15/RN-16), conforme o caso.
- O motivo do cancelamento deverá ser registrado.
- Caso o pagamento já tenha sido realizado, deverá ser aberto o processo de estorno (ver RN-19).
- Como o aparelho ainda não foi enviado, ele deverá ir direto para uma nova avaliação (status Em avaliação) antes de voltar a ficar Disponível.
- A venda cancelada não deverá ser excluída do sistema; o cancelamento fica registrado no histórico do cliente e da venda, para fins de auditoria (ver RN-23).

**Resultado esperado:** Permitir o cancelamento dentro do prazo estabelecido e apenas antes da saída do aparelho para entrega, mantendo o histórico financeiro e de estoque e direcionando corretamente os casos pós-envio para o fluxo de devolução.

#### Módulo 5 — Pós-venda: Troca e Devolução

##### RN-14 — Troca por Defeito Coberto pela Garantia

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

##### RN-15 — Devolução por Arrependimento

**Descrição:** O sistema deverá permitir a devolução de um aparelho no prazo de até 7 dias corridos a partir do recebimento, independentemente de defeito, em conformidade com o direito de arrependimento previsto no art. 49 do Código de Defesa do Consumidor para compras realizadas fora do estabelecimento comercial (e-commerce).

**Regras:**
- A devolução deverá estar vinculada à venda original.
- O sistema deverá registrar a data e o motivo da devolução, quando informado pelo cliente.
- O aparelho deverá ser devolvido em condições de revenda e passar por avaliação (status Em avaliação).
- O valor pago deverá ser integralmente restituído ao cliente (ver RN-19), sem necessidade de comprovação de defeito.
- O aparelho somente retorna ao estoque como Disponível após avaliação e aprovação; caso apresente dano, é direcionado para Em manutenção ou Inativo.

**Resultado esperado:** Garantir o cumprimento do direito de arrependimento do consumidor em compras de e-commerce, controlando devoluções sem perder o histórico da venda.

##### RN-16 — Devolução por Defeito

**Descrição:** O sistema deverá permitir a devolução (com reembolso) do aparelho quando for identificado defeito coberto pela garantia, sem solução adequada por troca, ou quando o aparelho já tiver sido entregue no momento em que o cliente reporta o problema (ver RN-13).

**Regras:**
- O aparelho deverá ser coletado para avaliação; a venda pode ser localizada por CPF/CNPJ, número da venda ou IMEI.
- O aparelho deverá ser submetido à avaliação técnica (status Em avaliação).
- Se o defeito for coberto pela garantia e não houver aparelho equivalente para troca (RN-14), a empresa deverá seguir o procedimento de devolução com restituição (RN-19).
- Se o problema for causado por mau uso, a devolução por esta regra não é autorizada (ver RN-18).
- O sistema deverá registrar o diagnóstico e a decisão tomada.
- O processo deverá ficar registrado no histórico do cliente e do aparelho.

**Resultado esperado:** Garantir que devoluções por defeito sejam realizadas somente quando a troca não for uma alternativa viável, mantendo a cobertura de garantia como critério central.

#### Módulo 6 — Pós-venda: Garantia e Avaliação de Danos

##### RN-17 — Garantia do Aparelho

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

##### RN-18 — Avaliação de Dano e Elegibilidade para Cobertura

**Descrição:** Quando o aparelho apresentar dano, o sistema deverá registrar a ocorrência e determinar se o caso é coberto pela garantia ou se é caracterizado como mau uso, sem cobertura da empresa.

**Regras:**
- O aparelho deverá ser avaliado tecnicamente (status Em avaliação).
- O sistema deverá registrar o tipo de dano e classificá-lo como: defeito de fabricação, dano por mau uso, dano acidental ou outros.
- Exemplos de mau uso (não cobertos pela garantia): tela quebrada por impacto, aparelho amassado, danos por líquido, alterações não autorizadas e outros danos por uso inadequado.
- Caso esteja dentro da garantia e seja defeito coberto, o atendimento segue as regras de garantia (RN-17) e, conforme o caso, troca (RN-14) ou devolução (RN-16).
- Caso o dano seja caracterizado como mau uso, a solicitação de troca ou devolução não será autorizada e o aparelho não será reparado pela empresa; o cliente deverá ser informado do diagnóstico e o atendimento é encerrado sem custo para a empresa.

**Resultado esperado:** Diferenciar de forma clara problemas cobertos pela garantia de danos causados por mau uso, sem que a empresa assuma qualquer serviço de reparo nesses casos.

#### Módulo 7 — Financeiro e Fiscal

##### RN-19 — Estorno e Restituição

**Descrição:** O sistema deverá processar estornos e restituições decorrentes de cancelamento ou devolução. A troca por defeito não gera estorno, pois o aparelho de reposição tem valor igual ou superior e não há diferença a devolver (RN-14).

**Regras:**
- Todo estorno deverá estar vinculado ao pagamento Aprovado que está sendo revertido.
- O estorno deverá seguir a forma de pagamento original utilizada na venda.
- Pagamentos via Pix deverão ser devolvidos para a conta de origem do pagamento.
- Pagamentos via cartão de crédito deverão ser estornados junto à operadora do cartão.
- O processo completo de estorno, da abertura da solicitação até a efetiva liberação do valor ao cliente, deverá ocorrer dentro do prazo de 7 a 15 dias corridos, podendo variar conforme a forma de pagamento.
- O sistema deverá registrar valor, data de abertura, prazo-limite (data de abertura + 15 dias) e status do estorno (Pendente, Processado, Recusado).
- Caso o prazo-limite seja ultrapassado com o estorno ainda Pendente, o sistema deverá sinalizá-lo como atrasado e notificar o perfil Financeiro/Administrativo (RN-24) para tratamento manual. "Atrasado" é uma situação calculada (prazo-limite vencido e status Pendente), e não um status gravado.
- Em vendas no cartão de crédito, inclusive parceladas, o estorno é solicitado à operadora pelo valor a restituir; a operadora ajusta as parcelas na fatura do cliente.

**Resultado esperado:** Garantir que todo valor devido ao cliente em cancelamentos e devoluções seja restituído de forma rastreável e dentro de um prazo definido.

##### RN-20 — Emissão de Nota Fiscal

**Descrição:** O sistema deverá possuir integração ou funcionalidade para emissão de nota fiscal eletrônica referente às vendas realizadas, incluindo tratamento fiscal específico para cancelamento, troca e devolução.

**Regras:**
- A nota fiscal documenta a operação com a mercadoria, e não o pagamento. A nota de venda deverá estar vinculada ao pedido e listar cada aparelho (IMEI) documentado, utilizando os dados cadastrados do cliente (RN-01) e do aparelho (RN-02).
- A aprovação do pagamento (RN-11) é o gatilho que inicia a emissão da nota de venda; o pagamento não fica vinculado à nota.
- A emissão deverá ocorrer conforme as regras fiscais aplicáveis, iniciando com status Aguardando emissão.
- O sistema deverá registrar o número e a chave de acesso da nota fiscal quando a SEFAZ autorizar a emissão (antes disso esses dados ficam vazios), e permitir consultar seu status (Aguardando emissão, Emitida, Pendente ou Cancelada).
- Em caso de cancelamento (RN-13) dentro do prazo legal da SEFAZ para cancelamento direto (via de regra, até 24 horas da emissão), a nota fiscal de venda deverá passar para o status Cancelada. Fora desse prazo, a nota de venda permanece Emitida e o cancelamento segue o mesmo procedimento fiscal da devolução (nota de entrada).
- Em caso de devolução (RN-15 — arrependimento, ou RN-16 — defeito), o sistema deverá emitir uma Nota Fiscal de Entrada (devolução), referenciando a NF-e de venda original, para desfazer fiscalmente a operação. A liberação do estorno (RN-19) só deverá ocorrer quando essa nota de devolução atingir o status Emitida.
- Em caso de troca por defeito (RN-14), o sistema deverá emitir duas notas: (1) uma Nota Fiscal de Entrada (devolução), referenciando a NF-e original, para o aparelho defeituoso devolvido; e (2) uma nova Nota Fiscal de Saída para o aparelho de reposição. Quando não houver diferença de valor entre os aparelhos, a nova nota é emitida sem cobrança adicional ao cliente.
- Caso ocorra erro na emissão de qualquer nota (venda, devolução ou reposição), ela permanece com status Pendente, o usuário deverá ser informado, e a venda correspondente fica sinalizada como "nota fiscal pendente" até a regularização. Essa sinalização é obtida pela consulta ao status das notas vinculadas, sem atributo próprio no pedido.

**Resultado esperado:** Garantir que todas as vendas e movimentações de pós-venda sejam devidamente documentadas fiscalmente antes da liberação do respectivo estorno ou da saída do aparelho de reposição.

##### RN-21 — Comissão de Vendedores — Não Aplicável

**Descrição:** O sistema não possuirá controle de comissão de vendedores, pois o modelo de negócio é de e-commerce, sem vendedor associado à venda.

**Regras:**
- Não haverá cálculo nem lançamento financeiro de comissão.
- O sistema poderá registrar o usuário responsável por atendimentos de pós-venda apenas para fins de auditoria (ver RN-23), sem gerar comissão.

**Resultado esperado:** Manter o módulo financeiro simplificado, coerente com a ausência de vendedores no modelo de e-commerce.

#### Módulo 8 — Histórico, Auditoria e Acesso

##### RN-22 — Histórico do Cliente

**Descrição:** O sistema deverá manter o histórico comercial completo de cada cliente.

**Regras:**
- Compras realizadas e aparelhos adquiridos, com IMEI/número de série e valores.
- Pagamentos, cancelamentos, trocas por defeito e devoluções.
- Solicitações de garantia e respectivos diagnósticos.
- Créditos ou estornos concedidos.

**Resultado esperado:** Permitir que a empresa tenha uma visão completa do relacionamento comercial com o cliente.

##### RN-23 — Auditoria das Operações

**Descrição:** Operações importantes realizadas no sistema deverão possuir registro para auditoria.

**Regras:**
- Registrar usuário responsável, data e hora, operação realizada, venda afetada, aparelho afetado e valores anteriores e novos, quando aplicável.
- Auditar principalmente: alterações de preço/desconto, cancelamentos, trocas, devoluções, estornos, alterações de pagamento e alterações de estoque.
- Auditar também: alertas de aparelhos encalhados (tempo em estoque crítico) por IMEI (RN-05), o ciclo completo das Requisições de Compra (RN-06), incluindo abertura, análise financeira e decisão da Diretoria, e as aquisições, avaliações de entrada e fins de quarentena (RN-25).

**Resultado esperado:** Garantir a rastreabilidade de todas as operações relevantes realizadas no ERP, incluindo as rotinas de gestão de estoque e de aquisição de aparelhos.

##### RN-24 — Perfis de Acesso e Autorizações

**Descrição:** O sistema deverá definir perfis de acesso que determinam quais usuários podem executar operações sensíveis, como cancelamentos, aprovações de troca/devolução, cadastro de aparelhos, ajustes financeiros, alertas de gestão de estoque (tempo em estoque e ponto de pedido) e requisições de compra. Os perfis seguem a estrutura organizacional do negócio: Diretoria (2 sócios) e 4 áreas operacionais com 8 colaboradores (Vendas e Atendimento, Estoque e Logística, Assistência Técnica e Financeiro/Administrativo).

**Regras:**
- São definidos 2 níveis hierárquicos de acesso: Nível 1 — Operacional (um perfil por área, para os 8 colaboradores) e Nível 2 — Estratégico (perfil único da Diretoria, para os 2 sócios).
- Cada colaborador recebe o perfil operacional correspondente à sua área; os sócios recebem o perfil de Diretoria, com acesso a todas as áreas.
- O perfil de Diretoria é o único autorizado a criar, editar ou remover perfis de acesso e a autorizar exceções fora do fluxo automático em qualquer área.
- Toda ação que exigir autorização deverá registrar o usuário autorizador, seu perfil e a área correspondente (ver RN-23).
- O sistema deverá impedir que usuários sem o perfil adequado executem operações fora de sua área ou nível de autorização.
- Na aquisição de aparelhos (RN-25), o registro da aquisição cabe ao perfil Estoque e Logística, e a avaliação de entrada cabe ao perfil Assistência Técnica.

**Resultado esperado:** Fechar a lacuna de definição de quem é o "usuário autorizado"/"usuário responsável" citado em várias regras do documento, com uma estrutura de perfis compatível com o tamanho da empresa (2 sócios e 8 colaboradores), que também cobre as rotinas de gestão de estoque (RN-05/RN-06) e de aquisição (RN-25).

#### Módulo 9 — Aquisição de Aparelhos

##### RN-25 — Aquisição, Procedência e Avaliação de Entrada

**Descrição:** O sistema deverá registrar a origem de todo aparelho que entra no estoque, comprovando o cumprimento da Política de Aquisição (Seção 5.4) antes que o aparelho possa ser vendido.

**Regras:**
- Toda entrada de aparelho deverá estar vinculada a uma aquisição, que registra o fornecedor, a data, o funcionário que a recebeu e o documento da compra (nota fiscal do fornecedor ou termo de compra e venda).
- O fornecedor poderá ser pessoa jurídica (distribuidor) ou pessoa física. Para pessoa física, é obrigatório registrar CPF, nome, tipo e número do documento oficial com foto e o aceite do termo de responsabilidade sobre a remoção de contas e dados pessoais.
- Um mesmo CPF poderá vender no máximo 3 aparelhos por dia à loja. O sistema verifica o limite contando as aquisições aprovadas daquele CPF na data.
- Cada aparelho oferecido deverá passar por uma avaliação de entrada, registrada mesmo quando o aparelho for recusado, contendo: IMEI consultado, base consultada, resultado da consulta (Regular, Roubado/Furtado, Bloqueado ou Adulterado), checklist técnico (bateria, tela, câmeras, botões, som, conectividade e originalidade das peças), resultado da verificação de bloqueio iCloud/FRP e resultado final (Aprovado ou Recusado), com motivo em caso de recusa.
- O aparelho deverá ser recusado se o IMEI não estiver Regular, se o checklist reprovar ou se o bloqueio de conta não puder ser removido. Aparelho recusado não é comprado nem cadastrado no estoque.
- Somente um aparelho com avaliação de entrada Aprovada poderá ser cadastrado (RN-02); o cadastro fica vinculado a essa avaliação.
- Para aparelhos lacrados comprados de distribuidor, o checklist técnico não se aplica; a consulta do IMEI continua obrigatória.
- Seminovos comprados de pessoa física entram com status Em quarentena por 15 dias corridos. Ao fim do prazo, o IMEI deverá ser consultado novamente: se estiver Regular, o aparelho passa a Disponível; se houver restrição, passa a Inativo e a Diretoria é notificada.
- O reset de fábrica deverá ser registrado antes de o aparelho passar a Disponível.
- Toda aquisição, toda avaliação de entrada e todo fim de quarentena deverão ser registrados para fins de auditoria (RN-23).

**Resultado esperado:** Garantir que a empresa saiba de onde veio cada aparelho, quem o vendeu e quais verificações foram feitas, evitando a revenda de aparelhos roubados, bloqueados ou adulterados e permitindo comprovar a procedência lícita do estoque.

### 5.4 Restrições e Políticas Organizacionais

#### Política de Aquisição de Aparelhos

- **Verificação de procedência:** consultar o IMEI antes da compra, confirmando que o aparelho não consta como roubado, furtado ou com restrição. A consulta fica registrada na avaliação de entrada (RN-25).
- **Recusa de aparelhos irregulares:** não aceitar celulares com IMEI adulterado, bloqueado ou com indícios de clonagem. A recusa e o motivo ficam registrados na avaliação de entrada (RN-25).
- **Identificação do vendedor:** exigir documento oficial com foto e CPF de quem está vendendo o aparelho para a loja. Esses dados ficam registrados no cadastro do fornecedor (RN-25).
- **Limite de compras por CPF/dia:** cada CPF pode vender no máximo 3 aparelhos por dia à loja, verificado pelo sistema (RN-25).
- **Documentação obrigatória:** emissão de nota fiscal ou termo de compra e venda, mesmo em transações entre pessoas físicas, registrada na aquisição (RN-25).

#### Política de Avaliação Técnica

- **Checklist técnico:** avaliação obrigatória de bateria, tela, câmeras, botões, autofalante, som, conectividade e autenticidade das peças em todo aparelho seminovo adquirido, registrada na avaliação de entrada (RN-25).
- **Verificação de bloqueios de conta:** checagem de bloqueio iCloud/Google (FRP), com recusa do aparelho caso não seja possível desbloquear, registrada na avaliação de entrada (RN-25).

#### Política de Revenda

- **Reset de fábrica:** remoção de contas, dados pessoais e bloqueios (FRP/iCloud) antes de expor o aparelho para venda, registrada na avaliação de entrada (RN-25).
- **Prazo de quarentena:** os seminovos comprados de pessoa física ficam 15 dias corridos com status Em quarentena, para confirmar que não haverá contestação de furto; ao fim do prazo, o IMEI é consultado novamente (RN-25).
- **Restrição etária:** como a venda é exclusivamente on-line, só são permitidos o cadastro e a compra por pessoa física maior de 18 anos. A data de nascimento é informada no cadastro do cliente (RN-01) e o sistema bloqueia a compra de menores.

#### Política Fiscal e Documental

- **Emissão de nota fiscal:** obrigatória para toda venda realizada.
- **Rastreabilidade por IMEI:** registro de garantia e histórico do aparelho vinculado ao número de IMEI.
- **Retenção de comprovantes:** guarda de comprovantes pelo prazo mínimo exigido pela legislação fiscal.

#### Política de Proteção de Dados (LGPD)

- **Termo de responsabilidade do fornecedor:** declaração de que a pessoa física que vende o aparelho à loja removeu contas e dados pessoais antes da entrega, com aceite registrado na aquisição (RN-25).
- **Minimização de dados:** armazenar apenas os dados pessoais estritamente necessários. Do fornecedor pessoa física são guardados apenas os dados exigidos para comprovar a procedência (CPF, nome e documento com foto).

#### Restrições Operacionais

- **Seguro de estoque:** contratação de seguro patrimonial adequado ao valor e ao perfil do estoque, com cobertura para riscos como roubo, furto qualificado, incêndio e outros eventos previstos na apólice.
- **Controle e segregação de estoque:** os aparelhos deverão permanecer armazenados em local seguro e com acesso restrito. Fisicamente, o estoque será dividido entre aparelhos em quarentena ou avaliação, aparelhos disponíveis para venda e aparelhos já vendidos aguardando expedição. Essa divisão acompanha o status de cada IMEI e não cria reserva de aparelhos antes da confirmação do pagamento (RN-03/RN-04).
- **Limite de exposição do estoque:** devido ao alto valor dos aparelhos, será mantida a quantidade mínima necessária de produtos fora do local de armazenamento seguro. A movimentação dos aparelhos deverá ser registrada no sistema.
- **Controle de acesso:** o acesso ao estoque será restrito a colaboradores previamente autorizados, com registro das movimentações de entrada, saída e transferência dos aparelhos.
- **Conferência na expedição:** todo pedido deverá passar por conferência do modelo, cor, capacidade, número de série/IMEI e integridade do produto antes do envio ao cliente.
- **Rastreabilidade:** cada aparelho deverá ser identificado e vinculado ao respectivo registro de estoque e, quando aplicável, ao pedido realizado pelo cliente, permitindo o acompanhamento desde a entrada do produto até a entrega.

#### Quem Pode Aprovar uma Operação

- **Aprovação de exceções:** qualquer operação fora do fluxo automático (cancelamento fora do prazo, troca sem aparelho equivalente, ajuste financeiro extraordinário) só pode ser autorizada pela Diretoria.
- **Aprovação de cancelamento padrão:** Vendas e Atendimento aprova cancelamentos apenas dentro do prazo de 7 dias corridos.
- **Aprovação de retorno ao estoque:** Estoque e Logística aprova o retorno do aparelho a "Disponível" após avaliação técnica.
- **Aprovação de troca/devolução técnica:** Assistência Técnica aprova troca ou devolução por defeito, dentro dos critérios técnicos definidos.
- **Aprovação financeira:** Financeiro/Administrativo aprova liberação de estornos e emissão de nota fiscal, dentro dos valores e prazos definidos.
- **Aprovação de entrada de aparelho:** Assistência Técnica aprova ou recusa cada aparelho na avaliação de entrada; Estoque e Logística registra a aquisição e libera o aparelho ao fim da quarentena (RN-25).

#### Quem Pode Alterar Cadastros

- **Cadastro de aparelho:** alteração restrita a funcionários autorizados.
- **Cadastro de cliente:** alteração permitida ao próprio cliente ou a usuário autorizado.
- **Perfis de acesso:** criação, edição ou remoção exclusiva da Diretoria.
- **Elegibilidade ao desconto Pix:** definição exclusiva da Diretoria.

#### Limites de Desconto

- **Desconto manual:** não é permitido desconto discricionário aplicado por vendedor.
- **Desconto automático via Pix:** único desconto existente, calculado por faixa de valor do produto (5%, 7% ou 10%).
  - 5% de desconto: produtos de até R$ 1.000,00;
  - 7% de desconto: produtos de R$ 1.001,00 a R$ 2.500,00;
  - 10% de desconto: produtos acima de R$ 2.500,00.

#### Condições de Pagamento

- **Formas aceitas:** Pix (à vista) e cartão de crédito (de 1 a 12 parcelas).
- **Formas não aceitas:** boleto bancário, cartão de débito e dinheiro.
- **Parcelamento:** permitido somente no cartão de crédito, em até 12 vezes.
- **Taxas do parcelamento:** os juros e encargos cobrados pela operadora do cartão, quando houver, são de responsabilidade do cliente.
- **Confirmação:** a venda só é considerada paga após a confirmação do pagamento.
- **Regras de consistência do pedido (usadas no banco de dados):**

| Forma_Pagamento | Numero_Parcelas | Percentual_Desconto_Pix e Valor_Desconto | Valor_Taxas |
|---|---|---|---|
| Pix | sempre 1 | preenchidos se o produto for elegível (5%, 7% ou 10%); vazios se não for | vazio |
| Cartão de crédito | de 1 a 12 | vazios | preenchido só se houver juros ou taxas do parcelamento |

## 6. DER Atualizado

### 6.1 Entidades

| Nº | Entidade | Tipo | Descrição |
|---:|---|---|---|
| 01 | **CLIENTE** | Forte | Pessoa física ou jurídica que compra aparelhos na loja on-line. |
| 02 | **ENDERECO** | Forte | Cada endereço do cliente, usado para entrega ou cobrança. |
| 03 | **TELEFONE** | Fraca (depende de CLIENTE) | Cada número de telefone de um cliente. |
| 04 | **PEDIDO** | Forte | A venda e suas condições comerciais: o que foi vendido, por qual valor e em qual forma de pagamento. |
| 05 | **ITEM_PEDIDO** | Associativa (PEDIDO × APARELHO) | Cada aparelho vendido em um pedido, com o preço praticado e as datas de garantia. |
| 06 | **PAGAMENTO** | Forte | Cada tentativa de cobrança do pedido enviada à instituição de pagamento. |
| 07 | **NOTA_FISCAL** | Forte | Documento fiscal de venda, de entrada (devolução) ou de saída (reposição). |
| 08 | **ITEM_NOTA_FISCAL** | Associativa (NOTA_FISCAL × APARELHO) | Cada aparelho (IMEI) documentado em uma nota fiscal. |
| 09 | **CANCELAMENTO** | Forte | Cancelamento de um pedido antes do envio. |
| 10 | **ESTORNO** | Forte | Devolução de valor ao cliente, ligada ao pagamento revertido. |
| 11 | **ENTREGA** | Forte | Envio de um pedido ou de um aparelho de reposição, com rastreamento. |
| 12 | **POS_VENDA** | Forte | Solicitação do cliente sobre um aparelho já vendido (arrependimento, defeito ou garantia). |
| 13 | **DEVOLUCAO** | Forte | Devolução de um aparelho, por arrependimento ou por defeito. |
| 14 | **AVALIACAO_DANO** | Forte | Avaliação técnica do aparelho em uma solicitação de pós-venda. |
| 15 | **TROCA** | Forte | Troca de um aparelho com defeito por um aparelho equivalente. |
| 16 | **APARELHO** | Forte | Unidade física de celular, identificada pelo IMEI. |
| 17 | **IMAGEM_APARELHO** | Forte | Foto de um aparelho exibida na loja on-line. |
| 18 | **ESPECIFICACAO_APARELHO** | Forte | Combinação de modelo, cor e capacidade, com os parâmetros de estoque. |
| 19 | **MODELO** | Forte | Modelo de celular e sua marca. |
| 20 | **REQUISICAO_COMPRA** | Forte | Pedido interno de reposição de estoque de uma especificação. |
| 21 | **MOVIMENTACAO** | Forte | Cada mudança de status de um aparelho. |
| 22 | **AUDITORIA** | Forte | Registro de operações sensíveis, com executor e autorizador. |
| 23 | **FUNCIONARIO** | Forte | Colaborador ou sócio que usa o sistema, com o seu perfil de acesso. |
| 24 | **PERFIL_ACESSO** | Forte | Perfil de acesso ao sistema e o nível hierárquico correspondente. |
| 25 | **FORNECEDOR** | Forte | Pessoa física ou distribuidor que vende aparelhos para a loja. |
| 26 | **AQUISICAO** | Forte | Compra de um ou mais aparelhos de um fornecedor, com o documento da compra. |
| 27 | **AVALIACAO_ENTRADA** | Forte | Verificação de procedência e checklist técnico de cada aparelho oferecido à loja. |

### 6.2 Atributos

#### CLIENTE
- Cpf_Cnpj (PK)
- Nome
- Email
- Data_Nascimento
- Tipo_Pessoa

#### ENDERECO
- Id_Endereco (PK)
- Cpf_Cnpj (FK)
- Rua
- Bairro
- Cidade
- CEP
- Numero
- Complemento
- Tipo_Endereco

#### TELEFONE
- DDD (PK)
- Numero_Telefone (PK)
- Cpf_Cnpj (PK, FK)

#### PEDIDO
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

#### ITEM_PEDIDO
- Imei (PK, FK)
- Id_Pedido (PK, FK)
- Preco_Unitario
- Data_Inicio_Garantia
- Data_Fim_Garantia_Loja
- Data_Fim_Garantia_Fabricante

#### PAGAMENTO
- Id_Pagamento (PK)
- Id_Pedido (FK)
- Codigo_Transacao
- Data_Tentativa
- Data_Confirmacao
- Valor
- Status
- Comprovante

#### NOTA_FISCAL
- Id_Nota (PK)
- Numero_Nota
- Id_PosVenda (FK)
- Id_Nota_Referencia (FK)
- Codigo_Cancelamento (FK)
- Id_Pedido (FK)
- Chave_Acesso
- Tipo_Nota
- Natureza
- Status
- Data_Emissao

#### ITEM_NOTA_FISCAL
- Imei (PK, FK)
- Id_Nota (PK, FK)
- Valor_Item

#### CANCELAMENTO
- Codigo_Cancelamento (PK)
- Id_Pedido (FK)
- Data_Solicitacao
- Motivo
- Status

#### ESTORNO
- Id_Estorno (PK)
- Id_Pagamento (FK)
- Codigo_Devolucao (FK)
- Codigo_Cancelamento (FK)
- Valor
- Data_Abertura
- Prazo_Limite
- Data_Conclusao
- Status

#### ENTREGA
- Codigo_Rastreio (PK)
- Codigo_Troca (FK)
- Id_Pedido (FK)
- Transportadora
- Status_Entrega
- Data_Despacho
- Data_Entrega
- Origem_Atualizacao

#### POS_VENDA
- Id_PosVenda (PK)
- Imei (FK)
- Id_Pedido (FK)
- Tipo_Solicitacao
- Data_Abertura
- Descricao
- Status

> Id_Pedido e Imei formam juntos uma única chave estrangeira composta, que aponta para ITEM_PEDIDO.

#### DEVOLUCAO
- Codigo_Devolucao (PK)
- Id_PosVenda (FK)
- Data_Devolucao
- Motivo
- Status

#### AVALIACAO_DANO
- Codigo_Avaliacao (PK)
- Id_PosVenda (FK)
- Codigo_Funcionario (FK)
- Classificacao_Dano
- Descricao_Dano
- Cobertura_Garantia
- Destino_Aparelho
- Data_Avaliacao

#### TROCA
- Codigo_Troca (PK)
- Id_PosVenda (FK)
- Imei_Reposicao (FK)
- Data_Troca
- Status

#### APARELHO
- Imei (PK)
- Id_Especificacao (FK)
- Id_Avaliacao_Entrada (FK)
- Codigo_Funcionario (FK)
- Condicao
- Preco_Venda
- Custo_Aquisicao
- Status
- Data_Entrada
- Data_Disponivel
- Data_Fim_Quarentena
- Elegivel_Desconto_Pix

#### IMAGEM_APARELHO
- Id_Imagem (PK)
- Imei (FK)
- URL

#### ESPECIFICACAO_APARELHO
- Id_Especificacao (PK)
- Id_Modelo (FK)
- Cor
- Capacidade
- Estoque_Minimo
- Limite_Dias_Atencao
- Limite_Dias_Critico

#### MODELO
- Id_Modelo (PK)
- Nome_Modelo
- Marca

#### REQUISICAO_COMPRA
- Id_Requisicao (PK)
- Codigo_Funcionario (FK)
- Id_Especificacao (FK)
- Qtd_Atual_Estoque
- Estoque_Minimo
- Parecer_Financeiro
- Data_Abertura
- Data_Decisao
- Motivo_Recusa
- Status
- Qtd_Sugerida

#### MOVIMENTACAO
- Numero_Movimentacao (PK)
- Codigo_Funcionario (FK)
- Imei (FK)
- Tipo_Movimento
- Status_Anterior
- Status_Novo
- Data_Hora

#### AUDITORIA
- Id_Auditoria (PK)
- Codigo_Funcionario (FK)
- Codigo_Autorizador (FK)
- Acao
- Tabela_Afetada
- Registro_Id
- Valor_Anterior
- Valor_Novo
- Data_Hora
- Descricao

#### FUNCIONARIO
- Codigo_Funcionario (PK)
- Nome
- Cargo
- Login
- Id_Perfil (FK)
- Ativo

#### PERFIL_ACESSO
- Id_Perfil (PK)
- Nome_Perfil
- Nivel_Acesso

#### FORNECEDOR
- Cpf_Cnpj_Fornecedor (PK)
- Tipo_Pessoa
- Nome
- Tipo_Documento
- Numero_Documento
- Telefone_Contato

#### AQUISICAO
- Id_Aquisicao (PK)
- Codigo_Funcionario (FK)
- Cpf_Cnpj_Fornecedor (FK)
- Data_Aquisicao
- Tipo_Documento_Compra
- Numero_Documento_Compra
- Termo_Responsabilidade_Aceito
- Valor_Total
- Status

#### AVALIACAO_ENTRADA
- Id_Avaliacao_Entrada (PK)
- Codigo_Funcionario (FK)
- Id_Aquisicao (FK)
- Imei_Avaliado
- Base_Consultada
- Resultado_Consulta_Imei
- Data_Consulta
- Checklist_Bateria
- Checklist_Tela
- Checklist_Cameras
- Checklist_Botoes
- Checklist_Som
- Checklist_Conectividade
- Checklist_Pecas_Originais
- Bloqueio_Conta
- Reset_Fabrica_Realizado
- Resultado
- Motivo_Recusa
- Data_Reconsulta_Imei
- Resultado_Reconsulta_Imei

### 6.3 Relacionamentos

| # | Entidade | Relação | Entidade |
|---|---|---|---|
| 1 | CLIENTE | **REALIZA** | PEDIDO |
| 2 | CLIENTE | **DISPÕE DE** (identificador) | TELEFONE |
| 3 | PEDIDO | **GERA** | PAGAMENTO |
| 4 | PEDIDO | **ORIGINA** | NOTA_FISCAL |
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
| 30 | ESTORNO | **REVERTE** | PAGAMENTO |
| 31 | NOTA_FISCAL | **LISTA** | ITEM_NOTA_FISCAL |
| 32 | ITEM_NOTA_FISCAL | **IDENTIFICA** | APARELHO |
| 33 | FORNECEDOR | **NEGOCIA** | AQUISICAO |
| 34 | AQUISICAO | **COMPREENDE** | AVALIACAO_ENTRADA |
| 35 | AVALIACAO_ENTRADA | **LIBERA** | APARELHO |
| 36 | FUNCIONARIO | **RECEBE** | AQUISICAO |
| 37 | FUNCIONARIO | **INSPECIONA** | AVALIACAO_ENTRADA |
| 38 | CLIENTE | **INFORMA** | ENDERECO |
| 39 | MODELO | **DEFINE** | ESPECIFICACAO_APARELHO |
| 40 | PERFIL_ACESSO | **CONCEDE** | FUNCIONARIO |

> Os relacionamentos 10 e 17 formam juntos a entidade associativa ITEM_PEDIDO, que resolve o relacionamento N:N entre PEDIDO e APARELHO. Da mesma forma, os relacionamentos 31 e 32 formam a entidade associativa ITEM_NOTA_FISCAL, que resolve o relacionamento N:N entre NOTA_FISCAL e APARELHO.

### 6.4 Cardinalidades

> Leitura da notação: em "A (x,y) — relação — B (z,w)", o par ao lado de cada entidade indica quantas ocorrências dela se ligam a uma ocorrência da outra.

**1. Cliente – Pedido**
 - Descrição: 1 CLIENTE realiza N PEDIDOs (cada pedido pertence a exatamente 1 cliente)
 - Notação: CLIENTE (1,1) — realiza — PEDIDO (0,N)

**2. Cliente – Telefone**
 - Descrição: 1 CLIENTE dispõe de pelo menos 1 TELEFONE (o telefone é obrigatório no cadastro, RN-01); cada telefone pertence a exatamente 1 cliente
 - Notação: CLIENTE (1,1) — dispõe de — TELEFONE (1,N)

**3. Pedido – Pagamento**
 - Descrição: 1 PEDIDO gera N PAGAMENTOs (tentativas de cobrança), dos quais no máximo 1 é Aprovado; cada pagamento pertence a exatamente 1 pedido
 - Notação: PEDIDO (1,1) — gera — PAGAMENTO (0,N)

**4. Pedido – Nota Fiscal**
 - Descrição: 1 PEDIDO origina no máximo 1 NOTA_FISCAL de venda; as notas de entrada e de reposição não têm essa origem
 - Notação: PEDIDO (0,1) — origina — NOTA_FISCAL (0,1)

**5. Pedido – Cancelamento**
 - Descrição: 1 PEDIDO sofre no máximo 1 CANCELAMENTO
 - Notação: PEDIDO (1,1) — sofre — CANCELAMENTO (0,1)

**6. Cancelamento – Nota Fiscal**
 - Descrição: 1 CANCELAMENTO exige no máximo 1 NOTA_FISCAL de entrada (apenas quando o prazo de cancelamento direto da nota de venda já passou)
 - Notação: CANCELAMENTO (0,1) — exige — NOTA_FISCAL (0,1)

**7. Cancelamento – Estorno**
 - Descrição: 1 CANCELAMENTO viabiliza no máximo 1 ESTORNO
 - Notação: CANCELAMENTO (0,1) — viabiliza — ESTORNO (0,1)

**8. Nota Fiscal (original) – Nota Fiscal (derivada)**
 - Descrição: 1 NOTA_FISCAL original é referenciada por N NOTA_FISCAL derivadas (autorrelacionamento); cada nota derivada referencia exatamente 1 nota original
 - Notação: NOTA_FISCAL original (1,1) — referencia — NOTA_FISCAL derivada (0,N)

**9. Pedido – Entrega**
 - Descrição: 1 PEDIDO possui N ENTREGAs (a entrega da venda e, quando houver troca, a entrega do aparelho de reposição)
 - Notação: PEDIDO (1,1) — possui — ENTREGA (0,N)

**10. Pedido – Item do Pedido**
 - Descrição: 1 PEDIDO contém N ITEM_PEDIDO (mínimo 1 item por pedido)
 - Notação: PEDIDO (1,1) — contém — ITEM_PEDIDO (1,N)

**11. Item do Pedido – Pós-Venda**
 - Descrição: 1 ITEM_PEDIDO recebe N solicitações de POS_VENDA
 - Notação: ITEM_PEDIDO (1,1) — recebe — POS_VENDA (0,N)

**12. Nota Fiscal – Pós-Venda**
 - Descrição: 1 POS_VENDA é documentado por N NOTA_FISCAL (na troca, uma de entrada e uma de saída); cada uma dessas notas documenta no máximo 1 POS_VENDA
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
 - Descrição: 1 APARELHO corresponde a N ITEM_PEDIDO ao longo do tempo (pode ser vendido de novo após devolução); cada item corresponde a exatamente 1 aparelho
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
 - Descrição: 1 APARELHO tem pelo menos 1 MOVIMENTACAO (a entrada no estoque); cada movimentação muda exatamente 1 aparelho
 - Notação: MOVIMENTACAO (1,N) — muda — APARELHO (1,1)

**23. Especificação do Aparelho – Requisição de Compra**
 - Descrição: 1 ESPECIFICACAO_APARELHO dispara N REQUISICAO_COMPRA
 - Notação: ESPECIFICACAO_APARELHO (1,1) — dispara — REQUISICAO_COMPRA (0,N)

**24. Funcionário – Requisição de Compra**
 - Descrição: 1 FUNCIONARIO (Diretoria) decide N REQUISICAO_COMPRA; a requisição ainda não decidida não tem decisor
 - Notação: FUNCIONARIO (0,1) — decide — REQUISICAO_COMPRA (0,N)

**25. Funcionário – Aparelho**
 - Descrição: 1 FUNCIONARIO cadastra N APARELHOs
 - Notação: FUNCIONARIO (1,1) — cadastra — APARELHO (0,N)

**26. Funcionário – Avaliação de Dano**
 - Descrição: 1 FUNCIONARIO avalia N AVALIACAO_DANO
 - Notação: FUNCIONARIO (1,1) — avalia — AVALIACAO_DANO (0,N)

**27. Auditoria – Funcionário**
 - Descrição: cada AUDITORIA rastreia no máximo 1 FUNCIONARIO executor (vazio quando a ação é automática)
 - Notação: AUDITORIA (0,N) — rastreia — FUNCIONARIO (0,1)

**28. Funcionário – Auditoria**
 - Descrição: 1 FUNCIONARIO (autorizador) autoriza N AUDITORIA (vazio quando a operação não exige autorização)
 - Notação: FUNCIONARIO (0,1) — autoriza — AUDITORIA (0,N)

**29. Funcionário – Movimentação**
 - Descrição: 1 FUNCIONARIO executa N MOVIMENTACAO (vazio quando a mudança é automática, como a baixa na aprovação do pagamento)
 - Notação: FUNCIONARIO (0,1) — executa — MOVIMENTACAO (0,N)

**30. Estorno – Pagamento**
 - Descrição: 1 PAGAMENTO aprovado pode ser revertido por N ESTORNOs (por exemplo, devoluções de aparelhos diferentes do mesmo pedido); cada estorno reverte exatamente 1 pagamento
 - Notação: ESTORNO (0,N) — reverte — PAGAMENTO (1,1)

**31. Nota Fiscal – Item da Nota Fiscal**
 - Descrição: 1 NOTA_FISCAL lista N ITEM_NOTA_FISCAL (mínimo 1 aparelho por nota)
 - Notação: NOTA_FISCAL (1,1) — lista — ITEM_NOTA_FISCAL (1,N)

**32. Item da Nota Fiscal – Aparelho**
 - Descrição: 1 APARELHO aparece em N ITEM_NOTA_FISCAL ao longo do tempo (venda, devolução, reposição); cada item identifica exatamente 1 aparelho
 - Notação: ITEM_NOTA_FISCAL (0,N) — identifica — APARELHO (1,1)

**33. Fornecedor – Aquisição**
 - Descrição: 1 FORNECEDOR negocia N AQUISICOES (o fornecedor só é cadastrado quando vende algo à loja); cada aquisição tem exatamente 1 fornecedor
 - Notação: FORNECEDOR (1,1) — negocia — AQUISICAO (1,N)

**34. Aquisição – Avaliação de Entrada**
 - Descrição: 1 AQUISICAO compreende N AVALIACAO_ENTRADA, uma para cada aparelho oferecido (mínimo 1)
 - Notação: AQUISICAO (1,1) — compreende — AVALIACAO_ENTRADA (1,N)

**35. Avaliação de Entrada – Aparelho**
 - Descrição: 1 AVALIACAO_ENTRADA aprovada libera no máximo 1 APARELHO (a recusada não libera nenhum); cada aparelho está ligado a exatamente 1 avaliação de entrada (a da sua entrada mais recente)
 - Notação: AVALIACAO_ENTRADA (1,1) — libera — APARELHO (0,1)

**36. Funcionário – Aquisição**
 - Descrição: 1 FUNCIONARIO (Estoque e Logística) recebe N AQUISICOES
 - Notação: FUNCIONARIO (1,1) — recebe — AQUISICAO (0,N)

**37. Funcionário – Avaliação de Entrada**
 - Descrição: 1 FUNCIONARIO (Assistência Técnica) inspeciona N AVALIACAO_ENTRADA
 - Notação: FUNCIONARIO (1,1) — inspeciona — AVALIACAO_ENTRADA (0,N)

**38. Cliente – Endereço**
 - Descrição: 1 CLIENTE informa pelo menos 1 ENDERECO (o endereço é obrigatório no cadastro, RN-01, e é usado na entrega e na nota fiscal); cada endereço pertence a exatamente 1 cliente
 - Notação: CLIENTE (1,1) — informa — ENDERECO (1,N)

**39. Modelo – Especificação do Aparelho**
 - Descrição: 1 MODELO define N ESPECIFICACAO_APARELHO (uma para cada combinação de cor e capacidade); cada especificação pertence a exatamente 1 modelo
 - Notação: MODELO (1,1) — define — ESPECIFICACAO_APARELHO (0,N)

**40. Perfil de Acesso – Funcionário**
 - Descrição: 1 PERFIL_ACESSO é concedido a N FUNCIONARIOs; cada funcionário tem exatamente 1 perfil
 - Notação: PERFIL_ACESSO (1,1) — concede — FUNCIONARIO (0,N)

### 6.5 Diagrama Entidade-Relacionamento

```mermaid
flowchart TD
    classDef entity fill:#e6f1fb,stroke:#185fa5,stroke-width:1px;
    classDef weak fill:#e6f1fb,stroke:#185fa5,stroke-width:4px;
    classDef assoc fill:#fff4d6,stroke:#b7791f,stroke-width:2px,stroke-dasharray: 6 3;
    classDef rel fill:#ffffff,stroke:#555555,stroke-width:1px;
    classDef relid fill:#ffffff,stroke:#555555,stroke-width:4px;

    CLIENTE[CLIENTE]
    ENDERECO[ENDERECO]
    TELEFONE[TELEFONE]
    PEDIDO[PEDIDO]
    ITEM_PEDIDO[ITEM_PEDIDO]
    PAGAMENTO[PAGAMENTO]
    NOTA_FISCAL[NOTA_FISCAL]
    ITEM_NOTA_FISCAL[ITEM_NOTA_FISCAL]
    CANCELAMENTO[CANCELAMENTO]
    ESTORNO[ESTORNO]
    ENTREGA[ENTREGA]
    POS_VENDA[POS_VENDA]
    DEVOLUCAO[DEVOLUCAO]
    AVALIACAO_DANO[AVALIACAO_DANO]
    TROCA[TROCA]
    APARELHO[APARELHO]
    IMAGEM_APARELHO[IMAGEM_APARELHO]
    ESPECIFICACAO_APARELHO[ESPECIFICACAO_APARELHO]
    MODELO[MODELO]
    REQUISICAO_COMPRA[REQUISICAO_COMPRA]
    MOVIMENTACAO[MOVIMENTACAO]
    AUDITORIA[AUDITORIA]
    FUNCIONARIO[FUNCIONARIO]
    PERFIL_ACESSO[PERFIL_ACESSO]
    FORNECEDOR[FORNECEDOR]
    AQUISICAO[AQUISICAO]
    AVALIACAO_ENTRADA[AVALIACAO_ENTRADA]

    class CLIENTE,ENDERECO,PEDIDO,PAGAMENTO,NOTA_FISCAL,CANCELAMENTO,ESTORNO,ENTREGA,POS_VENDA,DEVOLUCAO,AVALIACAO_DANO,TROCA,APARELHO,IMAGEM_APARELHO,ESPECIFICACAO_APARELHO,REQUISICAO_COMPRA,MOVIMENTACAO,AUDITORIA,FUNCIONARIO,FORNECEDOR,AQUISICAO,AVALIACAO_ENTRADA,MODELO,PERFIL_ACESSO entity
    class TELEFONE weak
    class ITEM_PEDIDO,ITEM_NOTA_FISCAL assoc

    CLIENTE -->|1| R1{"realiza"}
    R1 -->|0..N| PEDIDO

    CLIENTE -->|1| R2{"dispõe de"}
    R2 -->|1..N| TELEFONE

    PEDIDO -->|1| R3{"gera"}
    R3 -->|0..N| PAGAMENTO

    PEDIDO -->|0..1| R4{"origina"}
    R4 -->|0..1| NOTA_FISCAL

    PEDIDO -->|1| R5{"sofre"}
    R5 -->|0..1| CANCELAMENTO

    CANCELAMENTO -->|0..1| R6{"exige"}
    R6 -->|0..1| NOTA_FISCAL

    CANCELAMENTO -->|0..1| R7{"viabiliza"}
    R7 -->|0..1| ESTORNO

    NOTA_FISCAL -->|1| R8{"referencia"}
    R8 -->|0..N| NOTA_FISCAL

    PEDIDO -->|1| R9{"possui"}
    R9 -->|0..N| ENTREGA

    PEDIDO -->|1| R10{"contém"}
    R10 -->|1..N| ITEM_PEDIDO

    ITEM_PEDIDO -->|1| R11{"recebe"}
    R11 -->|0..N| POS_VENDA

    NOTA_FISCAL -->|0..N| R12{"documenta"}
    R12 -->|0..1| POS_VENDA

    POS_VENDA -->|1| R13{"ocasiona"}
    R13 -->|0..1| DEVOLUCAO

    DEVOLUCAO -->|0..1| R14{"resulta em"}
    R14 -->|0..1| ESTORNO

    POS_VENDA -->|1| R15{"desencadeia"}
    R15 -->|0..1| TROCA

    POS_VENDA -->|1| R16{"passa por"}
    R16 -->|0..1| AVALIACAO_DANO

    ITEM_PEDIDO -->|0..N| R17{"corresponde a"}
    R17 -->|1| APARELHO

    TROCA -->|0..N| R18{"repõe"}
    R18 -->|1| APARELHO

    TROCA -->|0..1| R19{"requer"}
    R19 -->|0..1| ENTREGA

    APARELHO -->|1| R20{"detém"}
    R20 -->|0..N| IMAGEM_APARELHO

    ESPECIFICACAO_APARELHO -->|1| R21{"classifica"}
    R21 -->|0..N| APARELHO

    MOVIMENTACAO -->|1..N| R22{"muda"}
    R22 -->|1| APARELHO

    ESPECIFICACAO_APARELHO -->|1| R23{"dispara"}
    R23 -->|0..N| REQUISICAO_COMPRA

    FUNCIONARIO -->|0..1| R24{"decide"}
    R24 -->|0..N| REQUISICAO_COMPRA

    FUNCIONARIO -->|1| R25{"cadastra"}
    R25 -->|0..N| APARELHO

    FUNCIONARIO -->|1| R26{"avalia"}
    R26 -->|0..N| AVALIACAO_DANO

    AUDITORIA -->|0..N| R27{"rastreia"}
    R27 -->|0..1| FUNCIONARIO

    FUNCIONARIO -->|0..1| R28{"autoriza"}
    R28 -->|0..N| AUDITORIA

    FUNCIONARIO -->|0..1| R29{"executa"}
    R29 -->|0..N| MOVIMENTACAO

    ESTORNO -->|0..N| R30{"reverte"}
    R30 -->|1| PAGAMENTO

    NOTA_FISCAL -->|1| R31{"lista"}
    R31 -->|1..N| ITEM_NOTA_FISCAL

    ITEM_NOTA_FISCAL -->|0..N| R32{"identifica"}
    R32 -->|1| APARELHO

    FORNECEDOR -->|1| R33{"negocia"}
    R33 -->|1..N| AQUISICAO

    AQUISICAO -->|1| R34{"compreende"}
    R34 -->|1..N| AVALIACAO_ENTRADA

    AVALIACAO_ENTRADA -->|1| R35{"libera"}
    R35 -->|0..1| APARELHO

    FUNCIONARIO -->|1| R36{"recebe"}
    R36 -->|0..N| AQUISICAO

    FUNCIONARIO -->|1| R37{"inspeciona"}
    R37 -->|0..N| AVALIACAO_ENTRADA

    CLIENTE -->|1| R38{"informa"}
    R38 -->|1..N| ENDERECO

    MODELO -->|1| R39{"define"}
    R39 -->|0..N| ESPECIFICACAO_APARELHO

    PERFIL_ACESSO -->|1| R40{"concede"}
    R40 -->|0..N| FUNCIONARIO

    class R1,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R27,R28,R29,R30,R31,R32,R33,R34,R35,R36,R37,R38,R39,R40 rel
    class R2 relid
```

#### Legenda

| Forma | Significado |
|---|---|
| Retângulo de borda fina | Entidade forte |
| Retângulo de borda grossa | Entidade fraca (`TELEFONE`) |
| Retângulo amarelo de borda tracejada | Entidade associativa (`ITEM_PEDIDO`, `ITEM_NOTA_FISCAL`): relacionamento N:N transformado em entidade por ter atributos próprios |
| Losango de borda fina | Relacionamento |
| Losango de borda grossa | Relacionamento identificador (`dispõe de`, entre `CLIENTE` e `TELEFONE`) |
| Número na linha | Cardinalidade (`1`, `0..1`, `0..N`, `1..N`) |

## 7. Modelo Lógico

O modelo lógico mostra cada tabela com os seus campos, tipos e chaves (PK e FK), e as ligações entre as tabelas com as cardinalidades. A cor do cabeçalho indica a área de cada tabela (legenda no canto inferior direito).

![Modelo lógico do CellGO](docs/diagramas/modelo_logico_cellgo.png)

### 7.1 Justificativas Técnicas

#### Controle de estoque por unidade (IMEI), e não por quantidade

**Decisão:** A entidade APARELHO é controlada individualmente pelo Imei (PK), e não existe nenhuma entidade de "saldo de estoque" por modelo.

**Justificativa:** A RN-03 e o RF-03 exigem que cada aparelho seja acompanhado individualmente, com seu próprio histórico, status, garantia e tempo em estoque. Isso não é possível quando o estoque é controlado apenas pela quantidade de cada modelo. Com um controle por quantidade, a empresa não saberia, por exemplo, qual unidade está parada há mais de 60 dias (RN-05) nem conseguiria ligar a garantia a um aparelho específico (RN-17). A contagem por modelo, usada no ponto de pedido (RN-06), é apenas uma consulta feita sobre os registros de APARELHO, e não uma tabela própria. Assim, não existem dois números de estoque diferentes que poderiam discordar entre si.

#### Separação entre APARELHO e ESPECIFICACAO_APARELHO

**Decisão:** Cor, Capacidade, Estoque_Minimo e os limites de dias de giro ficam em uma entidade própria, ESPECIFICACAO_APARELHO, separada da unidade física (APARELHO). O nome do modelo e a marca ficam em MODELO, ligada à especificação.

**Justificativa:** Esses dados valem para todos os aparelhos de uma mesma combinação de modelo, cor e capacidade, e não para cada unidade (RN-02, RN-05 e RN-06). Se ficassem dentro de APARELHO, o mesmo estoque mínimo teria de ser repetido em cada IMEI daquele modelo. Quando a Diretoria alterasse esse valor, seria preciso atualizar vários registros, com risco de algum ficar diferente dos outros. Com a separação, basta alterar um único registro. A separação também permite que a REQUISICAO_COMPRA (RN-06) seja gerada a partir da especificação, e não de um aparelho específico. Pelo mesmo motivo, o modelo e a marca ficam em MODELO: a marca depende só do modelo (todo iPhone 15 é da Apple), e não da cor nem da capacidade. Se a marca ficasse na especificação, ela se repetiria em cada combinação de cor e capacidade do mesmo modelo, o que seria uma dependência transitiva (Id_Especificacao → Modelo → Marca) e violaria a 3ª Forma Normal. Essa organização segue as regras de normalização: cada informação fica guardada na entidade da qual ela realmente depende.

#### Ausência de reserva de estoque e validação no fechamento da venda

**Decisão:** Não existe o status "Reservado" no ciclo de vida do APARELHO. A disponibilidade é conferida quando o cliente monta o pedido e conferida novamente no momento da aprovação do pagamento (RN-04).

**Justificativa:** A proibição de reserva é uma decisão explícita do negócio (RN-03 e RN-04). Ela simplifica o modelo e evita um problema comum em e-commerce: dois clientes "segurando" o mesmo aparelho ao mesmo tempo. Para impedir que duas compras sejam concluídas para a mesma unidade, a conferência da disponibilidade, a aprovação do pagamento e a mudança do status para "Vendido" acontecem como uma única operação: ou tudo é concluído junto, ou nada é gravado. Se outro cliente já tiver comprado o aparelho, a segunda compra é bloqueada e o cliente é informado. Isso sustenta o RNF-06 (confiabilidade).

#### Entidade fraca × entidade associativa

**Decisão:** O modelo usa os dois conceitos, cada um no lugar certo: TELEFONE é uma **entidade fraca**; ITEM_PEDIDO e ITEM_NOTA_FISCAL são **entidades associativas**.

**Justificativa:** Os dois conceitos são diferentes e não devem ser confundidos:

| | Entidade fraca | Entidade associativa |
|---|---|---|
| Origem | Depende de **uma** entidade dona para existir e para ser identificada | Nasce de um relacionamento **N:N** entre **duas** entidades que precisa guardar atributos próprios |
| Chave primária | Chave da entidade dona + um identificador parcial (discriminador) | Chaves das duas entidades que ela liga |
| Relacionamento | Ligada à dona por um relacionamento identificador | Ligada às duas entidades, sem dona única |
| No CellGO | TELEFONE: (Cpf_Cnpj + DDD + Numero_Telefone) | ITEM_PEDIDO: (Id_Pedido + Imei); ITEM_NOTA_FISCAL: (Id_Nota + Imei) |

TELEFONE é fraca porque não tem identidade fora do cliente: DDD e número só identificam o registro quando combinados com o Cpf_Cnpj do titular (identificador parcial), e o telefone deixa de existir se o cliente for removido. Por isso o relacionamento "dispõe de" é identificador.

ITEM_PEDIDO não é fraca: sua chave não é "chave do pedido + discriminador", mas a junção das chaves de duas entidades fortes, PEDIDO e APARELHO. A relação entre elas é N:N, porque um pedido pode ter vários aparelhos e um mesmo aparelho pode aparecer em vários pedidos ao longo do tempo (quando é devolvido e revendido). Esse relacionamento precisa guardar dados que pertencem à combinação dos dois: o preço praticado naquela venda e as datas de garantia daquele aparelho naquele pedido. Se ficassem em APARELHO, seriam substituídos a cada revenda; se ficassem em PEDIDO, não funcionariam para pedidos com mais de um aparelho. Por isso o relacionamento N:N é promovido a entidade associativa. A mesma lógica vale para ITEM_NOTA_FISCAL (uma nota lista vários aparelhos, e um aparelho aparece em várias notas: venda, devolução, reposição).

#### Telefone como entidade do cliente

**Decisão:** O telefone não é um campo dentro de CLIENTE: ele é modelado como a entidade fraca TELEFONE, ligada a CLIENTE por um relacionamento identificador, com cardinalidade 1..N.

**Justificativa:** A RN-01 e o RF-01 exigem telefone no cadastro, e um mesmo cliente pode ter mais de um número (celular, fixo ou WhatsApp). Um único atributo não comporta essa variação, e colunas fixas como Telefone1 e Telefone2 violariam a 1ª Forma Normal e limitariam a quantidade de números. Com a entidade TELEFONE, cada número é um registro separado. A cardinalidade mínima 1 no lado do telefone garante que todo cliente tenha pelo menos um contato, como exige a regra. Já no FORNECEDOR a regra pede apenas um contato, por isso lá o telefone é um atributo simples (Telefone_Contato).

#### Endereço como entidade própria

**Decisão:** Os dados de endereço (Rua, Numero, Complemento, Bairro, Cidade, CEP e Tipo_Endereco) saíram de CLIENTE e passaram para a entidade ENDERECO, com identificador próprio (Id_Endereco) e ligada ao cliente pelo Cpf_Cnpj, com cardinalidade 1..N.

**Justificativa:** Um mesmo cliente pode ter mais de um endereço: o residencial, o de entrega e, para pessoa jurídica, o comercial ou de cobrança. Com o endereço dentro de CLIENTE, só caberia um, ou seria preciso repetir colunas (Rua1, Rua2...), o que viola a 1ª Forma Normal. Com a entidade própria, cada endereço é um registro e o atributo Tipo_Endereco diz para que ele serve. ENDERECO tem identificador próprio (Id_Endereco) em vez de usar o Cpf_Cnpj como parte da chave porque nenhum outro atributo identifica o endereço com segurança: o cliente pode ter dois endereços do mesmo tipo, e qualquer campo do endereço pode ser alterado. A cardinalidade mínima 1 no lado do endereço garante que todo cliente tenha pelo menos um endereço, como exige a RN-01, já que ele é necessário para a entrega e para a nota fiscal.

#### Tipos de dados das chaves e dos valores

**Decisão:** IMEI é CHAR(15); CPF/CNPJ é VARCHAR(14); código de rastreio é VARCHAR(30); valores em dinheiro são DECIMAL(10,2). Os identificadores gerados pelo próprio sistema (Id_* e Codigo_*) são INT.

**Justificativa:** IMEI, CPF, CNPJ e código de rastreio são códigos, e não números usados em cálculos. O IMEI tem 15 dígitos e o CNPJ tem 14, o que não cabe em um INT; o CPF pode começar com zero, que seria perdido em um campo numérico; e o código de rastreio tem letras. Por isso são guardados como texto. Os valores em dinheiro usam DECIMAL(10,2), e não FLOAT, porque o FLOAT guarda valores aproximados e pode errar centavos em somas, descontos e estornos; o RNF-10 exige valores com duas casas decimais exatas.

#### Imagem do aparelho como entidade separada

**Decisão:** As fotos de cada aparelho ficam em uma entidade própria, IMAGEM_APARELHO (Id_Imagem, Imei, URL), e não em um atributo de APARELHO.

**Justificativa:** Como a venda é feita exclusivamente pela internet, cada aparelho pode ter várias fotos (frente, verso ou o detalhe de uma marca de uso em um seminovo, por exemplo), e a quantidade varia de uma unidade para outra. Guardar as fotos em um único campo de APARELHO dificultaria incluir ou remover uma imagem sem alterar o registro inteiro. Com a entidade própria, cada foto é um registro, identificado pelo seu próprio código (Id_Imagem) e ligado ao aparelho pelo Imei. Um aparelho pode não ter nenhuma foto ou ter uma ou várias (cardinalidade 1 : 0..N). Diferente de TELEFONE, IMAGEM_APARELHO tem identificador próprio (Id_Imagem), por isso é uma entidade forte.

#### Semântica de PEDIDO × PAGAMENTO

**Decisão:** PEDIDO representa a **venda e suas condições comerciais**: o que foi vendido (ITEM_PEDIDO), a forma de pagamento escolhida, o número de parcelas, o desconto, as taxas e o valor final. PAGAMENTO representa **cada tentativa de cobrança** desse valor enviada à instituição de pagamento, com código da transação, datas, valor e status. Os atributos Forma_Pagamento e Numero_Parcelas ficam apenas em PEDIDO, e os status das duas entidades são separados.

**Justificativa:** Na versão anterior, PEDIDO e PAGAMENTO repetiam a forma de pagamento e o número de parcelas, e o status do pedido misturava a situação da venda com a situação da cobrança ("Parcialmente pago"). Isso não deixava claro o que cada entidade representava, nem o que significava um pedido ter vários pagamentos.

A forma de pagamento pertence ao pedido porque é ela que define o valor da venda: o desconto Pix (RN-10) e as taxas do parcelamento (RN-12) são calculados antes da confirmação, a partir da forma escolhida. O pagamento, por sua vez, registra o que de fato aconteceu com a cobrança. A cardinalidade 1 : 0..N passa a ter um significado concreto: um Pix pode expirar, um cartão pode ser recusado e o cliente pode tentar de novo, e cada tentativa fica registrada com seu próprio status (Pendente, Aprovado, Recusado, Expirado ou Estornado). A regra de que existe no máximo um pagamento Aprovado por pedido garante que a venda não seja cobrada duas vezes. Se o cliente mudar a forma de pagamento entre uma tentativa e outra, o pedido é recalculado antes da nova cobrança (RN-11), e por isso a forma continua sendo um dado do pedido.

Com essa separação, cada status descreve uma única coisa: Status_Pedido diz em que ponto está a venda (Aberto, Aguardando pagamento, Pago, Finalizado, Cancelado), e o Status do pagamento diz o que aconteceu com cada cobrança. O status "Parcialmente pago" foi removido, pois o negócio não aceita dividir o pagamento entre formas diferentes e, no cartão parcelado, quem recebe as parcelas é a operadora, e não a loja.

#### NOTA_FISCAL ligada ao PEDIDO, e não ao PAGAMENTO

**Decisão:** A nota fiscal de venda passa a ser originada pelo PEDIDO (Id_Pedido), e não pelo PAGAMENTO. A NOTA_FISCAL continua tendo três origens possíveis e excludentes: Id_Pedido (nota de venda), Codigo_Cancelamento (nota de entrada por cancelamento fora do prazo de cancelamento direto) e Id_PosVenda (nota de entrada por devolução ou troca, e nota de saída do aparelho de reposição). O atributo Tipo_Nota indica qual é o documento.

**Justificativa:** A nota fiscal documenta uma operação com mercadoria: quem comprou, quais aparelhos (IMEI) e por qual valor. Essas informações estão no pedido e em seus itens, e não no pagamento. A aprovação do pagamento é apenas o **gatilho** que inicia a emissão (RN-20), ou seja, uma regra de momento, e não um vínculo entre os dados. Ligar a nota ao pagamento trazia ainda um problema: como um pedido pode ter várias tentativas de pagamento, a nota ficaria presa a uma tentativa específica, e não à venda. Ligada ao pedido, a nota de venda acompanha a venda inteira, independentemente de quantas tentativas de cobrança houve. A regra de que cada nota tem exatamente uma origem é registrada como restrição do modelo e verificada pelo sistema no momento da gravação.

#### Identificador próprio da NOTA_FISCAL e chave de acesso opcional

**Decisão:** A chave primária de NOTA_FISCAL passa a ser um identificador interno (Id_Nota). A chave de acesso (Chave_Acesso) e o número da nota (Numero_Nota) passam a ser atributos que podem ficar vazios, com a chave de acesso marcada como única.

**Justificativa:** A chave de acesso de 44 dígitos e o número da NF-e só existem depois que a SEFAZ autoriza a nota. Pela RN-20, a nota nasce com status "Aguardando emissão" e pode ficar "Pendente" em caso de erro, situações em que ainda não há chave nem número. Uma chave primária não pode ser vazia, por isso usar a chave de acesso como PK impediria registrar a nota antes da autorização. Com o Id_Nota, o registro existe desde o início da emissão, e a chave de acesso e o número são preenchidos quando a nota é autorizada. O número da nota também foi incluído porque o RF-17 e a RN-20 exigem registrá-lo.

#### ITEM_NOTA_FISCAL: os aparelhos documentados em cada nota

**Decisão:** A entidade associativa ITEM_NOTA_FISCAL (Id_Nota, Imei, Valor_Item) registra quais aparelhos cada nota documenta.

**Justificativa:** Uma nota fiscal lista mercadorias, e no CellGO cada mercadoria é um aparelho identificado pelo IMEI (Política Fiscal e Documental: rastreabilidade por IMEI). Sem essa entidade, a nota de saída da troca não teria como indicar o aparelho de reposição, porque esse aparelho não faz parte do pedido original (não é um ITEM_PEDIDO). Da mesma forma, a nota de entrada de uma devolução precisa indicar qual IMEI está voltando. Como uma nota pode listar vários aparelhos e um aparelho aparece em várias notas ao longo da vida (venda, devolução, reposição), a relação é N:N, resolvida pela entidade associativa.

#### Autorrelacionamento em NOTA_FISCAL ("referencia")

**Decisão:** NOTA_FISCAL tem um relacionamento com ela mesma. Uma nota de entrada ou de reposição aponta para a nota de venda original por meio do atributo Id_Nota_Referencia.

**Justificativa:** A RN-20, seguindo a legislação fiscal, exige que a nota de entrada (devolução) indique a nota de venda que está sendo desfeita: não existe nota de entrada "solta". A nota de saída do aparelho de reposição também fica ligada à nota original, para que toda a troca possa ser rastreada. O autorrelacionamento representa exatamente essa ligação. Uma nota original pode ter várias notas ligadas a ela (na troca, por exemplo, uma de entrada e uma de saída), mas cada uma dessas notas aponta para uma única nota original (cardinalidade 1 : 0..N). A nota de venda comum fica com Id_Nota_Referencia vazio, porque ela própria é a original.

#### POS_VENDA como entidade central de troca, devolução e garantia

**Decisão:** Em vez de ligar TROCA, DEVOLUCAO e AVALIACAO_DANO diretamente a ITEM_PEDIDO, o modelo cria POS_VENDA como ponto único de entrada para as solicitações do cliente sobre um aparelho já vendido. O CANCELAMENTO fica fora desse fluxo e se liga diretamente ao PEDIDO.

**Justificativa:** Troca por defeito (RN-14), devolução por arrependimento (RN-15), devolução por defeito (RN-16) e solicitações de garantia (RN-17) começam da mesma forma: o cliente abre uma solicitação, com data, descrição e status, sobre um aparelho específico. Depois disso, o aparelho passa por avaliação técnica (RN-18), e só então o caso segue para troca, devolução ou encerramento por mau uso. Concentrar essa abertura em POS_VENDA evita repetir os mesmos atributos em várias tabelas e permite que o histórico do cliente (RN-22) e a auditoria (RN-23) encontrem todas as solicitações em um só lugar. O cancelamento é diferente: ele vale para o pedido inteiro, só pode acontecer antes do envio (RN-13) e não passa por avaliação de dano. Por isso, fica em uma entidade própria, ligada ao PEDIDO.

#### DEVOLUCAO como entidade única para arrependimento e defeito

**Decisão:** Uma única entidade, DEVOLUCAO, atende tanto a devolução por arrependimento (RN-15) quanto a devolução por defeito (RN-16). O tipo vem do atributo Tipo_Solicitacao do POS_VENDA que originou a devolução.

**Justificativa:** Os dois tipos de devolução guardam as mesmas informações: data, motivo, status e ligação com POS_VENDA e ESTORNO. O que muda é a regra que autoriza cada uma. A devolução por arrependimento não exige defeito e deve ser pedida em até 7 dias após o recebimento. A devolução por defeito só é autorizada quando o defeito é coberto pela garantia e não há aparelho equivalente para troca. Nos dois casos, o aparelho passa por avaliação técnica (AVALIACAO_DANO) antes de voltar ao estoque. Criar duas entidades repetiria os mesmos atributos e dificultaria a consulta do histórico do cliente (RN-22), que precisa mostrar todas as devoluções juntas. A diferença entre os dois tipos fica no Tipo_Solicitacao do POS_VENDA e nas validações de cada regra, e não na estrutura da tabela. DEVOLUCAO não repete esse tipo em um atributo próprio porque ele já é determinado pela solicitação de origem; guardá-lo de novo criaria uma dependência transitiva (Codigo_Devolucao → Id_PosVenda → Tipo_Solicitacao), contrária à 3ª Forma Normal.

#### ESTORNO ligado ao pagamento revertido, com duas origens que não se misturam

**Decisão:** Todo ESTORNO tem uma chave estrangeira obrigatória para o PAGAMENTO que está sendo revertido (Id_Pagamento) e duas chaves estrangeiras opcionais de origem, Codigo_Cancelamento e Codigo_Devolucao, das quais apenas uma é preenchida.

**Justificativa:** A RN-19 determina que o estorno siga a forma de pagamento original: Pix devolvido para a conta de origem e cartão estornado junto à operadora. Para isso, o estorno precisa saber qual cobrança está desfazendo, e essa informação está no pagamento aprovado (código da transação, valor e data). Sem esse vínculo, o sistema teria de "adivinhar" o pagamento a partir do pedido. A forma de restituição não é guardada no ESTORNO, porque é determinada pela forma de pagamento do pedido (Pix → devolução Pix; cartão → estorno no cartão); guardá-la também seria uma dependência transitiva. Um mesmo pagamento pode ter mais de um estorno quando o pedido tem vários aparelhos e mais de um deles é devolvido (cardinalidade 1 : 0..N).

Quanto à origem, a RN-19 prevê estorno em duas situações diferentes: quando o pedido é cancelado antes do envio e o pagamento já tinha sido feito (RN-13), e quando há devolução, por arrependimento (RN-15) ou por defeito (RN-16). A troca não gera estorno, porque o aparelho de reposição tem valor igual ou superior e não há diferença a devolver ao cliente (RN-14). Um mesmo estorno nunca nasce de um cancelamento e de uma devolução ao mesmo tempo. Usar duas chaves estrangeiras com nomes claros, em vez de um único campo genérico de "origem", deixa evidente de onde veio cada estorno. A garantia de que apenas uma das duas é preenchida é registrada como restrição do modelo e verificada pelo sistema no momento da gravação. A situação "atrasado" não é gravada como status: ela é calculada pela comparação entre o Prazo_Limite e a data atual enquanto o estorno estiver Pendente.

#### Cardinalidades opcionais (0,1) nos relacionamentos de pós-venda

**Decisão:** Relacionamentos como POS_VENDA–DEVOLUCAO, POS_VENDA–TROCA e CANCELAMENTO–ESTORNO têm, do lado opcional, cardinalidade máxima 1 (0..1), e nunca 0..N.

**Justificativa:** As regras de negócio determinam que cada solicitação gere no máximo um resultado de cada tipo: uma solicitação de pós-venda gera no máximo uma troca e no máximo uma devolução, e um cancelamento gera no máximo um estorno. A cardinalidade 0..1 impede, já no modelo de dados, que esses registros sejam duplicados. Além disso, a RN-14 determina que uma mesma solicitação resulte em troca ou em devolução, nunca nas duas. Como a cardinalidade sozinha não consegue expressar essa escolha entre dois relacionamentos, ela é registrada como restrição do modelo e verificada pelo sistema.

#### Nenhum dado bancário armazenado (LGPD)

**Decisão:** O sistema não guarda dados bancários do cliente (banco, agência ou conta) em nenhuma entidade.

**Justificativa:** A RNF-02 exige que o sistema guarde o mínimo possível de dados pessoais. Como a loja aceita apenas Pix e cartão de crédito, todo estorno volta pelo mesmo meio usado na compra: o Pix é devolvido para a conta de origem pela própria instituição de pagamento, e o cartão é estornado junto à operadora, a partir do código da transação registrado em PAGAMENTO (RN-19). Em nenhum desses casos a loja precisa conhecer a conta bancária do cliente. Por isso, ESTORNO não tem atributos bancários, o que elimina um dado pessoal sensível do banco de dados e reduz o risco em caso de vazamento.

#### MOVIMENTACAO como histórico de mudanças de status do APARELHO

**Decisão:** Toda mudança de status do aparelho gera um registro em MOVIMENTACAO, com Status_Anterior, Status_Novo, Funcionário e Data_Hora. O APARELHO continua guardando o seu status atual.

**Justificativa:** A RN-03, a RN-23 e o RF-03 exigem o histórico completo de cada mudança de status: quando o aparelho entrou no estoque, quando saiu da quarentena, quando foi vendido, quando foi para "Em avaliação", quando voltou a "Disponível" e quem fez cada alteração. O status atual em APARELHO atende às consultas do dia a dia, como verificar se a unidade pode ser vendida, mas não mostra o que aconteceu antes. Por isso, o histórico fica em uma entidade própria, e todo aparelho tem pelo menos uma movimentação: a entrada no estoque (cardinalidade 1..N). O funcionário é opcional (Codigo_Funcionario pode ficar vazio) porque algumas mudanças são automáticas, como a baixa do aparelho quando o pagamento é aprovado. Esse histórico também ajuda a conferir o controle do tempo em estoque (RN-05), que reinicia a contagem quando o aparelho volta ao estoque após uma troca ou devolução.

#### Perfis de acesso em uma entidade própria (PERFIL_ACESSO)

**Decisão:** Os perfis de acesso ficam na entidade PERFIL_ACESSO (Id_Perfil, Nome_Perfil, Nivel_Acesso), e cada FUNCIONARIO aponta para o seu perfil (Id_Perfil). O nível de acesso deixa de ser um atributo do funcionário.

**Justificativa:** A RN-24 define cinco perfis (um para cada uma das quatro áreas e um para a Diretoria) e dois níveis hierárquicos: o Nível 1, operacional, para os perfis das áreas, e o Nível 2, estratégico, exclusivo da Diretoria. O nível depende apenas do perfil: todo funcionário com o perfil Diretoria tem Nível 2, e todos os outros têm Nível 1. Se o nível ficasse em FUNCIONARIO junto com o perfil, haveria uma dependência transitiva (Codigo_Funcionario → Perfil → Nivel_Acesso), que viola a 3ª Forma Normal e permitiria gravar combinações contraditórias, como um funcionário de Vendas com Nível 2. Com PERFIL_ACESSO, a relação entre perfil e nível é cadastrada uma única vez, e o funcionário só indica o seu perfil. Essa tabela também é consultada em toda validação de autorização (RF-20 e RN-24), por exemplo para conferir se o funcionário indicado como autorizador em AUDITORIA (Codigo_Autorizador) tem permissão para autorizar aquela operação.

#### Dois relacionamentos distintos entre AUDITORIA e FUNCIONARIO

**Decisão:** AUDITORIA se relaciona com FUNCIONARIO duas vezes: uma para quem executou a ação ("rastreia") e outra para quem a autorizou ("autoriza"). Cada uma usa sua própria chave estrangeira: Codigo_Funcionario e Codigo_Autorizador.

**Justificativa:** A RN-23 exige o registro do usuário responsável por cada operação, e a RN-24 exige que, nas operações que precisam de autorização, também fique registrado quem autorizou, com seu perfil e sua área. Essas duas pessoas podem ser diferentes. Por exemplo: quando um aparelho fica encalhado, um colaborador de Estoque e Logística pode registrar a revisão do preço daquele IMEI, mas essa alteração precisa ser autorizada pela Diretoria (RN-05). Uma única chave estrangeira não conseguiria guardar as duas informações. As duas chaves são opcionais (cardinalidade 0..1 do lado do funcionário): o executor fica vazio quando a ação é automática, como a atualização da entrega feita pela integração com a transportadora (RF-23), e o autorizador fica vazio quando a operação não exige autorização.

#### REQUISICAO_COMPRA ligada à especificação, e não ao aparelho

**Decisão:** REQUISICAO_COMPRA tem chave estrangeira para ESPECIFICACAO_APARELHO, e não para APARELHO.

**Justificativa:** O ponto de pedido (RN-06) é calculado por combinação de modelo, cor e capacidade, e a requisição trata de uma compra futura, cujos aparelhos ainda não existem no sistema e, portanto, ainda não têm IMEI. Por isso, não seria possível ligar a requisição a um APARELHO específico. A ligação correta é com a especificação. Ela também permite aplicar a regra de que só pode existir uma requisição em aberto para cada especificação, evitando pedidos de compra duplicados. O pedido de compra ao fornecedor fica fora do escopo do sistema (RN-06); quando os novos aparelhos chegam, a entrada deles segue o fluxo de aquisição (RN-25).

#### Aquisição e procedência: FORNECEDOR, AQUISICAO e AVALIACAO_ENTRADA

**Decisão:** A entrada de aparelhos no estoque passa a ser modelada por três entidades: FORNECEDOR (quem vende o aparelho para a loja), AQUISICAO (cada compra, com o documento da compra) e AVALIACAO_ENTRADA (a consulta do IMEI e o checklist técnico de cada aparelho oferecido). Todo APARELHO fica ligado à avaliação de entrada aprovada que permitiu o seu cadastro.

**Justificativa:** A Política de Aquisição (Seção 5.4) e a RN-25 exigem várias informações que, na versão anterior, não tinham onde ser guardadas: quem vendeu o aparelho e com qual documento, o resultado da consulta do IMEI, o checklist técnico, a verificação de bloqueio iCloud/FRP, o termo de responsabilidade, o documento da compra, o limite de aparelhos por CPF/dia e a quarentena. Sem essas entidades, a empresa não conseguiria comprovar a procedência lícita do estoque, que é justamente o objetivo das políticas.

Cada entidade guarda o que depende dela. Os dados de identificação ficam em FORNECEDOR, porque valem para todas as vendas que aquela pessoa ou empresa fizer à loja. O documento da compra, a data e o termo de responsabilidade ficam em AQUISICAO, porque pertencem àquela transação. Os resultados de verificação ficam em AVALIACAO_ENTRADA, porque são feitos aparelho por aparelho. O limite de 3 aparelhos por CPF/dia não precisa de atributo: é uma consulta que conta as avaliações aprovadas das aquisições daquele fornecedor naquela data.

AVALIACAO_ENTRADA é uma entidade separada de APARELHO porque a avaliação acontece **antes** de o aparelho existir no estoque e é registrada **mesmo quando o aparelho é recusado** (para comprovar que a loja verificou e recusou um aparelho irregular). Por isso o IMEI avaliado é um atributo comum (Imei_Avaliado), e não uma chave estrangeira: um aparelho recusado nunca chega a ser cadastrado em APARELHO. Quando a avaliação é aprovada, o aparelho é cadastrado e passa a apontar para ela (Id_Avaliacao_Entrada), e, por meio dela, chega-se à aquisição e ao fornecedor sem repetir esses dados no APARELHO. Se um aparelho já vendido for recomprado no futuro, ele passa por uma nova avaliação, e o APARELHO passa a apontar para a avaliação mais recente; as anteriores continuam no histórico, localizáveis pelo Imei_Avaliado.

Os itens do checklist foram modelados como atributos de AVALIACAO_ENTRADA, e não como uma entidade à parte, porque a lista de itens é fixa e definida pela própria política (bateria, tela, câmeras, botões, som, conectividade e peças). Ficam vazios para aparelhos lacrados, nos quais o checklist não se aplica.

A quarentena não precisou de uma entidade nova: ela é um status do APARELHO (Em quarentena), com a data de término calculada (Data_Fim_Quarentena), e a nova consulta do IMEI ao fim do prazo fica registrada na própria avaliação de entrada (Data_Reconsulta_Imei e Resultado_Reconsulta_Imei). Isso mantém o controle por IMEI (RN-03) e registra a mudança de status em MOVIMENTACAO, como acontece com qualquer outro status.

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

## 10. Implementação SQL

Os scripts ficam na pasta [`sql/`](sql) e foram feitos para MySQL 8. A estrutura do banco está dividida em dois arquivos:

| Arquivo | O que faz |
|---|---|
| [`tabelas.sql`](sql/ddl/tabelas.sql) | Cria o banco `cellgo` e as 27 tabelas do modelo lógico, com chaves primárias e estrangeiras, restrições `CHECK` e colunas calculadas |
| [`trigger.sql`](sql/ddl/trigger.sql) | Cria as 67 triggers que aplicam as regras de negócio direto no banco: controle de status por IMEI, desconto Pix pela faixa de preço, permissões da Diretoria, registro automático em `MOVIMENTACAO` e `AUDITORIA` e bloqueio de exclusão de dados históricos |
| [`update.sql`](sql/dados/update.sql) | Exemplos de alteração de registros (`UPDATE` com cálculo, subconsulta e `JOIN`), sempre informando o funcionário responsável em `@cellgo_funcionario` |
| [`delete.sql`](sql/dados/delete.sql) | Exemplos de exclusão permitida e de exclusões que o banco barra de propósito, seguindo a política de não apagar dados fiscais e de auditoria |

Para comprovar que as regras funcionam, há dois arquivos de teste. Cada teste roda dentro de uma transação desfeita no final, então o banco não é alterado:

| Arquivo | O que testa |
|---|---|
| [`testes_triggers.sql`](evidencias/testes_triggers.sql) | Se as triggers aceitam as operações corretas e barram as erradas (135 testes) |
| [`testes_validacoes.sql`](evidencias/testes_validacoes.sql) | Se as restrições das tabelas barram dados preenchidos de forma errada (171 testes) |

**Ordem de execução**

1. `DROP DATABASE IF EXISTS cellgo;` (só quando for rodar de novo)
2. [`tabelas.sql`](sql/ddl/tabelas.sql)
3. [`trigger.sql`](sql/ddl/trigger.sql)
4. [`insert_validos.sql`](sql/dados/insert_validos.sql)
5. [`select.sql`](sql/consultas/select.sql)
6. [`join.sql`](sql/consultas/join.sql)
7. [`consultas_gerenciais.sql`](sql/consultas/consultas_gerenciais.sql)
8. [`auditoria.sql`](sql/auditoria/auditoria.sql)
9. [`update.sql`](sql/dados/update.sql)
10. [`delete.sql`](sql/dados/delete.sql). A parte 5 tem erros intencionais, que mostram o banco barrando exclusões proibidas. Por isso é preciso rodar com "continuar em caso de erro" ou executar esses comandos um por um

Os testes devem rodar em um banco limpo: `DROP DATABASE`, [`tabelas.sql`](sql/ddl/tabelas.sql), [`trigger.sql`](sql/ddl/trigger.sql), [`testes_triggers.sql`](evidencias/testes_triggers.sql) e [`testes_validacoes.sql`](evidencias/testes_validacoes.sql).

## 11. Massa de Dados

O arquivo [`insert_validos.sql`](sql/dados/insert_validos.sql) carrega os dados de teste do projeto. Os `INSERT` seguem a ordem em que as operações aconteceriam na loja: fornecedores e aquisições, avaliação de entrada, cadastro dos aparelhos, pedidos, pagamentos, notas fiscais, entregas e pós-venda.

Parte dos dados não é digitada, e sim calculada pelas triggers. É o caso dos valores do pedido e do desconto Pix, do valor total da aquisição e do histórico em `MOVIMENTACAO`. Assim, a massa de dados também serve para mostrar as regras de negócio funcionando. Ela inclui casos que dão certo e casos com problema, como um pedido cancelado, um cancelamento recusado, uma devolução por arrependimento, uma garantia negada por mau uso e aparelhos recusados na avaliação de entrada por IMEI irregular.

Para consultar os dados carregados, use [`select.sql`](sql/consultas/select.sql) (consultas em uma tabela, com filtros, ordenação e agregação) e [`join.sql`](sql/consultas/join.sql) (consultas que juntam várias tabelas).

## 12. Consultas Gerenciais

O arquivo [`consultas_gerenciais.sql`](sql/consultas/consultas_gerenciais.sql) reúne as consultas que respondem perguntas de quem decide, como quanto foi vendido, quais modelos dão mais lucro e o que precisa ser reposto. Elas usam `JOIN`, `GROUP BY` e funções de agregação (`SUM`, `COUNT`, `AVG`) e consideram como venda apenas os pedidos Pagos ou Finalizados.

Os indicadores e relatórios gerenciais da Etapa 8 também foram calculados direto no banco e estão documentados em:

- [8.1 e 8.2 Indicadores](evidencias/etapa8/CellGO_Etapa8_Indicadores.docx): margem bruta por modelo, tempo em estoque por IMEI e taxa de recusa por fornecedor, com a consulta SQL de cada um
- [8.3 Informações Gerenciais](evidencias/etapa8/CellGO_Etapa8_Informacoes_Gerenciais.docx): painel de vendas, situação do pós-venda e dos estornos e histórico completo do cliente
- [8.4 Tomada de Decisão](evidencias/etapa8/CellGO_Etapa8_Tomada_de_Decisao.docx): quatro decisões apoiadas pelos dados e como cada uma fica registrada no banco

## 13. Consultas de Auditoria

O arquivo [`auditoria.sql`](sql/auditoria/auditoria.sql) reúne as consultas usadas para conferir o que aconteceu no sistema e quem fez cada operação. Elas leem a tabela `AUDITORIA`, preenchida automaticamente pelas triggers, e o histórico de status em `MOVIMENTACAO`. Com elas é possível ver, por exemplo, quem alterou o preço de um aparelho e quem autorizou, as decisões das requisições de compra e todo o caminho de um IMEI desde a entrada até a venda. Os registros de auditoria não podem ser alterados nem excluídos (RN-23).

## 14. Potencial para BI e IA

Como cada aparelho é identificado pelo IMEI do começo ao fim e as operações ficam registradas com data, valor e responsável, o banco já serve de base para análises mais avançadas:

- [8.5 Business Intelligence](evidencias/etapa8/CellGO_Etapa8_BI.docx): proposta de data mart em modelo estrela (4 tabelas de fatos e 6 dimensões), painéis por perfil e um exemplo de cruzamento entre pós-venda e fornecedor de origem
- [8.6 Futuras Aplicações de IA](evidencias/etapa8/CellGO_Etapa8_IA.docx): cinco aplicações possíveis (previsão de demanda, sugestão de preço, risco na aquisição, apoio à avaliação de dano e assistente de atendimento), o que o banco já oferece para cada uma e os cuidados para adotar IA

## 15. Histórico e Evolução do Projeto

| Período | O que foi feito |
|---|---|
| Setembro/2026 | Caracterização da empresa, problemas identificados, processos de negócio, requisitos funcionais e não funcionais e primeiras versões das regras de negócio |
| Setembro/2026 | Fluxogramas, entidades, atributos, relacionamentos, cardinalidades, DER com legenda, dicionário de dados, justificativas técnicas e conclusão |
| Outubro/2026 | Ajustes pedidos na devolutiva |
| Novembro/2026 | Normalização do modelo, dicionário de dados atualizado, modelo lógico e retirada do boleto das formas de pagamento |
| Novembro/2026 | Scripts SQL: criação das tabelas e triggers, massa de dados, `SELECT`, `JOIN`, consultas gerenciais, consultas de auditoria, `UPDATE`, `DELETE` e testes das regras |
| Novembro/2026 | Etapa 8: indicadores, informações gerenciais, tomada de decisão, BI e IA |

O histórico completo de alterações pode ser consultado nos commits de cada branch: [`feature/readme`](https://github.com/RyanHenrique20/CellGO/commits/feature/readme) (documentação) e [`feature/scripts`](https://github.com/RyanHenrique20/CellGO/commits/feature/scripts) (scripts SQL).

## 16. Conclusão

A CellGo Comércio de Celulares Ltda. vende aparelhos novos e seminovos exclusivamente pela internet. Por ser um e-commerce, a empresa não tem loja física, vendedor, comissão nem desconto negociado, e toda a relação com o cliente acontece on-line, do cadastro até o pós-venda. Sem um sistema que integre vendas, estoque, assistência técnica e financeiro, a empresa corre riscos concretos: vender um aparelho que já não está disponível, aceitar uma troca fora da garantia, perder o prazo de um estorno ou deixar uma devolução sem a nota fiscal correta. O problema, portanto, não é de tecnologia, mas de informação que não circula entre as áreas.

O ERP proposto reduz esses riscos pela forma como organiza os dados. Cada aparelho é controlado individualmente pelo IMEI, com seu próprio status, histórico de movimentações e tempo parado em estoque, e só entra no estoque depois de ter a procedência comprovada: o sistema registra quem vendeu o aparelho à loja, o documento da compra, a consulta do IMEI, o checklist técnico e, para seminovos comprados de pessoa física, a quarentena. Não existe reserva de aparelhos: a disponibilidade é conferida no fechamento da venda, e o aparelho só passa a constar como vendido quando o pagamento é aprovado. O pedido guarda as condições da venda, e cada tentativa de cobrança fica registrada como um pagamento separado. As formas de pagamento aceitas são apenas Pix, sempre à vista, e cartão de crédito, de 1 a 12 vezes. O único desconto é o do Pix, aplicado automaticamente conforme a faixa de preço e apenas aos produtos elegíveis.

A entrega é acompanhada por meio de integração com o sistema da transportadora, e o status do envio define o que o cliente pode solicitar. Enquanto o aparelho aguarda envio e dentro de 7 dias da compra, é possível cancelar a venda. Depois do despacho, o cliente pode pedir a devolução por arrependimento, em até 7 dias após o recebimento, ou o atendimento por defeito. A troca só é feita quando o defeito é coberto pela garantia da loja, em até 30 dias da compra, e sempre por um aparelho equivalente disponível em estoque. Se não houver aparelho equivalente, a empresa faz a devolução com restituição integral do valor. Danos causados por mau uso, identificados na avaliação técnica, não são cobertos nem reparados.

Cada uma dessas operações deixa registro fiscal e financeiro. A nota fiscal de venda documenta o pedido e os aparelhos vendidos, e sua emissão começa quando o pagamento é aprovado. Se a venda for cancelada dentro do prazo legal, essa nota também é cancelada; fora desse prazo, a operação é desfeita por uma nota de entrada. Devoluções e trocas também geram uma nota de entrada vinculada à nota original, e a troca gera ainda uma nota de saída para o aparelho de reposição. O estorno fica ligado ao pagamento que está sendo revertido e é feito pela mesma forma de pagamento usada na compra, em no máximo 15 dias, e o Financeiro é alertado em caso de atraso. Nas devoluções, o estorno só é liberado depois que a nota de entrada é emitida.

Na prática, a CellGo ganha três benefícios. O primeiro é menos prejuízo e menos retrabalho, porque o sistema impede erros que, sem ele, dependeriam de alguém lembrar de conferir. O segundo é a tomada de decisões com base em dados. O controle do tempo em estoque classifica cada aparelho como de giro normal, lento ou encalhado e avisa a Diretoria e a área de Estoque e Logística quando uma unidade fica parada por muito tempo, para que ela seja colocada em promoção ou tenha o preço revisto. Já o ponto de pedido abre automaticamente uma requisição de compra quando um modelo atinge o estoque mínimo; essa requisição é analisada pelo Financeiro e aprovada ou recusada pela Diretoria. O terceiro benefício é a segurança fiscal e jurídica: a procedência de cada aparelho, as notas, as garantias e os prazos do Código de Defesa do Consumidor são controlados pelo próprio sistema, e cada operação importante fica registrada na auditoria, com o nome de quem a realizou e, quando necessário, de quem a autorizou.

Com dois sócios e oito colaboradores, distribuídos entre a Diretoria e quatro áreas (Vendas e Atendimento, Estoque e Logística, Assistência Técnica e Financeiro/Administrativo), a empresa é pequena o bastante para adotar o sistema rapidamente e grande o bastante para perceber os benefícios logo no início. Os dois níveis de acesso garantem que cada pessoa realize apenas as tarefas da sua área. Além disso, a estrutura de dados permite o crescimento em vendas, aparelhos e usuários sem precisar ser refeita.
