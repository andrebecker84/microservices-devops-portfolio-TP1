package com.portfoliohub.project.application;

import java.util.UUID;

/**
 * Perfil do autor exibido junto de um projeto.
 *
 * <p>O {@link Status} distingue as três situações possíveis da chamada remota: perfil obtido,
 * perfil inexistente e serviço de perfil indisponível. Colapsar as duas últimas em um único
 * estado esconderia do cliente a diferença entre um dado errado e uma falha de infraestrutura.
 */
public record ProfileSummary(UUID id, String name, String headline, Status status) {

    public enum Status {
        /** Perfil recuperado do profile-service. */
        AVAILABLE,
        /** O profile-service respondeu que esse perfil não existe. */
        NOT_FOUND,
        /** O profile-service não respondeu: fora do ar, lento ou circuito aberto. */
        UNAVAILABLE
    }

    public static ProfileSummary available(UUID id, String name, String headline) {
        return new ProfileSummary(id, name, headline, Status.AVAILABLE);
    }

    public static ProfileSummary notFound() {
        return new ProfileSummary(null, "Profile not found",
                "The referenced profile does not exist", Status.NOT_FOUND);
    }

    public static ProfileSummary unavailable() {
        return new ProfileSummary(null, "Profile unavailable",
                "The profile service is temporarily unavailable", Status.UNAVAILABLE);
    }
}
