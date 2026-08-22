package com.portfoliohub.project.adapter.in.web;

import com.portfoliohub.project.application.ProfileDirectoryClient;
import com.portfoliohub.project.application.ProjectApplicationService;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/projects")
public class ProjectController {
    private final ProjectApplicationService service;
    private final ProfileDirectoryClient profileDirectoryClient;

    public ProjectController(ProjectApplicationService service, ProfileDirectoryClient profileDirectoryClient) {
        this.service = service;
        this.profileDirectoryClient = profileDirectoryClient;
    }

    @PostMapping
    public ResponseEntity<ProjectResponse> create(@Valid @RequestBody ProjectRequest request) {
        var response = service.create(request);
        return ResponseEntity.created(URI.create("/api/projects/" + response.id())).body(response);
    }

    @GetMapping
    public List<ProjectResponse> list() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ProjectResponse get(@PathVariable String id) {
        return service.findById(id);
    }

    /** Única composição entre serviços: o projeto é local, o perfil vem do profile-service. */
    @GetMapping("/{id}/details")
    public ProjectDetailsResponse details(@PathVariable String id) {
        var project = service.findById(id);
        return new ProjectDetailsResponse(project, profileDirectoryClient.findById(project.profileId()));
    }
}
