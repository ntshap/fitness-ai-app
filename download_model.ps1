# Download MoveNet Lightning model (optimized for mobile devices)
Write-Host "Downloading MoveNet Lightning model..."

# Create models directory if it doesn't exist
if (!(Test-Path "assets/models")) {
    New-Item -ItemType Directory -Path "assets/models" -Force
}

# Download the MoveNet Lightning model (smaller, faster, better for mobile)
$url = "https://tfhub.dev/google/lite-model/movenet/singlepose/lightning/tflite/float16/4?lite-format=tflite"
$output = "assets/movenet_lightning.tflite"

try {
    Invoke-WebRequest -Uri $url -OutFile $output
    Write-Host "MoveNet Lightning model downloaded successfully!" -ForegroundColor Green
    Write-Host "File saved as: $output" -ForegroundColor Green
    
    # Check file size
    $fileInfo = Get-Item $output
    Write-Host "File size: $($fileInfo.Length) bytes" -ForegroundColor Yellow
} catch {
    Write-Host "Error downloading model: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "You may need to download manually from: $url" -ForegroundColor Yellow
}
