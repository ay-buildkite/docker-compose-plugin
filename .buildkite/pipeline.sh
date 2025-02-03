#!/bin/bash

# Exit immediately on failure or undefined variable
set -eu

# Function to generate the pipeline configuration for multiple compose files approach
generate_multi_compose_config() {
    cat <<YAML
  # Multiple Docker Compose Files Approach
  - label: ':docker: Unit Tests (Multiple Files)'
    plugins:
      - docker-compose#v4.14.0:
          config: [multi-compose/docker-compose.yml, multi-compose/docker-compose.unit.yml]
          run: app
          command: ['npm', 'run', 'test:unit']
  - label: ':docker: :postgresql: Integration Tests (Multiple Files)'
    plugins:
      - docker-compose#v4.14.0:
          config: [multi-compose/docker-compose.yml, multi-compose/docker-compose.integration.yml]
          run: app
          command: ['npm', 'run', 'test:integration']
YAML
}

# Function to generate the pipeline configuration for dependencies control approach
generate_deps_ctrl_config() {
    cat <<YAML
  # Dependencies Control Approach
  - label: ':docker: Unit Tests (Dependencies Control)'
    plugins:
      - docker-compose#v4.14.0:
          config: deps-ctrl/docker-compose.yml
          run: app
          dependencies: false
          command: ['npm', 'run', 'test:unit']
  - label: ':docker: DB Tests (Dependencies Control)'
    plugins:
      - docker-compose#v4.14.0:
          config: deps-ctrl/docker-compose.yml
          run: app
          dependencies: true
          command: ['npm', 'run', 'test:db']
YAML
}

# Function to generate the pipeline configuration for manual service control approach
generate_manual_ctrl_config() {
    cat <<YAML
  # Manual Service Control Approach
  - label: ':docker: Unit Tests (Manual Control)'
    plugins:
      - docker-compose#v4.14.0:
          config: manual-serv-ctrl/docker-compose.yml
          run: app
          command: ['npm', 'run', 'test:unit']
  - label: ':docker: :postgresql: Integration Tests (Manual Control)'
    command:
      - cd manual-serv-ctrl
      - docker compose up -d db
      - docker compose run --rm app /bin/sh -c 'until nc -z db 5432; do sleep 1; done'
    plugins:
      - docker-compose#v4.14.0:
          config: manual-serv-ctrl/docker-compose.yml
          run: app
          command: ['npm', 'run', 'test:integration']
YAML
}

# Add debug output by redirecting to stderr
echo "Debug: Starting pipeline generation" >&2
pwd >&2
ls -la >&2

# Begin generating the pipeline
cat <<YAML
steps:
YAML

# Get back to root dir
cd ..

# Generate pipeline conf for each approach
for approach_dir in */; do
    echo "Debug: Found directory: $approach_dir" >&2
    # Skip any dotfiles or other config types
    if [[ "$approach_dir" =~ ^(\.|_) ]]; then
        echo "Debug: Skipping $approach_dir" >&2
        continue
    fi
    
    # Remove trailing slash from directory name
    approach=${approach_dir%/}

    # Call func based on approach
    case $approach in
        "multi-compose")
            generate_multi_compose_config
            ;;
        "deps-ctrl")
            generate_deps_ctrl_config
            ;;
        "manual-serv-ctrl")
            ;;
    esac
done
