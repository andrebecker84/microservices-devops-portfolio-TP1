package com.portfoliohub.project.application;

import com.portfoliohub.project.adapter.in.web.ProjectRequest;
import com.portfoliohub.project.adapter.in.web.ProjectResponse;
import com.portfoliohub.project.adapter.out.persistence.ProjectDocument;
import com.portfoliohub.project.adapter.out.persistence.ProjectMongoRepository;
import java.util.List;
import java.util.NoSuchElementException;
import org.springframework.stereotype.Service;

@Service
public class ProjectApplicationService {
    private final ProjectMongoRepository repository;

    public ProjectApplicationService(ProjectMongoRepository repository) {
        this.repository = repository;
    }

    public ProjectResponse create(ProjectRequest request) {
        var project = new ProjectDocument(
                request.profileId(),
                request.name(),
                request.summary(),
                request.technologies(),
                request.repositoryUrl(),
                request.featured());
        return ProjectResponse.from(repository.save(project));
    }

    public List<ProjectResponse> findAll() {
        return repository.findAll().stream().map(ProjectResponse::from).toList();
    }

    public ProjectResponse findById(String id) {
        return repository.findById(id)
                .map(ProjectResponse::from)
                .orElseThrow(() -> new NoSuchElementException("Project not found: " + id));
    }
}
