-- ============================================================
-- Povoamento inicial com dados fictícios para testes
-- ============================================================

USE oficina_mecanica;

-- ============================================================
-- CLIENTES
-- ============================================================
INSERT INTO CLIENTE (nome, cpf_cnpj, telefone, endereco) VALUES
('Carlos Eduardo Silva', '123.456.789-00', '(61) 98888-1111', 'Asa Norte CLN 204, Brasília - DF'),
('Mariana Souza Lima', '987.654.321-11', '(61) 99999-2222', 'Águas Claras Av. Castanheiras, Brasília - DF'),
('Auto Peças & Transportes LTDA', '12.345.678/0001-99', '(61) 3333-4444', 'SIA Trecho 3, Brasília - DF');

-- ============================================================
-- VEÍCULOS
-- ============================================================
INSERT INTO VEICULO (placa, modelo, marca, ano, id_cliente) VALUES
('ABC1D23', 'Civic 2.0', 'Honda', 2020, 1),
('XYZ9K88', 'Onix 1.0 Turbo', 'Chevrolet', 2022, 2),
('JHK4M55', 'Corolla 2.0', 'Toyota', 2019, 3);

-- ============================================================
-- MECÂNICOS
-- ============================================================
INSERT INTO MECANICO (nome, cpf, especialidade) VALUES
('Roberto Alves', '111.222.333-44', 'Motor e Injeção Eletrônica'),
('Fernando Costa', '555.666.777-88', 'Suspensão e Freios');

-- ============================================================
-- CATÁLOGO DE SERVIÇOS
-- ============================================================
INSERT INTO SERVICO (descricao, valor_tabela, tempo_estimado) VALUES
('Troca de Óleo e Filtro', 150.00, 45),
('Alinhamento e Balanceamento', 120.00, 60),
('Revisão do Sistema de Freios', 250.00, 90);

-- ============================================================
-- CATÁLOGO DE PEÇAS
-- ============================================================
INSERT INTO PECA (descricao, valor_tabela, qtd_estoque) VALUES
('Óleo Sintético 5W30 (Litro)', 45.00, 50),
('Filtro de Óleo', 35.00, 30),
('Jogo de Pastilhas de Freio Dianteira', 180.00, 15);

-- ============================================================
-- ORDENS DE SERVIÇO
-- Os valores totais foram ajustados para corresponder à soma
-- dos serviços e das peças cadastradas em cada OS.
-- ============================================================
INSERT INTO ORDEM_SERVICO (
    data_abertura,
    data_previsao,
    data_encerramento,
    status,
    valor_total,
    forma_pagamento,
    placa_veiculo,
    id_mecanico
) VALUES
(
    '2026-03-01 08:30:00',
    '2026-03-01 12:00:00',
    '2026-03-01 11:45:00',
    'Concluído',
    395.00,
    'PIX',
    'ABC1D23',
    1
),
(
    '2026-03-02 10:00:00',
    '2026-03-02 17:00:00',
    NULL,
    'Em Execução',
    430.00,
    NULL,
    'XYZ9K88',
    2
);

-- ============================================================
-- ITENS DE SERVIÇOS DAS ORDENS DE SERVIÇO
-- ============================================================
INSERT INTO ITEM_SERVICO (id_os, id_servico, valor_cobrado) VALUES
(1, 1, 150.00),
(1, 2, 120.00),
(2, 3, 250.00);

-- ============================================================
-- ITENS DE PEÇAS DAS ORDENS DE SERVIÇO
-- ============================================================
INSERT INTO ITEM_PECA (id_os, id_peca, quantidade, valor_cobrado) VALUES
(1, 1, 2, 45.00),
(1, 2, 1, 35.00),
(2, 3, 1, 180.00);
