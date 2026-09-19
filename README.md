# Sistema de Gestão de Oficina Mecânica

Projeto desenvolvido para a disciplina de **Laboratório de Banco de Dados** do curso de **Engenharia de Software**.

O projeto implementa um banco de dados relacional para uma oficina mecânica, abrangendo clientes, veículos, mecânicos, fornecedores, peças, serviços e ordens de serviço.

## Modelo Conceitual

O [modelo conceitual em PDF](docs/MER.pdf) define as entidades, atributos, relacionamentos e cardinalidades do banco de dados.

## Funcionalidades Modeladas

- Cadastro de clientes pessoa física e pessoa jurídica.
- Cadastro de veículos vinculados aos clientes.
- Cadastro de mecânicos e sua estrutura de supervisão.
- Cadastro de fornecedores, peças e controle de estoque.
- Catálogo de serviços com valor padrão e tempo estimado.
- Abertura e acompanhamento de ordens de serviço.
- Associação de serviços e peças às ordens de serviço.
- Registro de garantias das ordens de serviço.
- Histórico de alterações de status das ordens de serviço.

## Tecnologias Utilizadas

- MySQL 8.0 ou superior.
- MySQL Workbench, opcionalmente, para executar e consultar o banco.

## Estrutura do Repositório

```text
oficina-mecanica-db/
|-- README.md
|-- docs/
|   |-- MER.pdf
|   `-- Projeto-Final.pdf
`-- sql/
    |-- 01_ddl.sql
    |-- 02_carga.sql
    `-- 03_consultas.sql
```

## Como Executar

Execute os scripts na ordem abaixo:

1. `sql/01_ddl.sql`: cria o banco `oficina_mecanica`, as tabelas, chaves, restrições e índices.
2. `sql/02_carga.sql`: insere os dados fictícios para teste.
3. `sql/03_consultas.sql`: contém consultas básicas, intermediárias e avançadas.

> Atenção: o script `01_ddl.sql` remove as tabelas existentes do banco `oficina_mecanica` antes de recriá-las.

### MySQL Workbench

Abra cada arquivo da pasta `sql/` e execute-os na ordem indicada acima.

## Documentação

O relatório do projeto está disponível em [docs/Projeto-Final.pdf](docs/Projeto-Final.pdf).
