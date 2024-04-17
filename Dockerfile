# Stage 1: Build the application
FROM python:3.10.14-slim AS builder

WORKDIR /app

# Create and activate a virtual environment
RUN python3 -m venv venv

# Set the PATH to include the virtual environment
ENV PATH="/app/venv/bin:$PATH"

# Copy and install dependencies
COPY requirements.txt .

RUN . venv/bin/activate && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install uvicorn

# Copy the application code
COPY . .

# Stage 2: Run the application
CMD ["uvicorn", "main:app", "--host", "localhost", "--port", "8000"]
