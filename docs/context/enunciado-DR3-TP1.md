# Entrega 1 — Proposta e Arquitetura Inicial de Microservices

> **Documento de origem acadêmica.** Este é o enunciado da atividade, reproduzido aqui para que o
> repositório seja autocontido e a avaliação possa ser conferida contra o texto original.
> Bloco Engenharia de Softwares Escaláveis · Disciplina Microsserviços e DevOps com Spring Boot e
> Spring Cloud [26E3_3] · Professor Wesley Bruno Barbosa Silva · Instituto Infnet.
>
> A implementação deste repositório é resposta a este enunciado; o texto em si é de autoria docente.

---

## 1. Objetivo da entrega

Nesta primeira entrega, cada grupo deverá apresentar a proposta inicial do trabalho prático da
disciplina, descrevendo o tema escolhido, os integrantes do grupo e a arquitetura inicial da solução
baseada em microservices.

O objetivo é que o grupo demonstre capacidade de pensar uma aplicação distribuída, decompor o
problema em serviços menores, definir responsabilidades claras para cada microservice e iniciar a
construção de uma arquitetura com Discovery Server, API Gateway e bancos de dados separados por
serviço.

Esta entrega não exige ainda uma solução completa de negócio, mas exige que a arquitetura inicial
esteja bem definida e que os serviços principais estejam funcionando de forma integrada.

## 2. Organização da entrega por turma

As regras de formação e quantidade mínima de microservices variam de acordo com a turma.

### 2.1. Turma de segunda e quarta

O trabalho poderá ser realizado de duas formas: individualmente ou em dupla, no máximo. Não serão
permitidos grupos com mais de 2 alunos nesta turma.

**Trabalho individual.** O aluno deverá implementar pelo menos **2 microservices**. Além disso, o
projeto deverá conter pelo menos **1 banco de dados não relacional**, com justificativa técnica
clara para seu uso. O aluno deverá explicar:

- qual microservice utilizará o banco não relacional;
- qual banco não relacional será utilizado;
- por que esse banco faz sentido para aquele serviço;
- que tipo de dado, consulta ou necessidade arquitetural justifica essa escolha.

**Trabalho em dupla.** Cada aluno deverá ficar responsável por pelo menos 1 microservice. A dupla
deverá entregar, no mínimo: 2 microservices; 1 microservice por aluno; pelo menos 1 banco de dados
não relacional no projeto; justificativa técnica para o uso do banco não relacional. A divisão de
responsabilidade deverá estar explícita no documento e no README do projeto.

| Aluno | Microservice sob responsabilidade | Banco utilizado |
|---|---|---|
| Aluno 1 | product-service | PostgreSQL |
| Aluno 2 | search-service | MongoDB ou Elasticsearch |

### 2.2. Turma de terça e quinta

O trabalho deverá conter pelo menos N microservices, sendo N o número de alunos do grupo. Cada aluno
deverá estar associado a pelo menos um microservice no projeto.

| Quantidade de alunos | Quantidade mínima de microservices |
|---|---|
| 5 alunos | 5 microservices |
| 6 alunos | 6 microservices |
| 7 alunos | 7 microservices |
| 8 alunos | 8 microservices |

O grupo também deverá analisar seus microservices e indicar qual deles poderia utilizar um banco de
dados não relacional, justificando tecnicamente a escolha.

### 2.3. Informações obrigatórias sobre a equipe

Independentemente da turma, cada entrega deverá informar:

- nome completo dos integrantes;
- turma;
- se a entrega é individual, em dupla ou em grupo;
- microservice sob responsabilidade de cada integrante;
- responsável pela organização da entrega;
- link do repositório do projeto.

A divisão de papéis não precisa ser definitiva, mas deve indicar como o grupo pretende se organizar
inicialmente. Exemplos de papéis possíveis: responsável pelo API Gateway; pelo Discovery Server; por
um ou mais microservices; pelos bancos de dados; pela documentação; pelos testes e execução do
projeto.

## 3. Tema do trabalho

O tema do trabalho é livre. Cada grupo deverá escolher um domínio de aplicação que permita a
decomposição em múltiplos microservices.

Exemplos de temas possíveis: sistema de delivery; plataforma de cursos online; sistema de reservas;
marketplace; sistema de eventos; sistema de logística; sistema financeiro fictício; plataforma de
saúde; sistema acadêmico; aplicação para esportes, jogos, música, cinema ou qualquer outro domínio
aprovado pelo professor.

O grupo deverá descrever claramente:

- qual problema o sistema pretende resolver;
- quem são os usuários principais;
- quais são as principais funcionalidades previstas;
- por que o tema escolhido faz sentido para uma arquitetura baseada em microservices.

## 4. Definição dos microservices

Cada grupo deverá propor e implementar uma arquitetura inicial composta por múltiplos microservices.
Cada microservice deverá ter uma responsabilidade clara e bem delimitada.

