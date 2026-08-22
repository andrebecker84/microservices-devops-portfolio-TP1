# ADR 001 — Persistência poliglota por contexto de domínio

**Status:** Aceita

**Contexto**

O trabalho é individual e exige pelo menos dois microservices e um banco não relacional. O domínio do PortfolioHub possui dois contextos com características de dados distintas: o perfil profissional (estruturado, estável, consistente) e o catálogo de projetos técnicos (heterogêneo, com tecnologias e metadados variáveis).

**Decisão**

- `profile-service` utiliza **PostgreSQL**, com migration controlada por **Flyway**.
- `project-service` utiliza **MongoDB**, persistindo cada projeto como um documento.

Cada serviço é dono exclusivo do próprio banco lógico (`profile_db` e `project_db`). Nenhum serviço acessa diretamente o banco do outro. Um projeto apenas referencia `profileId`; o perfil permanece fonte de verdade no `profile-service`.

**Alternativas consideradas**

- Usar PostgreSQL em ambos: rejeitado por forçar uma modelagem relacional para dados naturalmente heterogêneos e flexíveis.
- Usar MongoDB em ambos: rejeitado por subutilizar a consistência e as relações exigidas pelos dados cadastrais de perfil.
- Redis como cache: aceito como melhoria futura, mas não atende ao requisito de banco não relacional principal.

**Consequências**

- Isolamento de estado e independência de evolução por serviço.
- Duas tecnologias de persistência para operar localmente (custo operacional aceitável para a entrega).
- A composição entre projeto e perfil passa a exigir comunicação HTTP, tratada na ADR 002.

**Validação**

Validado em execução: o Flyway aplica a migration no PostgreSQL e o `project-service` persiste documentos no MongoDB, cada um com credenciais próprias e banco lógico separado. Nenhum serviço alcança o banco do outro — a separação é de rede, não apenas de convenção.
