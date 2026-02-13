#!/bin/bash

set -e

VARIANT=$1

if [ -z "$VARIANT" ]; then
  echo "Usage: $0 <variant>"
  echo "Available variants: python, ts"
  exit 1
fi

DOCKERFILE="./docker/variants/$VARIANT/Dockerfile"

if [ ! -f "$DOCKERFILE" ]; then
  echo "Error: Variant '$VARIANT' not found!"
  echo "Available variants: python, ts"
  exit 1
fi

# Build with docker directory as context so variants can access base files
docker build -f "$DOCKERFILE" -t jdcode-$VARIANT ./docker