Para cada microservice, o grupo deverá informar: nome do microservice; responsabilidade principal;
principais entidades ou dados manipulados; principais endpoints previstos ou implementados; banco de
dados utilizado; justificativa para a existência desse serviço separado.

| Microservice | Responsabilidade | Banco de dados | Observações |
|---|---|---|---|
| user-service | Cadastro e gerenciamento de usuários | PostgreSQL | Responsável pelos dados cadastrais dos usuários |
| order-service | Criação e acompanhamento de pedidos | PostgreSQL | Controla o ciclo de vida dos pedidos |
| notification-service | Envio de notificações | MongoDB | Pode armazenar histórico flexível de mensagens |

## 5. Banco de dados por microservice

Cada microservice deverá possuir seu próprio banco de dados lógico. Neste primeiro momento, será
permitido que os grupos utilizem a mesma instância de banco de dados para facilitar a execução local
do projeto. Porém, mesmo usando a mesma instância, cada serviço deverá ter sua separação própria,
por exemplo: um database separado por microservice; ou um schema separado por microservice; ou uma
configuração claramente isolada para cada serviço.

O grupo não deverá criar uma única base compartilhada por todos os serviços como se fosse um
monolito distribuído. A ideia central é: **cada microservice deve ser dono dos seus próprios dados.**

Em uma etapa futura do projeto, essa estrutura deverá evoluir para um cenário com um banco ou
instância separada por microservice, reforçando o isolamento entre os serviços.

## 6. Uso de banco não relacional

Os grupos deverão analisar seus microservices e identificar se algum deles faz sentido utilizar um
banco de dados não relacional. O uso deverá ser justificado de acordo com a natureza dos dados e o
comportamento do serviço.

Exemplos de usos aceitáveis:

- MongoDB para documentos com estrutura flexível;
- Cassandra para grande volume de eventos ou registros orientados por consulta;
- Neo4j para dados altamente relacionais em formato de grafo;
- Elasticsearch/OpenSearch para busca textual e consultas analíticas;
- DynamoDB para acesso chave-valor/documento em alta escala;
- InfluxDB ou TimescaleDB para séries temporais.

O grupo deverá explicar: qual microservice poderia usar um banco não relacional; qual banco seria
usado; qual característica do serviço justifica essa escolha; quais consultas ou operações seriam
favorecidas por esse modelo.

> **Observação importante sobre Redis.** O uso de Redis como cache é permitido e pode ser considerado
> um ponto positivo na arquitetura. Porém, Redis usado apenas como cache **não** será aceito como
> critério principal de banco não relacional nesta entrega. Dizer que o projeto usa Redis apenas para
> cache não substitui a análise sobre qual microservice poderia usar um banco não relacional como
> banco principal ou complementar de persistência.

## 7. Discovery Server

A arquitetura deverá conter um Discovery Server, responsável por permitir que os microservices se
registrem e sejam descobertos dinamicamente dentro da arquitetura.

Tecnologias permitidas: Eureka Server; Consul; outra solução equivalente, desde que justificada e
aprovada.

Nesta entrega, o grupo deverá demonstrar que: o Discovery Server sobe corretamente; os microservices
conseguem se registrar nele; é possível visualizar os serviços registrados; a comunicação entre
serviços pode ser feita usando o nome lógico do serviço, quando aplicável.

## 8. API Gateway

A arquitetura deverá conter um API Gateway, que será o ponto único de entrada para as chamadas
externas da aplicação. O grupo deverá configurar rotas para encaminhar as requisições para os
microservices correspondentes.

Responsabilidades do gateway nesta entrega: receber requisições externas; roteá-las para o
microservice correto; integrar-se ao Discovery Server, se aplicável; centralizar o acesso à
aplicação; evitar que o cliente precise conhecer diretamente as portas internas dos serviços.

| Rota externa | Microservice destino |
|---|---|
| `/api/users/**` | user-service |
| `/api/orders/**` | order-service |
| `/api/products/**` | product-service |

O grupo deverá demonstrar pelo menos algumas chamadas passando pelo API Gateway.

## 9. Resiliência entre microservices

Além do Discovery Server e do API Gateway, o projeto deverá conter uma preocupação explícita com
resiliência na comunicação entre microservices.

Em uma arquitetura distribuída, uma chamada entre serviços pode falhar por diversos motivos: o
serviço chamado pode estar fora do ar; a resposta pode demorar mais do que o esperado; a rede pode
apresentar instabilidade; o serviço pode responder com erro temporário; uma falha em cascata pode
comprometer outros serviços.

Por isso, cada grupo deverá escolher pelo menos uma comunicação entre microservices e aplicar
mecanismos de resiliência. Exemplos aceitos: Timeout; Retry; Circuit Breaker; Fallback; Rate
Limiter; Bulkhead.

