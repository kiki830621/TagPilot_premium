---
id: "MP0049"
title: "Docker-Based Deployment"
type: "meta-principle"
date_created: "2025-04-08"
author: "Claude"
derives_from:
  - "MP0000": "Axiomatization System"
  - "MP0016": "Modularity"
  - "P08": "Deployment Patterns"
influences:
  - "R73": "App.R Change Permission Rule"
---

# Docker-Based Deployment Meta-Principle

## Core Principle

All production application deployments MUST be containerized using Docker, with standardized container definitions that ensure consistency, portability, and reproducibility across different environments. Docker containers serve as the foundational deployment unit for all precision marketing applications.

## Rationale

Containerization through Docker provides several critical advantages:

1. **Environment Consistency**: Eliminates "it works on my machine" problems by packaging the application with its dependencies
2. **Deployment Portability**: Enables deployment to any platform that supports Docker containers
3. **Resource Isolation**: Prevents conflicts between applications and optimizes resource usage
4. **Scalability**: Facilitates horizontal scaling and load balancing
5. **Versioning Control**: Provides clear versioning of application deployments
6. **Rapid Deployment**: Streamlines the deployment process and enables CI/CD integration
7. **Rollback Capability**: Simplifies reverting to previous application versions when needed

## Implementation Guidelines

### Dockerfile Structure

Every application MUST have a Dockerfile that:

1. **Uses Official Base Images**: Starts from official, verified base images
   ```dockerfile
   FROM rocker/shiny:latest
   ```

2. **Minimizes Image Layers**: Combines related operations to reduce complexity
   ```dockerfile
   RUN apt-get update && \
       apt-get install -y --no-install-recommends \
       libssl-dev \
       libxml2-dev && \
       apt-get clean && \
       rm -rf /var/lib/apt/lists/*
   ```

3. **Separates Installation Steps**: Organizes by dependency type
   ```dockerfile
   # System dependencies
   RUN apt-get update && apt-get install -y ...
   
   # R package dependencies
   RUN R -e "install.packages(c('shiny', 'dplyr', 'DT'))"
   
   # Application code
   COPY . /app
   ```

4. **Implements Proper User Permissions**: Avoids running as root
   ```dockerfile
   RUN useradd -m shiny-user
   USER shiny-user
   ```

5. **Includes Health Checks**: Enables container orchestration systems to monitor health
   ```dockerfile
   HEALTHCHECK --interval=30s --timeout=5s \
     CMD curl -f http://localhost:3838/ || exit 1
   ```

6. **Specifies Exposed Ports**: Clearly documents the application's network interface
   ```dockerfile
   EXPOSE 3838
   ```

7. **Defines Entry Point**: Establishes how the application starts
   ```dockerfile
   CMD ["R", "-e", "shiny::runApp('/app', host='0.0.0.0', port=3838)"]
   ```

### Environment Configuration

1. **Environment Variables**: Use environment variables for configuration
   ```dockerfile
   ENV APP_MODE="production"
   ENV LOG_LEVEL="info"
   ```

2. **Volume Management**: Define persistent storage requirements
   ```dockerfile
   VOLUME ["/app/data", "/app/logs"]
   ```

3. **Secrets Management**: Never embed secrets in the Docker image
   ```dockerfile
   # INCORRECT: Hard-coding credentials
   ENV DB_PASSWORD="secret123"
   
   # CORRECT: Define as build argument or leave for runtime injection
   ARG DB_PASSWORD
   ENV DB_PASSWORD=$DB_PASSWORD
   ```

### Multi-Stage Builds

For optimized production containers, use multi-stage builds:

```dockerfile
# Build stage
FROM rocker/r-ver:4.2.0 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y ...

# Install R packages
RUN R -e "install.packages(...)"

# Compile any necessary components
RUN Rscript -e "..."

# Final stage
FROM rocker/r-ver:4.2.0

# Copy only necessary files from builder
COPY --from=builder /usr/local/lib/R/site-library /usr/local/lib/R/site-library
COPY --from=builder /app/compiled /app/compiled

# Add application code
COPY app/ /app/

# Configure and run
EXPOSE 3838
CMD ["R", "-e", "shiny::runApp('/app', host='0.0.0.0', port=3838)"]
```

