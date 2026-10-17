-- ============================================================
-- RN01-RN20 | Regras operacionais, procedimentos e triggers
-- Execute apos 01_ddl.sql e antes de 03_carga.sql.
-- ============================================================

USE oficina_mecanica;

-- Permite reexecucao do script de regras apos uma nova criacao do esquema.
DROP TRIGGER IF EXISTS trg_pessoa_fisica_bi;
DROP TRIGGER IF EXISTS trg_pessoa_juridica_bi;
DROP TRIGGER IF EXISTS trg_cliente_bu;
DROP TRIGGER IF EXISTS trg_os_bi;
DROP TRIGGER IF EXISTS trg_os_bu;
DROP TRIGGER IF EXISTS trg_os_bd;
DROP TRIGGER IF EXISTS trg_os_ai;
DROP TRIGGER IF EXISTS trg_os_au;
DROP TRIGGER IF EXISTS trg_item_servico_bi;
DROP TRIGGER IF EXISTS trg_item_servico_bu;
DROP TRIGGER IF EXISTS trg_item_servico_bd;
DROP TRIGGER IF EXISTS trg_item_servico_ai;
DROP TRIGGER IF EXISTS trg_item_servico_au;
DROP TRIGGER IF EXISTS trg_item_servico_ad;
DROP TRIGGER IF EXISTS trg_item_peca_bi;
DROP TRIGGER IF EXISTS trg_item_peca_bu;
DROP TRIGGER IF EXISTS trg_item_peca_bd;
DROP TRIGGER IF EXISTS trg_item_peca_ai;
DROP TRIGGER IF EXISTS trg_item_peca_au;
DROP TRIGGER IF EXISTS trg_item_peca_ad;
DROP TRIGGER IF EXISTS trg_garantia_bi;
DROP TRIGGER IF EXISTS trg_historico_bu;
DROP TRIGGER IF EXISTS trg_historico_bd;
DROP PROCEDURE IF EXISTS sp_recalcular_valor_total;
DROP PROCEDURE IF EXISTS sp_validar_os_editavel;

DELIMITER //

-- RN01: impede que uma pessoa fisica seja cadastrada para cliente juridico.
CREATE TRIGGER trg_pessoa_fisica_bi
BEFORE INSERT ON PESSOA_FISICA
FOR EACH ROW
BEGIN
    DECLARE v_tipo_cliente VARCHAR(20);

    SELECT tipo_cliente INTO v_tipo_cliente
    FROM CLIENTE
    WHERE id_cliente = NEW.id_cliente;

    IF v_tipo_cliente <> 'Física' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pessoa fisica exige cliente do tipo Física.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM PESSOA_JURIDICA WHERE id_cliente = NEW.id_cliente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cliente nao pode ser pessoa fisica e juridica.';
    END IF;
END//

-- RN01: impede que uma pessoa juridica seja cadastrada para cliente fisico.
CREATE TRIGGER trg_pessoa_juridica_bi
BEFORE INSERT ON PESSOA_JURIDICA
FOR EACH ROW
BEGIN
    DECLARE v_tipo_cliente VARCHAR(20);

    SELECT tipo_cliente INTO v_tipo_cliente
    FROM CLIENTE
    WHERE id_cliente = NEW.id_cliente;

    IF v_tipo_cliente <> 'Jurídica' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pessoa juridica exige cliente do tipo Jurídica.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM PESSOA_FISICA WHERE id_cliente = NEW.id_cliente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cliente nao pode ser pessoa fisica e juridica.';
    END IF;
END//

-- RN01: o tipo do cliente nao pode mudar depois da especializacao cadastrada.
CREATE TRIGGER trg_cliente_bu
BEFORE UPDATE ON CLIENTE
FOR EACH ROW
BEGIN
    IF OLD.tipo_cliente <> NEW.tipo_cliente THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O tipo do cliente nao pode ser alterado.';
    END IF;
END//

-- RN10: centraliza o recalculo do total a partir dos valores congelados dos itens.
CREATE PROCEDURE sp_recalcular_valor_total(IN p_id_os INT)
BEGIN
    UPDATE ORDEM_SERVICO os
    SET os.valor_total = (
        SELECT COALESCE(SUM(isv.valor_cobrado), 0)
        FROM ITEM_SERVICO isv
        WHERE isv.id_os = p_id_os
    ) + (
        SELECT COALESCE(SUM(ip.quantidade * ip.valor_cobrado), 0)
        FROM ITEM_PECA ip
        WHERE ip.id_os = p_id_os
    )
    WHERE os.id_os = p_id_os;
END//

-- RN03, RN04 e RN11: uma OS inicia obrigatoriamente em Orcamento.
CREATE TRIGGER trg_os_bi
BEFORE INSERT ON ORDEM_SERVICO
FOR EACH ROW
BEGIN
    IF NEW.status <> 'Orçamento' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uma OS deve ser aberta com status Orçamento.';
    END IF;

    SET NEW.valor_total = 0.00;
    SET NEW.data_aprovacao = NULL;
    SET NEW.data_conclusao = NULL;
    SET NEW.forma_pagamento = NULL;