**Não é necessário aplicar todos os padrões nesta primeira entrega**, mas o grupo deverá demonstrar
que compreende o problema e que começou a tratar falhas entre serviços.

O grupo deverá documentar: qual microservice chama outro microservice; qual problema de falha pode
acontecer nessa comunicação; qual mecanismo de resiliência foi utilizado; como o sistema se comporta
quando o serviço chamado falha; como testar ou simular essa falha.

| Serviço que chama | Serviço chamado | Risco | Estratégia de resiliência |
|---|---|---|---|
| order-service | payment-service | Pagamento indisponível ou lento | Timeout + fallback |
| sighting-service | classification-service | Classificação fora do ar | Circuit Breaker + resposta alternativa |
| product-service | inventory-service | Estoque demorando para responder | Retry com limite de tentativas |

A resiliência deve ser pensada como parte da arquitetura, e não apenas como um detalhe técnico.

## 10. Requisitos mínimos da entrega

A Entrega 1 deverá conter obrigatoriamente:

1. Identificação da turma;
2. Identificação dos integrantes;
3. Tema do projeto descrito claramente;
4. Descrição do problema que o sistema resolve;
5. Lista dos microservices planejados;
6. Responsabilidade de cada microservice;
7. Associação entre integrantes e microservices;
8. Banco de dados previsto para cada microservice;
9. Separação dos bancos, schemas ou databases por microservice;
10. Análise de pelo menos um possível uso de banco não relacional;
11. Discovery Server funcionando;
12. Microservices registrados no Discovery Server;
13. API Gateway funcionando;
14. Rotas configuradas no API Gateway;
15. Pelo menos uma chamada demonstrando acesso via gateway;
16. Pelo menos uma comunicação entre microservices com estratégia de resiliência;
17. Repositório com instruções de execução;
18. README explicando como subir o projeto.

## 11. Entregáveis

### 11.1. Documento da proposta

Um documento em formato PDF ou Markdown contendo: nome do projeto; integrantes do grupo; tema
escolhido; descrição do problema; descrição dos microservices; desenho ou descrição textual da
arquitetura; bancos de dados utilizados; justificativa para possível uso de banco não relacional;
explicação sobre Discovery Server; explicação sobre API Gateway; prints ou evidências dos serviços
funcionando.

### 11.2. Código-fonte

O grupo deverá disponibilizar o código em um repositório Git, contendo: código dos microservices;
código/configuração do Discovery Server; código/configuração do API Gateway; arquivos de
configuração; instruções de execução; exemplos de requisições para teste.

### 11.3. README

O README deverá conter, no mínimo: descrição do projeto; lista dos serviços; tecnologias utilizadas;
como executar o projeto; portas utilizadas; exemplos de endpoints; como acessar o Discovery Server;
como testar as rotas pelo API Gateway.

## 12. Sugestão de estrutura do README

```markdown
# Nome do Projeto

## Integrantes
- Nome 1

## Descrição do Projeto
Explique o problema que o sistema resolve.

## Arquitetura
Explique os microservices, o Discovery Server, o API Gateway e os bancos de dados.

## Microservices
| Serviço | Responsabilidade | Porta | Banco |
|---|---|---|---|
| service-a | ... | 8081 | ... |
| service-b | ... | 8082 | ... |

## Como executar
Explique os comandos necessários para subir o projeto.

## Discovery Server
URL de acesso e serviços registrados.

## API Gateway
Rotas configuradas.

## Exemplos de requisições
Inclua exemplos com curl, Postman ou arquivos HTTP.
```

## 13. Observações importantes

- O tema é livre, mas precisa permitir uma arquitetura realista com microservices.
- Não basta criar vários serviços sem necessidade. A divisão precisa fazer sentido.
- Cada microservice deve ter uma responsabilidade própria.
- Cada microservice deve ser dono dos seus próprios dados.
- Nesta etapa, os bancos podem estar na mesma instância, mas devem estar logicamente separados.
- Em etapas futuras, a arquitetura deverá evoluir para maior isolamento entre os serviços.
- Redis como cache é permitido, mas não conta sozinho como justificativa de banco não relacional.
- O API Gateway deve ser o ponto de entrada da aplicação.
- O Discovery Server deve permitir visualizar os serviços registrados.
- O projeto deve demonstrar preocupação com resiliência na comunicação entre serviços.
- A entrega deve ser executável por outra pessoa a partir das instruções do README.

## 14. Resultado esperado

Ao final desta entrega, espera-se que o grupo tenha uma primeira versão funcional da arquitetura do
projeto, ainda simples, mas já estruturada com os principais elementos de uma solução baseada em
microservices: serviços separados; responsabilidades bem definidas; bancos separados por serviço;
Discovery Server; API Gateway; primeira análise sobre persistência poliglota; primeira estratégia de
resiliência entre microservices.

Esta entrega servirá como base para as próximas evoluções do projeto ao longo da disciplina.
