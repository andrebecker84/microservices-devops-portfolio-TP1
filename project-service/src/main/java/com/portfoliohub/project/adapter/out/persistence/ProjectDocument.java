package com.portfoliohub.project.adapter.out.persistence;

import java.time.Instant;
import java.util.List;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document("projects")
public class ProjectDocument {
    @Id private String id;
    private String profileId;
    private String name;
    private String summary;
    private List<String> technologies;
    private String repositoryUrl;
    private boolean featured;
    private Instant createdAt;

    public ProjectDocument(String profileId, String name, String summary, List<String> technologies, String repositoryUrl, boolean featured) {
        this.profileId = profileId; this.name = name; this.summary = summary;
        this.technologies = List.copyOf(technologies); this.repositoryUrl = repositoryUrl;
        this.featured = featured; this.createdAt = Instant.now();
    }
    public String getId() { return id; }
    public String getProfileId() { return profileId; }
    public String getName() { return name; }
    public String getSummary() { return summary; }
    public List<String> getTechnologies() { return technologies; }
    public String getRepositoryUrl() { return repositoryUrl; }
    public boolean isFeatured() { return featured; }
    public Instant getCreatedAt() { return createdAt; }
}
