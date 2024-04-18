# Stage 1: Build the application
FROM cgr.dev/chainguard/wolfi-base AS builder
RUN apk update && apk add python-3.10 && apk add py3.10-pip --update

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN python -m venv /app/venv

# Copy and install dependencies
COPY requirements.txt .

RUN pip install -r requirements.txt

FROM cgr.dev/chainguard/wolfi-base as final
RUN apk update && apk add python-3.10 && apk add py3.10-pip --update && apk add netcat-openbsd

ENV PYTHONUNBUFFERED=1


COPY main.py .
COPY ./pkg/src .

COPY *.sh .
RUN chmod +x ./start.sh && chmod +x ./wait.sh  

ENV PATH="/venv/bin:$PATH"
COPY --from=builder /app/venv /venv
RUN pip install uvicorn && \
    pip install fastAPI

EXPOSE 8000

EXPOSE 9042

# Stage 2: Run the application
CMD ["./wait.sh", "cassandra:9042","--", "./start.sh"]
# CMD ["/bin/bash"]