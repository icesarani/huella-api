FROM mcr.microsoft.com/devcontainers/ruby:3.3

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      # Adds liboq-dev for dependencies of PostgreSQL
      libpq-dev \
      libvips \
      pkg-config