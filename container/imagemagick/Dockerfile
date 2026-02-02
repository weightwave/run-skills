FROM docker.io/library/alpine:3.19

# Install ImageMagick and runtime dependencies
# Note: In Alpine, the main imagemagick package includes most format support
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    imagemagick \
    imagemagick-jpeg \
    imagemagick-tiff \
    imagemagick-webp

# Copy wrapper script
COPY wrapper.sh /usr/local/bin/wrapper.sh
RUN chmod +x /usr/local/bin/wrapper.sh

# Set working directory
WORKDIR /vol

# Set the command to be executed
ENV COMMAND=/usr/bin/convert

# Run the wrapper
ENTRYPOINT ["/usr/local/bin/wrapper.sh"]
