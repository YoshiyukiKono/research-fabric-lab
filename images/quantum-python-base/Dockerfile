FROM python:3.12-slim

LABEL org.opencontainers.image.title="research-fabric quantum-python-base"
LABEL org.opencontainers.image.description="Base Python runtime image for Research Fabric Lab quantum/HPC experiments"
LABEL org.opencontainers.image.source="https://github.com/YoshiyukiKono/research-fabric-lab"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /workspace

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       git \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip \
    && pip install -r /tmp/requirements.txt

CMD ["python", "-c", "import json; print(json.dumps({'status': 'ready', 'runtime': 'quantum-python-base'}))"]
