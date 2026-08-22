package com.portfoliohub.project.application;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import com.portfoliohub.project.application.ProfileSummary.Status;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class ProfileSummaryTest {

    @Test
    void unavailableMarksProfileAsUnavailableWithSafeMessage() {
        ProfileSummary summary = ProfileSummary.unavailable();

        assertEquals(Status.UNAVAILABLE, summary.status());
        assertNull(summary.id());
        assertEquals("Profile unavailable", summary.name());
        assertEquals("The profile service is temporarily unavailable", summary.headline());
    }

    @Test
    void notFoundIsDistinctFromUnavailable() {
        ProfileSummary notFound = ProfileSummary.notFound();

        assertEquals(Status.NOT_FOUND, notFound.status());
        assertNull(notFound.id());
        assertNotEquals(ProfileSummary.unavailable().status(), notFound.status());
    }

    @Test
    void availableCarriesTheRemoteProfile() {
        UUID id = UUID.randomUUID();

        ProfileSummary summary = ProfileSummary.available(id, "André Becker", "Software Engineer");

        assertEquals(Status.AVAILABLE, summary.status());
        assertEquals(id, summary.id());
        assertEquals("André Becker", summary.name());
    }
}
