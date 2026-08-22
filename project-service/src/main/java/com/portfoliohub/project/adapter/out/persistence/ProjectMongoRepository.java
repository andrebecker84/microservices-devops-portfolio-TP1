package com.portfoliohub.project.adapter.out.persistence;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface ProjectMongoRepository extends MongoRepository<ProjectDocument, String> { }
