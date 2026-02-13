# AGENTS.md - Development Guidelines

This file provides guidance for agentic coding agents operating in this repository.

## Build Commands

### Docker

```bash
# Build main image
docker build -t jdcode-dev .

# Build specific variant
./build.sh python   # Python development variant
./build.sh ts       # TypeScript development variant

# Run container
docker run -it --rm -v "$PWD":/code -p 8080:8080 jdcode-dev

# With password authentication
docker run -it --rm -v "$PWD":/code -p 8080:8080 -e PASSWORD=secret jdcode-dev

# View logs
docker logs <container-id>

# Shell access
docker exec -it <container-id> bash
```

### Testing (TypeScript variant)

```bash
cd docker/variants/ts

# Run all tests
npm test

# Run single test file
npm test <filepath>

# Watch mode
npm run test:watch

# With coverage
npm run test:coverage
```

---

## Code Style Guidelines

### General Principles

- Keep files focused and modular
- Use meaningful, descriptive names
- Add comments for non-obvious logic
- Prefer explicit over implicit
- Fail fast with clear error messages

---

## Shell Script Conventions

### Structure

```bash
#!/bin/bash
set -e

# Section comment (if script is long)
# ─────────────────────────────────────────────

# Functions go at top or in separate files
function main() {
    local arg="${1}"
    # ...
}

# Entry point
main "$@"
```

### Naming

- Scripts: lowercase with hyphens (e.g., `check-host.sh`)
- Functions: lowercase with underscores (e.g., `check_docker_running`)
- Constants: UPPERCASE (e.g., `DEFAULT_PORT=8080`)

### Error Handling

- Always use `set -e` at the top for fail-fast
- Check exit codes: `if command; then ... fi`
- Use `|| true` for optional commands that shouldn't fail
- Exit with meaningful codes: `exit 1` for errors

### Formatting

- Indent with 2 spaces
- Use spaces around `[ ]` brackets: `[ -n "$VAR" ]`
- Quote variables: `"$VAR"` not `$VAR`
- Use `local` for function-scoped variables

### Examples

```bash
# Good
if [ -n "${PASSWORD}" ]; then
    code-server --auth password --bind-addr "0.0.0.0:${PORT}"
fi

# Bad
if [ -n $PASSWORD ]; then
code-server --auth password
fi
```

---

## Dockerfile Conventions

### Structure

```dockerfile
# syntax=docker/dockerfile:1

# Base image
FROM python:3.12-slim

# ─────────────────────────────────────────────
# Section: Description
# ─────────────────────────────────────────────

# Install dependencies in single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy files
COPY file.txt /destination/

# Environment
ENV PORT=8080

# Expose
EXPOSE 8080

# Entrypoint
ENTRYPOINT ["/script.sh"]
```

### Best Practices

- **No root**: Create and use non-root users where possible
- **Layer optimization**: Combine RUN commands to reduce layers
- **Cleanup**: Always clean apt caches in same layer
- **Version pinning**: Pin versions for reproducibility
- **Health checks**: Use HEALTHCHECK for long-running services
- **Labels**: Add maintainer labels for images

### Portability

- Use environment variables for configurable values
- Don't hardcode paths; use variables
- Make volumes mountable at standard locations

---

## Configuration Files (JSON)

### Format

- Use 2-space indentation
- Include trailing commas (JSONC style is acceptable)
- Add comments for non-obvious settings

### Structure

```json
{
  "$schema": "https://opencode.ai/config.json",
  "key": "value",
  "nested": {
    "option": true
  }
}
```

---

## Error Handling

### Shell Scripts

```bash
# Fail on any error
set -e

# Explicit error checking
if ! command -v curl > /dev/null; then
    echo "ERROR: curl is required" >&2
    exit 1
fi

# Trap for cleanup
trap 'cleanup_on_exit' EXIT
```

### Docker

```bash
# Check process started
if ! ps aux | grep -v grep | grep code-server > /dev/null; then
    echo "ERROR: code-server failed to start"
    cat /var/log/code-server.log
    exit 1
fi
```

---

## Git Conventions

- Write meaningful commit messages
- Keep commits focused and atomic
- No secrets or keys in code
- Use `.dockerignore` to exclude build context

---

## Testing Guidelines

- Write tests for new features
- Use descriptive test names
- One concern per test
- Clean up after tests (temp files, processes)

---

## Documentation

- Document non-obvious configurations
- Keep README.md updated with new commands
- Add inline comments for complex logic
- Explain "why" not just "what"
