#
# This Dockerfile is for cloud deployment to EBS, Digital Ocean or compatible platforms.
# https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/docker.html
# https://docs.digitalocean.com/products/app-platform/
#

FROM python:3.13

ENV PYTHONUNBUFFERED=1 \
    POETRY_VERSION=2.1.2 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PATH="$PATH:/home/appuser/.local/bin"

# Install system packages
RUN apt-get update
RUN apt-get install -y nodejs patch

# Make user and app dir
RUN groupadd -r appuser && useradd -ms /bin/bash -g appuser appuser
RUN mkdir /app
RUN chown appuser:appuser -R /app

# Set non-root app user
USER appuser
WORKDIR /app

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python -

# Copy only requirements to cache them in docker layer
COPY poetry.lock pyproject.toml ./

# Project initialization:
RUN poetry install --only=main --no-interaction --no-ansi --no-root

# Copy project
COPY --chown=appuser:appuser . /app


