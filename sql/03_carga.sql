-- ============================================================
-- RN01-RN20 | Carga de dados para testes
-- 40 registros nas entidades principais e 100+ nas movimentacoes.
-- Execute apos 01_ddl.sql e 02_regras_negocio.sql.
-- ============================================================

USE oficina_mecanica;

-- 40 clientes; email e endereco nulos demonstram atributos opcionais.
INSERT INTO CLIENTE (nome, telefone, email, endereco, tipo_cliente)
WITH RECURSIVE sequencia AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 40
)
SELECT
    CONCAT('Cliente ', LPAD(n, 2, '0')),
    CONCAT('(61) 9', LPAD(8000 + n, 4, '0'), '-', LPAD(1000 + n, 4, '0')),
    CASE WHEN n % 7 = 0 THEN NULL ELSE CONCAT('cliente', n, '@exemplo.com') END,
    CASE WHEN n % 9 = 0 THEN NULL ELSE CONCAT('Endereco ', n, ', Brasilia - DF') END,
    CASE WHEN n <= 30 THEN 'Física' ELSE 'Jurídica' END
FROM sequencia;

-- 30 especializacoes de pessoa fisica.
INSERT INTO PESSOA_FISICA (id_cliente, cpf, rg, data_nasc)
WITH RECURSIVE sequencia AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 30
)
SELECT
    n,
    CONCAT('111.222.', LPAD(n, 3, '0'), '-', LPAD(n, 2, '0')),
    CONCAT('RG-', LPAD(n, 7, '0')),
    DATE_ADD('1975-01-01', INTERVAL n * 365 DAY)
FROM sequencia;

-- 10 especializacoes de pessoa juridica.
INSERT INTO PESSOA_JURIDICA (id_cliente, cnpj, razao_social, inscricao_estadual)
WITH RECURSIVE sequencia AS (
    SELECT 31 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 40
)
SELECT
    n,
    CONCAT('12.345.', LPAD(n, 3, '0'), '/0001-', LPAD(n, 2, '0')),
    CONCAT('Empresa Cliente ', n, ' LTDA'),
    CONCAT('IE-', LPAD(n, 12, '0'))
FROM sequencia;

-- 60 veiculos vinculados aos clientes.
INSERT INTO VEICULO (placa, modelo, marca, ano_fabricacao, cor, id_cliente)
WITH RECURSIVE sequencia AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 60
)
SELECT
    CONCAT('A', LPAD(n, 3, '0'), 'B', LPAD(n, 2, '0')),
    CONCAT('Modelo ', n),
    CASE n % 4
        WHEN 0 THEN 'Honda'
        WHEN 1 THEN 'Chevrolet'
        WHEN 2 THEN 'Toyota'
        ELSE 'Volkswagen'
    END,
    CASE WHEN n % 11 = 0 THEN NULL ELSE 2010 + (n % 16) END,
    CASE WHEN n % 10 = 0 THEN NULL ELSE ELT(n % 6 + 1, 'Preto', 'Branco', 'Prata', 'Azul', 'Vermelho', 'Cinza') END,
    ((n - 1) % 40) + 1
FROM sequencia;

-- 40 fornecedores.
INSERT INTO FORNECEDOR (cnpj, nome_fantasia, telefone, email)
WITH RECURSIVE sequencia AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 40
)
SELECT
    CONCAT('55.666.', LPAD(n, 3, '0'), '/0001-', LPAD(n, 2, '0')),
    CONCAT('Fornecedor ', n),
    CONCAT('(61) 9', LPAD(7000 + n, 4, '0'), '-', LPAD(2000 + n, 4, '0')),
    CASE WHEN n % 8 = 0 THEN NULL ELSE CONCAT('fornecedor', n, '@exemplo.com') END
FROM sequencia;

-- 40 pecas, todas com estoque suficiente para os cenarios de consumo.
INSERT INTO PECA (codigo_barras, descricao, preco_unitario, quantidade_estoque, id_fornecedor)
WITH RECURSIVE sequencia AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 40
)
SELECT
    CONCAT('789000000', LPAD(n, 4, '0')),
    CONCAT('Peca de teste ', n),
    ROUND(25 + n * 4.75, 2),
    500,
    n
FROM sequencia;

-- 40 mecanicos; o primeiro e supervisor e os demais sao subordinados a ele.
INSERT INTO MECANICO (nome, cpf, especialidade, valor_hora, id_supervisor)
VALUES ('Mecanico 01', '333.444.000-01', 'Gestao Tecnica', 120.00, NULL);

