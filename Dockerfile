# Stage 1: Build the application
FROM cgr.dev/chainguard/wolfi-base AS builder
RUN apk update && apk add python-3.10 && \
apk add py3.10-pip 

USER nonroot
ENV PYTHONDONTWRITEBYTECODE=1

ENV PYTHONUNBUFFERED=1
USER nonroot
WORKDIR /app
COPY --chown=nonroot:nonroot requirements.txt /app/requirements.txt 
RUN pip install -r /app/requirements.txt --user


# Stage 2: Copy the venv and run the application
FROM cgr.dev/chainguard/wolfi-base AS final 
RUN apk update && apk add python-3.10 && \
    apk add py3.10-pip 
RUN pip install --upgrade pip setuptools
USER nonroot
WORKDIR /app

ENV PYTHONUNBUFFERED=1

COPY --chown=nonroot:nonroot . .
COPY --from=builder --chown=nonroot:nonroot /home/nonroot/.local /home/nonroot/.local
ENV PATH=/home/nonroot/.local/bin:$PATH
EXPOSE 8000

# ENTRYPOINT ["python", "main.py"] 
CMD ["uvicorn", "main:app","--host", "0.0.0.0","--port", "9042"]