# Dockerfile único para os quatro módulos.
#
# O módulo a construir vem por ARG, então não há quatro arquivos quase iguais
# para manter em sincronia. O contexto de build é a raiz do projeto, porque os
# módulos herdam do pom.xml pai.
#
#   docker build --build-arg MODULO=profile-service -t portfoliohub/profile .
#
# Normalmente não é preciso chamar assim: o docker-compose.yml já passa o ARG.
#
# Escolha das imagens:
#  · build   — Debian, não Alpine. O estágio de build é descartado no multi-stage,
#              então ali vale priorizar confiabilidade sobre bytes.
#  · runtime — Alpine com JRE (não JDK): o compilador não é necessário para
#              executar, e cada binário a menos é uma superfície de ataque a menos.
ARG IMAGEM_BUILD=maven:3-eclipse-temurin-25
ARG IMAGEM_RUNTIME=eclipse-temurin:25-jre-alpine

# ─── build ────────────────────────────────────────────────────────────────────
FROM ${IMAGEM_BUILD} AS build
ARG MODULO
WORKDIR /src

# Primeiro só os pom.xml: enquanto as dependências não mudarem, esta camada é
# reaproveitada e o download não se repete a cada alteração de código.
COPY pom.xml ./
COPY discovery-server/pom.xml discovery-server/
COPY api-gateway/pom.xml     api-gateway/
COPY profile-service/pom.xml profile-service/
COPY project-service/pom.xml project-service/
RUN mvn -B -pl ${MODULO} -am dependency:go-offline

# Agora o código. -am constrói também o pai e o que o módulo precisa.
COPY discovery-server/src discovery-server/src
COPY api-gateway/src     api-gateway/src
COPY profile-service/src profile-service/src
COPY project-service/src project-service/src
RUN mvn -B -pl ${MODULO} -am package -DskipTests \
    && cp ${MODULO}/target/*.jar /app.jar

# Separa o jar em camadas por frequência de mudança. As dependências raramente
# mudam e ficam numa camada própria; o código da aplicação, que muda a cada
# commit, fica em outra. Sem isso, um ajuste de uma linha invalida os ~60 MB de
# dependências e o push/pull da imagem recomeça do zero.
# --destination e obrigatorio: sem ele o extract cria um diretorio nomeado a
# partir do jar (project-service-0.0.1-SNAPSHOT/), que varia por modulo e versao.
RUN java -Djarmode=tools -jar /app.jar extract --layers --launcher --destination /extraido

# ─── runtime ──────────────────────────────────────────────────────────────────
FROM ${IMAGEM_RUNTIME}

# curl serve ao HEALTHCHECK do compose; a imagem JRE não traz cliente HTTP.
RUN apk add --no-cache curl

# Processo sem privilégio de root: se o container for comprometido, o atacante
# não herda root no host através de volumes montados.
RUN addgroup -S portfoliohub \
    && adduser -S -G portfoliohub -u 10001 portfoliohub

WORKDIR /app

# A ordem das camadas é deliberada: da que menos muda para a que mais muda.
COPY --from=build --chown=portfoliohub:portfoliohub /extraido/dependencies/ ./
COPY --from=build --chown=portfoliohub:portfoliohub /extraido/spring-boot-loader/ ./
COPY --from=build --chown=portfoliohub:portfoliohub /extraido/snapshot-dependencies/ ./
COPY --from=build --chown=portfoliohub:portfoliohub /extraido/application/ ./

USER portfoliohub

# -XX:MaxRAMPercentage — a JVM enxerga o limite do container, não o da máquina;
#   sem isso ela dimensiona a heap pela RAM do host e o container é encerrado por
#   esgotamento de memória.
#
# Nota: Class Data Sharing (-XX:+AutoCreateSharedArchive) foi testado e removido.
# O arquivo compartilhado não chegou a ser gravado nem após encerramento limpo do
# container e, ainda que fosse, viveria na camada gravável — perdida a cada
# reconstrução da imagem. Manter a flag anunciaria uma otimização inexistente.
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "org.springframework.boot.loader.launch.JarLauncher"]
