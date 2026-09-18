-- ============================================================
-- Criacao do banco, tabelas, chaves e restricoes
-- Modelo baseado no diagrama entidade-relacionamento
-- ============================================================

CREATE DATABASE IF NOT EXISTS oficina_mecanica
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE oficina_mecanica;

-- Remove as tabelas respeitando as dependencias das chaves estrangeiras.
DROP TABLE IF EXISTS HISTORICO_STATUS_OS;
DROP TABLE IF EXISTS GARANTIA;
DROP TABLE IF EXISTS ITEM_PECA;
DROP TABLE IF EXISTS ITEM_SERVICO;
DROP TABLE IF EXISTS ORDEM_SERVICO;
DROP TABLE IF EXISTS PECA;
DROP TABLE IF EXISTS SERVICO;
DROP TABLE IF EXISTS MECANICO;
DROP TABLE IF EXISTS VEICULO;
DROP TABLE IF EXISTS PESSOA_JURIDICA;
DROP TABLE IF EXISTS PESSOA_FISICA;
DROP TABLE IF EXISTS CLIENTE;
DROP TABLE IF EXISTS FORNECEDOR;

-- ============================================================
-- CLIENTE e suas especializacoes
-- ============================================================
CREATE TABLE CLIENTE (
    id_cliente INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    endereco VARCHAR(150),
    tipo_cliente VARCHAR(20) NOT NULL,

    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT ck_cliente_tipo
        CHECK (tipo_cliente IN ('Pessoa Fisica', 'Pessoa Juridica'))
);

CREATE TABLE PESSOA_FISICA (
    id_cliente INT NOT NULL,
    cpf VARCHAR(14) NOT NULL,
    rg VARCHAR(20) NOT NULL,
    data_nasc DATE NOT NULL,

    CONSTRAINT pk_pessoa_fisica PRIMARY KEY (id_cliente),
    CONSTRAINT uq_pessoa_fisica_cpf UNIQUE (cpf),
    CONSTRAINT fk_pessoa_fisica_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE PESSOA_JURIDICA (
    id_cliente INT NOT NULL,
    cnpj VARCHAR(18) NOT NULL,
    razao_social VARCHAR(150) NOT NULL,
    inscricao_estadual VARCHAR(30) NOT NULL,

    CONSTRAINT pk_pessoa_juridica PRIMARY KEY (id_cliente),
    CONSTRAINT uq_pessoa_juridica_cnpj UNIQUE (cnpj),
    CONSTRAINT fk_pessoa_juridica_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
);

-- ============================================================
-- VEICULO
-- ============================================================
CREATE TABLE VEICULO (
    id_veiculo INT AUTO_INCREMENT,
    placa VARCHAR(8) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    ano_fabricacao INT,
    cor VARCHAR(30),
    id_cliente INT NOT NULL,

    CONSTRAINT pk_veiculo PRIMARY KEY (id_veiculo),
    CONSTRAINT uq_veiculo_placa UNIQUE (placa),
    CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente),

    INDEX idx_veiculo_id_cliente (id_cliente)
);

-- ============================================================
-- FORNECEDOR e PECA
-- ============================================================
CREATE TABLE FORNECEDOR (
    id_fornecedor INT AUTO_INCREMENT,
    cnpj VARCHAR(18) NOT NULL,
    nome_fantasia VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(100),

    CONSTRAINT pk_fornecedor PRIMARY KEY (id_fornecedor),
    CONSTRAINT uq_fornecedor_cnpj UNIQUE (cnpj)
);

CREATE TABLE PECA (
    id_peca INT AUTO_INCREMENT,
    codigo_barras VARCHAR(50) NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0,
    id_fornecedor INT NOT NULL,

    CONSTRAINT pk_peca PRIMARY KEY (id_peca),
    CONSTRAINT uq_peca_codigo_barras UNIQUE (codigo_barras),
    CONSTRAINT fk_peca_fornecedor
        FOREIGN KEY (id_fornecedor)
        REFERENCES FORNECEDOR(id_fornecedor),
    CONSTRAINT ck_peca_preco_unitario
        CHECK (preco_unitario >= 0),
    CONSTRAINT ck_peca_quantidade_estoque
        CHECK (quantidade_estoque >= 0),

    INDEX idx_peca_id_fornecedor (id_fornecedor)
);

