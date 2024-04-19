# Stage 1: Build the application
FROM cgr.dev/chainguard/wolfi-base AS builder

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
FROM cgr.dev/chainguard/wolfi-base as final

RUN apk update && apk add python-3.10

WORKDIR /app/

ENV PYTHONUNBUFFERED=1

COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip setuptools

RUN addgroup -g 1001 appuser && \
    adduser -S -u 1001 -G appuser appuser

RUN chown -R appuser:appuser /app/ && \
    chmod 755 /app/

USER appuser

EXPOSE 8000

EXPOSE 9042

CMD ["uvicorn","main:app","--host","0.0.0.0", "--port", "8000"] 