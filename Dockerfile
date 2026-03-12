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

# Try to install Flash Attention 3 from prebuilt wheel (aarch64), fallback to flash-attn v2
RUN if [ "$(uname -m)" = "aarch64" ]; then \
            python3.11 -m pip install "https://huggingface.co/datasets/malaysia-ai/Flash-Attention3-wheel/resolve/main/flash_attn_3-3.0.0b1-cp39-abi3-linux_aarch64-2.7.1-12.8.whl" \
            || (echo "Flash Attention 3 wheel install failed, trying flash-attn==2.8.3" && python3.11 -m pip install flash-attn==2.8.3) \
            || echo "flash-attn installation failed, will use native backends"; \
        else \
            echo "Skipping Flash Attention 3 wheel (requires aarch64); trying flash-attn==2.8.3" && \
            python3.11 -m pip install flash-attn==2.8.3 \
            || echo "flash-attn installation failed, will use native backends"; \
        fi

EXPOSE 8080

CMD ["qwen-tts-demo", "Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign", "--port", "8080", "--ip", "0.0.0.0"]
# qwen-tts-demo Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign --port 8080 --ip 0.0.0.0