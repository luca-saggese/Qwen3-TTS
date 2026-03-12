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

### Costruire l'Immagine

```bash
# Dalla directory radice del progetto
docker build -t qwen3-tts:latest .

# O con tag specifico
docker build -t qwen3-tts:25.10 .
```

### Eseguire il Container

#### 1. **Con Accesso GPU (Consigliato)**

```bash
docker run --gpus all -p 7860:7860 \
  --name qwen3-tts-demo \
  qwen3-tts:latest
```

#### 2. **Solo CPU**

```bash
docker run -p 7860:7860 \
  --name qwen3-tts-demo \
  qwen3-tts:latest
```

#### 3. **Con Volume Persistente per i Modelli**

```bash
docker run --gpus all -p 7860:7860 \
  -v /path/to/models:/app/models \
  --name qwen3-tts-demo \
  qwen3-tts:latest
```

#### 4. **Con File di Input/Output**

```bash
docker run --gpus all -p 7860:7860 \
  -v /path/to/input:/app/input \
  -v /path/to/output:/app/output \
  --name qwen3-tts-demo \
  qwen3-tts:latest
```

### Accesso all'Interfaccia

Una volta il container è in esecuzione, accedi all'interfaccia web:

```
http://localhost:7860
```

### Comandi Utili per Docker

```bash
# Visualizza i log
docker logs qwen3-tts-demo

# Accedi al container interattivamente
docker exec -it qwen3-tts-demo bash

# Ferma il container
docker stop qwen3-tts-demo

# Rimuovi il container
docker rm qwen3-tts-demo

# Rimuovi l'immagine
docker rmi qwen3-tts:latest
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

### Problema: "CUDA out of memory"

**Soluzione:**
- Usa il modello 0.6B invece di 1.7B
- Riduci la lunghezza del testo di input
- Aumenta la RAM della GPU nel container: `docker run --gpus all --memory 32g`

### Problema: "Model files not found"

**Soluzione:**
- Scarica i modelli prima: vedi sezione "Download dei Modelli"
- O monta una directory con i modelli: `-v /path/to/models:/app/models`

### Problema: L'interfaccia non è accessibile

**Soluzione:**
- Verifica che il container sia in esecuzione: `docker ps`
- Verifica i log: `docker logs qwen3-tts-demo`
- Assicurati che la porta 7860 non sia occupata: `lsof -i :7860`
- Su Docker Desktop per Mac/Windows, potrebbe essere necessario accedere tramite `http://host.docker.internal:7860` o l'IP Docker

### Problema: Audio di scarsa qualità

**Soluzione:**
- Assicurati che il testo di input sia privo di errori
- Usa istruzioni dettagliate per il voice design
- Utilizza un campione di voce pulito per il voice clone (almeno 3 secondi)

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
