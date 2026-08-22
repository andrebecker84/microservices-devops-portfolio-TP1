# ADR 002 — Comunicação síncrona com resiliência entre serviços

**Status:** Aceita

**Contexto**

A composição dos detalhes de um projeto com o perfil do autor exige que `project-service` consulte `profile-service`. Em arquitetura distribuída, essa chamada pode falhar por indisponibilidade, lentidão ou erro temporário, podendo causar falha em cascata.

**Decisão**

- A chamada usa o nome lógico `profile-service`, resolvido pelo **Spring Cloud LoadBalancer** a partir dos registros do **Eureka**.
- O cliente remoto (`ProfileDirectoryClient`) é protegido por **timeout** e **Circuit Breaker (Resilience4j)** com um **fallback**.
- O **timeout** (2s de conexão, 3s de leitura, configuráveis por ambiente) cobre o risco de lentidão. Ele é necessário porque o Circuit Breaker conta falhas, não demora: sem timeout, um `profile-service` travado prenderia a chamada indefinidamente e o circuito nunca abriria.
- `ProfileSummary` carrega um `status` de três estados — `AVAILABLE`, `NOT_FOUND` e `UNAVAILABLE`. O `404` do serviço remoto é tratado dentro do cliente e **não** chega ao Circuit Breaker.

**Alternativas consideradas**

- Chamada direta por URL física: rejeitada por acoplar endereços e quebrar a descoberta dinâmica.
- Retry sem circuit breaker: rejeitado por não interromper a sobrecarga quando o serviço permanece fora do ar.
- Mensageria assíncrona: rejeitada nesta entrega por adicionar infraestrutura sem requisito de domínio.
- Tratar o `404` do perfil como indisponibilidade: rejeitado por dois motivos. Abriria o circuito contra um serviço saudável por causa de dado inválido do cliente, e esconderia do consumidor a diferença entre uma referência inexistente e uma falha de infraestrutura — situações com causas e ações corretivas distintas.
- Devolver `404` para a rota inteira quando o perfil não existe: rejeitado porque o projeto existe; falhar a resposta toda por causa de uma referência pendente seria menos informativo do que degradá-la.

**Consequências**

- Evita falha em cascata e mantém a disponibilidade parcial do `project-service`.
- A indisponibilidade do perfil degrada a resposta de detalhes, mas de forma explícita e observável.
- O consumidor precisa interpretar três estados em vez de um booleano — custo aceitável pela informação que ganha.

**Validação**

Testes unitários dos três estados de `ProfileSummary` (`ProfileSummaryTest`), e verificação em execução de `AVAILABLE` e `NOT_FOUND` pela rota `/api/projects/{id}/details`.

A validação em execução revelou um defeito que os testes unitários não alcançavam: o `RestClient.Builder` anotado com `@LoadBalanced` era o único bean do tipo, então o transporte do Eureka o adotava e tentava resolver `discovery-server` pelo próprio LoadBalancer. O `project-service` não se registrava e toda chamada por nome lógico caía no fallback.

O episódio reforça a decisão registrada aqui e acrescenta uma lição: um fallback bem construído devolve a mesma resposta quando o serviço remoto está fora e quando a descoberta está quebrada. Degradar com elegância pode mascarar defeito de configuração, e só a verificação em execução distingue os dois casos.
