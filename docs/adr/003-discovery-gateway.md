# ADR 003 — Discovery Server e API Gateway como infraestrutura de entrada

**Status:** Aceita

**Contexto**

Os clientes externos não devem conhecer as portas internas dos serviços. A arquitetura precisa permitir registro e descoberta dinâmica, além de um ponto único de entrada.

**Decisão**

- **Netflix Eureka** (`discovery-server`, porta 18761) registra e descobre os serviços por nome lógico.
- **Spring Cloud Gateway** (`api-gateway`, porta 18080) é a única fronteira externa e roteia:
  - `/api/profiles/**` → `profile-service`
  - `/api/projects/**` → `project-service`
- O roteamento usa `lb://` para resolver os nomes lógicos via LoadBalancer.

**Alternativas consideradas**

- Consul: rejeitado por adicionar um agente externo; Eureka é suficiente e integrada ao ecossistema Spring Cloud.
- Roteamento por URLs físicas no Gateway: rejeitado por reintroduzir acoplamento de endereços.

**Consequências**

- Fronteira única e roteamento centralizado, alinhados ao requisito de cloud-native.
- Desacoplamento entre cliente externo e topologia interna.

**Validação**

Validado em execução: os três serviços registram-se no Eureka e as chamadas externas passam pela porta 18080. Em containers, o encadeamento por healthcheck garante que o Discovery Server responda antes de os demais subirem.
