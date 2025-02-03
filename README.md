```markdown
# Docker Compose Plugin Examples

This repository demonstrates different approaches for managing service dependencies in Buildkite pipelines using the Docker Compose plugin.

## Structure

### `multi-compose/`
Shows how to split dependencies across multiple Docker Compose files. Different steps can include different compose files as needed.

### `deps-ctrl/` 
Demonstrates using the plugin's `dependencies` flag to toggle whether dependent services should start.

### `manual-serv-ctrl/`
Showcases manual service orchestration by explicitly starting and waiting for required services in pipeline steps.

## Usage
See individual directories for specific implementation details. Pipeline examples assume a Node.js application needing PostgreSQL for integration tests.
```