END//

-- RN11-RN13 e RN17: controla o ciclo de vida e protege OS concluida.
CREATE TRIGGER trg_os_bu
BEFORE UPDATE ON ORDEM_SERVICO
FOR EACH ROW
BEGIN
    IF OLD.status = 'Concluído' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uma OS concluida nao pode ser alterada.';
    END IF;

    IF OLD.status = 'Cancelado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uma OS cancelada nao pode ser alterada.';
    END IF;

    IF NEW.status <> OLD.status THEN
        IF NOT (
            (OLD.status = 'Orçamento' AND NEW.status IN ('Aprovado', 'Cancelado'))
            OR (OLD.status = 'Aprovado' AND NEW.status IN ('Em Execução', 'Cancelado'))
            OR (OLD.status = 'Em Execução' AND NEW.status IN ('Concluído', 'Cancelado'))
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Transicao de status invalida para a OS.';
        END IF;

        IF NEW.status = 'Aprovado' AND NEW.data_aprovacao IS NULL THEN
            SET NEW.data_aprovacao = CURRENT_TIMESTAMP;
        END IF;

        IF NEW.status = 'Em Execução' AND NEW.data_aprovacao IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A execucao exige aprovacao previa registrada.';
        END IF;

        IF NEW.status = 'Concluído' THEN
            IF NEW.data_aprovacao IS NULL
                OR NEW.data_conclusao IS NULL
                OR NEW.forma_pagamento IS NULL THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Conclusao exige aprovacao, data e forma de pagamento.';
            END IF;
        END IF;
    END IF;
END//

-- RN17: nao permite excluir uma OS concluida, preservando o historico de manutencao.
CREATE TRIGGER trg_os_bd
BEFORE DELETE ON ORDEM_SERVICO
FOR EACH ROW
BEGIN
    IF OLD.status = 'Concluído' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Uma OS concluida nao pode ser excluida.';
    END IF;
END//

-- RN14 e RN20: registra a abertura da OS no historico imutavel.
CREATE TRIGGER trg_os_ai
AFTER INSERT ON ORDEM_SERVICO
FOR EACH ROW
BEGIN
    INSERT INTO HISTORICO_STATUS_OS (
        id_os,
        data_mudanca,
        status_anterior,
        status_novo,
        observacao,
        id_mecanico_responsavel
    ) VALUES (
        NEW.id_os,
        NEW.data_abertura,
        NULL,
        NEW.status,
        'OS aberta.',
        NEW.id_mecanico
    );
END//

-- RN14 e RN20: registra cada transicao de status e seu mecanico responsavel.
CREATE TRIGGER trg_os_au
AFTER UPDATE ON ORDEM_SERVICO
FOR EACH ROW
BEGIN
    IF NEW.status <> OLD.status THEN
        INSERT INTO HISTORICO_STATUS_OS (
            id_os,
            data_mudanca,
            status_anterior,
            status_novo,
            observacao,
            id_mecanico_responsavel
        ) VALUES (
            NEW.id_os,
            CURRENT_TIMESTAMP,
            OLD.status,
            NEW.status,
            CONCAT('Status alterado de ', OLD.status, ' para ', NEW.status, '.'),
            NEW.id_mecanico
        );
    END IF;
END//

-- RN08 e RN17: bloqueia alteracoes em itens de uma OS concluida ou cancelada.
CREATE PROCEDURE sp_validar_os_editavel(IN p_id_os INT)
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status
    FROM ORDEM_SERVICO
    WHERE id_os = p_id_os;

    IF v_status NOT IN ('Orçamento', 'Aprovado', 'Em Execução') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Itens so podem ser alterados em OS editavel.';
    END IF;
END//

-- RN08, RN10 e RN15: valida inclusao de servico com preco congelado.
CREATE TRIGGER trg_item_servico_bi
BEFORE INSERT ON ITEM_SERVICO
FOR EACH ROW
BEGIN
    CALL sp_validar_os_editavel(NEW.id_os);
END//

-- RN08, RN10 e RN15: valida alteracao de servico em OS editavel.
CREATE TRIGGER trg_item_servico_bu
BEFORE UPDATE ON ITEM_SERVICO
FOR EACH ROW
BEGIN
    CALL sp_validar_os_editavel(NEW.id_os);
END//

-- RN08, RN10 e RN15: valida exclusao de servico em OS editavel.
CREATE TRIGGER trg_item_servico_bd
BEFORE DELETE ON ITEM_SERVICO
FOR EACH ROW
BEGIN
    CALL sp_validar_os_editavel(OLD.id_os);
END//

-- RN10: atualiza o valor total apos inclusao de servico.
CREATE TRIGGER trg_item_servico_ai
AFTER INSERT ON ITEM_SERVICO
FOR EACH ROW
BEGIN
    CALL sp_recalcular_valor_total(NEW.id_os);
END//

-- RN10: atualiza o valor total apos alteracao de servico.
CREATE TRIGGER trg_item_servico_au
AFTER UPDATE ON ITEM_SERVICO
FOR EACH ROW
BEGIN
    CALL sp_recalcular_valor_total(NEW.id_os);
END//

-- RN10: atualiza o valor total apos exclusao de servico.
CREATE TRIGGER trg_item_servico_ad
AFTER DELETE ON ITEM_SERVICO
FOR EACH ROW
BEGIN
    CALL sp_recalcular_valor_total(OLD.id_os);
END//

-- RN09 e RN16: impede a inclusao de peca sem saldo em estoque.
CREATE TRIGGER trg_item_peca_bi
BEFORE INSERT ON ITEM_PECA
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;

    CALL sp_validar_os_editavel(NEW.id_os);
    SELECT quantidade_estoque INTO v_estoque
    FROM PECA
    WHERE id_peca = NEW.id_peca;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estoque insuficiente para a peca informada.';
    END IF;
END//

-- RN09 e RN16: valida aumento da quantidade contra o saldo disponivel.
CREATE TRIGGER trg_item_peca_bu
BEFORE UPDATE ON ITEM_PECA
FOR EACH ROW
BEGIN
    DECLARE v_estoque INT;

    CALL sp_validar_os_editavel(NEW.id_os);
    SELECT quantidade_estoque INTO v_estoque
    FROM PECA
    WHERE id_peca = NEW.id_peca;

    IF NEW.id_peca <> OLD.id_peca THEN
        SELECT quantidade_estoque INTO v_estoque
        FROM PECA
        WHERE id_peca = NEW.id_peca;

        IF v_estoque < NEW.quantidade THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Estoque insuficiente para a nova peca.';
        END IF;
    ELSEIF v_estoque < (NEW.quantidade - OLD.quantidade) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estoque insuficiente para aumentar a quantidade.';
    END IF;
END//

-- RN16: impede a remocao de consumo em OS nao editavel.
CREATE TRIGGER trg_item_peca_bd
BEFORE DELETE ON ITEM_PECA
FOR EACH ROW
BEGIN
    CALL sp_validar_os_editavel(OLD.id_os);
END//

-- RN10 e RN16: baixa estoque e recalcula total apos incluir peca.
CREATE TRIGGER trg_item_peca_ai
AFTER INSERT ON ITEM_PECA
FOR EACH ROW
BEGIN
    UPDATE PECA
    SET quantidade_estoque = quantidade_estoque - NEW.quantidade
    WHERE id_peca = NEW.id_peca;

    CALL sp_recalcular_valor_total(NEW.id_os);
END//

-- RN10 e RN16: ajusta estoque e total apos alterar uma peca consumida.
CREATE TRIGGER trg_item_peca_au
AFTER UPDATE ON ITEM_PECA
FOR EACH ROW
BEGIN
    IF NEW.id_peca = OLD.id_peca THEN
        UPDATE PECA
        SET quantidade_estoque = quantidade_estoque + OLD.quantidade - NEW.quantidade
        WHERE id_peca = NEW.id_peca;
    ELSE
        UPDATE PECA
        SET quantidade_estoque = quantidade_estoque + OLD.quantidade
        WHERE id_peca = OLD.id_peca;

        UPDATE PECA
        SET quantidade_estoque = quantidade_estoque - NEW.quantidade
        WHERE id_peca = NEW.id_peca;
    END IF;

    CALL sp_recalcular_valor_total(NEW.id_os);
END//

-- RN10 e RN16: devolve estoque e recalcula total ao remover uma peca.
CREATE TRIGGER trg_item_peca_ad
AFTER DELETE ON ITEM_PECA
FOR EACH ROW
BEGIN
    UPDATE PECA
    SET quantidade_estoque = quantidade_estoque + OLD.quantidade
    WHERE id_peca = OLD.id_peca;

    CALL sp_recalcular_valor_total(OLD.id_os);
END//

-- RN18: garantia somente pode iniciar na conclusao e durar ao menos 90 dias.
CREATE TRIGGER trg_garantia_bi
BEFORE INSERT ON GARANTIA
FOR EACH ROW
BEGIN
    DECLARE v_data_conclusao DATETIME;
    DECLARE v_status VARCHAR(20);

    SELECT data_conclusao, status
    INTO v_data_conclusao, v_status
    FROM ORDEM_SERVICO
    WHERE id_os = NEW.id_os;

    IF v_status <> 'Concluído' OR v_data_conclusao IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Garantia exige uma OS concluida.';
    END IF;

    IF NEW.data_inicio <> DATE(v_data_conclusao) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Garantia deve iniciar na data de conclusao da OS.';
    END IF;
END//

-- RN14: o historico de status e imutavel apos o registro.
CREATE TRIGGER trg_historico_bu
BEFORE UPDATE ON HISTORICO_STATUS_OS
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Historico de status e imutavel.';
END//

-- RN14: o historico de status nao pode ser excluido.
CREATE TRIGGER trg_historico_bd
BEFORE DELETE ON HISTORICO_STATUS_OS
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Historico de status nao pode ser excluido.';
END//

DELIMITER ;
