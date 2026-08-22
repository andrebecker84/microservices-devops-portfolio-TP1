# Rúbrica de avaliação — DR3-TP1

> **Documento de origem acadêmica.** Critérios oficiais de avaliação da atividade, reproduzidos aqui
> para que o repositório seja autocontido. Bloco Engenharia de Softwares Escaláveis · Disciplina
> Microsserviços e DevOps com Spring Boot e Spring Cloud [26E3_3] · Professor Wesley Bruno Barbosa
> Silva · Instituto Infnet.
>
> A coluna "Onde se comprova" é análise do autor deste repositório, não do enunciado.

**Competência avaliada:** desenvolver microserviços cloud nativos com Spring Boot e Spring Cloud.

---

## Os 13 critérios

**1.** O aluno documentou e desenhou a arquitetura inicial da solução, descrevendo corretamente o
papel e a interação dos componentes de uma arquitetura distribuída (como API Gateway, Discovery
Server e serviços de domínio)?

**2.** O aluno justificou claramente no documento da proposta por que o tema escolhido faz sentido e
se beneficia da arquitetura de microsserviços, evidenciando as responsabilidades bem delimitadas de
cada serviço?

**3.** O aluno implementou o ecossistema de microsserviços (incluindo Discovery Server e API Gateway)
de forma funcional, permitindo que os serviços subam e se registrem corretamente na arquitetura?

**4.** O aluno documentou como a arquitetura proposta (com descoberta dinâmica e roteamento
centralizado) suporta a escalabilidade e a distribuição características dos modelos de computação
baseados em nuvem?

**5.** O aluno aplicou o princípio de isolamento de estado ao garantir e justificar que cada
microsserviço possua seu próprio banco de dados lógico (schema ou database separado), sendo dono de
seus próprios dados?

**6.** O aluno configurou os serviços para rodarem de forma independente, externalizando portas e
configurações de rotas, e declarando explicitamente os serviços de apoio (backing services) como os
bancos de dados relacionais e não relacionais propostos?

**7.** O aluno implementou mecanismos explícitos de resiliência na comunicação entre os
microsserviços (como Timeout, Retry, Circuit Breaker ou Fallback) e documentou como o sistema se
comporta diante de falhas?

**8.** O aluno demonstrou na prática o funcionamento da fronteira da aplicação configurando o API
Gateway como ponto único de entrada, roteando requisições externas para as portas internas corretas
dos serviços?

**9.** O aluno avaliou criticamente a granularidade do projeto, justificando tecnicamente a
existência de cada microsserviço criado e evitando a fragmentação desnecessária ("não basta criar
vários serviços sem necessidade")?

**10.** O aluno entregou o código-fonte organizado em um repositório Git, acompanhado de um README
completo com instruções claras de execução que permitem a reprodução de toda a infraestrutura
distribuída localmente?

**11.** O aluno garantiu a autonomia de execução local configurando cada microsserviço para rodar em
seu próprio servidor embutido, em portas distintas e sem conflitos de inicialização?

**12.** O aluno desenvolveu endpoints RESTful operacionais para as entidades propostas, justificando
tecnicamente a escolha do banco de dados (relacional ou não relacional) mais adequado para as
operações de cada serviço?

**13.** O aluno validou o funcionamento da solução fornecendo exemplos concretos de requisições
(cURL, Postman ou arquivos HTTP) e evidências visuais (prints) de que as rotas pelo Gateway e a
descoberta de serviços respondem conforme o esperado?

---

## Onde cada critério se comprova neste repositório

| # | Onde se comprova |
|---|---|
| 1 | `README.md` (diagrama Mermaid) · `RELATORIO_TP1.md` §3 · `adr/003-discovery-gateway.md` |
| 2 | `RELATORIO_TP1.md` §2 e §4 · Introdução do documento da proposta |
| 3 | **Evidências 01 e 02** — execução real |
| 4 | `RELATORIO_TP1.md` §3, subseção "Escalabilidade e características cloud-native" |
| 5 | `docker-compose.yml` · ADR 001 · `application.yml` de cada serviço |
| 6 | Variáveis de ambiente nos `application.yml` · `docker-compose.yml` · `.env.example` |
| 7 | Timeout + Circuit Breaker + fallback · ADR 002 · **Evidência 06** |
| 8 | **Evidências 03, 04 e 05** — chamadas apenas pela porta 18080 |
| 9 | `RELATORIO_TP1.md` §2 (escopo excluído) e §4 · ADR 001 |
| 10 | Repositório publicado · `README.md` |
| 11 | Portas 18761 / 18080 / 18081 / 18082 · **Evidência 02** |
| 12 | `ProfileController` · `ProjectController` · ADR 001 |
| 13 | `http/` · **Evidências 01–07** |

## Leitura da matriz

Sete dos treze critérios — 3, 7, 8, 10, 11, 13 e parte do 12 — dependem de **execução real e
prints**. Documentação sozinha não os satisfaz.

O critério 10 exige repositório Git de fato publicado: enquanto o diretório não for um repositório
com push feito, ele está pendente, e qualquer texto que afirme repositório público está incorreto.
