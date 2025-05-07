#!/bin/bash

# Source the environment variables
source /home/glue_user/.bashrc

# Start Jupyter Notebook
exec jupyter notebook \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token='' \
    --NotebookApp.password='' \
    --notebook-dir=/home/glue_user/workspace 