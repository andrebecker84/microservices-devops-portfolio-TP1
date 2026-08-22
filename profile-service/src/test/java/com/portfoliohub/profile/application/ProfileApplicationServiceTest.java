package com.portfoliohub.profile.application;

import com.portfoliohub.profile.adapter.in.web.ProfileRequest;
import com.portfoliohub.profile.adapter.in.web.ProfileResponse;
import com.portfoliohub.profile.adapter.out.persistence.ProfileEntity;
import com.portfoliohub.profile.adapter.out.persistence.ProfileJpaRepository;
import jakarta.persistence.EntityNotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProfileApplicationServiceTest {

    @Mock
    private ProfileJpaRepository repository;

    @InjectMocks
    private ProfileApplicationService service;

    private ProfileRequest request() {
        return new ProfileRequest("André Becker", "Software Engineer", "Resumo", "Brasil");
    }

    @Test
    void createPersistsAndMapsProfile() {
        when(repository.save(any(ProfileEntity.class))).thenAnswer(inv -> inv.getArgument(0));

        ProfileResponse response = service.create(request());

        assertEquals("André Becker", response.name());
        assertEquals("Software Engineer", response.headline());
        assertEquals("Resumo", response.summary());
        assertEquals("Brasil", response.location());
        verify(repository).save(any(ProfileEntity.class));
    }

    @Test
    void findByIdMapsExistingProfile() {
        UUID id = UUID.randomUUID();
        ProfileEntity entity = new ProfileEntity("André Becker", "Software Engineer", "Resumo", "Brasil");
        when(repository.findById(id)).thenReturn(Optional.of(entity));

        ProfileResponse response = service.findById(id);

        assertEquals("André Becker", response.name());
        assertEquals("Software Engineer", response.headline());
    }

    @Test
    void findByIdThrowsWhenMissing() {
        UUID id = UUID.randomUUID();
        when(repository.findById(id)).thenReturn(Optional.empty());

        EntityNotFoundException exception = assertThrows(EntityNotFoundException.class, () -> service.findById(id));
        assertTrue(exception.getMessage().contains("Profile not found"));
    }

    @Test
    void updateAppliesChangesAndMapsProfile() {
        UUID id = UUID.randomUUID();
        ProfileEntity entity = new ProfileEntity("André Becker", "Software Engineer", "Resumo", "Brasil");
        when(repository.findById(id)).thenReturn(Optional.of(entity));

        ProfileResponse response = service.update(id, request());

        assertEquals("André Becker", response.name());
        assertEquals("Software Engineer", response.headline());
    }

    @Test
    void updateThrowsWhenMissing() {
        UUID id = UUID.randomUUID();
        when(repository.findById(id)).thenReturn(Optional.empty());

        assertThrows(EntityNotFoundException.class, () -> service.update(id, request()));
    }
}
