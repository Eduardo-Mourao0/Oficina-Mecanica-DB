-- ============================================================
-- CONSULTAS BÁSICAS
-- ============================================================

-- 01. Quais são todos os clientes cadastrados na oficina?
SELECT *
FROM CLIENTE;


-- 02. Quais são os veículos cadastrados, mostrando placa, modelo, marca e ano?
SELECT placa, modelo, marca, ano
FROM VEICULO;


-- 03. Quais são os mecânicos cadastrados e suas respectivas especialidades?
SELECT nome, especialidade
FROM MECANICO;


-- 04. Quais ordens de serviço estão atualmente com status "Em Execução"?
SELECT id_os, placa_veiculo, data_abertura, status
FROM ORDEM_SERVICO
WHERE status = 'Em Execução';


-- 05. Quais peças possuem quantidade disponível em estoque?
SELECT descricao, qtd_estoque
FROM PECA
WHERE qtd_estoque > 0;


-- ============================================================
-- CONSULTAS INTERMEDIÁRIAS
-- ============================================================

-- 06. Quais ordens de serviço pertencem a cada cliente, mostrando o cliente, o veículo e o status da OS?
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
    ON os.placa_veiculo = v.placa;


-- 07. Quantas ordens de serviço cada mecânico possui?
SELECT
    m.nome AS mecanico,
    COUNT(os.id_os) AS quantidade_os
FROM MECANICO m
JOIN ORDEM_SERVICO os
    ON os.id_mecanico = m.id_mecanico
GROUP BY m.id_mecanico, m.nome;


-- 08. Qual é o valor total gasto em peças em cada ordem de serviço?
SELECT
    id_os,
    SUM(quantidade * valor_cobrado) AS total_pecas
FROM ITEM_PECA
GROUP BY id_os;


-- 09. Quais serviços foram realizados em cada ordem de serviço e qual foi o valor cobrado?
SELECT
    os.id_os,
    s.descricao AS servico,
    isv.valor_cobrado
FROM ORDEM_SERVICO os
JOIN ITEM_SERVICO isv
    ON isv.id_os = os.id_os
JOIN SERVICO s
    ON s.id_servico = isv.id_servico;


-- 10. Quais mecânicos possuem mais de uma ordem de serviço atribuída?
SELECT
    m.nome AS mecanico,
    COUNT(os.id_os) AS quantidade_os
FROM MECANICO m
JOIN ORDEM_SERVICO os
    ON os.id_mecanico = m.id_mecanico
GROUP BY m.id_mecanico, m.nome
HAVING COUNT(os.id_os) > 1;


-- ============================================================
-- CONSULTAS AVANÇADAS
-- ============================================================

-- 11. Quais ordens de serviço possuem valor total superior à média das ordens de serviço?
SELECT id_os, valor_total
FROM ORDEM_SERVICO
WHERE valor_total > (
    SELECT AVG(valor_total)
    FROM ORDEM_SERVICO
);


-- 12. Qual é o valor total das ordens de serviço concluídas sob responsabilidade de cada mecânico?
SELECT
    m.nome AS mecanico,
    SUM(os.valor_total) AS valor_total
FROM MECANICO m
JOIN ORDEM_SERVICO os
    ON os.id_mecanico = m.id_mecanico
WHERE os.status = 'Concluído'
GROUP BY m.id_mecanico, m.nome;


-- 13. Quais peças possuem quantidade em estoque abaixo da média?
SELECT descricao, qtd_estoque
FROM PECA
WHERE qtd_estoque < (
    SELECT AVG(qtd_estoque)
    FROM PECA
);


-- 14. Quais veículos possuem mais de uma ordem de serviço concluída?
SELECT
    v.placa,
    v.modelo,
    v.marca,
    COUNT(os.id_os) AS quantidade_manutencoes
FROM VEICULO v
JOIN ORDEM_SERVICO os
    ON os.placa_veiculo = v.placa
WHERE os.status = 'Concluído'
GROUP BY v.placa, v.modelo, v.marca
HAVING COUNT(os.id_os) > 1;


-- 15. Qual é o ranking dos mecânicos pelo valor total das ordens de serviço concluídas?
SELECT 
    m.nome AS mecanico,
    SUM(os.valor_total) AS valor_total
FROM MECANICO m
JOIN ORDEM_SERVICO os
    ON os.id_mecanico = m.id_mecanico
WHERE os.status = 'Concluído'
GROUP BY m.id_mecanico, m.nome
ORDER BY valor_total DESC;
