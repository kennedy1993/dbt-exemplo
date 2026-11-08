# 🚀 Projeto de Engenharia Analítica com dbt Core & Google BigQuery

[![Fase do Projeto: Configuração & Setup](https://img.shields.io/badge/Status-Configura%C3%A7%C3%A3o%20100%25%20Validada-success?style=for-the-badge&logo=checkmarx&logoColor=white)](#-status-atual-do-projeto)
[![dbt Core](https://img.shields.io/badge/dbt--core-v1.13-FF694B?style=for-the-badge&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![Google BigQuery](https://img.shields.io/badge/Google_Cloud-BigQuery-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)](https://cloud.google.com/bigquery)
[![Python](https://img.shields.io/badge/Python-3.12.8-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![DBeaver](https://img.shields.io/badge/DBeaver-Enterprise%20Ready-372923?style=for-the-badge&logo=dbeaver&logoColor=white)](https://dbeaver.io/)

Este repositório documenta a implementação de um ecossistema de **Modern Data Stack (MDS)**, utilizando o **dbt (data build tool)** integrado ao **Google BigQuery** como Data Warehouse em nuvem. 

O foco deste documento é detalhar o **setup profissional, governança, segurança e configuração de infraestrutura**, servindo como padrão de engenharia antes do desenvolvimento das camadas analíticas.

---

## 📌 Sumário
- [Status Atual do Projeto](#-status-atual-do-projeto)
- [Arquitetura da Solução](#-arquitetura-da-solução)
- [Estrutura do Repositório](#-estrutura-do-repositório)
- [Guia Passo a Passo de Configuração Profissional](#-guia-passo-a-passo-de-configuração-profissional)
  - [Etapa 1: Ambiente Local e Ferramentas (Windows / Linux)](#etapa-1-ambiente-local-e-ferramentas-windows--linux)
  - [Etapa 2: Isolamento com Ambiente Virtual Python (`.venv`)](#etapa-2-isolamento-com-ambiente-virtual-python-venv)
  - [Etapa 3: Governança no Google Cloud Platform (GCP & IAM)](#etapa-3-governança-no-google-cloud-platform-gcp--iam)
  - [Etapa 4: Inicialização e Estrutura do dbt (`dbt init`)](#etapa-4-inicialização-e-estrutura-do-dbt-dbt-init)
  - [Etapa 5: Gestão Segura de Perfis (`profiles.yml`)](#etapa-5-gestão-segura-de-perfis-profilesyml)
  - [Etapa 6: Validação de Ponta a Ponta (`dbt debug`, `run`, `test`)](#etapa-6-validação-de-ponta-a-ponta-dbt-debug-run-test)
  - [Etapa 7: Conexão e Auditoria no DBeaver](#etapa-7-conexão-e-auditoria-no-dbeaver)
- [Padrões de Qualidade e Boas Práticas Adotadas](#-padrões-de-qualidade-e-boas-práticas-adotadas)
- [Guia de Troubleshooting (Problemas Reais e Soluções)](#-guia-de-troubleshooting-problemas-reais-e-soluções)
- [Roadmap das Próximas Fases](#-roadmap-das-próximas-fases)

---

## 🎯 Status Atual do Projeto

| Marco de Engenharia | Status | Evidência / Validação |
| :--- | :---: | :--- |
| **Isolamento de Runtime Python** | Concluído | `.venv` com Python 3.12 e dependências congeladas em `requirements.txt` |
| **Governança no GCP / IAM** | Concluído | Service Account com papéis de execução de Jobs e escrita no BigQuery |
| **Conexão dbt Core ↔ BigQuery** | Concluído | `dbt debug` com resultado `All checks passed!` |
| **Ingestão via Seeds (`dbt seed`)** | Concluído | `raw_clientes` (10 linhas) e `raw_pedidos` (15 linhas) carregados no BigQuery |
| **Arquitetura em 3 Camadas (`dbt run`)** | Concluído | 7 modelos criados em `dbt_dev` (`staging`, `intermediate` e `marts` Star Schema) |
| **Validação de Qualidade (`dbt test`)** | Concluído | **43 testes executados com 100% de sucesso** (`41 data tests` + `2 unit tests`) |
| **Catálogo & Linhagem (`dbt docs`)** | Concluído | Catálogo (`catalog.json`) e manifesto (`manifest.json`) gerados via `dbt docs generate` |

---

## 🏗 Arquitetura da Solução

```mermaid
flowchart TD
    subgraph Local_Environment["Ambiente Local do Engenheiro"]
        direction TB
        A["Repositório Git\n(Projeto-DBT)"] --> B["Python 3.12 (.venv)\ndbt-core + dbt-bigquery"]
        B --> C["Configuração de Perfis\n(profiles.yml + service-account.json)"]
    end

    subgraph Google_Cloud["Google Cloud Platform (analise-dados-513914)"]
        direction TB
        D["IAM & Security\n(dbt-707 Service Account)"] --> E["Motor de Processamento\n(BigQuery Engine - Dataset: dbt_dev)"]
        E --> S["Seeds (CSV Raw)\n- raw_clientes\n- raw_pedidos"]
        S --> STG["Camada Staging (Views)\n- stg_clientes\n- stg_pedidos"]
        STG --> INT["Camada Intermediate (View)\n- int_pedidos_por_cliente"]
        INT --> MARTS["Camada Marts - Star Schema (Tables)\n- dim_clientes\n- fct_pedidos"]
    end

    subgraph Analytics_Layer["Camada de Auditoria e Consumo"]
        MARTS --> G["DBeaver / BI Tools\n(Inspeção de Esquemas e Consultas)"]
    end

    C -- "Autenticação via Chave JSON" --> D
    B -- "dbt seed / dbt run / dbt test" --> E
```

### 🌐 Grafo de Linhagem Real (dbt Docs Lineage Graph - DAG)

Abaixo está o grafo de linhagem (DAG) real gerado pelo `dbt docs serve`, demonstrando o fluxo completo desde os arquivos brutos (`seeds`) até a camada `marts` (**Star Schema**) e seus testes unitários:

![Grafo de Linhagem (DAG) no dbt Docs](./assets/lineage_graph.png)

---

## 📁 Estrutura do Repositório

```text
Projeto-DBT/
│
├── .vscode/
│   └── settings.json              # Associa *.sql a jinja-sql para evitar falsos positivos de linter
├── .gitignore                     # Protege credenciais (*.json), .venv/ e diretórios temporários
├── requirements.txt               # Lista exata das dependências instaladas (pip freeze)
├── README.md                      # Documentação técnica e governança do repositório
│
└── dbt_exemplo/                   # Subdiretório do projeto dbt (isolamento de infraestrutura)
    ├── dbt_project.yml            # Manifesto principal do projeto dbt e materializações por camada
    ├── profiles.yml               # Configuração da conexão com BigQuery (Dev / Prod)
    ├── service-account.json       # Chave privada da Service Account (IGNORADA PELO GIT)
    │
    ├── seeds/                     # Cargas de dados brutos (CSV) via dbt seed
    │   ├── raw_clientes.csv       # Cadastro bruto de clientes (10 registros)
    │   └── raw_pedidos.csv        # Histórico bruto de pedidos de e-commerce (15 registros)
    │
    ├── models/                    # Arquitetura Medalhão / 3 Camadas do dbt
    │   ├── staging/               # Camada 1: Limpeza, padronização e tipagem (Views)
    │   │   ├── stg_clientes.sql
    │   │   ├── stg_pedidos.sql
    │   │   └── schema.yml         # Testes de contrato (unique, not_null, accepted_values, relationships)
    │   │
    │   ├── intermediate/          # Camada 2: Regras de negócio e agregações intermediárias (Views)
    │   │   ├── int_pedidos_por_cliente.sql
    │   │   └── schema.yml
    │   │
    │   ├── marts/                 # Camada 3: Modelos Finais Star Schema para BI (Tables)
    │   │   ├── dim_clientes.sql   # Dimensão de clientes com segmentação (VIP, Ativo, Sem Compras)
    │   │   ├── fct_pedidos.sql    # Tabela Fato de pedidos enriquecida com receita líquida
    │   │   ├── dim_clientes_test.yml # Teste unitário validando regra de segmentação de clientes
    │   │   └── schema.yml         # Documentação executiva e testes de integridade da camada Marts
    │   │
    │   └── example/               # Modelos de validação inicial do template dbt
    │       ├── my_first_dbt_model.sql
    │       ├── my_second_dbt_model.sql
    │       └── schema.yml
    │
    ├── analyses/                  # Scripts SQL analíticos para exploração (não materializados)
    ├── macros/                    # Funções Jinja/SQL reutilizáveis
    ├── snapshots/                 # Rastreamento de histórico (Slowly Changing Dimensions)
    └── tests/                     # Testes SQL singulares customizados
```

---

## 🛠 Guia Passo a Passo de Configuração Profissional

### Etapa 1: Ambiente Local e Ferramentas (Windows / Linux)

1. **Instalação do Git e Python**:
   - Python: Versão recomendada **3.12.x** instalada com a opção *"Add python.exe to PATH"*.
   - Git: Instalado com suporte a **Git Bash**.

2. **Diferença Crítica de Terminais no Windows (Senior Tip)**:
   - No **PowerShell**, o comando `ls -l` gera erro de parâmetro `LiteralPath` porque `ls` é um *alias* para o cmdlet `Get-ChildItem`.
   - **Solução profissional**: No VS Code, alterne o terminal padrão para **Git Bash** (`Ctrl + Shift + P` > *Terminal: Select Default Profile* > *Git Bash*) para ter compatibilidade nativa com comandos Unix (`ls -la`, `source`, caminhos `/`).

3. **Clonagem do Repositório**:
   ```bash
   git clone https://github.com/kennedy1993/dbt-exemplo.git
   cd Projeto-DBT
   ```

---

### Etapa 2: Isolamento com Ambiente Virtual Python (`.venv`)

O uso de um ambiente virtual isolado é um requisito mandatário em engenharia de software para garantir que atualizações do sistema não quebrem dependências do dbt.

1. **Criação do ambiente virtual**:
   ```bash
   python -m venv .venv
   ```

2. **Ativação do ambiente**:
   - **Windows (PowerShell)**:
     ```powershell
     .\.venv\Scripts\Activate.ps1
     ```
     *(Se houver erro de permissão de script no PowerShell, execute antes: `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`)*
   - **Git Bash / Linux / macOS**:
     ```bash
     source .venv/bin/activate
     ```

3. **Instalação dos pacotes**:
   ```bash
   pip install -r requirements.txt
   ```

---

### Etapa 3: Governança no Google Cloud Platform (GCP & IAM)

#### 1. Criação do Projeto e Habilitação de APIs
- Projeto GCP: `analise-dados-513914`
- API obrigatória: **BigQuery API** (ativada por padrão em novos projetos).

#### 2. Criação da Conta de Serviço (Service Account)
1. Navegue até **GCP Console** > **IAM e administração** > **Contas de serviço**.
2. Crie a conta de serviço (ex: `dbt-707`).
3. Vá na aba **Chaves (Keys)** > **Adicionar Chave** > **Criar nova chave (JSON)**.
4. Salve o arquivo gerado como:
   `c:\Users\lustrabits\Documents\Projeto-DBT\dbt_exemplo\service-account.json`

#### 3. Configuração de Papéis (IAM) — A Pegadinha do BigQuery
> [!IMPORTANT]
> Apenas conceder *Editor de Dados* não é suficiente para o dbt! O dbt precisa executar queries na GCP, o que requer a permissão `bigquery.jobs.create`.
> 
> No menu **IAM Principal** (não apenas dentro da tela de Service Account), adicione à conta `dbt-707@analise-dados-513914.iam.gserviceaccount.com`:
> - **Papel Recomendado:** `Administrador do BigQuery` (`roles/bigquery.admin`)  
> - *OU a combinação de privilégios mínimos:*
>   - `Usuário de jobs do BigQuery` (`roles/bigquery.jobUser`)
>   - `Editor de dados do BigQuery` (`roles/bigquery.dataEditor`)

---

### Etapa 4: Inicialização e Estrutura do dbt (`dbt init`)

O projeto foi inicializado de forma silenciosa e estruturada dentro do diretório dedicado `dbt_exemplo/`, evitando poluir a raiz do repositório:

```bash
dbt init dbt_exemplo --skip-profile-setup
```

Arquivo de configuração principal ([dbt_project.yml](file:///c:/Users/lustrabits/Documents/Projeto-DBT/dbt_exemplo/dbt_project.yml)):
```yaml
name: 'dbt_exemplo'
version: '1.0.0'
profile: 'dbt_exemplo'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]
clean-targets:
  - "target"
  - "dbt_packages"

models:
  dbt_exemplo:
    example:
      +materialized: view
    staging:
      +materialized: view
    intermediate:
      +materialized: view
    marts:
      +materialized: table
```

---

### Etapa 5: Gestão Segura de Perfis (`profiles.yml`)

O arquivo [profiles.yml](file:///c:/Users/lustrabits/Documents/Projeto-DBT/dbt_exemplo/profiles.yml) define como o dbt conecta no Data Warehouse:

```yaml
dbt_exemplo:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: analise-dados-513914
      dataset: dbt_dev
      threads: 4
      keyfile: ./service-account.json
      location: US
      priority: interactive
      job_execution_timeout_seconds: 300
      job_retries: 1
```

> [!CAUTION]
> **Segurança de Credenciais:**  
> O arquivo [.gitignore](file:///c:/Users/lustrabits/Documents/Projeto-DBT/.gitignore) está configurado com `*.json` para garantir que o `service-account.json` **NUNCA** seja versionado para o repositório remoto no GitHub.

---

### Etapa 6: Validação de Ponta a Ponta (`dbt debug`, `seed`, `run`, `test`, `docs`)

Com o ambiente ativado, navegue para a pasta `dbt_exemplo/`:
```bash
cd dbt_exemplo
```

#### 1. Verificação de Saúde da Conexão
```bash
dbt debug --profiles-dir .
```
Resultado validado:
```text
Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]
Required dependencies:
 - git [OK found]
Connection:
  method: service-account
  database: analise-dados-513914
  schema: dbt_dev
  location: US
Registered adapter: bigquery=1.12.2
  Connection test: [OK connection ok]
All checks passed!
```

#### 2. Carga de Dados Brutos via Seeds (`dbt seed`)
```bash
dbt seed --profiles-dir .
```
Resultado validado:
```text
1 of 2 OK loaded seed file dbt_dev.raw_clientes .................... [INSERT 10 in 5.83s]
2 of 2 OK loaded seed file dbt_dev.raw_pedidos ..................... [INSERT 15 in 5.42s]
Completed successfully. PASS=2 WARN=0 ERROR=0 TOTAL=2
```

#### 3. Execução das Transformações em 3 Camadas (`dbt run`)
```bash
dbt run --profiles-dir .
```
Resultado validado:
```text
1 of 7 OK created sql table model dbt_dev.my_first_dbt_model ....... [CREATE TABLE (1.0 rows)]
2 of 7 OK created sql view model dbt_dev.stg_clientes .............. [CREATE VIEW]
3 of 7 OK created sql view model dbt_dev.stg_pedidos ............... [CREATE VIEW]
4 of 7 OK created sql view model dbt_dev.my_second_dbt_model ....... [CREATE VIEW]
5 of 7 OK created sql view model dbt_dev.int_pedidos_por_cliente ... [CREATE VIEW]
6 of 7 OK created sql table model dbt_dev.fct_pedidos .............. [CREATE TABLE (15.0 rows)]
7 of 7 OK created sql table model dbt_dev.dim_clientes ............. [CREATE TABLE (10.0 rows)]
Completed successfully. PASS=7 WARN=0 ERROR=0 TOTAL=7
```

#### 4. Execução dos Testes Automatizados de Qualidade (`dbt test`)
```bash
dbt test --profiles-dir .
```
Resultado validado:
```text
Found 7 models, 2 seeds, 41 data tests, 561 macros, 2 unit tests
Completed successfully
Done. PASS=43 WARN=0 ERROR=0 SKIP=0 NO-OP=0 REUSED=0 TOTAL=43
```

#### 5. Geração do Catálogo e Grafo de Linhagem (`dbt docs`)
```bash
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir . --port 8085
```

![Grafo de Linhagem (DAG) no dbt Docs](./assets/lineage_graph.png)

---

### Etapa 7: Conexão e Auditoria no DBeaver

Para inspecionar visualmente o modelo **Star Schema** criado pelo dbt no BigQuery:
1. Abra o **DBeaver** e atualize (`F5`) a conexão `analise-dados-513914` > `dbt_dev`.
2. Execute as consultas analíticas abaixo:

```sql
-- 1. Dimensão de Clientes (com Segmentação VIP, Ativo e Sem Compras Concluídas)
SELECT
    cliente_id,
    nome_cliente,
    cidade,
    uf,
    total_pedidos,
    pedidos_concluidos,
    receita_total,
    ticket_medio,
    segmento_cliente
FROM `analise-dados-513914.dbt_dev.dim_clientes`
ORDER BY receita_total DESC;

-- 2. Tabela Fato de Pedidos Enriquecida
SELECT
    pedido_id,
    data_pedido,
    nome_cliente,
    cidade,
    uf,
    status_pedido,
    metodo_pagamento,
    valor_pedido,
    valor_receita_liquida
FROM `analise-dados-513914.dbt_dev.fct_pedidos`
ORDER BY data_pedido DESC, pedido_id DESC;
```

#### Evidências de Auditoria no DBeaver

**1. Dimensão de Clientes (`dim_clientes`):**
![Resultado dim_clientes no DBeaver](./assets/dbeaver_dim_clientes.jpg)

**2. Tabela Fato de Pedidos (`fct_pedidos`):**
![Resultado fct_pedidos no DBeaver](./assets/dbeaver_fct_pedidos.jpg)

---

## 💎 Padrões de Qualidade e Boas Práticas Adotadas

1. **Column Pruning (Otimização BigQuery)**:
   - Listagem explícita de colunas em todas as CTEs (zero uso de `SELECT *`) para minimizar custos de leitura (*bytes scanned*).
2. **Materialização Híbrida (`Views` vs `Tables`)**:
   - Camadas `staging` e `intermediate` materializadas como `view` (economia de armazenamento) e camada `marts` materializada como `table` (alta performance para leitura no BI e DBeaver).
3. **Tipagem Defensiva (`SAFE_CAST`)**:
   - Conversão segura de tipos (`INT64`, `DATE`, `NUMERIC`) na camada `staging`, protegendo o pipeline contra quebras por dados malformados.
4. **Contratos de Dados e Testes Unitários**:
   - Validação de chaves primárias (`unique`, `not_null`), domínios (`accepted_values`), integridade referencial (`relationships`) e testes unitários de regras de negócio (`dim_clientes_test.yml`).

---

## 🔧 Guia de Troubleshooting (Problemas Reais e Soluções)

| Erro Encontrado | Causa Técnica | Solução Aplicada |
| :--- | :--- | :--- |
| `Get-ChildItem : Missing an argument for parameter 'LiteralPath'` | Digitação de `ls -l` no PowerShell (que interpreta `-l` como `-LiteralPath`). | Utilizar `ls -Force` no PowerShell ou mudar o terminal padrão para **Git Bash**. |
| `Access Denied: User does not have bigquery.jobs.create permission` | A Service Account tinha papel de dados, mas não de execução de consultas. | Concedido papel `BigQuery Admin` (ou `BigQuery Job User`) no IAM do projeto GCP. |
| `Could not find profile named 'dbt_exemplo'` | O dbt procura por padrão em `~/.dbt/profiles.yml`. | Criado `profiles.yml` local e executado com `--profiles-dir .`, além de espelhado em `~/.dbt/`. |
| `No dbt_project.yml found at expected path` | Execução do comando `dbt run` na pasta raiz `Projeto-DBT` em vez da subpasta `dbt_exemplo`. | Entrar na pasta do projeto (`cd dbt_exemplo`) antes de rodar os comandos do dbt. |
| `FAIL 1 not_null_my_first_dbt_model_id` | Modelo de exemplo vinha com registro nulo intencional (`SELECT null AS id`). | Ajustado filtro `WHERE id IS NOT NULL` no modelo, alcançando 100% de aprovação nos testes. |
| `Syntax Error at line ... dbtools` | Extensão *Oracle SQL Developer* tentando validar arquivos `.sql` com sintaxe Jinja (`{{ ... }}`) como SQL puro. | Configurado [`.vscode/settings.json`](file:///c:/Users/lustrabits/Documents/Projeto-DBT/.vscode/settings.json) associando `*.sql` para `jinja-sql`. |

---

## 🗺 Roadmap das Próximas Fases

- [x] **Fase 1: Setup & Configuração de Ambiente** (Concluído)
- [x] **Fase 2: Ingestão via Seeds & Camada Staging (`models/staging/`)**:
  - Carga de `raw_clientes.csv` e `raw_pedidos.csv` via `dbt seed`.
  - Limpeza primária, renomeação de colunas e tipagem em `stg_clientes` e `stg_pedidos`.
- [x] **Fase 3: Camada Intermediária (`models/intermediate/`)**:
  - Agregações financeiras e comportamentais por cliente em `int_pedidos_por_cliente`.
- [x] **Fase 4: Camada Marts (`models/marts/`)**:
  - Modelagem dimensional Star Schema (`dim_clientes` com segmentação VIP/Ativo e `fct_pedidos`).
- [x] **Fase 5: Catálogo & Documentação**:
  - Geração do catálogo e linhagem (`catalog.json` / `manifest.json`) via `dbt docs generate`.
