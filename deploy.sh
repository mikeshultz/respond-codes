#!/bin/bash

# Exit on error
set -e

export NAME="respond"
export NAMESPACE="respond"

# Figure out our docker tags
export BUILD_ID="$(date +%Y%m%d%H%M%S)"
export REGISTRY="registry.mikes.network/$NAME"
export TAG="$REGISTRY:$BUILD_ID"

echo "Building $TAG..."

# Build & send it
docker build -f devops/dockerfiles/$NAME -t $TAG .
docker tag $TAG $REGISTRY:latest
docker push $TAG
docker push $REGISTRY:latest

kubectl -n $NAMESPACE set image deployment/$NAME $NAME=$TAG

echo "Complete"
