#!/bin/bash

set -e

IMAGE="$1"
CONTAINER_NAME="rivermark-backend"
PORT="5000"

if [ -z "$IMAGE" ]; then
  echo "Error: Docker image is required."
  echo "Usage: ./deploy-backend.sh <image>"
  exit 1
fi

echo "======================================"
echo "Deploying Rivermark backend"
echo "Image: $IMAGE"
echo "======================================"

# Login to ECR
AWS_REGION="${AWS_REGION:-ap-south-1}"

ECR_REGISTRY=$(echo "$IMAGE" | cut -d'/' -f1)

echo "Logging into ECR..."

aws ecr get-login-password --region "$AWS_REGION" | \
  docker login \
  --username AWS \
  --password-stdin "$ECR_REGISTRY"

# Pull new image
echo "Pulling new image..."

docker pull "$IMAGE"

# Remove old container on this EC2
echo "Removing previous container..."

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Start new container
echo "Starting new container..."

docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p "$PORT:5000" \
  "$IMAGE"

echo "Waiting for application to start..."

sleep 10

# Health check
echo "Running health check..."

if curl -f http://localhost:$PORT/health; then

  echo "======================================"
  echo "New backend is healthy."
  echo "Deployment successful."
  echo "======================================"

else

  echo "======================================"
  echo "New backend failed health check."
  echo "Deployment failed."
  echo "======================================"

  docker logs "$CONTAINER_NAME" || true

  docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

  exit 1
fi