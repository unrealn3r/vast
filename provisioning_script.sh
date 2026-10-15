#!/bin/bash
# Vast.ai provisioning script for Qwen 2511 + Wan 2.2 NSFW stack
echo "=== Starting provisioning ==="

echo "=== Installing custom nodes ==="
cd /workspace/ComfyUI/custom_nodes || exit 1

# Fill-Nodes
if [ ! -d "ComfyUI_Fill-Nodes" ]; then
  git clone --depth 1 https://github.com/filliptm/ComfyUI_Fill-Nodes
fi
pip install -q -r ComfyUI_Fill-Nodes/requirements.txt || true

# ComfyUI Manager
if [ ! -d "ComfyUI-Manager" ]; then
  git clone --depth 1 https://github.com/Comfy-Org/ComfyUI-Manager
fi
pip install -q -r ComfyUI-Manager/requirements.txt || true

# ComfyUI-GGUF
if [ ! -d "ComfyUI-GGUF" ]; then
  git clone --depth 1 https://github.com/city96/ComfyUI-GGUF
fi
pip install -q -r ComfyUI-GGUF/requirements.txt || true

# rgthree-comfy
if [ ! -d "rgthree-comfy" ]; then
  git clone --depth 1 https://github.com/rgthree/rgthree-comfy
fi

# Mobile Frontend
if [ ! -d "comfyui-mobile-frontend" ]; then
  git clone --depth 1 https://github.com/cosmicbuffalo/comfyui-mobile-frontend
fi

echo "=== Downloading models and LoRAs ==="
BASE="/workspace/ComfyUI/models"
mkdir -p "$BASE/diffusion_models" "$BASE/text_encoders" "$BASE/vae" "$BASE/loras"

#FLUX models

#!/bin/bash
set -e
echo "=== Installing PuLID custom node ==="
cd /workspace/ComfyUI/custom_nodes
if [ ! -d "ComfyUI_PuLID_Flux_ll" ]; then
  git clone --depth 1 https://github.com/lldacing/ComfyUI_PuLID_Flux_ll.git
fi
cd ComfyUI_PuLID_Flux_ll
pip install -q -r requirements.txt || true
pip install -q insightface onnxruntime-gpu facenet-pytorch --no-deps || true

echo "=== Downloading models ==="
BASE="/workspace/ComfyUI/models"
mkdir -p "$BASE/unet" "$BASE/clip" "$BASE/vae" "$BASE/loras" "$BASE/pulid" "$BASE/insightface/models/antelopev2"

# Flux base (full)
wget -c -O "$BASE/unet/flux1-dev.safetensors" \
  "https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev.safetensors" || true

wget -c -O "$BASE/clip/clip_l.safetensors" \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" || true

wget -c -O "$BASE/clip/t5xxl_fp16.safetensors" \
  "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" || true

wget -c -O "$BASE/vae/ae.safetensors" \
  "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors" || true

# PuLID model
wget -c -O "$BASE/pulid/pulid_flux_v0.9.1.safetensors" \
  "https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors" || true

# NSFW unlock LoRA
wget -c -O "$BASE/loras/aidmaNSFWunlock-FLUX-V0.2.safetensors" \
  "https://huggingface.co/shahtab/FLUXNSFWunlock/resolve/main/aidmaNSFWunlock-FLUX-V0.2.safetensors" || true

echo "=== Done ==="
echo "Restart ComfyUI after this finishes."
echo "Place additional anatomy LoRAs into $BASE/loras/ manually."

hf buckets cp hf://buckets/unrealn3r/vast_loras/scg-anatomy-female-v2.safetensors /workspace/ComfyUI/models/loras/ || true
hf buckets cp hf://buckets/unrealn3r/vast_loras/MS_Nude_Style_Flux_V2.safetensors /workspace/ComfyUI/models/loras/ || true
hf buckets cp hf://buckets/unrealn3r/vast_loras/ae.safetensors /workspace/ComfyUI/models/vae/ae.safetensors || true

mkdir -p /workspace/ComfyUI/models/insightface/models/antelopev2
cd /tmp

wget -c -O antelopev2.zip \
  "https://github.com/deepinsight/insightface/releases/download/v0.7/antelopev2.zip"

unzip -o antelopev2.zip -d /workspace/ComfyUI/models/insightface/models/

ls -lh /workspace/ComfyUI/models/insightface/models/antelopev2/

# Qwen models
#wget -c -O "$BASE/diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors" \
#  "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors" || true

#wget -c -O "$BASE/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" \
#  "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" || true

#wget -c -O "$BASE/vae/qwen_image_vae.safetensors" \
#  "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors" || true

# Public LoRAs
#wget -c -O "$BASE/loras/Qwen-Image-Edit-2511-Lightning-8steps-V1.0-bf16.safetensors" \
#  "https://huggingface.co/lightx2v/Qwen-Image-Edit-2511-Lightning/resolve/main/Qwen-Image-Edit-2511-Lightning-8steps-V1.0-bf16.safetensors" || true

#wget -c -O "$BASE/loras/Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors" \
#  "https://huggingface.co/lightx2v/Qwen-Image-Edit-2511-Lightning/resolve/main/Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors" || true

#wget -c -O "$BASE/loras/Qwen_Snofs_1_3.safetensors" \
#  "https://huggingface.co/rkppvc/qwen_snofs_v13/resolve/main/Qwen_Snofs_1_3.safetensors" || true

#wget -c -O "$BASE/loras/qwen-edit-skin_1.1_000002750.safetensors" \
#  "https://huggingface.co/tlennon-ie/qwen-edit-skin/resolve/main/qwen-edit-skin_1.1_000002750.safetensors" || true

#wget -c -O "$BASE/loras/Qwen-Smartphone.safetensors" \
#  "https://huggingface.co/ribilu74/qwensnapshot/resolve/main/Qwen-Smartphone.safetensors" || true

# Wan 2.2 (commented out)
#wget -c -O "$BASE/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" \
#  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" || true
#wget -c -O "$BASE/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" \
#  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" || true
#wget -c -O "$BASE/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
#  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" || true
#wget -c -O "$BASE/vae/wan_2.1_vae.safetensors" \
#  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" || true

echo "=== Downloading ship2hf.sh ==="
wget -c -O /workspace/ship2hf.sh \
  "https://raw.githubusercontent.com/unrealn3r/vast/refs/heads/main/ship2hf.sh" || true
chmod +x /workspace/ship2hf.sh
echo "Saved to /workspace/ship2hf.sh"

echo "=== Downloading workflows from private Hugging Face bucket ==="
WORKFLOW_DIR="/workspace/ComfyUI/user/default/workflows"
mkdir -p "$WORKFLOW_DIR"
if [ -n "$HF_TOKEN" ]; then
  hf buckets sync hf://buckets/unrealn3r/workflows "$WORKFLOW_DIR" || true
  echo "Workflows synced to $WORKFLOW_DIR"
  ls -la "$WORKFLOW_DIR"
else
  echo "Warning: HF_TOKEN not set, skipping private workflow download"
fi

echo "=== Downloading LoRAs from private Hugging Face bucket ==="
LORA_DIR="/workspace/ComfyUI/models/loras"
mkdir -p "$LORA_DIR"
if [ -n "$HF_TOKEN" ]; then
  hf buckets sync hf://buckets/unrealn3r/vast_loras "$LORA_DIR" || true
  echo "LoRAs synced to $LORA_DIR"
  ls -la "$LORA_DIR"
else
  echo "Warning: HF_TOKEN not set, skipping private LoRA download"
fi

echo "=== Provisioning complete ==="
