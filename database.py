import os
import mysql.connector
from dotenv import load_dotenv

# Carrega as variaveis declaradas no arquivo .env local.
load_dotenv()


def get_connection():
    """Cria uma conexao MySQL a partir das variaveis de ambiente."""
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )
