FROM docker.io/library/alpine:3.19

# Install ffmpeg and runtime dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    ffmpeg \
    ffmpeg-libs

# Copy wrapper script
COPY wrapper.sh /usr/local/bin/wrapper.sh
RUN chmod +x /usr/local/bin/wrapper.sh

# Set working directory
WORKDIR /vol

# Set the command to be executed
ENV COMMAND=/usr/bin/ffmpeg

# Run the wrapper
ENTRYPOINT ["/usr/local/bin/wrapper.sh"]
