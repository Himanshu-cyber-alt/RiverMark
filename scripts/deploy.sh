#!/bin/bash

set -e

IMAGE="$1"
CONTAINER_NAME="rivermark-backend"
PORT="5000"
AWS_REGION="${AWS_REGION:-ap-south-1}"

if [ -z "$IMAGE" ]; then
  echo "Error"
  echo "Usage"
  exit 1
fi


echo " Rivermark backend"
echo "Image: $IMAGE"


ECR_REGISTRY=$(echo "$IMAGE" | cut -d'/' -f1)

echo "Logging into ECR..."

aws ecr get-login-password --region "$AWS_REGION" | \
  docker login \
  --username AWS \
  --password-stdin "$ECR_REGISTRY"

echo "Pulling new image"
docker pull "$IMAGE"

echo "Removing"
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "Starting new container"

docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p "$PORT:5000" \
  "$IMAGE"

echo "Waiting for application to start"
sleep 10

echo "Running health check..."

if curl -f "http://localhost:$PORT/health"; then


 
  echo "yes"


else



  echo "no"


  docker logs "$CONTAINER_NAME" || true

  docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

  exit 1
fi