### Docker Compose

Applications with multiple services should include a docker-compose.yml:

```yaml
version: '3.8'

services:
  shiny-app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3838:3838"
    volumes:
      - ./data:/app/data
    environment:
      - DB_HOST=database
      - LOG_LEVEL=info
    depends_on:
      - database

  database:
    image: postgres:13
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt

volumes:
  postgres_data:
```

## Deployment Process

The Docker-based deployment process MUST follow these steps:

1. **Build**: Create Docker image with appropriate version tag
   ```bash
   docker build -t precision-marketing-app:1.0.0 .
   ```

2. **Test**: Validate the Docker image in a test environment
   ```bash
   docker run -d -p 3838:3838 --name test-deployment precision-marketing-app:1.0.0
   # Run automated tests against container
   ```

3. **Tag**: Label the validated image for the appropriate environment
   ```bash
   docker tag precision-marketing-app:1.0.0 registry.example.com/precision-marketing-app:1.0.0
   docker tag precision-marketing-app:1.0.0 registry.example.com/precision-marketing-app:latest
   ```

4. **Push**: Upload the image to a container registry
   ```bash
   docker push registry.example.com/precision-marketing-app:1.0.0
   docker push registry.example.com/precision-marketing-app:latest
   ```

5. **Deploy**: Pull and run the image in the target environment
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

6. **Verify**: Confirm the deployment is functioning correctly
   ```bash
   curl -f http://localhost:3838/healthcheck
   ```

## Versioning

Docker images MUST follow semantic versioning with:

1. **Major.Minor.Patch**: Corresponding to application version
2. **Environment Tags**: Such as `dev`, `staging`, `production`
3. **Latest Tag**: For the most recent stable version
4. **Git SHA Tags**: For development builds

Example:
```
precision-marketing-app:1.0.0-production
precision-marketing-app:1.0.0-a1b2c3d (git SHA)
precision-marketing-app:latest
```

## Documentation Requirements

Each containerized application MUST include:

1. **README.md**: With Docker-specific setup instructions
2. **docker-compose.yml**: For local development and testing
3. **Dockerfile**: With commented sections explaining each step
4. **env.example**: Template for required environment variables
5. **.dockerignore**: List of files to exclude from the container

## Integration with CI/CD

Docker-based deployments MUST integrate with CI/CD pipelines:

1. Build and test Docker images on each commit
2. Deploy to development environment automatically
3. Deploy to staging/production with approval steps
4. Run security scans on Docker images
5. Enforce image signing for production deployments

## Relationship to Other Principles

This meta-principle:

1. **Implements P08 (Deployment Patterns)**: Provides the container-based implementation of deployment patterns
2. **Extends MP0016 (Modularity)**: Applies modularity concepts to deployment units
3. **Supports R73 (App.R Change Permission)**: Provides controlled deployment of app.R changes
4. **Enhances MP0031 (Initialization First)**: Ensures proper initialization sequence in containers
5. **Complements MP0048 (Universal Initialization)**: Ensures environment variables and configuration are properly initialized

## Exception Process

Exceptions to Docker-based deployment require:

1. Formal documentation of technical limitations
2. Alternative deployment method that preserves environment consistency
3. Approval by the architecture team
4. Regular review to determine if the exception can be eliminated

## Verification Process

To verify compliance:

1. Validate Dockerfile against best practices
2. Run security scanning on Docker images
3. Test container startup and shutdown procedures
4. Verify proper handling of environment variables
5. Confirm resource isolation and proper permissions

By following this meta-principle, we ensure consistent, reproducible deployments across all environments, reducing deployment risks and enabling rapid scaling of applications.
