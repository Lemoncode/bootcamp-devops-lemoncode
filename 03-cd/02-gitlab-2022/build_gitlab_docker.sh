#!/bin/bash
# Run docker-compose
docker-compose -f gitlab/docker/docker-compose.yml up -d

#Auto register runner to gitlab
/bin/bash gitlab/docker/runner_register.sh
