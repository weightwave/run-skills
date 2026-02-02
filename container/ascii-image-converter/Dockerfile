FROM docker.io/library/alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    wget \
    tar

# Download and install ascii-image-converter pre-built binary
RUN set -ex && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        FILENAME="ascii-image-converter_Linux_amd64_64bit.tar.gz"; \
        DIRNAME="ascii-image-converter_Linux_amd64_64bit"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        FILENAME="ascii-image-converter_Linux_armv6_32bit.tar.gz"; \
        DIRNAME="ascii-image-converter_Linux_armv6_32bit"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    VERSION="1.13.1" && \
    \
    # Download from GitHub
    wget "https://github.com/TheZoraiz/ascii-image-converter/releases/download/v${VERSION}/${FILENAME}" -O /tmp/ascii.tar.gz && \
    \
    # Extract
    tar -xzf /tmp/ascii.tar.gz -C /tmp && \
    \
    # Find and move the binary (it's in a subdirectory)
    find /tmp/${DIRNAME} -type f -name "ascii-image-converter" -exec mv {} /usr/local/bin/ascii-image-converter \; && \
    chmod +x /usr/local/bin/ascii-image-converter && \
    \
    # Cleanup
    rm -rf /tmp/ascii.tar.gz /tmp/${DIRNAME} && \
    apk del wget

# Copy wrapper script
COPY wrapper.sh /usr/local/bin/wrapper.sh
RUN chmod +x /usr/local/bin/wrapper.sh

# Set working directory
WORKDIR /vol

# Set the command to be executed
ENV COMMAND=/usr/local/bin/ascii-image-converter

# Run the wrapper
ENTRYPOINT ["/usr/local/bin/wrapper.sh"]
