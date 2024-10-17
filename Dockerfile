FROM rocm62_pt24:latest
SHELL ["/bin/bash", "-c"]  
ENV PORT=8188 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    radePYTHONIOENCODING=UTF-8 \
    REQS_FILE='requirements.txt' \
    COMMANDLINE_ARGS='' \
    ### For your AMD GPU
    PYTORCH_ROCM_ARCH=gfx803 

WORKDIR /

RUN apt --fix-broken install -y &&\
    true
 
RUN apt-get install -y --no-install-recommends virtualenv &&\
    pip install cmake mkl mkl-include && \
    pip install --upgrade pip wheel && \
    true

RUN git clone https://github.com/ROCm/pyrsmi /pyrsmi && \
    true

WORKDIR /pyrsmi

RUN python -m pip install -e . && \
    true

WORKDIR /    

RUN pip install cmake mkl mkl-include && \
    pip install --upgrade pip wheel && \
    true

# #### ComfyUI
RUN apt autoclean -y && \
    apt install  -y --no-install-recommends ffmpeg virtualenv google-perftools ccache tmux mc pigz plocate && \&& \
    git clone https://github.com/comfyanonymous/ComfyUI.git /ComfyUI && \
    true

WORKDIR /ComfyUI

RUN touch comfi.sh && \
    chmod +x comfi.sh && \
    true

RUN python -m venv venv && \
    ./venv/bin/python -m pip install --upgrade pip && \
    ./venv/bin/pip install psutil && \
    ./venv/bin/pip install -r requirements.txt && \
    ./venv/bin/pip uninstall -y torch torchvision && \    
    ./venv/bin/pip install /pytorch/dist/torch*-cp310-cp310-linux_x86_64.whl && \
    ./venv/bin/pip install /vision/dist/torchvision-*-cp310-cp310-linux_x86_64.whl && \
    ./venv/bin/python -m pip install -e /pyrsmi/. && \
    ./venv/bin/python -m pip uninstall numpy -y && \
    ./venv/bin/pip install numpy==1.26.4 && \
    true    

WORKDIR /ComfyUI/custom_nodes

RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git &&\
    true

WORKDIR /ComfyUI    

RUN pip install psutil && \
    true    

RUN ./venv/bin/pip install -e /pyrsmi && \
    true
    

ENV args="" 

EXPOSE ${PORT}
EXPOSE 22/tcp

VOLUME [ "/ComfyUI", "/ComfyUI/custom_nodes","/ComfyUI/models","/ComfyUI/output","/ComfyUI/input"]
#ENTRYPOINT ./venv/bin/python main.py --listen --port "${PORT}" ${COMMANDLINE_ARGS}
CMD ["/bin/bash","-c"]
