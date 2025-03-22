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
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt-get install -y nodejs
    else
        echo "Node.js já está instalado."
    fi

    # Verifica se o npm está instalado
    if ! command -v npm &> /dev/null; then
        echo "npm não encontrado. Instalando npm..."
        sudo apt-get install -y npm
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

# Função para criar o botão de "Play"
create_play_button() {
    echo "Criando botão de 'Play'..."

    cat > "$BASE_DIR/play.sh" <<EOF
#!/bin/bash

echo "Iniciando o bot..."
cd "$BASE_DIR"
node leandrus.js
EOF

    chmod +x "$BASE_DIR/play.sh"
    echo "Botão de 'Play' criado com sucesso!"
}

# Função principal
main() {
    echo "Iniciando instalação do Leandrus..."

    # Instala dependências
    install_dependencies

    # Baixa arquivos
    download_files

    # Cria botão de "Play"
    create_play_button

    echo "Instalação concluída com sucesso!"
    echo "Para iniciar o bot, execute:"
    echo "cd $BASE_DIR && ./play.sh"
}

# Executa a função principal
main