-- ============================================================
-- MECANICO, incluindo a autorrelacao SUPERVISIONA
-- ============================================================
CREATE TABLE MECANICO (
    id_mecanico INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL,
    especialidade VARCHAR(50) NOT NULL,
    valor_hora DECIMAL(10,2) NOT NULL,
    id_supervisor INT,

    CONSTRAINT pk_mecanico PRIMARY KEY (id_mecanico),
    CONSTRAINT uq_mecanico_cpf UNIQUE (cpf),
    CONSTRAINT fk_mecanico_supervisor
        FOREIGN KEY (id_supervisor)
        REFERENCES MECANICO(id_mecanico),
    CONSTRAINT ck_mecanico_valor_hora
        CHECK (valor_hora >= 0),

    INDEX idx_mecanico_id_supervisor (id_supervisor)
);

-- ============================================================
-- SERVICO, ORDEM_SERVICO e suas relacoes N:N
-- ============================================================
CREATE TABLE SERVICO (
    id_servico INT AUTO_INCREMENT,
    descricao VARCHAR(100) NOT NULL,
    valor_tabela_padrao DECIMAL(10,2) NOT NULL,
    tempo_estimado_horas INT,

    CONSTRAINT pk_servico PRIMARY KEY (id_servico),
    CONSTRAINT ck_servico_valor_tabela_padrao
        CHECK (valor_tabela_padrao >= 0),
    CONSTRAINT ck_servico_tempo_estimado_horas
        CHECK (tempo_estimado_horas IS NULL OR tempo_estimado_horas > 0)
);

CREATE TABLE ORDEM_SERVICO (
    id_os INT AUTO_INCREMENT,
    data_abertura DATETIME NOT NULL,
    data_previsao DATETIME,
    data_conclusao DATETIME,
    status VARCHAR(20) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    id_veiculo INT NOT NULL,
    id_mecanico INT NOT NULL,

    CONSTRAINT pk_ordem_servico PRIMARY KEY (id_os),
    CONSTRAINT fk_os_veiculo
        FOREIGN KEY (id_veiculo)
        REFERENCES VEICULO(id_veiculo),
    CONSTRAINT fk_os_mecanico
        FOREIGN KEY (id_mecanico)
        REFERENCES MECANICO(id_mecanico),
    CONSTRAINT ck_os_valor_total
        CHECK (valor_total >= 0),

    INDEX idx_os_id_veiculo (id_veiculo),
    INDEX idx_os_id_mecanico (id_mecanico),
    INDEX idx_os_status (status)
);

CREATE TABLE ITEM_SERVICO (
    id_os INT NOT NULL,
    id_servico INT NOT NULL,

    CONSTRAINT pk_item_servico PRIMARY KEY (id_os, id_servico),
    CONSTRAINT fk_item_servico_os
        FOREIGN KEY (id_os)
        REFERENCES ORDEM_SERVICO(id_os),
    CONSTRAINT fk_item_servico_servico
        FOREIGN KEY (id_servico)
        REFERENCES SERVICO(id_servico),

    INDEX idx_item_servico_id_servico (id_servico)
);

CREATE TABLE ITEM_PECA (
    id_os INT NOT NULL,
    id_peca INT NOT NULL,

    CONSTRAINT pk_item_peca PRIMARY KEY (id_os, id_peca),
    CONSTRAINT fk_item_peca_os
        FOREIGN KEY (id_os)
        REFERENCES ORDEM_SERVICO(id_os),
    CONSTRAINT fk_item_peca_peca
        FOREIGN KEY (id_peca)
        REFERENCES PECA(id_peca),

    INDEX idx_item_peca_id_peca (id_peca)
);

-- ============================================================
-- GARANTIA e HISTORICO_STATUS_OS
-- ============================================================
CREATE TABLE GARANTIA (
    id_garantia INT AUTO_INCREMENT,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    termos VARCHAR(500) NOT NULL,
    id_os INT NOT NULL,

    CONSTRAINT pk_garantia PRIMARY KEY (id_garantia),
    CONSTRAINT uq_garantia_id_os UNIQUE (id_os),
    CONSTRAINT fk_garantia_os
        FOREIGN KEY (id_os)
        REFERENCES ORDEM_SERVICO(id_os),
    CONSTRAINT ck_garantia_periodo
        CHECK (data_fim >= data_inicio)
);

CREATE TABLE HISTORICO_STATUS_OS (
    id_os INT NOT NULL,
    id_historico INT NOT NULL,
    data_mudanca DATETIME NOT NULL,
    status_anterior VARCHAR(20),
    status_novo VARCHAR(20) NOT NULL,
    observacao VARCHAR(500),

    CONSTRAINT pk_historico_status_os PRIMARY KEY (id_os, id_historico),
    CONSTRAINT fk_historico_status_os
        FOREIGN KEY (id_os)
        REFERENCES ORDEM_SERVICO(id_os),

    INDEX idx_historico_data_mudanca (data_mudanca)
);
