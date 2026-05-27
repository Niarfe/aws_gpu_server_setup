SHELL := /bin/bash

default:
        @cat makefile

check1:
        . ~/llm_course/bin/activate && \
        python --version && \
        which python && \
        which jupyter

check2: # 2. Verify GPU + PyTorch
        . ~/llm_course/bin/activate && python -c "import torch; print(torch.__version__); \
                print('CUDA:', torch.cuda.is_available()); print('GPU:', torch.cuda.get_device_name(0))"


check3: # 3. Spot-check the key course packages:
        . ~/llm_course/bin/activate; \
                python -c "import transformers, trl, bitsandbytes, langchain, sentence_transformers; print('All good')"


VENV = $(HOME)/llm_course

up:
        source $(VENV)/bin/activate && jupyter lab --no-browser --port=8888

session:
        tmux new -s 5002
