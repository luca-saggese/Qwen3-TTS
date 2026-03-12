# Multi-stage build: utilizza l'immagine NVIDIA PyTorch come base
FROM nvcr.io/nvidia/pytorch:25.10-py3

# Metadata
LABEL maintainer="Qwen Team"
LABEL description="Qwen3-TTS with CUDA support"
LABEL version="0.1.1"

# Imposta il working directory
WORKDIR /app

# ============================================================================
# Layer 1: Installa le dipendenze di sistema (cache strategy: rarely change)
# ============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    sox \
    libsndfile1 \
    git \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# Layer 2: Setup variabili d'ambiente per HuggingFace
# ============================================================================
# HF_HOME: directory di cache per i modelli di HuggingFace
ENV HF_HOME=/huggingface
# ============================================================================
# Installa le dipendenze del progetto escludendo torch, cuda e gpu-related
# che sono già presenti nell'immagine base pytorch:25.10-py3
RUN pip install --no-cache-dir -q \
    transformers==4.57.3 \
    accelerate==1.12.0 \
    gradio \
    librosa \
    torchaudio \
    soundfile \
    onnxruntime \
    einops

# ============================================================================
# Layer 5: Copia il codice sorgente (cache strategy: change frequently)
# ============================================================================
COPY . /app

# ============================================================================
# Layer 6: Installa il pacchetto qwen-tts in modalità develop
# ============================================================================
RUN pip install --no-cache-dir -e .

# ============================================================================
# Layer 7: Pre-scarica i modelli (opzionale, commentare per setup lean)
# ============================================================================
# Uncomment the line below per pre-scaricare i modelli durante il build
# (questo aumenta il tempo di build ma riduce il tempo di startup)
# RUN python /app/download_models.py --tokenizer-only
    onnxruntime \
    einops

# ============================================================================
# Layer 4: Copia il codice sorgente (cache strategy: change frequently)
# ============================================================================
COPY . /app
# ============================================================================
# Layer 5: Installa il pacchetto qwen-tts in modalità develop
# ============================================================================
RUN pip install --no-cache-dir -e .

# ============================================================================
# Layer 6: Configurazione runtime
# ============================================================================
EXPOSE 7860

# Variabili d'ambiente per la demo Gradio
ENV GRADIO_SERVER_NAME=0.0.0.0
ENV GRADIO_SERVER_PORT=7860

# Health check opzionale (utile per orchestrazione)
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:7860/info || exit 1

# Lancia la demo all'avvio del container
CMD ["qwen-tts-demo"]
