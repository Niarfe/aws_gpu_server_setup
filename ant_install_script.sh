#!/bin/bash
# =============================================================================
# EC2 LLM Environment Setup Script
# Course: How to Train your LLM (Masters in Data Science)
# Instance: g4dn.xlarge — AWS Deep Learning AMI (Ubuntu, PyTorch)
# Python: venv-based (required on Ubuntu 24 / Python 3.12)
# =============================================================================

set -e

echo "============================================="
echo " LLM Course Environment Setup"
echo "============================================="

# -----------------------------------------------------------------------------
# 1. SYSTEM UPDATE
# -----------------------------------------------------------------------------
echo ""
echo "[1/5] Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y git curl wget unzip htop nvtop python3-pip python3-full python3-venv

# -----------------------------------------------------------------------------
# 2. VERIFY GPU IS VISIBLE
# -----------------------------------------------------------------------------
echo ""
echo "[2/5] Checking GPU..."
nvidia-smi
if [ $? -ne 0 ]; then
    echo "ERROR: nvidia-smi failed. Make sure you're on a GPU instance and the"
    echo "       AWS Deep Learning AMI was selected."
    exit 1
fi

# -----------------------------------------------------------------------------
# 3. CREATE VIRTUAL ENVIRONMENT
# -----------------------------------------------------------------------------
echo ""
echo "[3/5] Creating virtual environment at ~/llm_course..."
python3 -m venv ~/llm_course
source ~/llm_course/bin/activate
echo "  Python : $(python --version)"
echo "  pip    : $(pip --version)"

# -----------------------------------------------------------------------------
# 4. INSTALL PYTORCH + COURSE PACKAGES
# -----------------------------------------------------------------------------
echo ""
echo "[4/5] Installing PyTorch (CUDA 12.1)..."
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Sanity check
python - <<'PYCHECK'
import torch
print(f"  PyTorch version : {torch.__version__}")
print(f"  CUDA available  : {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"  GPU             : {torch.cuda.get_device_name(0)}")
    print(f"  VRAM            : {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB")
PYCHECK

echo ""
echo "Installing course packages..."
pip install \
    transformers \
    huggingface_hub \
    numpy \
    pandas \
    datasets \
    trl \
    accelerate \
    bitsandbytes \
    langchain \
    sentence-transformers \
    faiss-cpu \
    openpyxl \
    pacmap \
    langchain-community \
    ragatouille \
    matplotlib \
    plotly \
    nbformat \
    notebook \
    ipykernel \
    ipywidgets \
    scipy

# -----------------------------------------------------------------------------
# 5. CONFIGURE JUPYTER
# -----------------------------------------------------------------------------
echo ""
echo "[5/5] Configuring Jupyter..."
jupyter notebook --generate-config -y

cat >> ~/.jupyter/jupyter_notebook_config.py << 'JCONF'

# Listen on all interfaces — connect via SSH tunnel only.
# Do NOT open port 8888 in your EC2 Security Group.
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.iopub_data_rate_limit = 1e10
JCONF

# -----------------------------------------------------------------------------
# WRITE MAKEFILE
# The venv must be activated each session, so we source it in the Makefile.
# -----------------------------------------------------------------------------
cat > ~/makefile << 'MKEOF'
VENV = $(HOME)/llm_course

up:
	source $(VENV)/bin/activate && jupyter notebook --no-browser --port=8888
MKEOF

echo ""
echo "============================================="
echo " Setup Complete!"
echo "============================================="
echo ""
echo "  Start Jupyter:         make up"
echo ""
echo "  SSH tunnel (laptop):   ssh -i your-key.pem -L 8888:localhost:8888 ubuntu@<EC2_PUBLIC_IP>"
echo "  Then open browser:     http://localhost:8888"
echo ""
echo "  To activate the venv manually:"
echo "    source ~/llm_course/bin/activate"
echo ""