INSERT INTO MECANICO (nome, cpf, especialidade, valor_hora, id_supervisor)
WITH RECURSIVE sequencia AS (
    SELECT 2 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 40
)
SELECT
    CONCAT('Mecanico ', LPAD(n, 2, '0')),
    CONCAT('333.444.', LPAD(n, 3, '0'), '-', LPAD(n, 2, '0')),
    ELT(n % 5 + 1, 'Motor', 'Suspensão', 'Freios', 'Elétrica', 'Injeção Eletrônica'),
    ROUND(70 + n * 2.5, 2),
    1
FROM sequencia;

-- 40 servicos; alguns nao possuem tempo estimado informado.
INSERT INTO SERVICO (descricao, valor_tabela_padrao, tempo_estimado_horas)
WITH RECURSIVE sequencia AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 40
)
SELECT
    CONCAT('Servico de manutencao ', n),
    ROUND(100 + n * 7.50, 2),
    CASE WHEN n % 10 = 0 THEN NULL ELSE (n % 5) + 1 END
FROM sequencia;

-- 100 OS inicialmente abertas em Orcamento; o historico inicial e criado por trigger.
INSERT INTO ORDEM_SERVICO (
    data_abertura,
    data_previsao,
    status,
    id_veiculo,
    id_mecanico
)
WITH RECURSIVE sequencia AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 100
)
SELECT
    DATE_ADD('2026-01-01 08:00:00', INTERVAL n DAY),
    DATE_ADD('2026-01-04 18:00:00', INTERVAL n DAY),
    'Orçamento',
    ((n - 1) % 60) + 1,
    ((n - 1) % 40) + 1
FROM sequencia;

-- 200 itens de servico com valores congelados (dois por OS).
INSERT INTO ITEM_SERVICO (id_os, id_servico, valor_cobrado)
WITH RECURSIVE sequencia AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 100
)
SELECT n, ((n - 1) % 40) + 1, ROUND(100 + (((n - 1) % 40) + 1) * 7.50, 2)
FROM sequencia
UNION ALL
SELECT n, ((n + 12) % 40) + 1, ROUND(100 + (((n + 12) % 40) + 1) * 7.50, 2)
FROM sequencia;

-- 200 itens de peca com quantidade e preco congelados (dois por OS).
INSERT INTO ITEM_PECA (id_os, id_peca, quantidade, valor_cobrado)
WITH RECURSIVE sequencia AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequencia WHERE n < 100
)
SELECT
    n,
    ((n + 4) % 40) + 1,
    (n % 3) + 1,
    ROUND(25 + (((n + 4) % 40) + 1) * 4.75, 2)
FROM sequencia
UNION ALL
SELECT
    n,
    ((n + 21) % 40) + 1,
    ((n + 1) % 3) + 1,
    ROUND(25 + (((n + 21) % 40) + 1) * 4.75, 2)
FROM sequencia;

-- 70 OS aprovadas, gerando segundo evento no historico.
UPDATE ORDEM_SERVICO
SET status = 'Aprovado',
    data_aprovacao = DATE_ADD(data_abertura, INTERVAL 1 HOUR)
WHERE id_os BETWEEN 1 AND 70;

-- 50 OS em execucao, gerando terceiro evento no historico.
UPDATE ORDEM_SERVICO
SET status = 'Em Execução'
WHERE id_os BETWEEN 1 AND 50;

-- 35 OS concluidas com forma de pagamento e data de conclusao.
UPDATE ORDEM_SERVICO
SET forma_pagamento = ELT((id_os % 4) + 1, 'Dinheiro', 'Cartão de Crédito', 'Cartão de Débito', 'PIX'),
    data_conclusao = DATE_ADD(data_abertura, INTERVAL 2 DAY)
WHERE id_os BETWEEN 1 AND 35;

UPDATE ORDEM_SERVICO
SET status = 'Concluído'
WHERE id_os BETWEEN 1 AND 35;

-- 10 OS canceladas diretamente a partir do Orcamento.
UPDATE ORDEM_SERVICO
SET status = 'Cancelado'
WHERE id_os BETWEEN 91 AND 100;

-- 35 garantias de 90 dias para as OS concluidas.
INSERT INTO GARANTIA (data_inicio, data_fim, termos, id_os)
SELECT
    DATE(data_conclusao),
    DATE_ADD(DATE(data_conclusao), INTERVAL 90 DAY),
    'Garantia legal de 90 dias para servicos e pecas aplicadas.',
    id_os
FROM ORDEM_SERVICO
WHERE status = 'Concluído';

-- A tabela HISTORICO_STATUS_OS e preenchida automaticamente pelos triggers.
