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
    GRADIO_SERVER_NAME=0.0.0.0 \
    GRADIO_SERVER_PORT=7860

RUN mkdir -p /app/models

COPY . /app

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

RUN pip install --no-cache-dir -e .
RUN pip install --no-cache-dir torchao tqdm scipy matplotlib pillow

# Uninstall and reinstall torchvision to ensure compatibility with the PyTorch version in the base image
RUN pip uninstall torchvision -y
RUN pip install torchvision --no-cache-dir
RUN pip install --upgrade librosa

# Installa flash_attention scaricando il wheel precompilato (sostituisci l'URL con la tua versione/architettura target)
RUN wget -q "https://github.com/Dao-AILab/flash-attention/releases/download/v2.7.2.post1/flash_attn-2.7.2.post1+cu12torch2.5cxx11abiFALSE-cp312-cp312-linux_aarch64.whl" -O flash_attn_aarch64.whl \
    && pip install --no-cache-dir flash_attn_aarch64.whl \
    && rm flash_attn_aarch64.whl

EXPOSE 8080

CMD ["qwen-tts-demo", "Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign", "--port", "8080", "--ip", "0.0.0.0"]
# qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign --port 8080 --ip 0.0.0.0