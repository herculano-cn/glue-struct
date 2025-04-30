import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp, lit, concat, sha2

# Inicializar GlueContext
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# Definir parâmetros (em produção, viriam dos args)
mysql_host = "mysql"
mysql_port = "3306"
mysql_database = "ai_cockpit"
mysql_user = "root"
mysql_password = "rootpassword"

postgres_host = "postgres"
postgres_port = "5432"
postgres_database = "langfuse"
postgres_user = "postgres"
postgres_password = "postgres"

# URL de conexão JDBC
mysql_url = f"jdbc:mysql://{mysql_host}:{mysql_port}/{mysql_database}"
postgres_url = f"jdbc:postgresql://{postgres_host}:{postgres_port}/{postgres_database}"

# Propriedades de conexão
mysql_properties = {
    "user": mysql_user,
    "password": mysql_password,
    "driver": "com.mysql.cj.jdbc.Driver"
}

postgres_properties = {
    "user": postgres_user,
    "password": postgres_password,
    "driver": "org.postgresql.Driver"
}

# Log de início do job
print("Iniciando ETL de MySQL para PostgreSQL")

try:
    # 1. Extrair dados do MySQL
    print("Extraindo dados de conversas e mensagens do MySQL...")
    
    # Consulta que combina conversas e mensagens
    conversas_mensagens_query = """
    (SELECT 
        c.id AS conversation_id,
        c.user_id,
        c.model_id,
        m.id AS message_id,
        m.role,
        m.content,
        m.tokens_used,
        m.created_at
    FROM 
        conversations c
    JOIN 
        messages m ON c.id = m.conversation_id) AS conversations_messages
    """
    
    df_mysql = spark.read.jdbc(
        url=mysql_url,
        table=conversas_mensagens_query,
        properties=mysql_properties
    )
    
    print(f"Dados extraídos do MySQL: {df_mysql.count()} registros")
    
    # 2. Transformar dados para o formato do Langfuse
    print("Transformando dados para o formato do Langfuse...")
    
    # Criar trace_id a partir do conversation_id
    df_transformed = df_mysql \
        .withColumn("trace_id", concat(lit("trace-"), col("conversation_id"))) \
        .withColumn("generation_id", concat(lit("gen-"), col("message_id"))) \
        .withColumn("user_id", concat(lit("user-"), col("user_id"))) \
        .withColumn("model", 
            when(col("model_id") == 1, "gpt-4") \
            .when(col("model_id") == 2, "claude-3") \
            .when(col("model_id") == 3, "llama-2") \
            .otherwise("unknown"))
    
    # Criar DataFrame para traces
    df_traces = df_transformed \
        .select(
            "trace_id", 
            col("conversation_id").alias("name"),
            "user_id",
            col("created_at").alias("timestamp")
        ) \
        .dropDuplicates(["trace_id"])
    
    # Criar DataFrame para generations - apenas mensagens do assistente
    df_generations = df_transformed \
        .filter(col("role") == "assistant") \
        .select(
            "generation_id",
            "trace_id",
            "model",
            "content",
            "tokens_used",
            col("created_at").alias("timestamp")
        )
    
    # 3. Carregar dados no PostgreSQL
    print("Carregando dados no PostgreSQL...")
    
    # Carregar traces
    df_traces.write \
        .jdbc(
            url=postgres_url,
            table="langfuse.traces",
            mode="append",
            properties=postgres_properties
        )
    
    # Carregar generations
    df_generations.write \
        .jdbc(
            url=postgres_url,
            table="langfuse.generations",
            mode="append",
            properties=postgres_properties
        )
    
    print("ETL concluído com sucesso!")

except Exception as e:
    print(f"Erro durante o processo de ETL: {str(e)}")
    raise e

finally:
    # Finalizar o job
    job.commit()