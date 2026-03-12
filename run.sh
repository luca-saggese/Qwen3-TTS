#!/bin/bash
# Script per lanciare il container Qwen3-TTS con le migliori configurazioni GPU

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variabili di default
IMAGE_NAME="qwen3-tts:latest"
CONTAINER_NAME="qwen3-tts-demo"
PORT="7860"
GPU_FLAG="--gpus all"
MODE="interactive"
REBUILD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-gpu)
            GPU_FLAG=""
            shift
            ;;
        --image)
            IMAGE_NAME="$2"
            shift 2
            ;;
        --name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --detach)
            MODE="detach"
            shift
            ;;
        --rebuild)
            REBUILD=true
            shift
            ;;
        --models-dir)
            MODELS_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Uso: $0 [options]"
            echo ""
            echo "Opzioni:"
            echo "  --no-gpu              Disabilita GPU"
            echo "  --image TARGET        Immagine da usare (default: $IMAGE_NAME)"
            echo "  --name NOME           Nome del container (default: $CONTAINER_NAME)"
            echo "  --port PORTA          Porta Gradio (default: $PORT)"
            echo "  --detach              Esegui in background"
            echo "  --rebuild             Ricompila l'immagine"
            echo "  --models-dir DIR      Directory per i modelli (per riutilizzo)"
            echo "  --help                Mostra questo messaggio"
            exit 0
            ;;
        *)
            echo "Opzione sconosciuta: $1"
            exit 1
            ;;
    esac
done

# Funzione helper
show_banner() {
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           Qwen3-TTS Docker Container Launcher             ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_banner

# Step 1: Build se necessario
if [ "$REBUILD" = true ]; then
    echo -e "${YELLOW}📦 Ricompilando l'immagine...${NC}"
    docker build -t "$IMAGE_NAME" .
    echo -e "${GREEN}✅ Build completato${NC}\n"
fi

# Step 2: Check se container esiste e fermalo
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}⚠️  Container ${CONTAINER_NAME} già esiste, lo rimuovo...${NC}"
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# Step 3: Prepara le flag di esecuzione
RUN_FLAGS=(
    $GPU_FLAG
    "-p" "$PORT:7860"
    "--name" "$CONTAINER_NAME"
    "--ipc=host"
    "--ulimit" "memlock=-1"
    "--ulimit" "stack=67108864"
    "--shm-size=2gb"
)

# Aggiungi volume per modelli se specificato
if [ ! -z "$MODELS_DIR" ]; then
    RUN_FLAGS+=("-v" "$MODELS_DIR:/app/models")
    echo -e "${GREEN}📁 Montando modelli da: $MODELS_DIR${NC}"
fi

# Step 4: Mostra la configurazione
echo -e "${GREEN}🚀 Configurazione:${NC}"
echo "  Immagine:    $IMAGE_NAME"
echo "  Container:   $CONTAINER_NAME"
echo "  Porta:       http://localhost:$PORT"
echo "  GPU:         ${GPU_FLAG:-disabled}"
echo "  SHMEM:       2GB (consigliato per PyTorch)"
echo ""

# Step 5: Avvia il container
echo -e "${YELLOW}⏳ Avviando container...${NC}\n"

if [ "$MODE" = "detach" ]; then
    docker run "${RUN_FLAGS[@]}" -d "$IMAGE_NAME"
    echo -e "${GREEN}✅ Container avviato in background${NC}"
    echo ""
    echo -e "${GREEN}📝 Comandi utili:${NC}"
    echo "  Vedi i log:    ${YELLOW}docker logs -f $CONTAINER_NAME${NC}"
    echo "  Accedi bash:   ${YELLOW}docker exec -it $CONTAINER_NAME bash${NC}"
    echo "  Ferma:         ${YELLOW}docker stop $CONTAINER_NAME${NC}"
    echo "  Rimuovi:       ${YELLOW}docker rm $CONTAINER_NAME${NC}"
else
    # Interactive mode - mostra i log
    docker run "${RUN_FLAGS[@]}" "$IMAGE_NAME"
fi

# Step 6: Post-launch info
if [ "$MODE" != "detach" ]; then
    echo ""
    echo -e "${GREEN}🎉 Container avviato!${NC}"
fi

echo ""
echo -e "${GREEN}🌐 Accedi a: http://localhost:$PORT${NC}"
echo ""
