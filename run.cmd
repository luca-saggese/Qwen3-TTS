@echo off
REM Script per lanciare il container Qwen3-TTS su Windows

setlocal enabledelayedexpansion

REM Variabili di default
set IMAGE_NAME=qwen3-tts:latest
set CONTAINER_NAME=qwen3-tts-demo
set PORT=7860
set GPU_FLAG=--gpus all
set MODE=interactive
set REBUILD=false

REM Parse arguments
:parse_args
if "%1"=="" goto end_parse
if "%1"=="--no-gpu" (
    set GPU_FLAG=
    shift
    goto parse_args
)
if "%1"=="--image" (
    set IMAGE_NAME=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--name" (
    set CONTAINER_NAME=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--port" (
    set PORT=%2
    shift
    shift
    goto parse_args
)
if "%1"=="--detach" (
    set MODE=detach
    shift
    goto parse_args
)
if "%1"=="--rebuild" (
    set REBUILD=true
    shift
    goto parse_args
)
if "%1"=="--help" (
    echo.
    echo Uso: %0 [options]
    echo.
    echo Opzioni:
    echo   --no-gpu              Disabilita GPU
    echo   --image TARGET        Immagine da usare (default: %IMAGE_NAME%)
    echo   --name NOME           Nome del container (default: %CONTAINER_NAME%)
    echo   --port PORTA          Porta Gradio (default: %PORT%)
    echo   --detach              Esegui in background
    echo   --rebuild             Ricompila l'immagine
    echo   --help                Mostra questo messaggio
    echo.
    exit /b 0
)

:end_parse

REM Check se Docker è disponibile
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERRORE] Docker non trovato. Installa Docker Desktop.
    exit /b 1
)

REM Step 1: Build se necessario
if "%REBUILD%"=="true" (
    echo [INFO] Ricompilando l'immagine...
    docker build -t %IMAGE_NAME% .
    echo [OK] Build completato
    echo.
)

REM Step 2: Check se container esiste e fermalo
for /f "tokens=*" %%A in ('docker ps -a --format {{.Names}} 2^>nul ^| find "%CONTAINER_NAME%"') do (
    echo [INFO] Container %CONTAINER_NAME% già esiste, lo rimuovo...
    docker stop %CONTAINER_NAME% >nul 2>&1
    docker rm %CONTAINER_NAME% >nul 2>&1
)

REM Step 3: Mostra la configurazione
echo.
echo [CONFIG]
echo   Immagine:    %IMAGE_NAME%
echo   Container:   %CONTAINER_NAME%
echo   Porta:       http://localhost:%PORT%
if "%GPU_FLAG%"=="" (
    echo   GPU:         disabled
) else (
    echo   GPU:         enabled
)
echo   SHMEM:       2GB (consigliato per PyTorch)
echo.

REM Step 4: Avvia il container
echo [INFO] Avviando container...
echo.

if "%MODE%"=="detach" (
    docker run %GPU_FLAG% -p %PORT%:7860 --name %CONTAINER_NAME% --ipc=host --shm-size=2gb -d %IMAGE_NAME%
    echo [OK] Container avviato in background
    echo.
    echo [INFO] Comandi utili:
    echo   Vedi i log:    docker logs -f %CONTAINER_NAME%
    echo   Accedi bash:   docker exec -it %CONTAINER_NAME% bash
    echo   Ferma:         docker stop %CONTAINER_NAME%
    echo   Rimuovi:       docker rm %CONTAINER_NAME%
) else (
    docker run %GPU_FLAG% -p %PORT%:7860 --name %CONTAINER_NAME% --ipc=host --shm-size=2gb %IMAGE_NAME%
)

echo.
echo [OK] Accedi a: http://localhost:%PORT%
echo.

endlocal
