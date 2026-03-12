FROM nvcr.io/nvidia/pytorch:24.12-py3

LABEL maintainer="Qwen Team"
LABEL description="Qwen3-TTS with CUDA support"
LABEL version="0.1.1"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    sox \
    libsndfile1 \
    git \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENV HF_HOME=/app/models \
    HUGGINGFACE_HUB_CACHE=/app/models/hub \
    PIP_CONSTRAINT=/etc/pip/constraint.txt \
    GRADIO_SERVER_NAME=0.0.0.0 \
    GRADIO_SERVER_PORT=7860

RUN mkdir -p /app/models

COPY pyproject.toml MANIFEST.in /app/

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
    transformers==4.49.0 \
    accelerate==1.12.0 \
    torchao \
    gradio \
    librosa \
    soundfile \
    onnxruntime \
    einops \
    tqdm \
    scipy \
    matplotlib \
    pillow

COPY . /app

RUN pip install -e .

EXPOSE 7860

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:7860/info || exit 1

CMD ["qwen-tts-demo"]