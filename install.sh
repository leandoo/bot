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

# Função para criar o comando "play"
create_play_command() {
    echo "Configurando o comando 'play'..."

    # Adiciona o alias ao arquivo de configuração do shell
    if [[ -f "$HOME/.bashrc" ]]; then
        echo "alias play='cd $BASE_DIR && node leandrus.js'" >> "$HOME/.bashrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        echo "alias play='cd $BASE_DIR && node leandrus.js'" >> "$HOME/.zshrc"
    else
        echo "Nenhum arquivo de configuração do shell encontrado. Criando ~/.bashrc..."
        echo "alias play='cd $BASE_DIR && node leandrus.js'" > "$HOME/.bashrc"
    fi

    # Recarrega o shell para aplicar o alias
    if [[ -n "$BASH" ]]; then
        source "$HOME/.bashrc"
    elif [[ -n "$ZSH_NAME" ]]; then
        source "$HOME/.zshrc"
    fi

    echo "Comando 'play' configurado com sucesso!"
}

# Função principal
main() {
    echo "Iniciando instalação do Leandrus..."

    # Instala dependências
    install_dependencies

    # Baixa arquivos
    download_files

    # Configura o comando "play"
    create_play_command

    echo "Instalação concluída com sucesso!"
    echo "Para iniciar o bot, digite:"
    echo "play"
}

# Executa a função principal
main
