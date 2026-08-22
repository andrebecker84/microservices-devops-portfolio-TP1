package com.portfoliohub.profile.adapter.in.web;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ProfileRequest(
        @NotBlank @Size(max = 120) String name,
        @NotBlank @Size(max = 160) String headline,
        @Size(max = 2_000) String summary,
        @Size(max = 120) String location) { }
