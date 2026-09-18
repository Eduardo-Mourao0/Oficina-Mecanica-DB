-- ============================================================
-- Povoamento inicial com dados ficticios para testes
-- ============================================================

USE oficina_mecanica;

-- ============================================================
-- CLIENTES E ESPECIALIZACOES
-- ============================================================
INSERT INTO CLIENTE (nome, telefone, email, endereco, tipo_cliente) VALUES
('Carlos Eduardo Silva', '(61) 98888-1111', 'carlos@email.com', 'Asa Norte CLN 204, Brasilia - DF', 'Pessoa Fisica'),
('Mariana Souza Lima', '(61) 99999-2222', 'mariana@email.com', 'Aguas Claras, Brasilia - DF', 'Pessoa Fisica'),
('Auto Pecas e Transportes LTDA', '(61) 3333-4444', 'contato@autopecas.com', 'SIA Trecho 3, Brasilia - DF', 'Pessoa Juridica');

INSERT INTO PESSOA_FISICA (id_cliente, cpf, rg, data_nasc) VALUES
(1, '123.456.789-00', '1234567-SSP/DF', '1985-05-12'),
(2, '987.654.321-11', '7654321-SSP/DF', '1990-10-24');

INSERT INTO PESSOA_JURIDICA (id_cliente, cnpj, razao_social, inscricao_estadual) VALUES
(3, '12.345.678/0001-99', 'Auto Pecas e Transportes LTDA', '07345678001-20');

-- ============================================================
-- VEICULOS
-- ============================================================
INSERT INTO VEICULO (placa, modelo, marca, ano_fabricacao, cor, id_cliente) VALUES
('ABC1D23', 'Civic 2.0', 'Honda', 2020, 'Prata', 1),
('XYZ9K88', 'Onix 1.0 Turbo', 'Chevrolet', 2022, 'Branco', 2),
('JHK4M55', 'Corolla 2.0', 'Toyota', 2019, 'Preto', 3);

-- ============================================================
-- FORNECEDORES E PECAS
-- ============================================================
INSERT INTO FORNECEDOR (cnpj, nome_fantasia, telefone, email) VALUES
('11.222.333/0001-44', 'Distribuidora Brasil', '(61) 3222-1000', 'vendas@distribuidorabrasil.com'),
('55.666.777/0001-88', 'Pecas Express', '(61) 3333-2000', 'contato@pecasexpress.com');

INSERT INTO PECA (codigo_barras, descricao, preco_unitario, quantidade_estoque, id_fornecedor) VALUES
('7891000000011', 'Oleo Sintetico 5W30 (Litro)', 45.00, 50, 1),
('7891000000028', 'Filtro de Oleo', 35.00, 30, 1),
('7891000000035', 'Jogo de Pastilhas de Freio Dianteira', 180.00, 15, 2);

-- ============================================================
-- MECANICOS
-- ============================================================
INSERT INTO MECANICO (nome, cpf, especialidade, valor_hora, id_supervisor) VALUES
('Roberto Alves', '111.222.333-44', 'Motor e Injecao Eletronica', 95.00, NULL),
('Fernando Costa', '555.666.777-88', 'Suspensao e Freios', 85.00, 1);

-- ============================================================
-- CATALOGO DE SERVICOS
-- ============================================================
INSERT INTO SERVICO (descricao, valor_tabela_padrao, tempo_estimado_horas) VALUES
('Troca de Oleo e Filtro', 150.00, 1),
('Alinhamento e Balanceamento', 120.00, 1),
('Revisao do Sistema de Freios', 250.00, 2);

-- ============================================================
-- ORDENS DE SERVICO
-- ============================================================
INSERT INTO ORDEM_SERVICO (
    data_abertura,
    data_previsao,
    data_conclusao,
    status,
    valor_total,
    id_veiculo,
    id_mecanico
) VALUES
('2026-03-01 08:30:00', '2026-03-01 12:00:00', '2026-03-01 11:45:00', 'Concluido', 350.00, 1, 1),
('2026-03-02 10:00:00', '2026-03-02 17:00:00', NULL, 'Em Execucao', 430.00, 2, 2);

-- ============================================================
-- RELACOES CONTEM E UTILIZA
-- ============================================================
INSERT INTO ITEM_SERVICO (id_os, id_servico) VALUES
(1, 1),
(1, 2),
(2, 3);

INSERT INTO ITEM_PECA (id_os, id_peca) VALUES
(1, 1),
(1, 2),
(2, 3);

-- ============================================================
-- GARANTIAS E HISTORICO DE STATUS
-- ============================================================
INSERT INTO GARANTIA (data_inicio, data_fim, termos, id_os) VALUES
('2026-03-01', '2026-06-01', 'Garantia de 90 dias para servicos e pecas aplicadas.', 1);

INSERT INTO HISTORICO_STATUS_OS (
    id_os,
    id_historico,
    data_mudanca,
    status_anterior,
    status_novo,
    observacao
) VALUES
(1, 1, '2026-03-01 08:30:00', NULL, 'Orcamento', 'Ordem de servico aberta.'),
(1, 2, '2026-03-01 09:00:00', 'Orcamento', 'Aprovado', 'Orcamento aprovado pelo cliente.'),
(1, 3, '2026-03-01 11:45:00', 'Aprovado', 'Concluido', 'Servico finalizado.'),
(2, 1, '2026-03-02 10:00:00', NULL, 'Em Execucao', 'Servico em andamento.');
