-- ============================================================
-- Consultas de negocio para o Sistema de Gestao de Oficina
-- Execute apos 01_ddl.sql, 02_regras_negocio.sql e 03_carga.sql.
-- ============================================================

USE oficina_mecanica;

-- 01. Quais clientes possuem "Cliente 0" no nome? (LIKE)
SELECT id_cliente, nome, telefone, email
FROM CLIENTE
WHERE nome LIKE 'Cliente 0%';

-- 02. Quais veiculos foram fabricados entre 2015 e 2020? (BETWEEN)
SELECT placa, modelo, marca, ano_fabricacao
FROM VEICULO
WHERE ano_fabricacao BETWEEN 2015 AND 2020;

-- 03. Quais mecanicos atuam em Motor, Freios ou Eletrica? (IN)
SELECT nome, especialidade, valor_hora
FROM MECANICO
WHERE especialidade IN ('Motor', 'Freios', 'Elétrica');

-- 04. Quais OS ainda nao foram concluidas? (IS NULL)
SELECT id_os, status, data_abertura, data_previsao
FROM ORDEM_SERVICO
WHERE data_conclusao IS NULL;

-- 05. Quais pecas ainda possuem estoque disponivel?
SELECT descricao, quantidade_estoque, preco_unitario
FROM PECA
WHERE quantidade_estoque > 0
ORDER BY quantidade_estoque;

-- 06. Quais OS pertencem a cada cliente, com veiculo e mecanico responsavel?
SELECT
    c.nome AS cliente,
    v.placa,
    os.id_os,
    os.status,
    m.nome AS mecanico_responsavel
FROM CLIENTE c
JOIN VEICULO v ON v.id_cliente = c.id_cliente
JOIN ORDEM_SERVICO os ON os.id_veiculo = v.id_veiculo
JOIN MECANICO m ON m.id_mecanico = os.id_mecanico
ORDER BY c.nome, os.id_os;

-- 07. Quais mecanicos ainda nao possuem OS atribuida? (LEFT JOIN)
SELECT m.id_mecanico, m.nome, m.especialidade
FROM MECANICO m
LEFT JOIN ORDEM_SERVICO os ON os.id_mecanico = m.id_mecanico
WHERE os.id_os IS NULL;

-- 08. Qual e o valor total de pecas utilizadas em cada OS?
SELECT
    ip.id_os,
    SUM(ip.quantidade * ip.valor_cobrado) AS total_pecas
FROM ITEM_PECA ip
GROUP BY ip.id_os
ORDER BY ip.id_os;

-- 09. Quais servicos foram realizados em cada OS e qual foi o valor congelado?
SELECT
    isv.id_os,
    s.descricao AS servico,
    isv.valor_cobrado
FROM ITEM_SERVICO isv
JOIN SERVICO s ON s.id_servico = isv.id_servico
ORDER BY isv.id_os, s.descricao;

-- 10. Quais OS concluidas foram quitadas por PIX ou cartao? (IN)
SELECT id_os, valor_total, forma_pagamento, data_conclusao
FROM ORDEM_SERVICO
WHERE status = 'Concluído'
  AND forma_pagamento IN ('PIX', 'Cartão de Crédito', 'Cartão de Débito');

-- 11. Quais OS superam a media de valor do respectivo mecanico? (subconsulta correlacionada)
SELECT os.id_os, m.nome AS mecanico, os.valor_total
FROM ORDEM_SERVICO os
JOIN MECANICO m ON m.id_mecanico = os.id_mecanico
WHERE os.valor_total > (
    SELECT AVG(os_media.valor_total)
    FROM ORDEM_SERVICO os_media
    WHERE os_media.id_mecanico = os.id_mecanico
)
ORDER BY m.nome, os.valor_total DESC;

-- 12. Qual o faturamento das OS concluidas por mecanico?
SELECT
    m.nome AS mecanico,
    COUNT(os.id_os) AS os_concluidas,
    SUM(os.valor_total) AS faturamento
FROM MECANICO m
JOIN ORDEM_SERVICO os ON os.id_mecanico = m.id_mecanico
WHERE os.status = 'Concluído'
GROUP BY m.id_mecanico, m.nome
ORDER BY faturamento DESC;

-- 13. Quais pecas estao com estoque abaixo da media do catalogo?
SELECT descricao, quantidade_estoque
FROM PECA
WHERE quantidade_estoque < (
    SELECT AVG(quantidade_estoque)
    FROM PECA
)
ORDER BY quantidade_estoque;

-- 14. Quais veiculos possuem ao menos uma OS concluida? (EXISTS)
SELECT v.placa, v.modelo, v.marca
FROM VEICULO v
WHERE EXISTS (
    SELECT 1
    FROM ORDEM_SERVICO os
    WHERE os.id_veiculo = v.id_veiculo
      AND os.status = 'Concluído'
)
ORDER BY v.placa;

-- 15. Qual e o ranking dos mecanicos pelo faturamento de OS concluidas?
SELECT
    m.nome AS mecanico,
    SUM(os.valor_total) AS faturamento
FROM MECANICO m
JOIN ORDEM_SERVICO os ON os.id_mecanico = m.id_mecanico
WHERE os.status = 'Concluído'
GROUP BY m.id_mecanico, m.nome
ORDER BY faturamento DESC, m.nome;
