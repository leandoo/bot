#!/bin/bash

# Nome do arquivo JS principal
MAIN_JS="leandrus.js"

# URL do arquivo JS no repositório raw
JS_URL="https://raw.githubusercontent.com/leandoo/bot/refs/heads/main/leandrus.js"

# Diretório de instalação
INSTALL_DIR="/usr/local/bin/leandrus"

# Função para verificar e instalar Node.js e npm
install_nodejs() {
  if ! command -v node &> /dev/null; then
    echo "Node.js não encontrado. Instalando Node.js e npm..."
    # Adiciona o repositório do NodeSource para Node.js 18.x
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
  else
    echo "Node.js já está instalado."
  fi

  if ! command -v npm &> /dev/null; then
    echo "npm não encontrado. Instalando npm..."
    sudo apt-get install -y npm
  else
    echo "npm já está instalado."
  fi
}

# Função para instalar dependências do sistema (caso necessário)
install_system_dependencies() {
  echo "Instalando dependências do sistema..."
  sudo apt-get update
  sudo apt-get install -y curl git build-essential
}

# Função para instalar dependências do Google Gemini
install_gemini_dependencies() {
  echo "Instalando dependências do Google Gemini..."
  cd $INSTALL_DIR
  npm install @google/generative-ai fs path os readline express
}

# Função para configurar o comando 'play'
setup_play_command() {
  echo "Configurando o comando 'play'..."
  sudo ln -sf $INSTALL_DIR/$MAIN_JS /usr/local/bin/play
  sudo chmod +x $INSTALL_DIR/$MAIN_JS
}

# Função principal de instalação
main() {
  # Criar diretório de instalação
  echo "Criando diretório de instalação..."
  sudo mkdir -p $INSTALL_DIR

  # Instalar dependências do sistema
  install_system_dependencies

  # Verificar e instalar Node.js e npm
  install_nodejs

  # Baixar o arquivo leandrus.js
  echo "Baixando o arquivo leandrus.js..."
  sudo curl -o $INSTALL_DIR/$MAIN_JS $JS_URL

  # Verificar se o download foi bem-sucedido
  if [ ! -f "$INSTALL_DIR/$MAIN_JS" ]; then
    echo "Erro: Falha ao baixar o arquivo leandrus.js."
    exit 1
  fi

  # Instalar dependências do Google Gemini
  install_gemini_dependencies

  # Verificar se as dependências foram instaladas corretamente
  if [ $? -ne 0 ]; then
    echo "Erro: Falha ao instalar as dependências."
    exit 1
  fi

  # Configurar o comando 'play'
  setup_play_command

  echo "Instalação concluída! Agora você pode executar o Leandrus com o comando 'play'."
}

# Executar a função principal
main
