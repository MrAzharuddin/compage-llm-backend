# Stage 1: Build the application
FROM cgr.dev/chainguard/wolfi-base AS builder
RUN apk update && apk add python-3.10 && apk add py3.10-pip --update && apk add netcat-openbsd

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN python -m venv /app/venv

# Copy and install dependencies
COPY requirements.txt .

COPY main.py ./
COPY *.sh .
RUN chmod +x ./start.sh && chmod +x ./wait.sh  
RUN pip install -r requirements.txt


EXPOSE 8000

EXPOSE 9042

CMD ["./wait.sh", "cassandra:9042","--", "./start.sh"]


#TODO: Add Stage 2: Run the application 