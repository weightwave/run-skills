# Run-Skills Docker Containers

This directory contains Docker configurations for each skill that can be executed via the run-skills API.

## Available Skills

- **ascii-image-converter**: Convert images to ASCII art
- **ffmpeg**: Media processing and conversion
- **imagemagick**: Image manipulation and conversion

## Directory Structure

```
container/
├── wrapper.sh                       # Shared wrapper script for all skills
├── ascii-image-converter/
│   ├── Dockerfile
│   └── wrapper.sh
├── ffmpeg/
│   ├── Dockerfile
│   └── wrapper.sh
└── imagemagick/
    ├── Dockerfile
    └── wrapper.sh
```

## Building Images

**⚠️ Platform Notice**: All images are built for `linux/amd64` to ensure compatibility with cloud deployment (AWS/Fly.io), even when building on ARM64 Macs.

### Build all images

```bash
./scripts/build-images.sh
```

### Build a specific skill

```bash
docker build \
  --platform=linux/amd64 \
  -t 471112576951.dkr.ecr.ap-northeast-1.amazonaws.com/weightwave/skill:ascii-image-converter-latest \
  -f container/ascii-image-converter/Dockerfile \
  container/ascii-image-converter
```

## Pushing to ECR

### Prerequisites

1. Ensure you have AWS CLI installed
2. Configure your AWS credentials
3. Ensure you have access to the ECR repository

### Push all images

```bash
./scripts/push-images.sh
```

### Build and push in one command

```bash
./scripts/build-and-push.sh
```

## Local Testing with Docker Compose

```bash
# Set required environment variables
export CALLBACK_URL=http://localhost:3000/callback
export INTERNAL_SECRET=your-secret-here
export USER_ID=test

# Run a specific skill
docker-compose run ascii-image-converter
```

## How It Works

1. Each skill container includes:
   - The specific tool (ascii-image-converter, ffmpeg, or imagemagick)
   - A wrapper script that handles command execution
   - Runtime dependencies (bash, curl, jq)

2. The wrapper script:
   - Receives commands and arguments via environment variables
   - Executes the command with the provided arguments
   - Streams stdout/stderr back to the API via HTTP callbacks
   - Reports the exit code when complete

3. Environment variables:
   - `CALLBACK_URL`: HTTP endpoint to send output chunks
   - `INTERNAL_SECRET`: Authentication token for callbacks
   - `COMMAND`: The command to execute (set in Dockerfile)
   - `ARGS`: Null-byte separated command arguments
   - `USER_ID`: User identifier for volume mounting

## Adding a New Skill

1. Create a new directory: `container/your-skill/`
2. Copy `wrapper.sh` to the new directory
3. Create a `Dockerfile` that:
   - Installs the required tool
   - Installs bash, curl, jq, ca-certificates
   - Copies the wrapper script
   - Sets the `COMMAND` environment variable
   - Uses wrapper.sh as the entrypoint
4. Add the skill to `src/services/registry.ts`
5. Add the skill to build scripts
6. Update this README

## Example Dockerfile Template

```dockerfile
FROM alpine:3.19

# Install your tool and dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    your-tool

# Copy wrapper script
COPY wrapper.sh /usr/local/bin/wrapper.sh
RUN chmod +x /usr/local/bin/wrapper.sh

# Set working directory
WORKDIR /vol

# Set the command to be executed
ENV COMMAND=/usr/bin/your-tool

# Run the wrapper
ENTRYPOINT ["/usr/local/bin/wrapper.sh"]
```

## ECR Repository

- Registry: `471112576951.dkr.ecr.ap-northeast-1.amazonaws.com`
- Repository: `weightwave/skill`
- Region: `ap-northeast-1`

## Image Tags

Each skill uses the following tag format:
- `{skill-name}-latest` (e.g., `ascii-image-converter-latest`)
