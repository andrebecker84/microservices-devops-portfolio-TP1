package com.portfoliohub.project.application;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClient;

/**
 * Consulta o profile-service pelo nome lógico registrado no Eureka.
 *
 * <p>Um perfil inexistente é resposta legítima do serviço remoto, não falha dele: por isso o
 * {@code 404} é tratado aqui dentro e não chega ao Circuit Breaker, que ficaria aberto por causa
 * de dados inválidos do cliente. O fallback cobre apenas indisponibilidade real — serviço fora do
 * ar, lentidão acima do timeout ou circuito já aberto.
 */
@Component
public class ProfileDirectoryClient {
    private final RestClient client;

    // @LoadBalanced é um qualificador: sem ele, a injeção pegaria o builder @Primary,
    // que não resolve nomes lógicos, e o nome do serviço viraria um host inexistente.
    //
    // O esquema é configurável porque o TLS interno é um perfil opcional: com
    // `docker-compose.tls.yml` ativo o profile-service atende em HTTPS, e sem ele
    // continua em HTTP. O default mantém o comportamento de sempre.
    public ProfileDirectoryClient(
            @LoadBalanced RestClient.Builder loadBalancedRestClientBuilder,
            @Value("${portfoliohub.profile-client.scheme:http}") String scheme) {
        this.client = loadBalancedRestClientBuilder.baseUrl(scheme + "://profile-service").build();
    }

    @CircuitBreaker(name = "profileService", fallbackMethod = "profileUnavailable")
    public ProfileSummary findById(String profileId) {
        try {
            var profile = client.get().uri("/api/profiles/{id}", profileId).retrieve().body(ProfileSummary.class);
            if (profile == null) {
                throw new IllegalStateException("Profile service returned an empty body");
            }
            return ProfileSummary.available(profile.id(), profile.name(), profile.headline());
        } catch (HttpClientErrorException.NotFound notFound) {
            return ProfileSummary.notFound();
        }
    }

    private ProfileSummary profileUnavailable(String profileId, Throwable exception) {
        return ProfileSummary.unavailable();
    }
}
