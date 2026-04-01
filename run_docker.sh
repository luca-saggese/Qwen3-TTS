#!/bin/bash
# Script helper per lanciare il container Qwen3-TTS con GPU e configurazione ottimale

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funzioni helper
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Controlla se Docker è installato
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker non è installato o non è nel PATH"
        exit 1
    fi
    print_success "Docker trovato: $(docker --version)"
}

# Controlla se nvidia-docker o docker con GPU support è disponibile
check_gpu_support() {
    if ! command -v nvidia-docker &> /dev/null; then
        print_warning "nvidia-docker non trovato, utilizzerò 'docker run' con --gpus"
        USE_NVIDIA_DOCKER=false
    else
        print_success "nvidia-docker trovato"
        USE_NVIDIA_DOCKER=true
    fi
}

# Controlla se NVIDIA GPU è disponibile
check_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        print_success "NVIDIA GPU disponibile:"
        nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader | while read line; do
            echo -e "  ${BLUE}$line${NC}"
        done
        return 0
    else
        print_warning "nvidia-smi non trovato - GPU potrebbe non essere disponibile"
        return 1
    fi
}

# Build dell'immagine Docker
build_image() {
    print_header "Building Docker Image"
    
    if [ -f "Dockerfile" ]; then
        docker build -t qwen3-tts:latest .
        print_success "Immagine builddata con successo"
    else
        print_error "Dockerfile non trovato nella directory corrente"
        exit 1
    fi
}

# Run container con GPU
run_with_gpu() {
    print_header "Avviando Container con GPU Support"
    
    # Parametri per GPU support
    GPU_FLAGS="--gpus all"
    IPC_FLAGS="--ipc=host"
    ULIMIT_FLAGS="--ulimit memlock=-1 --ulimit stack=67108864"
    SHM_FLAGS="--shm-size=8gb"
    
    print_info "Usando flags di GPU e memory:"
    echo "  GPU Flags: $GPU_FLAGS"
    echo "  IPC Flags: $IPC_FLAGS"
    echo "  SHM Size: 8GB"
    
    docker run \
        $GPU_FLAGS \
        $IPC_FLAGS \
        $ULIMIT_FLAGS \
        $SHM_FLAGS \
        -p 7860:7860 \
        -v qwen3_models:/app/models \
        -e HF_HOME=/app/models \
        -e TRANSFORMERS_CACHE=/app/models \
        --name qwen3-tts-demo \
        --rm \
        qwen3-tts:latest
}

# Run container solo CPU
run_with_cpu() {
    print_header "Avviando Container (CPU mode)"
    
    print_warning "Modalità CPU: le prestazioni saranno significativamente più lente"
    
    docker run \
        -p 7860:7860 \
        -v qwen3_models:/app/models \
        -e HF_HOME=/app/models \
        -e TRANSFORMERS_CACHE=/app/models \
        --name qwen3-tts-demo \
        --rm \
        qwen3-tts:latest
}

# Run container con docker-compose
run_with_compose() {
    print_header "Avviando con docker-compose"
    
    if [ -f "docker-compose.yml" ]; then
        docker-compose up
    else
        print_error "docker-compose.yml non trovato"
        exit 1
    fi
}

# Main
main() {
    print_header "Qwen3-TTS Docker Helper"
    
    # Parse argomenti
    MODE=${1:-gpu}
    
    # Checks
    # check_docker
    
    case $MODE in
        gpu)
            check_gpu_support
            check_nvidia_gpu || print_warning "GPU not detected - container avverrà comunque, ma più lentamente"
            run_with_gpu
            ;;
        cpu)
            print_warning "CPU Mode - questo sarà MOLTO lento"
            run_with_cpu
            ;;
        compose)
            check_gpu_support
            run_with_compose
            ;;
        build)
            build_image
            ;;
        *)
            echo "Uso: $0 [gpu|cpu|compose|build]"
            echo ""
            echo "Opzioni:"
            echo "  gpu      - Avvia con GPU support (default)"
            echo "  cpu      - Avvia solo CPU (lento!)"
            echo "  compose  - Avvia con docker-compose"
            echo "  build    - Build l'immagine Docker"
            exit 1
            ;;
    esac
}

main "$@"
