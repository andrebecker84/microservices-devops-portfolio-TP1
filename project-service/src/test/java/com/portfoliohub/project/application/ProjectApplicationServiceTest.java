package com.portfoliohub.project.application;

import com.portfoliohub.project.adapter.in.web.ProjectRequest;
import com.portfoliohub.project.adapter.in.web.ProjectResponse;
import com.portfoliohub.project.adapter.out.persistence.ProjectDocument;
import com.portfoliohub.project.adapter.out.persistence.ProjectMongoRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProjectApplicationServiceTest {

    @Mock
    private ProjectMongoRepository repository;

    @InjectMocks
    private ProjectApplicationService service;

    private ProjectRequest request() {
        return new ProjectRequest("profile-id", "PortfolioHub", "Resumo do projeto",
                List.of("Java", "Spring Boot"), "https://github.com", true);
    }

    @Test
    void createPersistsAndMapsProject() {
        when(repository.save(any(ProjectDocument.class))).thenAnswer(inv -> inv.getArgument(0));

        ProjectResponse response = service.create(request());

        assertEquals("PortfolioHub", response.name());
        assertEquals("profile-id", response.profileId());
        assertEquals(List.of("Java", "Spring Boot"), response.technologies());
        verify(repository).save(any(ProjectDocument.class));
    }

    @Test
    void findAllMapsAllProjects() {
        ProjectDocument project = new ProjectDocument("profile-id", "PortfolioHub", "Resumo",
                List.of("Java"), "https://github.com", true);
        when(repository.findAll()).thenReturn(List.of(project));

        List<ProjectResponse> result = service.findAll();

        assertEquals(1, result.size());
        assertEquals("PortfolioHub", result.get(0).name());
    }

    @Test
    void findByIdMapsExistingProject() {
        ProjectDocument project = new ProjectDocument("profile-id", "PortfolioHub", "Resumo",
                List.of("Java"), "https://github.com", true);
        when(repository.findById("1")).thenReturn(Optional.of(project));

        ProjectResponse response = service.findById("1");

        assertEquals("PortfolioHub", response.name());
    }

    @Test
    void findByIdThrowsWhenMissing() {
        when(repository.findById("missing")).thenReturn(Optional.empty());

        NoSuchElementException exception = assertThrows(NoSuchElementException.class, () -> service.findById("missing"));
        assertTrue(exception.getMessage().contains("Project not found"));
    }
}
