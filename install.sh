#!/bin/bash

# Nome do arquivo do bot
BOT_FILE="leandrus.js"
HTML_URL="https://raw.githubusercontent.com/leandoo/bot/refs/heads/main/index.html"
BOT_URL="https://raw.githubusercontent.com/leandoo/bot/refs/heads/main/leandrus.js"

# Diretório base
BASE_DIR="$HOME/Leandrus"
PUBLIC_DIR="$BASE_DIR/public"
HTML_FILE="$PUBLIC_DIR/index.html"

# Função para verificar e instalar dependências
install_dependencies() {
    echo "Instalando dependências..."

    # Verifica se o Node.js está instalado
    if ! command -v node &> /dev/null; then
        echo "Node.js não encontrado. Instalando Node.js..."
        pkg install nodejs -y
    else
        echo "Node.js já está instalado."
    fi

    # Verifica se o npm está instalado
    if ! command -v npm &> /dev/null; then
        echo "npm não encontrado. Instalando npm..."
        pkg install npm -y
    else
        echo "npm já está instalado."
    fi

    # Instala dependências do projeto
    echo "Instalando dependências do projeto..."
    npm install @google/generative-ai express chalk
}

# Função para baixar arquivos
download_files() {
    echo "Baixando arquivos..."

    # Cria diretórios
    mkdir -p "$BASE_DIR"
    mkdir -p "$PUBLIC_DIR"

    # Baixa o arquivo leandrus.js
    echo "Baixando $BOT_FILE..."
    curl -sL "$BOT_URL" -o "$BASE_DIR/$BOT_FILE"

    # Baixa o arquivo HTML
    echo "Baixando index.html..."
    curl -sL "$HTML_URL" -o "$HTML_FILE"

    echo "Arquivos baixados com sucesso!"
}

# Função para criar o script "startbot"
create_startbot_script() {
    echo "Criando o script 'startbot'..."

    # Cria o script
    cat > /data/data/com.termux/files/usr/bin/startbot <<EOF
#!/bin/bash
cd "$BASE_DIR" && node leandrus.js
EOF

    # Dá permissão de execução
    chmod +x /data/data/com.termux/files/usr/bin/startbot

    echo "Script 'startbot' criado com sucesso!"
}

# Função principal
main() {
    echo "Iniciando instalação do Leandrus..."

    # Instala dependências
    install_dependencies

    # Baixa arquivos
    download_files

    # Cria o script "startbot"
    create_startbot_script

    echo "Instalação concluída com sucesso!"
    echo "Para iniciar o bot, digite:"
    echo "startbot"
}

# Executa a função principal
main
