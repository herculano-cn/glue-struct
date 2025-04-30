# AWS Glue Local com MySQL e PostgreSQL

Este ambiente permite executar o AWS Glue localmente com Docker, integrando MySQL (para AI Cockpit) e PostgreSQL (para Langfuse).

## Pré-requisitos

- Docker e Docker Compose instalados
- Git
- Pelo menos 8GB de RAM disponível para os containers

## Estrutura de Diretórios

```
glue-local-dev/
├── docker/
│   ├── Dockerfile.glue
│   ├── docker-compose.yml
├── scripts/
│   ├── init-mysql.sql
│   ├── init-postgres.sql
│   └── setup-glue.sh
├── jobs/
│   ├── mysql_to_postgres.py
├── shared/
│   └── notebooks/
└── README.md
```

## Instruções de Instalação

### 1. Clonar o Repositório

```bash
git clone https://github.com/sua-organizacao/glue-local-dev.git
cd glue-local-dev
```

### 2. Construir e Iniciar os Containers

```bash
cd docker
docker-compose up -d
```

Isso iniciará os seguintes serviços:
- `glue-local`: AWS Glue Studio local com Jupyter Notebook
- `mysql`: Banco de dados MySQL para AI Cockpit
- `phpmyadmin`: Interface administrativa para MySQL
- `postgres`: Banco de dados PostgreSQL para Langfuse
- `pgadmin`: Interface administrativa para PostgreSQL

### 3. Acessar o Jupyter Notebook

Abra o navegador e acesse:
```
http://localhost:8888
```

### 4. Acessar o PHPMyAdmin (MySQL)

```
http://localhost:8080
Usuário: root
Senha: rootpassword
```

### 5. Acessar o PGAdmin (PostgreSQL)

```
http://localhost:8081
E-mail: admin@example.com
Senha: admin
```

Adicione um servidor:
- Nome: postgres-local
- Host: postgres
- Porta: 5432
- Usuário: postgres
- Senha: postgres

## Executando Jobs do Glue

### Via Jupyter Notebook

1. Abra o notebook `shared/notebooks/glue_test.ipynb` para validar as conexões
2. Crie novos notebooks para desenvolver seus próprios ETLs

### Via CLI (dentro do container)

```bash
#