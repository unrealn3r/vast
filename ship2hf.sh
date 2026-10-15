#!/bin/bash
# Zip ComfyUI output and upload to private Hugging Face repo

set -e

# === CONFIG ===
OUTPUT_DIR="/workspace/ComfyUI/output"
ZIP_NAME="comfyui_output_$(date +%Y%m%d_%H%M%S).zip"
HF_REPO="unrealn3r/output"   # <-- change this
HF_TOKEN="${HF_TOKEN:-}"                # set HF_TOKEN env var, or paste token below
# HF_TOKEN="hf_xxxxxxxxxxxxxxxxxxxxxxxx"

# === CHECKS ===
if [ -z "$HF_TOKEN" ]; then
  echo "Error: HF_TOKEN is not set. Export it or edit the script."
  exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Error: Output directory not found: $OUTPUT_DIR"
  exit 1
fi

# === ZIP ===
echo "=== Zipping $OUTPUT_DIR ==="
cd /tmp
zip -r "$ZIP_NAME" "$OUTPUT_DIR" -x "$OUTPUT_DIR/$ZIP_NAME"

echo "Created: /tmp/$ZIP_NAME"
ls -lh "/tmp/$ZIP_NAME"

# === UPLOAD TO HUGGING FACE ===
echo "=== Uploading to $HF_REPO ==="

# Install huggingface_hub if needed
pip install -q huggingface_hub || true

# Upload
huggingface-cli upload "$HF_REPO" "/tmp/$ZIP_NAME" "$ZIP_NAME" \
  --token "$HF_TOKEN" \
  --repo-type model

echo "=== Upload complete ==="
echo "File available at: https://huggingface.co/$HF_REPO/blob/main/$ZIP_NAME"

# Optional cleanup
# rm -f "/tmp/$ZIP_NAME"
