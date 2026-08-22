package com.portfoliohub.project.adapter.in.web;

import com.portfoliohub.project.adapter.out.persistence.ProjectDocument;
import java.time.Instant;
import java.util.List;

public record ProjectResponse(String id, String profileId, String name, String summary, List<String> technologies,
                              String repositoryUrl, boolean featured, Instant createdAt) {
    public static ProjectResponse from(ProjectDocument project) {
        return new ProjectResponse(project.getId(), project.getProfileId(), project.getName(), project.getSummary(),
                project.getTechnologies(), project.getRepositoryUrl(), project.isFeatured(), project.getCreatedAt());
    }
}
