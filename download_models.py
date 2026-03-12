#!/usr/bin/env python3
# coding=utf-8
"""
Script per pre-scaricare i modelli Qwen3-TTS in HF_HOME.
Utilizzato durante il build Docker o manualmente prima di eseguire il container.

Uso:
  python download_models.py                          # Scarica i modelli default
  python download_models.py --tokenizer-only         # Solo tokenizer
  python download_models.py --model Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice
"""

import os
import sys
import argparse
from pathlib import Path

try:
    from transformers import AutoModel, AutoProcessor
except ImportError:
    print("Error: transformers not installed. Run: pip install transformers")
    sys.exit(1)


def download_model(model_id: str, cache_dir: str = None) -> bool:
    """
    Scarica un modello da HuggingFace.
    
    Args:
        model_id: ID del modello su HuggingFace (es: Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice)
        cache_dir: Directory di cache (default: HF_HOME)
    
    Returns:
        True se il download è riuscito, False altrimenti
    """
    print(f"\n📥 Scaricando: {model_id}")
    print(f"   Cache dir: {cache_dir or os.environ.get('HF_HOME', '~/.cache/huggingface')}")
    
    try:
        # Scarica il modello
        print(f"   → Modello...")
        AutoModel.from_pretrained(model_id, cache_dir=cache_dir, trust_remote_code=True)
        
        # Scarica il processor
        print(f"   → Processor...")
        AutoProcessor.from_pretrained(model_id, cache_dir=cache_dir, trust_remote_code=True)
        
        print(f"✅ Completato: {model_id}")
        return True
    except Exception as e:
        print(f"❌ Errore scaricando {model_id}: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Pre-scarica i modelli Qwen3-TTS in HF_HOME",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    
    parser.add_argument(
        "--model",
        type=str,
        default=None,
        help="Scarica un modello specifico (es: Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice)",
    )
    parser.add_argument(
        "--tokenizer-only",
        action="store_true",
        help="Scarica solo il tokenizer",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Scarica tutti i modelli (tokenizer + tutti i modelli disponibili)",
    )
    parser.add_argument(
        "--cache-dir",
        type=str,
        default=None,
        help="Directory di cache personalizzata (default: HF_HOME)",
    )
    
    args = parser.parse_args()
    
    # Se non è specificato cache_dir, usa HF_HOME o il default di HuggingFace
    cache_dir = args.cache_dir or os.environ.get("HF_HOME")
    
    if cache_dir:
        print(f"🎯 Usando HF_HOME: {cache_dir}")
        os.environ["HF_HOME"] = cache_dir
    else:
        print(f"🎯 Usando HF_HOME default: {os.environ.get('HF_HOME', '~/.cache/huggingface')}")
    
    # Modelli disponibili
    tokenizer = "Qwen/Qwen3-TTS-Tokenizer-12Hz"
    models = [
        "Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign",
        "Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice",
        "Qwen/Qwen3-TTS-12Hz-1.7B-Base",
        "Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice",
        "Qwen/Qwen3-TTS-12Hz-0.6B-Base",
    ]
    
    downloaded = 0
    failed = 0
    
    # Scarica con base su argomenti
    if args.model:
        # Modello specifico
        if download_model(args.model, cache_dir):
            downloaded += 1
        else:
            failed += 1
    
    elif args.tokenizer_only:
        # Solo tokenizer
        if download_model(tokenizer, cache_dir):
            downloaded += 1
        else:
            failed += 1
    
    elif args.all:
        # Tutti i modelli
        print("\n🚀 Download di TUTTI i modelli (questa operazione può durare parecchio)...")
        
        # Tokenizer first
        if download_model(tokenizer, cache_dir):
            downloaded += 1
        else:
            failed += 1
        
        # Poi i modelli
        for model in models:
            if download_model(model, cache_dir):
                downloaded += 1
            else:
                failed += 1
    
    else:
        # Default: tokenizer + modello 0.6B (più leggero)
        print("\n🚀 Download di modelli default (tokenizer + 0.6B)...")
        
        if download_model(tokenizer, cache_dir):
            downloaded += 1
        else:
            failed += 1
        
        if download_model("Qwen/Qwen3-TTS-12Hz-0.6B-CustomVoice", cache_dir):
            downloaded += 1
        else:
            failed += 1
    
    # Riepilogo
    print("\n" + "=" * 60)
    print(f"📊 Riepilogo: {downloaded} scaricati, {failed} errori")
    print("=" * 60)
    
    if failed > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
