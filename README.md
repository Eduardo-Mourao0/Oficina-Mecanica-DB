# Sistema de Gestão de Oficina Mecânica

Projeto desenvolvido para a disciplina de **Laboratório de Banco de Dados** do curso de **Engenharia de Software**.

O projeto implementa um banco de dados relacional para uma oficina mecânica, abrangendo clientes, veículos, mecânicos, fornecedores, peças, serviços, ordens de serviço, garantia e auditoria de status.

## Modelo Conceitual

O [modelo conceitual (PDF)](docs/MER.pdf?raw=1) define as entidades, atributos, relacionamentos e cardinalidades do banco de dados.

## Funcionalidades Modeladas

- Cadastro de clientes pessoa física e pessoa jurídica.
- Cadastro de veículos vinculados aos clientes.
- Cadastro de mecânicos e sua estrutura de supervisão.
- Cadastro de fornecedores, peças e controle de estoque.
- Catálogo de serviços com valor padrão e tempo estimado.
- Abertura, aprovação, execução, conclusão ou cancelamento de ordens de serviço.
- Associação de serviços e peças às ordens de serviço, com quantidade e preço congelado.
- Cálculo automático do total da OS e atualização automática do estoque.
- Registro de garantias das ordens de serviço.
- Histórico imutável das alterações de status das ordens de serviço.

## Tecnologias Utilizadas

- MySQL 8.0 ou superior.
- MySQL Workbench, opcionalmente, para executar e consultar o banco.
- Python 3.10 ou superior.
- Streamlit, MySQL Connector/Python e Python Dotenv.

## Estrutura do Repositório

```text
oficina-mecanica-db/
|-- .env.example
|-- README.md
|-- app.py
|-- database.py
|-- requirements.txt
|-- docs/
|   |-- evidencias/
|   |   |-- abertura-ordem-servico.png
|   |   |-- catalogo-pecas.png
|   |   |-- consulta-clientes.png
|   |   `-- erro-validacao-telefone.png
|   |-- MER.pdf
|   |-- Relatorio_Tecnico_Etapa_1.pdf
|   `-- Relatorio_Tecnico_Etapa_2.pdf
`-- sql/
    |-- 01_ddl.sql
    |-- 02_regras_negocio.sql
    |-- 03_carga.sql
    `-- 04_consultas.sql
```

## Como Executar

Execute os scripts na ordem abaixo:

1. `sql/01_ddl.sql`: cria o banco `oficina_mecanica`, as tabelas, chaves, restrições e índices.
2. `sql/02_regras_negocio.sql`: cria procedures e triggers das regras de negócio.
3. `sql/03_carga.sql`: insere os dados fictícios para teste.
4. `sql/04_consultas.sql`: contém as 15 consultas de negócio.

> Atenção: o script `01_ddl.sql` remove as tabelas existentes do banco `oficina_mecanica` antes de recriá-las.

### MySQL Workbench

Abra cada arquivo da pasta `sql/` e execute-os na ordem indicada acima.

## Aplicação Streamlit

Após executar os scripts SQL, crie um arquivo `.env` a partir de `.env.example`, informe as credenciais locais do MySQL e execute:

```bash
python -m pip install -r requirements.txt
streamlit run app.py
```

O `.env` possui dados sensíveis e está ignorado pelo Git.

## Documentação

- Etapa 1: [docs/Relatorio_Tecnico_Etapa_1.pdf](docs/Relatorio_Tecnico_Etapa_1.pdf)
- Etapa 2: [docs/Relatorio_Tecnico_Etapa_2.pdf](docs/Relatorio_Tecnico_Etapa_2.pdf)
- Modelo conceitual: [docs/MER.pdf](docs/MER.pdf)

> O relatório da Etapa 1 é o registro histórico da primeira entrega. Para o esquema vigente, consulte os scripts da pasta `sql/` e o relatório da Etapa 2.
