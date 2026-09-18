-- ============================================================
-- Criação do banco, tabelas, chaves, restrições e índices
-- ============================================================

CREATE DATABASE IF NOT EXISTS oficina_mecanica
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE oficina_mecanica;

-- Remove as tabelas caso já existam, respeitando a ordem das FKs
DROP TABLE IF EXISTS ITEM_PECA;
DROP TABLE IF EXISTS ITEM_SERVICO;
DROP TABLE IF EXISTS ORDEM_SERVICO;
DROP TABLE IF EXISTS PECA;
DROP TABLE IF EXISTS SERVICO;
DROP TABLE IF EXISTS MECANICO;
DROP TABLE IF EXISTS VEICULO;
DROP TABLE IF EXISTS CLIENTE;

-- ============================================================
-- 1. TABELA CLIENTE (RN01)
-- ============================================================
CREATE TABLE CLIENTE (
    id_cliente INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf_cnpj VARCHAR(18) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    endereco VARCHAR(150),

    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_cpf_cnpj UNIQUE (cpf_cnpj)
);

-- ============================================================
-- 2. TABELA VEICULO (RN02)
-- ============================================================
CREATE TABLE VEICULO (
    placa VARCHAR(8) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    ano INT,
    id_cliente INT NOT NULL,

    CONSTRAINT pk_veiculo PRIMARY KEY (placa),
    CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente),

    INDEX idx_veiculo_id_cliente (id_cliente)
);

-- ============================================================
-- 3. TABELA MECANICO (RN06, RN07)
-- ============================================================
CREATE TABLE MECANICO (
    id_mecanico INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL,
    especialidade VARCHAR(50) NOT NULL,

    CONSTRAINT pk_mecanico PRIMARY KEY (id_mecanico),
    CONSTRAINT uq_mecanico_cpf UNIQUE (cpf)
);

-- ============================================================
-- 4. TABELA ORDEM_SERVICO
-- RN03, RN04, RN05, RN10, RN11, RN13
-- ============================================================
CREATE TABLE ORDEM_SERVICO (
    id_os INT AUTO_INCREMENT,
    data_abertura DATETIME NOT NULL,
    data_previsao DATETIME,
    data_encerramento DATETIME,
    status VARCHAR(20) NOT NULL DEFAULT 'Orçamento',
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    forma_pagamento VARCHAR(20),
    placa_veiculo VARCHAR(8) NOT NULL,
    id_mecanico INT NOT NULL,

    CONSTRAINT pk_ordem_servico PRIMARY KEY (id_os),

    CONSTRAINT fk_os_veiculo
        FOREIGN KEY (placa_veiculo)
        REFERENCES VEICULO(placa),

    CONSTRAINT fk_os_mecanico
        FOREIGN KEY (id_mecanico)
        REFERENCES MECANICO(id_mecanico),

    CONSTRAINT ck_os_status
        CHECK (status IN (
            'Orçamento',
            'Aprovado',
            'Em Execução',
            'Concluído',
            'Cancelado'
        )),

    CONSTRAINT ck_os_pagamento
        CHECK (
            forma_pagamento IS NULL
            OR forma_pagamento IN (
                'Dinheiro',
                'Cartão de Crédito',
                'Cartão de Débito',
                'PIX'
            )
        ),

    CONSTRAINT ck_os_valor_total
        CHECK (valor_total >= 0),

    INDEX idx_os_placa_veiculo (placa_veiculo),
    INDEX idx_os_id_mecanico (id_mecanico),
    INDEX idx_os_status (status)
);

-- ============================================================
-- 5. TABELA SERVICO (RN08)
-- ============================================================
CREATE TABLE SERVICO (
    id_servico INT AUTO_INCREMENT,
    descricao VARCHAR(100) NOT NULL,
    valor_tabela DECIMAL(10,2) NOT NULL,
    tempo_estimado INT,

    CONSTRAINT pk_servico PRIMARY KEY (id_servico),
    CONSTRAINT ck_servico_valor
        CHECK (valor_tabela >= 0),
    CONSTRAINT ck_servico_tempo
        CHECK (tempo_estimado IS NULL OR tempo_estimado > 0)
);

-- ============================================================
-- 6. TABELA ITEM_SERVICO (RN08, RN15)
-- ============================================================
CREATE TABLE ITEM_SERVICO (
    id_os INT NOT NULL,
    id_servico INT NOT NULL,
    valor_cobrado DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_item_servico PRIMARY KEY (id_os, id_servico),

    CONSTRAINT fk_itemserv_os
        FOREIGN KEY (id_os)
        REFERENCES ORDEM_SERVICO(id_os),

    CONSTRAINT fk_itemserv_servico
        FOREIGN KEY (id_servico)
        REFERENCES SERVICO(id_servico),

    CONSTRAINT ck_itemserv_valor
        CHECK (valor_cobrado >= 0),

    INDEX idx_itemserv_id_servico (id_servico)
);

-- ============================================================
-- 7. TABELA PECA (RN09, RN16)
-- ============================================================
CREATE TABLE PECA (
    id_peca INT AUTO_INCREMENT,
    descricao VARCHAR(100) NOT NULL,
    valor_tabela DECIMAL(10,2) NOT NULL,
    qtd_estoque INT NOT NULL DEFAULT 0,

    CONSTRAINT pk_peca PRIMARY KEY (id_peca),
    CONSTRAINT ck_peca_valor
        CHECK (valor_tabela >= 0),
    CONSTRAINT ck_peca_estoque
        CHECK (qtd_estoque >= 0)
);

-- ============================================================
-- 8. TABELA ITEM_PECA (RN09, RN15, RN16)
-- ============================================================
CREATE TABLE ITEM_PECA (
    id_os INT NOT NULL,
    id_peca INT NOT NULL,
    quantidade INT NOT NULL,
    valor_cobrado DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_item_peca PRIMARY KEY (id_os, id_peca),

    CONSTRAINT fk_itempeca_os
        FOREIGN KEY (id_os)
        REFERENCES ORDEM_SERVICO(id_os),

    CONSTRAINT fk_itempeca_peca
        FOREIGN KEY (id_peca)
        REFERENCES PECA(id_peca),

    CONSTRAINT ck_itempeca_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT ck_itempeca_valor
        CHECK (valor_cobrado >= 0),

    INDEX idx_itempeca_id_peca (id_peca)
);
