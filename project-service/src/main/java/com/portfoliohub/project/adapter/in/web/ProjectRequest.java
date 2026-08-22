package com.portfoliohub.project.adapter.in.web;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import java.util.List;

public record ProjectRequest(
        @NotBlank String profileId,
        @NotBlank @Size(max = 120) String name,
        @NotBlank @Size(max = 1_000) String summary,
        @NotEmpty List<@NotBlank String> technologies,
        @Size(max = 300) String repositoryUrl,
        boolean featured) { }
