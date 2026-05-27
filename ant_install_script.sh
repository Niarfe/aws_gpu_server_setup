#!/bin/bash
# =============================================================================
# EC2 LLM Environment Setup Script
# Course: How to Train your LLM (Masters in Data Science)
# Instance: g4dn.xlarge (or similar) — AWS Deep Learning AMI (Ubuntu, PyTorch)
# Source: Claude.ai, chat is in project 6015
# =============================================================================

set -e  # Exit immediately on any error

echo "============================================="
echo " LLM Course Environment Setup"
echo "============================================="

# -----------------------------------------------------------------------------
# 1. SYSTEM UPDATE
# -----------------------------------------------------------------------------
echo ""
echo "[1/6] Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y git curl wget unzip htop nvtop

# -----------------------------------------------------------------------------
# 2. VERIFY GPU IS VISIBLE
# -----------------------------------------------------------------------------
echo ""
echo "[2/6] Checking GPU..."
nvidia-smi
if [ $? -ne 0 ]; then
    echo "WARNING: nvidia-smi failed. Make sure you're on a GPU instance and the"
    echo "         AWS Deep Learning AMI was selected."
    exit 1
fi

# -----------------------------------------------------------------------------
# 3. SET UP CONDA ENVIRONMENT
#    The Deep Learning AMI ships with conda. We create an isolated env so
#    nothing conflicts with the base system packages.
# -----------------------------------------------------------------------------
echo ""
echo "[3/6] Creating conda environment 'llm_course' (Python 3.11)..."

# Initialise conda for this shell session if not already done
source /opt/conda/etc/profile.d/conda.sh 2>/dev/null || \
    source ~/anaconda3/etc/profile.d/conda.sh 2>/dev/null || \
    source ~/miniconda3/etc/profile.d/conda.sh 2>/dev/null

conda create -n llm_course python=3.11 -y
conda activate llm_course

echo "Conda environment 'llm_course' created and activated."

# -----------------------------------------------------------------------------
# 4. INSTALL PYTORCH (CUDA 12.1)
#    The Deep Learning AMI already has CUDA drivers; we install the matching
#    PyTorch wheel directly so the conda env has its own copy.
# -----------------------------------------------------------------------------
echo ""
echo "[4/6] Installing PyTorch with CUDA support..."
pip install --upgrade pip

pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Quick sanity check
python - <<'EOF'
import torch
print(f"  PyTorch version : {torch.__version__}")
print(f"  CUDA available  : {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"  GPU             : {torch.cuda.get_device_name(0)}")
    print(f"  VRAM            : {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB")
EOF

# -----------------------------------------------------------------------------
# 5. INSTALL COURSE REQUIREMENTS
# -----------------------------------------------------------------------------
echo ""
echo "[5/6] Installing course packages from requirements.txt..."

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
    "faiss-cpu" \
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

# Register the conda env as a Jupyter kernel so notebooks see it
python -m ipykernel install --user --name llm_course --display-name "Python (llm_course)"

echo "All packages installed."

# -----------------------------------------------------------------------------
# 6. CONFIGURE JUPYTER
#    Generates a config, sets a password hash, and configures it to listen on
#    all interfaces so you can reach it from your laptop via SSH tunnel.
# -----------------------------------------------------------------------------
echo ""
echo "[6/6] Configuring Jupyter Notebook..."

jupyter notebook --generate-config -y

# Jupyter config tweaks
cat >> ~/.jupyter/jupyter_notebook_config.py << 'JCONF'

# Allow connections from any IP (we'll secure via SSH tunnel — do NOT open
# port 8888 in your EC2 Security Group; use SSH forwarding instead)
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False

# Increase iopub data rate for plotly/widgets
c.NotebookApp.iopub_data_rate_limit = 1e10
JCONF

echo ""
echo "============================================="
echo " Setup Complete!"
echo "============================================="
echo ""
echo "  To activate your environment in future sessions:"
echo ""
echo "    source /opt/conda/etc/profile.d/conda.sh"
echo "    conda activate llm_course"
echo ""
echo "  To start Jupyter (run on the EC2 instance):"
echo ""
echo "    conda activate llm_course"
echo "    jupyter notebook --no-browser --port=8888"
echo ""
echo "  To connect from your laptop (SSH tunnel):"
echo ""
echo "    ssh -i your-key.pem -L 8888:localhost:8888 ubuntu@<YOUR_EC2_PUBLIC_IP>"
echo ""
echo "  Then open in your browser: http://localhost:8888"
echo ""
echo "  HuggingFace models cache to: ~/.cache/huggingface/"
echo "  To point cache to a bigger volume (if you add one later):"
echo "    export HF_HOME=/data/huggingface_cache"
echo ""
