# Base image: Python 3.12 slim variant for smaller image size
FROM python:3.13-slim

# Set working directory for subsequent commands
WORKDIR /app

# Copy requirements file to leverage Docker layer caching
COPY python/requirements.txt .

# Install Python dependencies without caching to reduce image size
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code into container
COPY python/ .

# Document the port the application listens on
EXPOSE 5001

# Default command to run when container starts
CMD ["python", "app.py"]