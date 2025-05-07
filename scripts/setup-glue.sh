#!/bin/bash

# Script para configurar o ambiente AWS Glue local

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

# Glue specific environment variables
export PYTHONPATH=/home/glue_user/workspace:$PYTHONPATH
export SPARK_CONF_DIR=/etc/spark/conf
EOL

# Create working directories
mkdir -p /home/glue_user/workspace/jobs
mkdir -p /home/glue_user/workspace/shared/notebooks
mkdir -p /home/glue_user/workspace/data

# Configure spark-defaults.conf to allow Glue jobs
cat > /etc/spark/conf/spark-defaults.conf << EOF
spark.driver.extraClassPath=/opt/spark/jars/*
spark.executor.extraClassPath=/opt/spark/jars/*
spark.driver.extraJavaOptions=-Dlog4j.configuration=file:///etc/spark/conf/log4j.properties
spark.executor.extraJavaOptions=-Dlog4j.configuration=file:///etc/spark/conf/log4j.properties
spark.driver.cores=1
spark.driver.memory=4g
spark.executor.cores=1
spark.executor.memory=4g
spark.dynamicAllocation.enabled=false
spark.shuffle.service.enabled=false
EOF

# Create a sample notebook for testing
cat > /home/glue_user/workspace/shared/notebooks/glue_test.ipynb << EOF
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
   "source": [
    "import sys\n",
    "from pyspark.context import SparkContext\n",
    "from awsglue.context import GlueContext\n",
    "from awsglue.job import Job\n",
    "from awsglue.utils import getResolvedOptions\n",
    "\n",
    "# Inicializar Glue Context\n",
    "sc = SparkContext()\n",
    "glueContext = GlueContext(sc)\n",
    "spark = glueContext.spark_session\n",
    "job = Job(glueContext)\n",
    "\n",
    "print(\"AWS Glue inicializado com sucesso!\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Testar conexão com MySQL\n",
    "mysql_url = \"jdbc:mysql://mysql:3306/ai_cockpit\"\n",
    "mysql_properties = {\n",
    "    \"user\": \"root\",\n",
    "    \"password\": \"rootpassword\",\n",
    "    \"driver\": \"com.mysql.cj.jdbc.Driver\"\n",
    "}\n",
    "\n",
    "try:\n",
    "    df_mysql = spark.read.jdbc(url=mysql_url, table=\"users\", properties=mysql_properties)\n",
    "    print(\"Conexão com MySQL bem-sucedida!\")\n",
    "    print(f\"Total de registros na tabela users: {df_mysql.count()}\")\n",
    "    df_mysql.show(5)\n",
    "except Exception as e:\n",
    "    print(f\"Erro ao conectar ao MySQL: {str(e)}\")\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Testar conexão com PostgreSQL\n",
    "postgres_url = \"jdbc:postgresql://postgres:5432/langfuse\"\n",
    "postgres_properties = {\n",
    "    \"user\": \"postgres\",\n",
    "    \"password\": \"postgres\",\n",
    "    \"driver\": \"org.postgresql.Driver\"\n",
    "}\n",
    "\n",
    "try:\n",
    "    df_postgres = spark.read.jdbc(url=postgres_url, table=\"traces\", properties=postgres_properties)\n",
    "    print(\"Conexão com PostgreSQL bem-sucedida!\")\n",
    "    print(f\"Total de registros na tabela traces: {df_postgres.count()}\")\n",
    "    df_postgres.show(5)\n",
    "except Exception as e:\n",
    "    print(f\"Erro ao conectar ao PostgreSQL: {str(e)}\")\n"
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

# Adjust permissions
chown -R glue_user:glue_user /home/glue_user/workspace

echo "Configuration of AWS Glue local environment completed!" 