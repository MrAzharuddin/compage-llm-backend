# Stage 1: Build the application
FROM cgr.dev/chainguard/wolfi-base AS builder
RUN apk update && apk add python-3.10 && \
    apk add py3.10-pip 
WORKDIR /app

RUN python -m venv /app/venv


COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt
ENV PATH="/app/venv/bin:$PATH"
USER nonroot
EXPOSE 8000
CMD ["uvicorn","main:app","--host", "0.0.0.0","--port", "8000"]