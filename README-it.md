# Qwen3-TTS - Guida all'Utilizzo

## 📋 Indice

- [Panoramica](#panoramica)
- [Requisiti](#requisiti)
- [Installazione](#installazione)
- [Utilizzo](#utilizzo)
  - [Interfaccia Web Locale](#interfaccia-web-locale)
  - [Dalla Linea di Comando](#dalla-linea-di-comando)
  - [Come Libreria Python](#come-libreria-python)
- [Docker](#docker)
  - [Costruire l'Immagine](#costruire-limmagine)
  - [Eseguire il Container](#eseguire-il-container)
- [Modelli Disponibili](#modelli-disponibili)
- [Esempi di Utilizzo](#esempi-di-utilizzo)
  - [Generazione Voce Personalizzata](#generazione-voce-personalizzata)
  - [Voice Design](#voice-design)
  - [Voice Clone](#voice-clone)
- [Risoluzione dei Problemi](#risoluzione-dei-problemi)
- [Risorse Aggiuntive](#risorse-aggiuntive)

---

## Panoramica

**Qwen3-TTS** è un modello generativo di sintesi vocale basato su intelligenza artificiale che fornisce:

- **Clonazione Vocale**: Clona una voce a partire da un campione di 3 secondi
- **Voice Design**: Crea voci personalizzate basate su descrizioni testuali
- **Voice Control**: Controlla tono, velocità e tono emotivo tramite istruzioni in linguaggio naturale
- **Supporto Multilingue**: Supporta 10 lingue principali (cinese, inglese, giapponese, coreano, tedesco, francese, russo, portoghese, spagnolo, italiano)
- **Generazione in Streaming**: Latenza ultra-bassa (~97ms) per applicazioni in tempo reale

---

## Requisiti

### Per l'Esecuzione Locale

- **Python**: 3.9 o superiore
- **GPU NVIDIA**: Con CUDA 12.0+ per le migliori prestazioni
- **RAM**: Almeno 8GB (consigliato 16GB per modelli più grandi)

### Per Docker

- **Docker Desktop**: Con supporto GPU NVIDIA (nvidia-docker)
- **NVIDIA Container Runtime**: Abilitato

---

## Installazione

### 1. Installazione da Sorgente

```bash
# Clona il repository
git clone https://github.com/Qwen/Qwen3-TTS.git
cd Qwen3-TTS

# Crea un ambiente virtuale (opzionale, consigliato)
python -m venv venv
source venv/bin/activate  # Su Windows: venv\Scripts\activate

# Installa il pacchetto
pip install -e .
```

### 2. Installazione delle Dipendenze

Le dipendenze principali verranno installate automaticamente:

```
- transformers: Modelli transformer
- accelerate: Accelerazione GPU
- gradio: Interfaccia web
- librosa: Elaborazione audio
- torchaudio: Utilities PyTorch per audio
- soundfile: I/O file audio
- sox: Manipolazione audio
- onnxruntime: Runtime ONNX
- einops: Operazioni tensor einsum
```

### 3. Download dei Modelli (Opzionale, Consigliato)

Se non hai una buona connessione internet al runtime, scarica i modelli in anticipo:

```bash
# Via HuggingFace
huggingface-cli download Qwen/Qwen3-TTS-Tokenizer-12Hz --local-dir ./models/Qwen3-TTS-Tokenizer-12Hz
huggingface-cli download Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice --local-dir ./models/Qwen3-TTS-12Hz-1.7B-CustomVoice

# Via ModelScope (recommandato in Cina)
modelscope download --model Qwen/Qwen3-TTS-Tokenizer-12Hz --local_dir ./models/Qwen3-TTS-Tokenizer-12Hz
modelscope download --model Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice --local_dir ./models/Qwen3-TTS-12Hz-1.7B-CustomVoice
```

---

## Utilizzo

### Interfaccia Web Locale

Lanciare l'interfaccia web Gradio:

```bash
qwen-tts-demo
```

L'interfaccia sarà disponibile su:
```
http://localhost:7860
```

**Funzionalità dell'interfaccia:**
- Selezione del modello
- Input di testo in più lingue
- Caricamento di file audio per voice clone
- Descrizione scritta per voice design
- Anteprima e download dell'audio generato

### Pre-Scaricare i Modelli

Per evitare download durante la prima esecuzione, puoi pre-scaricare i modelli con lo script dedicato:

```bash
# Scarica solo il tokenizer (leggero, ~500MB)
python download_models.py --tokenizer-only

# Scarica i modelli default (tokenizer + 0.6B)
python download_models.py

# Scarica un modello specifico
python download_models.py --model Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice

# Scarica TUTTI i modelli (richiede ~60GB)
python download_models.py --all

# Usa una directory custom per i modelli
python download_models.py --cache-dir /mnt/models --tokenizer-only
```

I modelli verranno salvati in:
```
$HF_HOME/hub/
```

Per impostare HF_HOME:
```bash
export HF_HOME=/custom/path/to/models
python download_models.py
```

### Dalla Linea di Comando

Consultare gli script di esempio nella cartella `examples/`:

```bash
python examples/test_model_12hz_custom_voice.py
python examples/test_model_12hz_voice_design.py
python examples/test_model_12hz_base.py
```

### Come Libreria Python

```python
from qwen_tts.inference import Qwen3TTSInference

# Inizializza il modello
model = Qwen3TTSInference(model_name="Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice")

# Genera audio
audio_data = model.generate(
    text="Ciao, sono una voce sintetica generata da Qwen3-TTS",
    instruction="Parla con un tono amichevole e allegro"
)

# Salva il risultato
audio_data.save("output.wav")
```

---

## Docker

### Configurazione Variabili d'Ambiente

L'immagine Docker usa le seguenti variabili d'ambiente per gestire i modelli:

```bash
# Directory di cache per HuggingFace (dove vengono salvati i modelli)
HF_HOME=/app/models
HUGGINGFACE_HUB_CACHE=/app/models/hub
```

### Costruire l'Immagine

#### 1. Build Lean (senza modelli pre-scaricati)

```bash
docker build -t qwen3-tts:latest .
```

Questa versione è leggera (~5GB) ma scarica i modelli al primo avvio.

#### 2. Build con Pre-Scaricamento (opzionale)

Uncomment la linea nel Dockerfile:

```dockerfile
RUN python /app/download_models.py --tokenizer-only
```

Poi ricompila:

```bash
docker build -t qwen3-tts:with-models .
```

Questa versione include il tokenizer nel'immagine (~7GB totali).

### Eseguire il Container

#### Metodo 1: Script Helper (Consigliato)

Per eseguire il container con le migliori configurazioni GPU automaticamente:

**Su Linux/macOS:**

```bash
# Rendi lo script eseguibile
chmod +x run.sh

# Esegui con default (GPU, porta 7860)
./run.sh

# Altre opzioni
./run.sh --no-gpu              # Disabilita GPU
./run.sh --port 8000           # Cambia porta
./run.sh --detach              # Background
./run.sh --rebuild             # Ricompila l'immagine
./run.sh --models-dir /mnt/my-models  # Riusa modelli
./run.sh --help                # Mostra tutte le opzioni
```

**Su Windows (PowerShell/CMD):**

```cmd
run.cmd
run.cmd --no-gpu
run.cmd --port 8000
run.cmd --detach
run.cmd --rebuild
run.cmd --help
```

#### Metodo 2: Docker Run Diretto

Con le flag corrette per GPU e PyTorch:

```bash
docker run --gpus all -p 7860:7860 \
  --name qwen3-tts-demo \
  --ipc=host \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  --shm-size=2gb \
  qwen3-tts:latest
```

**Spiegazione delle flag:**
- `--gpus all`: Abilita tutte le GPU NVIDIA
- `--ipc=host`: Abilita IPC per comunicazione tra processi (richiesto da PyTorch)
- `--ulimit memlock=-1`: Memoria lockable illimitata
- `--ulimit stack=67108864`: Stack size 64MB
- `--shm-size=2gb`: Shared memory 2GB (PyTorch ne ha bisogno)

#### Metodo 3: Docker Compose

Il file `docker-compose.yml` già include tutte le configurazioni ottimali:

```bash
# Avvia con docker-compose
docker-compose up

# In background
docker-compose up -d

# Ferma
docker-compose down
```

### Pre-Scaricare Modelli nei Container

Per evitare download durante il primo avvio:

```bash
# Accedi al container in esecuzione
docker exec -it qwen3-tts-demo bash

# Dentro il container: scarica solo il tokenizer
python /app/download_models.py --tokenizer-only

# Oppure scarica un modello specifico
python /app/download_models.py --model Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice

# Oppure scarica tutto (richiede ~60GB)
python /app/download_models.py --all
```

I modelli saranno salvati in `/app/models` nel container, che puoi montare come volume per riusarli:

```bash
./run.sh --models-dir /path/to/models
```

---

## Modelli Disponibili

| Modello | Caratteristiche | Lingue | Streaming | Controllo Istruzioni |
|---------|-----------------|--------|-----------|----------------------|
| **Qwen3-TTS-12Hz-1.7B-VoiceDesign** | Crea voci da descrizioni | 10 lingue | ✅ | ✅ |
| **Qwen3-TTS-12Hz-1.7B-CustomVoice** | 9 voci premium predefinite | 10 lingue | ✅ | ✅ |
| **Qwen3-TTS-12Hz-1.7B-Base** | Voice clone, fine-tuning | 10 lingue | ✅ | ❌ |
| **Qwen3-TTS-12Hz-0.6B-CustomVoice** | Leggero, 9 voci premium | 10 lingue | ✅ | ❌ |
| **Qwen3-TTS-12Hz-0.6B-Base** | Leggero, voice clone | 10 lingue | ✅ | ❌ |
| **Qwen3-TTS-Tokenizer-12Hz** | Tokenizzatore audio (encoder/decoder) | - | - | - |

---

## Esempi di Utilizzo

### Generazione Voce Personalizzata

```python
from qwen_tts.inference import Qwen3TTSInference

model = Qwen3TTSInference(
    model_name="Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice"
)

# Scegli una delle 9 voci premium
audio = model.generate(
    text="Questo è un test di sintesi vocale",
    voice="default"  # Voce premium predefinita
)

audio.save("custom_voice.wav")
```

### Voice Design

```python
model = Qwen3TTSInference(
    model_name="Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign"
)

# Descrivi la voce che desideri
audio = model.generate(
    text="Ciao, come stai?",
    instruction="Una voce professionale, calda e rassicurante, di una donna dai 30-40 anni"
)

audio.save("designed_voice.wav")
```

### Voice Clone

```python
model = Qwen3TTSInference(
    model_name="Qwen/Qwen3-TTS-12Hz-1.7B-Base"
)

# Clona una voce da un file audio (almeno 3 secondi)
audio = model.generate(
    text="Testo da sintetizzare con la voce clonata",
    reference_audio_path="reference_voice.wav"
)

audio.save("cloned_voice.wav")
```

---

## Risoluzione dei Problemi

### Problema: "ModuleNotFoundError: Could not import module 'AutoProcessor'"

Questo errore indica un conflitto di dipendenze tra `torch` e `torchvision`.

**Soluzione:**

L'immagine Docker è stata aggiornata a `pytorch:24.12-py3` che ha migliore stabilità. Ricompila:

```bash
docker rmi qwen3-tts:latest  # Rimuovi la vecchia immagine
docker build -t qwen3-tts:latest .
./run.sh  # Esegui con lo script aggiornato
```

Se il problema persiste in locale (non Docker):

```bash
# Reinstalla le dipendenze giuste
pip install --upgrade \
    transformers==4.57.3 \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121
```

### Problema: "WARNING: The NVIDIA Driver was not detected"

Questo è un **solo warning**, non un errore. Significa che NVIDIA Docker non è configurato.

**Soluzione per abilitare GPU:**

1. **Installa NVIDIA Container Toolkit:**
   ```bash
   # Ubuntu/Debian
   curl https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   sudo apt-get update && sudo apt-get install -y nvidia-docker2
   sudo systemctl restart docker
   
   # Altre distro: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
   ```

2. **Su macOS con Docker Desktop:**
   - Settings → Resources → GPU: Toggle su ON

3. **Verifica l'installazione:**
   ```bash
   docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
   ```

### Problema: "CUDA out of memory"

**Soluzione:**
- Usa il modello 0.6B invece di 1.7B
- Riduci la lunghezza del testo di input
- Aumenta la shared memory: `./run.sh` usa già 2GB, se non bastano puoi usare `--shm-size=4gb`
- O esegui in CPU: `./run.sh --no-gpu`

### Problema: "Model files not found"

**Soluzione:**
- Scarica i modelli prima: `python download_models.py --tokenizer-only`
- O monta una directory con i modelli: `./run.sh --models-dir /path/to/models`
- Verifica che HF_HOME sia impostato correttamente: `echo $HF_HOME`

### Problema: L'interfaccia non è accessibile

**Soluzione:**
- Verifica che il container sia in esecuzione: `docker ps`
- Verifica i log: `docker logs qwen3-tts-demo`
- Assicurati che la porta 7860 non sia occupata: `lsof -i :7860` (su Linux/macOS)
- Su Docker Desktop per Mac/Windows, potrebbe essere necessario accedere tramite `http://127.0.0.1:7860` o `http://host.docker.internal:7860`
- Se usi `./run.sh --port 8000`, accedi a `http://localhost:8000`

### Problema: Audio di scarsa qualità

**Soluzione:**
- Assicurati che il testo di input sia privo di errori
- Usa istruzioni dettagliate per il voice design
- Utilizza un campione di voce pulito per il voice clone (almeno 3 secondi)
- Verifica che il modello sia stato scaricato completamente (file non corrotti)

### Problema: "docker: command not found"

**Soluzione:**
- Installa Docker Desktop: https://www.docker.com/products/docker-desktop
- Su Linux, installa Docker Engine: https://docs.docker.com/engine/install/

### Problema: Permessi denied su Linux

**Soluzione:**

Esegui come root o aggiungi l'utente al gruppo docker:

```bash
sudo usermod -aG docker $USER
newgrp docker  # Applica i cambiamenti senza logout
```

---

## Variabili d'Ambiente

Nel container, puoi personalizzare il comportamento con:

```bash
# Indirizzo del server Gradio
GRADIO_SERVER_NAME=0.0.0.0

# Porta del server Gradio
GRADIO_SERVER_PORT=7860

# Modalità debug
GRADIO_DEBUG=false

# Disabilita analytics
GRADIO_ANALYTICS_ENABLED=false
```

Esempio:
```bash
docker run --gpus all -p 7860:7860 \
  -e GRADIO_ANALYTICS_ENABLED=false \
  qwen3-tts:latest
```

---

## Risorse Aggiuntive

- 📄 **Paper**: [ArXiv 2601.15621](https://arxiv.org/abs/2601.15621)
- 🤗 **HuggingFace**: [Qwen3-TTS Collection](https://huggingface.co/collections/Qwen/qwen3-tts)
- 🤖 **ModelScope**: [Qwen3-TTS Models](https://modelscope.cn/collections/Qwen/Qwen3-TTS)
- 🌐 **Demo Online**: [HuggingFace Spaces](https://huggingface.co/spaces/Qwen/Qwen3-TTS) | [ModelScope Spaces](https://modelscope.cn/studios/Qwen/Qwen3-TTS)
- 💬 **Discord**: [Community](https://discord.gg/CV4E9rpNSD)
- 🧳 **API**: [Aliyun DashScope](https://help.aliyun.com/zh/model-studio/qwen-tts-realtime)

---

## Licenza

Apache License 2.0 - Vedi [LICENSE](LICENSE) per dettagli

---

**Versione**: 0.1.1  
**Ultimo Aggiornamento**: Marzo 2026

Per domande o segnalazioni di bug, apri una issue su [GitHub](https://github.com/Qwen/Qwen3-TTS/issues).
