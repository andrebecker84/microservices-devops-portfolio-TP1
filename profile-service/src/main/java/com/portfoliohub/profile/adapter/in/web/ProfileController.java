package com.portfoliohub.profile.adapter.in.web;

import com.portfoliohub.profile.application.ProfileApplicationService;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/profiles")
public class ProfileController {
    private final ProfileApplicationService service;
    public ProfileController(ProfileApplicationService service) { this.service = service; }

    @PostMapping
    public ResponseEntity<ProfileResponse> create(@Valid @RequestBody ProfileRequest request) {
        var response = service.create(request);
        return ResponseEntity.created(URI.create("/api/profiles/" + response.id())).body(response);
    }
    @GetMapping("/{id}")
    public ProfileResponse get(@PathVariable UUID id) { return service.findById(id); }
    @PutMapping("/{id}")
    public ProfileResponse update(@PathVariable UUID id, @Valid @RequestBody ProfileRequest request) { return service.update(id, request); }
}
