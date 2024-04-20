# Stage 1: Build the application
FROM cgr.dev/chainguard/python:latest-dev AS builder

ENV PYTHONDONTWRITEBYTECODE=1

ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN python -m venv /app/venv

ENV PATH="/app/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip setuptools
RUN pip install -r requirements.txt


# Stage 2: Copy the venv and run the application
FROM cgr.dev/chainguard/python:latest AS final 

WORKDIR /app

ENV PYTHONUNBUFFERED=1

COPY main.py ./
COPY --from=builder /app/venv /venv

ENV PATH="/venv/bin:$PATH"


EXPOSE 8000

ENTRYPOINT ["python", "main.py"] 