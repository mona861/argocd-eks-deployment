# Simple Deployment Server

A lightweight Python Flask server that displays a customizable deployment landing page.

## Features

- Simple, configurable landing page
- Easy color and text customization
- Multi-stage Docker build for minimal image size
- Alpine-based Python image for security and efficiency

## Quick Start

### Local Development

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run the server:
```bash
python app.py
```

3. Visit `http://localhost:8080`

### Docker Deployment

1. Build the image:
```bash
docker build -t deployment-server .
```

2. Run the container:
```bash
docker run -p 8080:8080 deployment-server
```

3. Visit `http://localhost:8080`

## Customization

To change the deployment color and text, edit the configuration variables at the top of `app.py`:

```python
# Easy configuration - change these values to customize your deployment
BACKGROUND_COLOR = "green"  # Change to "blue", "red", "#FF5733", etc.
DEPLOYMENT_TEXT = "Green Deployment"  # Change to "Blue Deployment", etc.
```

### Example: Blue Deployment

```python
BACKGROUND_COLOR = "blue"
DEPLOYMENT_TEXT = "Blue Deployment"
```

### Example: Custom Color Deployment

```python
BACKGROUND_COLOR = "#FF6B6B"  # Coral red
DEPLOYMENT_TEXT = "Production Deployment"
```

## File Structure

```
.
├── app.py              # Flask application
├── requirements.txt    # Python dependencies
├── Dockerfile          # Multi-stage Docker build
└── README.md          # This file
```

## Docker Image Details

- **Base Image**: `python:3.11-alpine`
- **Multi-stage build**: Yes (reduces final image size)
- **Exposed Port**: 5000
- **Image Size**: Approximately 50-60 MB
