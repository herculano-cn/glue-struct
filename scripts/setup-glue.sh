#!/bin/bash

# Script para configurar o ambiente AWS Glue local

# Verificar se está rodando como root ou glue_user
if [ "$(id -u)" = "0" ]; then
    SPARK_CONF_DIR_PATH="/etc/spark/conf"
else
    SPARK_CONF_DIR_PATH="/home/glue_user/.spark/conf"
    mkdir -p $SPARK_CONF_DIR_PATH
fi

# Configure environment variables for AWS Glue
cat > /home/glue_user/.bashrc << 'EOL'
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH

# Python environment
export PYTHONUSERBASE=/home/glue_user/.local
export PYTHONPATH=/home/glue_user/workspace:$PYTHONPATH

# Glue & Spark environment variables
export SPARK_HOME=/opt/spark
export SPARK_CONF_DIR=/etc/spark/conf
export SPARK_LOCAL_IP=127.0.0.1

# Java options for better compatibility
export SPARK_DRIVER_MEMORY=4g
export SPARK_EXECUTOR_MEMORY=4g

# AWS Glue specific
export GLUE_HOME=/opt/amazon/lib
export PATH=$PATH:$SPARK_HOME/bin:$GLUE_HOME
EOL

# Create working directories
mkdir -p /home/glue_user/workspace/jobs
mkdir -p /home/glue_user/workspace/shared/notebooks
mkdir -p /home/glue_user/workspace/data
mkdir -p /home/glue_user/.jupyter

# Configure spark-defaults.conf to allow Glue jobs
cat > $SPARK_CONF_DIR_PATH/spark-defaults.conf << EOF
spark.driver.extraClassPath=/opt/spark/jars/*:/opt/amazon/spark/jars/*
spark.executor.extraClassPath=/opt/spark/jars/*:/opt/amazon/spark/jars/*
spark.driver.extraJavaOptions=-Dlog4j.configuration=file:///etc/spark/conf/log4j.properties
spark.executor.extraJavaOptions=-Dlog4j.configuration=file:///etc/spark/conf/log4j.properties
spark.driver.cores=1
spark.driver.memory=4g
spark.executor.cores=1
spark.executor.memory=4g
spark.dynamicAllocation.enabled=false
spark.shuffle.service.enabled=false
spark.sql.warehouse.dir=/home/glue_user/spark-warehouse
spark.local.dir=/tmp/spark
spark.driver.host=localhost
EOF

# Configure Jupyter
cat > /home/glue_user/.jupyter/jupyter_notebook_config.py << 'EOF'
c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.allow_root = True
c.NotebookApp.token = ''
c.NotebookApp.password = ''
c.NotebookApp.notebook_dir = '/home/glue_user/workspace'
EOF

# Create a sample notebook for testing (mantém o mesmo)
cat > /home/glue_user/workspace/shared/notebooks/glue_test.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Teste de Ambiente AWS Glue Local\n",
    "\n",
    "Este notebook valida o ambiente AWS Glue local e suas conexões com MySQL e PostgreSQL."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import sys\n",
    "from pyspark.context import SparkContext\n",
    "from awsglue.context import GlueContext\n",
    "from awsglue.job import Job\n",
    "from awsglue.utils import getResolvedOptions\n",
    "\n",
    "# Inicializar Glue Context\n",
    "sc = SparkContext.getOrCreate()\n",
    "glueContext = GlueContext(sc)\n",
    "spark = glueContext.spark_session\n",
    "job = Job(glueContext)\n",
    "\n",
    "print(\"AWS Glue inicializado com sucesso!\")\n",
    "print(f\"Spark version: {spark.version}\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

# Create additional directories for WSL compatibility
mkdir -p /tmp/spark
mkdir -p /home/glue_user/spark-warehouse

# Adjust permissions
if [ "$(id -u)" = "0" ]; then
    chown -R glue_user:glue_user /home/glue_user
    chmod -R 755 /home/glue_user/workspace
    chmod -R 775 /tmp/spark
    chown -R glue_user:glue_user /tmp/spark
fi

echo "Configuration of AWS Glue local environment completed!"