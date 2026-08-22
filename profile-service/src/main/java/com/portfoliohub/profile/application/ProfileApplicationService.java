package com.portfoliohub.profile.application;

import com.portfoliohub.profile.adapter.in.web.ProfileRequest;
import com.portfoliohub.profile.adapter.in.web.ProfileResponse;
import com.portfoliohub.profile.adapter.out.persistence.ProfileEntity;
import com.portfoliohub.profile.adapter.out.persistence.ProfileJpaRepository;
import jakarta.persistence.EntityNotFoundException;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class ProfileApplicationService {
    private final ProfileJpaRepository repository;

    public ProfileApplicationService(ProfileJpaRepository repository) {
        this.repository = repository;
    }

    public ProfileResponse create(ProfileRequest request) {
        var entity = new ProfileEntity(request.name(), request.headline(), request.summary(), request.location());
        return ProfileResponse.from(repository.save(entity));
    }

    @Transactional(readOnly = true)
    public ProfileResponse findById(UUID id) {
        return ProfileResponse.from(findEntity(id));
    }

    public ProfileResponse update(UUID id, ProfileRequest request) {
        var entity = findEntity(id);
        entity.update(request.name(), request.headline(), request.summary(), request.location());
        return ProfileResponse.from(entity);
    }

    private ProfileEntity findEntity(UUID id) {
        return repository.findById(id).orElseThrow(() -> new EntityNotFoundException("Profile not found: " + id));
    }
}
