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

# Qwen models
wget -c -O "$BASE/diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors" \
  "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors" || true

wget -c -O "$BASE/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" \
  "https://huggingface.co/Comfy-Org/HunyuanVideo_1.5_repackaged/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" || true

wget -c -O "$BASE/vae/qwen_image_vae.safetensors" \
  "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors" || true

# LoRAs
wget -c -O "$BASE/loras/Qwen-Image-Edit-2511-Lightning-8steps-V1.0-bf16.safetensors" \
  "https://huggingface.co/lightx2v/Qwen-Image-Edit-2511-Lightning/resolve/main/Qwen-Image-Edit-2511-Lightning-8steps-V1.0-bf16.safetensors" || true

wget -c -O "$BASE/loras/Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors" \
  "https://huggingface.co/lightx2v/Qwen-Image-Edit-2511-Lightning/resolve/main/Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors" || true

wget -c -O "$BASE/loras/Qwen_Snofs_1_3.safetensors" \
  "https://huggingface.co/rkppvc/qwen_snofs_v13/resolve/main/Qwen_Snofs_1_3.safetensors" || true

wget -c -O "$BASE/loras/qwen_2512_pussy_anus_v2.safetensors" \
  "https://huggingface.co/Sentinel7/qwen-image/resolve/main/2289084/2576020/qwen_2512_pussy_anus_v2.safetensors" || true

wget -c -O "$BASE/loras/qwen-edit-skin_1.1_000002750.safetensors" \
  "https://huggingface.co/tlennon-ie/qwen-edit-skin/resolve/main/qwen-edit-skin_1.1_000002750.safetensors" || true

wget -c -O "$BASE/loras/qwen_image_smartphone_snapshot_photo_reality_v4.safetensors" \
  "https://huggingface.co/ribilu74/qwensnapshot/resolve/main/qwen_image_smartphone_snapshot_photo_reality_v4.safetensors" || true

rm -f "$BASE/loras/AmateurSelfie_v2.safetensors" || true

# Wan 2.2
wget -c -O "$BASE/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" || true

wget -c -O "$BASE/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" || true

wget -c -O "$BASE/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" || true

wget -c -O "$BASE/vae/wan_2.1_vae.safetensors" \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" || true

# Download the whole workflows folder from GitHub
echo "=== Downloading workflows folder ==="
WORKFLOW_DIR="/workspace/ComfyUI/user/default/workflows"
mkdir -p "$WORKFLOW_DIR"

# Sparse checkout so we only get the workflows folder
cd /tmp
rm -rf vast-workflows
git clone --depth 1 --filter=blob:none --sparse https://github.com/unrealn3r/vast.git vast-workflows
cd vast-workflows
git sparse-checkout set workflows
cp -r workflows/* "$WORKFLOW_DIR/" || true

echo "Workflows copied to $WORKFLOW_DIR"
ls -la "$WORKFLOW_DIR"

echo "=== Provisioning complete ==="
