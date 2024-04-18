# Stage 1: Build the application
FROM cgr.dev/chainguard/wolfi-base AS builder
RUN apk update && apk add python-3.10 && apk add py3.10-pip --update

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app/

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy and install dependencies
COPY requirements.txt .

RUN pip install -Ur requirements.txt

FROM cgr.dev/chainguard/wolfi-base as final
RUN apk update && apk add python-3.10 && apk add py3.10-pip --update 
WORKDIR /app/
ENV PYTHONUNBUFFERED=1


COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8000

EXPOSE 9042

CMD ["uvicorn","main:app","--host","0.0.0.0", "--port", "8000"] 