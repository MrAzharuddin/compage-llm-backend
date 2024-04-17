# Stage 1: Build the application
FROM python:3.10.14-slim AS builder

WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .

RUN pip install -r requirements.txt

# Copy the application code
COPY . .

EXPOSE 8000

EXPOSE 9042

# Stage 2: Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]