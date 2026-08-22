package com.portfoliohub.profile.adapter.out.persistence;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "profiles")
public class ProfileEntity {
    @Id @GeneratedValue private UUID id;
    private String name;
    private String headline;
    private String summary;
    private String location;

    protected ProfileEntity() { }

    public ProfileEntity(String name, String headline, String summary, String location) {
        update(name, headline, summary, location);
    }
    public void update(String name, String headline, String summary, String location) {
        this.name = name; this.headline = headline; this.summary = summary; this.location = location;
    }
    public UUID getId() { return id; }
    public String getName() { return name; }
    public String getHeadline() { return headline; }
    public String getSummary() { return summary; }
    public String getLocation() { return location; }
}
