-- ============================================================
-- CONSULTAS BASICAS
-- ============================================================

-- 01. Quais sao todos os clientes cadastrados na oficina?
SELECT *
FROM CLIENTE;

-- 02. Quais sao os veiculos cadastrados, mostrando placa, modelo, marca e ano?
SELECT placa, modelo, marca, ano_fabricacao
FROM VEICULO;

-- 03. Quais sao os mecanicos cadastrados e suas respectivas especialidades?
SELECT nome, especialidade
FROM MECANICO;

-- 04. Quais ordens de servico estao atualmente em execucao?
SELECT id_os, id_veiculo, data_abertura, status
FROM ORDEM_SERVICO
WHERE status = 'Em Execucao';

-- 05. Quais pecas possuem quantidade disponivel em estoque?
SELECT descricao, quantidade_estoque
FROM PECA
WHERE quantidade_estoque > 0;

-- ============================================================
-- CONSULTAS INTERMEDIARIAS
-- ============================================================

-- 06. Quais ordens de servico pertencem a cada cliente?
SELECT
    c.nome AS cliente,
    v.placa,
    v.modelo,
    os.id_os,
    os.status
FROM CLIENTE c
JOIN VEICULO v
    ON v.id_cliente = c.id_cliente
JOIN ORDEM_SERVICO os
    ON os.id_veiculo = v.id_veiculo;

-- 07. Quantas ordens de servico cada mecanico possui?
SELECT
    m.nome AS mecanico,
    COUNT(os.id_os) AS quantidade_os
FROM MECANICO m
JOIN ORDEM_SERVICO os
    ON os.id_mecanico = m.id_mecanico
GROUP BY m.id_mecanico, m.nome;

-- 08. Qual e o valor total das pecas utilizadas em cada ordem de servico?
SELECT
    ip.id_os,
    SUM(p.preco_unitario) AS total_pecas
FROM ITEM_PECA ip
JOIN PECA p
    ON p.id_peca = ip.id_peca
GROUP BY ip.id_os;

-- 09. Quais servicos foram realizados em cada ordem de servico?
SELECT
    os.id_os,
    s.descricao AS servico,
    s.valor_tabela_padrao
FROM ORDEM_SERVICO os
JOIN ITEM_SERVICO isv
    ON isv.id_os = os.id_os
JOIN SERVICO s
    ON s.id_servico = isv.id_servico;

-- 10. Quais mecanicos possuem mais de uma ordem de servico atribuida?
SELECT
    m.nome AS mecanico,
    COUNT(os.id_os) AS quantidade_os
FROM MECANICO m
JOIN ORDEM_SERVICO os
    ON os.id_mecanico = m.id_mecanico
GROUP BY m.id_mecanico, m.nome
HAVING COUNT(os.id_os) > 1;

-- ============================================================
-- CONSULTAS AVANCADAS
-- ============================================================

-- 11. Quais ordens de servico possuem valor total superior a media?
SELECT id_os, valor_total
FROM ORDEM_SERVICO
WHERE valor_total > (
    SELECT AVG(valor_total)
    FROM ORDEM_SERVICO
);

-- 12. Qual e o valor total das OS concluidas sob responsabilidade de cada mecanico?
SELECT
    m.nome AS mecanico,
    SUM(os.valor_total) AS valor_total
FROM MECANICO m
JOIN ORDEM_SERVICO os
    ON os.id_mecanico = m.id_mecanico
WHERE os.status = 'Concluido'
GROUP BY m.id_mecanico, m.nome;

-- 13. Quais pecas possuem quantidade em estoque abaixo da media?
SELECT descricao, quantidade_estoque
FROM PECA
WHERE quantidade_estoque < (
    SELECT AVG(quantidade_estoque)
    FROM PECA
);

-- 14. Quais veiculos possuem mais de uma ordem de servico concluida?
SELECT
    v.placa,
    v.modelo,
    v.marca,
    COUNT(os.id_os) AS quantidade_manutencoes
FROM VEICULO v
JOIN ORDEM_SERVICO os
    ON os.id_veiculo = v.id_veiculo
WHERE os.status = 'Concluido'
GROUP BY v.id_veiculo, v.placa, v.modelo, v.marca
HAVING COUNT(os.id_os) > 1;

-- 15. Qual e o ranking dos mecanicos pelo valor total das OS concluidas?
SELECT
    m.nome AS mecanico,
    SUM(os.valor_total) AS valor_total
FROM MECANICO m
JOIN ORDEM_SERVICO os
    ON os.id_mecanico = m.id_mecanico
WHERE os.status = 'Concluido'
GROUP BY m.id_mecanico, m.nome
ORDER BY valor_total DESC;
