package com.portfoliohub.profile.adapter.in.web;

import com.portfoliohub.profile.adapter.out.persistence.ProfileEntity;
import java.util.UUID;

public record ProfileResponse(UUID id, String name, String headline, String summary, String location) {
    public static ProfileResponse from(ProfileEntity entity) {
        return new ProfileResponse(entity.getId(), entity.getName(), entity.getHeadline(), entity.getSummary(), entity.getLocation());
    }
}
