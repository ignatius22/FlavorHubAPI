# syntax = docker/dockerfile:1

# Stage 1: Base Image
# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Set working directory for the Rails app
WORKDIR /app

# Set production environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# Stage 2: Build Stage
FROM base as build

# Install packages needed to build gems and application dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        libpq-dev \
        libvips-dev \
        pkg-config

# Install Bundler (if not installed by default in the Ruby image)
RUN gem install bundler --no-document

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install application gems
RUN bundle config --global frozen 1 && \
    bundle install --jobs "$(nproc)" --retry 5 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Stage 3: Final Stage for App Image
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        libvips \
        postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy built artifacts from the build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Ensure gems are in the PATH
ENV PATH /usr/local/bundle/bin:/app/bin:$PATH

# Create necessary directories
RUN mkdir -p /app/db /app/log /app/storage /app/tmp
# Create a non-root user for running the app securely
RUN adduser --system --group app && \
    chown -R app /app && \
    chmod -R 755 /app

# Set the user to run the app as non-root
USER app:app

# Expose port 3000
EXPOSE 3000

# Entrypoint script to prepare the database and start the server
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
CMD ["bundle", "exec", "rails", "server"]
