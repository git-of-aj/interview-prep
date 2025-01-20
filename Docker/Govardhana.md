![image](https://github.com/user-attachments/assets/9ea3d7b2-5ff8-4847-a6e1-125f398d8987)
> Dockerfile builds the image, while Docker Compose manages multiple containers.
## Docker Compose Overview
Docker Compose defines and runs multi-container applications using a YAML file to configure services, networks, and volumes, managing container interactions.

Since version 1.28.6, Docker Compose defaults to compose.yaml or compose.yml, with backward compatibility for docker-compose.yaml/yml. If both exist, compose.yaml is preferred.

Key Features:
Orchestration: Manages container communication, data sharing, and networking.

Multi-Container Support: Simplifies managing multiple services.

Declarative Configuration: Uses YAML for easy service setup.

Resource Limiting: Sets memory and CPU limits for services.

Network Management: Handles service networking automatically.

Volume Management: Manages shared or persistent data.

## Reduce Docker Image size: Less the image size = Faster deployments + Quicker scaling + Lean infrastructure
> Minimizing Docker image sizes accelerates container deployment, and for large-scale operations, this can lead to substantial savings in storage space
1. use base image
python:3.9-slim or python:3.9-alpine not python3.9
2. Min commands:
Every command in your Dockerfile (like RUN, COPY, etc.) generates a separate layer in the final image. Grouping similar commands together into one step decreases the total number of layers, leading to a smaller overall image size.
```dockerfile
RUN apk update
RUN apk add --no-cache git
RUN rm -rf /var/cache/apk/*

-----

RUN apk update && apk add --no-cache git && rm -rf /var/cache/apk/*
```
3. Use .dockerignore File:
When creating Docker images, Docker transfers all the files from your project directory into the image by default. To avoid including unneeded files, use a .dockerignore file to exclude them.
4. Multi-stage builds
```dockerfile
# Dockerfile.multi-stage

# Stage 1: Build
FROM python:3.9-alpine AS builder

# Install necessary build dependencies
RUN apk add --no-cache build-base \
    && apk add --no-cache gfortran musl-dev lapack-dev

# Set the working directory
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code to the working directory
COPY . .

# Uninstall unnecessary dependencies
RUN pip uninstall -y pandas && apk del build-base gfortran musl-dev lapack-dev

# Stage 2: Production
FROM python:3.9-alpine

# Set the working directory
WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=builder /app /app

# Expose the port the app will run on
EXPOSE 5000

# Run the Flask app
CMD ["python", "app.py"]
```
5. Use Static Binaries and the 'scratch' Base Image:
If your application can be compiled into a static binary, you can use the scratch base image, which is essentially an empty image. This leads to extremely small final images.

Example:
```
FROM scratch
COPY myapp /
CMD ["/myapp"]
```
Works well for applications that don’t need operating system-level dependencies.

## Security Considerations
- Use Trusted and Official Base Images

- Run Containers as Non-Root Users

- Regularly scan your Docker images for known vulnerabilities

- Limit the network exposure of your container by restricting the ports and IP addresses
