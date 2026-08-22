package com.portfoliohub.project.config;

import java.time.Duration;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

/**
 * Cliente HTTP balanceado pelo Eureka, com timeouts explícitos.
 *
 * <p>O Circuit Breaker conta falhas, não lentidão: sem timeout, um profile-service travado
 * deixaria a chamada pendurada indefinidamente e o circuito nunca abriria. Os timeouts convertem
 * lentidão em falha, que é o que o Resilience4j sabe tratar.
 */
@Configuration
public class HttpClientConfiguration {

    /**
     * Builder comum, sem balanceamento. Existe por necessidade, não por conveniência.
     *
     * <p>O auto-configure do Spring Boot só fornece um {@code RestClient.Builder} quando não há
     * nenhum declarado. Se o único bean do tipo fosse o balanceado abaixo, o próprio transporte do
     * Eureka o adotaria e tentaria resolver {@code discovery-server} pelo LoadBalancer — que
     * depende do Eureka para saber onde ele está. O resultado é referência circular: o serviço não
     * se registra e toda chamada por nome lógico falha.
     *
     * <p>Marcado como {@code @Primary} para ser o escolhido por quem injeta sem qualificador,
     * caso do Eureka. O balanceado é obtido explicitamente via {@code @LoadBalanced}.
     */
    @Bean
    @Primary
    RestClient.Builder restClientBuilder() {
        return RestClient.builder();
    }

    @Bean
    @LoadBalanced
    RestClient.Builder loadBalancedRestClientBuilder(
            @Value("${portfoliohub.profile-client.connect-timeout:2s}") Duration connectTimeout,
            @Value("${portfoliohub.profile-client.read-timeout:3s}") Duration readTimeout) {
        var requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(connectTimeout);
        requestFactory.setReadTimeout(readTimeout);
        return RestClient.builder().requestFactory(requestFactory);
    }
}
