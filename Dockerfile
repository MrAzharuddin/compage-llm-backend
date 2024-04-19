# Stage 1: Build the application
FROM cgr.dev/chainguard/wolfi-base@sha256:6bc98699de679ce5e9d1d53b9d06b99acde93584bf539690d61ec538916b1e74 AS builder

RUN apk update && \
    apk add python-3.10 && \
    apk add py3.10-pip --upgrade

ENV PYTHONDONTWRITEBYTECODE=1

ENV PYTHONUNBUFFERED=1

WORKDIR /app/

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

RUN pip install -Ur requirements.txt

# Stage 2: Copy the venv and run the application
FROM cgr.dev/chainguard/wolfi-base@sha256:6bc98699de679ce5e9d1d53b9d06b99acde93584bf539690d61ec538916b1e74 as final

RUN apk update && apk add python-3.10

WORKDIR /app/

ENV PYTHONUNBUFFERED=1

COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip setuptools

EXPOSE 8000

CMD ["uvicorn","main:app","--host","0.0.0.0", "--port", "8000"] 