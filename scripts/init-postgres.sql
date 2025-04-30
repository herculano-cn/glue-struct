-- Inicialização do banco de dados PostgreSQL para Langfuse

-- Criar esquema se não existir
CREATE SCHEMA IF NOT EXISTS langfuse;

-- Definir esquema padrão
SET search_path TO langfuse;

-- Tabela de traces (rastreamento)
CREATE TABLE IF NOT EXISTS traces (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    user_id VARCHAR(255),
    session_id VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de generations (gerações)
CREATE TABLE IF NOT EXISTS generations (
    id VARCHAR(255) PRIMARY KEY,
    trace_id VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    prompt TEXT NOT NULL,
    completion TEXT,
    tokens_prompt INTEGER,
    tokens_completion INTEGER,
    latency REAL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trace_id) REFERENCES traces(id)
);

-- Tabela de scores (pontuações)
CREATE TABLE IF NOT EXISTS scores (
    id VARCHAR(255) PRIMARY KEY,
    trace_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    value REAL NOT NULL,
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trace_id) REFERENCES traces(id)
);

-- Tabela de spans (intervalos de execução)
CREATE TABLE IF NOT EXISTS spans (
    id VARCHAR(255) PRIMARY KEY,
    trace_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trace_id) REFERENCES traces(id)
);

-- Inserir dados de exemplo
INSERT INTO traces (id, name, user_id, session_id, metadata)
VALUES 
    ('trace-1', 'chat-completion', 'user-1', 'session-1', '{"source": "web_app"}'),
    ('trace-2', 'document-qa', 'user-2', 'session-2', '{"source": "mobile_app"}'),
    ('trace-3', 'summarization', 'user-1', 'session-3', '{"source": "api"}');

INSERT INTO generations (id, trace_id, model, prompt, completion, tokens_prompt, tokens_completion, latency)
VALUES 
    ('gen-1', 'trace-1', 'gpt-4', 'Explique o que é machine learning', 'Machine learning é um subcampo da inteligência artificial...', 5, 15, 0.8),
    ('gen-2', 'trace-2', 'claude-3', 'Resuma este documento sobre finanças', 'O documento cobre aspectos fundamentais de investimentos...', 12, 20, 1.2),
    ('gen-3', 'trace-3', 'llama-2', 'Sintetize as principais conclusões', 'As principais conclusões indicam que...', 6, 10, 0.5);

INSERT INTO scores (id, trace_id, name, value, comment)
VALUES 
    ('score-1', 'trace-1', 'relevance', 0.92, 'Resposta altamente relevante'),
    ('score-2', 'trace-1', 'correctness', 0.85, 'Alguns detalhes imprecisos'),
    ('score-3', 'trace-2', 'completeness', 0.78, 'Faltam alguns pontos-chave');

INSERT INTO spans (id, trace_id, name, start_time, end_time, status, metadata)
VALUES 
    ('span-1', 'trace-1', 'process_input', CURRENT_TIMESTAMP - INTERVAL '5 minutes', CURRENT_TIMESTAMP - INTERVAL '4 minutes 55 seconds', 'completed', '{"cpu_usage": 0.2}'),
    ('span-2', 'trace-1', 'generate_response', CURRENT_TIMESTAMP - INTERVAL '4 minutes 55 seconds', CURRENT_TIMESTAMP - INTERVAL '4 minutes', 'completed', '{"cpu_usage": 0.8}'),
    ('span-3', 'trace-2', 'retrieve_documents', CURRENT_TIMESTAMP - INTERVAL '10 minutes', CURRENT_TIMESTAMP - INTERVAL '9 minutes 30 seconds', 'completed', '{"docs_retrieved": 5}');

-- Criar usuário para AWS Glue
CREATE USER glue_user WITH PASSWORD 'glue_password';
GRANT ALL PRIVILEGES ON SCHEMA langfuse TO glue_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA langfuse TO glue_user;