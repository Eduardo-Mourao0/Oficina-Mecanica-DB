import streamlit as st
import mysql.connector
from datetime import date, timedelta
from database import get_connection

st.set_page_config(page_title="Oficina MecÃ¢nica", layout="wide")
st.title("Sistema de GestÃ£o de Oficina MecÃ¢nica")

# Menu Lateral de NavegaÃ§Ã£o
menu = st.sidebar.selectbox(
    "Selecione o MÃ³dulo",
    ["CRUD Cliente", "CRUD VeÃ­culo", "CRUD PeÃ§a", "CRUD MecÃ¢nico", "Abrir OS (TransaÃ§Ã£o)", "Consultas & RelatÃ³rios"]
)

# ============================================================
# 1. MÃ“DULO: CRUD CLIENTE
# ============================================================
if menu == "CRUD Cliente":
    st.header("Gerenciamento de Clientes")
    aba1, aba2, aba3, aba4 = st.tabs(["Cadastrar", "Listar/Buscar", "Atualizar", "Excluir"])

    with aba1:
        st.subheader("Novo Cliente")
        tipo = st.radio("Tipo de Cliente", ["FÃ­sica", "JurÃ­dica"], horizontal=True)
        nome = st.text_input("Nome / Nome Fantasia")
        telefone = st.text_input("Telefone Celular (Ex: (61) 98888-7777)")
        email = st.text_input("E-mail")
        endereco = st.text_input("EndereÃ§o")

        if tipo == "FÃ­sica":
            cpf = st.text_input("CPF (Ex: 000.000.000-00)")
            rg = st.text_input("RG")
            data_nasc = st.date_input("Data de Nascimento")
        else:
            cnpj = st.text_input("CNPJ (Ex: 00.000.000/0001-00)")
            razao_social = st.text_input("RazÃ£o Social")
            inscricao_estadual = st.text_input("InscriÃ§Ã£o Estadual")

        if st.button("Salvar Cliente"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                cursor.execute("START TRANSACTION;")

                sql_cliente = "INSERT INTO CLIENTE (nome, telefone, email, endereco, tipo_cliente) VALUES (%s, %s, %s, %s, %s)"
                cursor.execute(sql_cliente, (nome, telefone, email, endereco, tipo))
                id_cliente = cursor.lastrowid

                if tipo == "FÃ­sica":
                    sql_pf = "INSERT INTO PESSOA_FISICA (id_cliente, cpf, rg, data_nasc) VALUES (%s, %s, %s, %s)"
                    cursor.execute(sql_pf, (id_cliente, cpf, rg, data_nasc))
                else:
                    sql_pj = "INSERT INTO PESSOA_JURIDICA (id_cliente, cnpj, razao_social, inscricao_estadual) VALUES (%s, %s, %s, %s)"
                    cursor.execute(sql_pj, (id_cliente, cnpj, razao_social, inscricao_estadual))

                conn.commit()
                st.success(f"Cliente cadastrado com sucesso! ID: {id_cliente}")
            except mysql.connector.Error as err:
                if 'conn' in locals(): conn.rollback()
                st.error(f"Erro no banco de dados: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

    with aba2:
        st.subheader("Clientes Cadastrados")
        try:
            conn = get_connection()
            cursor = conn.cursor(dictionary=True)
            query = """
                SELECT c.id_cliente, c.nome, c.telefone, c.email, c.tipo_cliente, pf.cpf, pj.cnpj
                FROM CLIENTE c
                LEFT JOIN PESSOA_FISICA pf ON c.id_cliente = pf.id_cliente
                LEFT JOIN PESSOA_JURIDICA pj ON c.id_cliente = pj.id_cliente
                ORDER BY c.id_cliente DESC
            """
            cursor.execute(query)
            st.dataframe(cursor.fetchall(), use_container_width=True)
        except mysql.connector.Error as err:
            st.error(f"Erro ao consultar: {err.msg}")
        finally:
            if 'cursor' in locals(): cursor.close()
            if 'conn' in locals(): conn.close()

    with aba3:
        st.subheader("Atualizar Contato do Cliente")
        id_atualizar = st.number_input("Informe o ID do Cliente", min_value=1, step=1)
        novo_telefone = st.text_input("Novo Telefone")
        novo_email = st.text_input("Novo E-mail")

        if st.button("Atualizar Dados"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                cursor.execute("UPDATE CLIENTE SET telefone = %s, email = %s WHERE id_cliente = %s", (novo_telefone, novo_email, id_atualizar))
                conn.commit()
                st.success("Dados atualizados com sucesso!") if cursor.rowcount > 0 else st.warning("Cliente nÃ£o encontrado.")
            except mysql.connector.Error as err:
                st.error(f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

    with aba4:
        st.subheader("Excluir Cliente")
        id_deletar = st.number_input("ID do Cliente para Excluir", min_value=1, step=1, key="del_cli")
        if st.button("Excluir Cliente", type="primary"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                cursor.execute("DELETE FROM CLIENTE WHERE id_cliente = %s", (id_deletar,))
                conn.commit()
                st.success("Cliente removido!") if cursor.rowcount > 0 else st.warning("Cliente nÃ£o encontrado.")
            except mysql.connector.Error as err:
                st.error("NÃ£o Ã© possÃ­vel excluir cliente com veÃ­culos vinculados!" if err.errno == 1451 else f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

# ============================================================
# 2. MÃ“DULO: CRUD VEÃCULO
# ============================================================
elif menu == "CRUD VeÃ­culo":
    st.header("Gerenciamento de VeÃ­culos")
    aba1, aba2, aba3, aba4 = st.tabs(["Cadastrar", "Listar", "Atualizar", "Excluir"])

    with aba1:
        placa = st.text_input("Placa (Ex: ABC1D23)")
        modelo = st.text_input("Modelo")
        marca = st.text_input("Marca")
        ano = st.number_input("Ano de FabricaÃ§Ã£o", min_value=1900, max_value=2100, value=2020)
        cor = st.text_input("Cor")
        id_cliente = st.number_input("ID do ProprietÃ¡rio (Cliente)", min_value=1, step=1)

        if st.button("Cadastrar VeÃ­culo"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                sql = "INSERT INTO VEICULO (placa, modelo, marca, ano_fabricacao, cor, id_cliente) VALUES (%s, %s, %s, %s, %s, %s)"
                cursor.execute(sql, (placa, modelo, marca, ano, cor, id_cliente))
                conn.commit()
                st.success("VeÃ­culo cadastrado!")
            except mysql.connector.Error as err:
                st.error(f"Erro ao cadastrar: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

    with aba2:
        try:
            conn = get_connection()
            cursor = conn.cursor(dictionary=True)
            query = "SELECT v.*, c.nome AS proprietario FROM VEICULO v JOIN CLIENTE c ON v.id_cliente = c.id_cliente"
            cursor.execute(query)
            st.dataframe(cursor.fetchall(), use_container_width=True)
        except mysql.connector.Error as err:
            st.error(f"Erro: {err.msg}")
        finally:
            if 'cursor' in locals(): cursor.close()
            if 'conn' in locals(): conn.close()

    with aba3:
        id_veiculo_up = st.number_input("ID do VeÃ­culo", min_value=1, step=1)
        nova_cor = st.text_input("Nova Cor")
        if st.button("Atualizar Cor"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                cursor.execute("UPDATE VEICULO SET cor = %s WHERE id_veiculo = %s", (nova_cor, id_veiculo_up))
                conn.commit()
                st.success("Cor atualizada!") if cursor.rowcount > 0 else st.warning("VeÃ­culo nÃ£o encontrado.")
            except mysql.connector.Error as err:
                st.error(f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

    with aba4:
        id_veiculo_del = st.number_input("ID do VeÃ­culo para Excluir", min_value=1, step=1, key="del_veic")
        if st.button("Excluir VeÃ­culo", type="primary"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                cursor.execute("DELETE FROM VEICULO WHERE id_veiculo = %s", (id_veiculo_del,))
                conn.commit()
                st.success("VeÃ­culo excluÃ­do!") if cursor.rowcount > 0 else st.warning("VeÃ­culo nÃ£o encontrado.")
            except mysql.connector.Error as err:
                st.error(f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

# ============================================================
# 3. MÃ“DULO: CRUD PEÃ‡A
# ============================================================
elif menu == "CRUD PeÃ§a":
    st.header("CatÃ¡logo de PeÃ§as")
    aba1, aba2, aba3, aba4 = st.tabs(["Cadastrar", "Listar Estoque", "Atualizar PreÃ§o/Estoque", "Excluir"])

    with aba1:
        cod_barras = st.text_input("CÃ³digo de Barras")
        desc = st.text_input("DescriÃ§Ã£o da PeÃ§a")
        preco = st.number_input("PreÃ§o UnitÃ¡rio", min_value=0.0, format="%.2f")
        qtd = st.number_input("Quantidade em Estoque", min_value=0, step=1)
        id_forn = st.number_input("ID do Fornecedor", min_value=1, step=1)

        if st.button("Cadastrar PeÃ§a"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                sql = "INSERT INTO PECA (codigo_barras, descricao, preco_unitario, quantidade_estoque, id_fornecedor) VALUES (%s, %s, %s, %s, %s)"
                cursor.execute(sql, (cod_barras, desc, preco, qtd, id_forn))
                conn.commit()
                st.success("PeÃ§a cadastrada!")
            except mysql.connector.Error as err:
                st.error(f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

    with aba2:
        try:
            conn = get_connection()
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT p.*, f.nome_fantasia AS fornecedor FROM PECA p JOIN FORNECEDOR f ON p.id_fornecedor = f.id_fornecedor")
            st.dataframe(cursor.fetchall(), use_container_width=True)
        except mysql.connector.Error as err:
            st.error(f"Erro: {err.msg}")
        finally:
            if 'cursor' in locals(): cursor.close()
            if 'conn' in locals(): conn.close()

    with aba3:
        id_p_up = st.number_input("ID da PeÃ§a", min_value=1, step=1)
        n_preco = st.number_input("Novo PreÃ§o", min_value=0.0, format="%.2f")
        n_qtd = st.number_input("Adicionar ao Estoque", min_value=0, step=1)
        if st.button("Atualizar PeÃ§a"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                cursor.execute("UPDATE PECA SET preco_unitario = %s, quantidade_estoque = quantidade_estoque + %s WHERE id_peca = %s", (n_preco, n_qtd, id_p_up))
                conn.commit()
                st.success("PeÃ§a atualizada!") if cursor.rowcount > 0 else st.warning("PeÃ§a nÃ£o encontrada.")
            except mysql.connector.Error as err:
                st.error(f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

    with aba4:
        id_p_del = st.number_input("ID da PeÃ§a para Excluir", min_value=1, step=1, key="del_peca")
        if st.button("Excluir PeÃ§a", type="primary"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                cursor.execute("DELETE FROM PECA WHERE id_peca = %s", (id_p_del,))
                conn.commit()
                st.success("PeÃ§a excluÃ­da!") if cursor.rowcount > 0 else st.warning("PeÃ§a nÃ£o encontrada.")
            except mysql.connector.Error as err:
                st.error(f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

# ============================================================
# 4. MÃ“DULO: CRUD MECÃ‚NICO
# ============================================================
elif menu == "CRUD MecÃ¢nico":
    st.header("Gerenciamento de MecÃ¢nicos")
    aba1, aba2, aba3, aba4 = st.tabs(["Cadastrar", "Listar", "Atualizar", "Excluir"])

    with aba1:
        nome_m = st.text_input("Nome do MecÃ¢nico")
        cpf_m = st.text_input("CPF")
        esp_m = st.text_input("Especialidade")
        v_hora = st.number_input("Valor Hora", min_value=0.0, format="%.2f")
        id_sup = st.number_input("ID Supervisor (Opcional)", min_value=0, step=1)

        if st.button("Cadastrar MecÃ¢nico"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                supervisor_val = id_sup if id_sup > 0 else None
                sql = "INSERT INTO MECANICO (nome, cpf, especialidade, valor_hora, id_supervisor) VALUES (%s, %s, %s, %s, %s)"
                cursor.execute(sql, (nome_m, cpf_m, esp_m, v_hora, supervisor_val))
                conn.commit()
                st.success("MecÃ¢nico cadastrado!")
            except mysql.connector.Error as err:
                st.error(f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

    with aba2:
        try:
            conn = get_connection()
            cursor = conn.cursor(dictionary=True)
            query = "SELECT m.*, s.nome AS supervisor FROM MECANICO m LEFT JOIN MECANICO s ON m.id_supervisor = s.id_mecanico"
            cursor.execute(query)
            st.dataframe(cursor.fetchall(), use_container_width=True)
        except mysql.connector.Error as err:
            st.error(f"Erro: {err.msg}")
        finally:
            if 'cursor' in locals(): cursor.close()
            if 'conn' in locals(): conn.close()

    with aba3:
        id_m_up = st.number_input("ID do MecÃ¢nico", min_value=1, step=1)
        n_v_hora = st.number_input("Novo Valor Hora", min_value=0.0, format="%.2f")
        if st.button("Atualizar Valor Hora"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                cursor.execute("UPDATE MECANICO SET valor_hora = %s WHERE id_mecanico = %s", (n_v_hora, id_m_up))
                conn.commit()
                st.success("Atualizado com sucesso!") if cursor.rowcount > 0 else st.warning("MecÃ¢nico nÃ£o encontrado.")
            except mysql.connector.Error as err:
                st.error(f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

    with aba4:
        id_m_del = st.number_input("ID do MecÃ¢nico para Excluir", min_value=1, step=1, key="del_mec")
        if st.button("Excluir MecÃ¢nico", type="primary"):
            try:
                conn = get_connection()
                cursor = conn.cursor()
                cursor.execute("DELETE FROM MECANICO WHERE id_mecanico = %s", (id_m_del,))
                conn.commit()
                st.success("MecÃ¢nico excluÃ­do!") if cursor.rowcount > 0 else st.warning("MecÃ¢nico nÃ£o encontrado.")
            except mysql.connector.Error as err:
                st.error(f"Erro: {err.msg}")
            finally:
                if 'cursor' in locals(): cursor.close()
                if 'conn' in locals(): conn.close()

# ============================================================
# 5. OPERAÃ‡ÃƒO TRANSACIONAL MULTITABELA
# ============================================================
elif menu == "Abrir OS (TransaÃ§Ã£o)":
    st.header("Abertura de Ordem de ServiÃ§o (OperaÃ§Ã£o Transacional)")
    st.info("Esta operaÃ§Ã£o cria a OS e seu item de peÃ§a em uma Ãºnica transaÃ§Ã£o. O histÃ³rico, o estoque e o valor total sÃ£o atualizados pelos triggers do banco.")

    col1, col2 = st.columns(2)
    with col1:
        id_veiculo = st.number_input("ID do VeÃ­culo", min_value=1, step=1)
        id_mecanico = st.number_input("ID do MecÃ¢nico ResponsÃ¡vel", min_value=1, step=1)
        data_minima = date.today() + timedelta(days=1)
        data_prev = st.date_input(
            "Data de PrevisÃ£o de ConclusÃ£o",
            value=data_minima,
            min_value=data_minima,
        )
    with col2:
        id_peca = st.number_input("ID da PeÃ§a a Incluir", min_value=1, step=1)
        qtd_peca = st.number_input("Quantidade da PeÃ§a", min_value=1, step=1)
        valor_peca = st.number_input("Valor Cobrado por Unidade", min_value=0.0, format="%.2f")

    if st.button("Processar Abertura de OS (COMMIT/ROLLBACK)", type="primary"):
        try:
            conn = get_connection()
            cursor = conn.cursor()

            # INÃCIO EXPLÃCITO DA TRANSAÃ‡ÃƒO
            conn.start_transaction()

            # 1. Insere a OS. O trigger define o valor_total inicial.
            sql_os = """
                INSERT INTO ORDEM_SERVICO (data_abertura, data_previsao, status, id_veiculo, id_mecanico)
                VALUES (NOW(), %s, 'OrÃ§amento', %s, %s)
            """
            cursor.execute(sql_os, (data_prev, id_veiculo, id_mecanico))
            id_os = cursor.lastrowid

            # 2. Insere o item de peÃ§a
            sql_item = "INSERT INTO ITEM_PECA (id_os, id_peca, quantidade, valor_cobrado) VALUES (%s, %s, %s, %s)"
            cursor.execute(sql_item, (id_os, id_peca, qtd_peca, valor_peca))

            # 3. Os triggers registram histÃ³rico, atualizam estoque e recalculam o total.
            conn.commit()
            st.success(f"TransaÃ§Ã£o concluÃ­da com sucesso! Ordem de ServiÃ§o NÂº {id_os} criada.")

        except mysql.connector.Error as err:
            # DESFAZ EM CASO DE ERRO
            if 'conn' in locals(): conn.rollback()
            st.error(f"FALHA NA TRANSAÃ‡ÃƒO (ROLLBACK EXECUTADO): {err.msg}")
        finally:
            if 'cursor' in locals(): cursor.close()
            if 'conn' in locals(): conn.close()

# ============================================================
# 6. CONSULTAS & RELATÃ“RIOS (VisÃ£o e Filtros)
# ============================================================
elif menu == "Consultas & RelatÃ³rios":
    st.header("RelatÃ³rios Consolidados")
    st.subheader("Ordens de ServiÃ§o por PerÃ­odo (Consulta Parametrizada)")

    st_filtro = st.selectbox("Filtrar por Status", ["Todos", "OrÃ§amento", "Aprovado", "Em ExecuÃ§Ã£o", "ConcluÃ­do", "Cancelado"])

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        if st_filtro == "Todos":
            query = """
                SELECT os.id_os, os.data_abertura, os.status, os.valor_total, v.placa, c.nome AS cliente
                FROM ORDEM_SERVICO os
                JOIN VEICULO v ON os.id_veiculo = v.id_veiculo
                JOIN CLIENTE c ON v.id_cliente = c.id_cliente
                ORDER BY os.id_os DESC
            """
            cursor.execute(query)
        else:
            query = """
                SELECT os.id_os, os.data_abertura, os.status, os.valor_total, v.placa, c.nome AS cliente
                FROM ORDEM_SERVICO os
                JOIN VEICULO v ON os.id_veiculo = v.id_veiculo
                JOIN CLIENTE c ON v.id_cliente = c.id_cliente
                WHERE os.status = %s
                ORDER BY os.id_os DESC
            """
            cursor.execute(query, (st_filtro,))

        st.dataframe(cursor.fetchall(), use_container_width=True)
    except mysql.connector.Error as err:
        st.error(f"Erro: {err.msg}")
    finally:
        if 'cursor' in locals(): cursor.close()
        if 'conn' in locals(): conn.close()
