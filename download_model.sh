#!/bin/bash

# Download MoveNet Lightning model (optimized for speed and mobile devices)
echo "Downloading MoveNet Lightning model..."

# Create models directory if it doesn't exist
mkdir -p assets/models

# Download the MoveNet Lightning model (smaller, faster, better for mobile)
curl -L "https://tfhub.dev/google/lite-model/movenet/singlepose/lightning/tflite/float16/4?lite-format=tflite" \
  -o "assets/movenet_lightning.tflite"

echo "MoveNet Lightning model downloaded successfully!"
echo "File saved as: assets/movenet_lightning.tflite"

# Check file size
ls -lh assets/movenet_lightning.tflite
