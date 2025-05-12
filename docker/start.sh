#!/bin/bash

# Detectar se está no WSL
if grep -qi microsoft /proc/version; then
    echo "Running in WSL environment"
    export WSL_ENV=1
fi

# Source the environment variables
if [ -f /home/glue_user/.bashrc ]; then
    source /home/glue_user/.bashrc
fi

# Configurar variáveis adicionais
export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=python3

# Criar diretórios necessários
mkdir -p /home/glue_user/workspace
mkdir -p /tmp/spark
mkdir -p /home/glue_user/spark-warehouse

# Verificar se o Jupyter está instalado
if ! command -v jupyter &> /dev/null; then
    echo "Jupyter not found, installing..."
    pip3 install --user jupyter notebook
fi

# Start Jupyter Notebook
exec jupyter notebook \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password='' \
    --notebook-dir=/home/glue_user/workspace