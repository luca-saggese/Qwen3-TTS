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
# NOTA: TRANSFORMERS_CACHE è deprecato, usiamo solo HF_HOME
ENV HF_HOME=/app/models \
    HUGGINGFACE_HUB_CACHE=/app/models/hub

# Crea la directory di cache
RUN mkdir -p /app/models

# ============================================================================
# Layer 3: Copia solo i file di configurazione (cache strategy: setup base)
# ============================================================================
COPY pyproject.toml MANIFEST.in /app/

# ============================================================================
# Layer 4: Installa le dipendenze Python con fix di compatibilità
# ============================================================================
# Nota: Usando versioni stabili compatibili con pytorch:24.12
RUN pip install --no-cache-dir -q --upgrade pip setuptools wheel

RUN pip install --no-cache-dir -q \
    gradio \
    librosa \
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

# ============================================================================
# Layer 8: Configurazione runtime
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

# Lancia la demo all'