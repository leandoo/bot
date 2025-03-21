incipal
main#!/bin/bash

# Nome do arquivo JS principal
MAIN_JS="leandrus.js"

# URL do arquivo JS no repositório raw
JS_URL="https://raw.githubusercontent.com/leandoo/bot/refs/heads/main/leandrus.js"

# Diretório de instalação
INSTALL_DIR="$HOME/leandrus"

# Função para atualizar o sistema e fazer upgrade dos pacotes
update_system() {
  echo "Atualizando o sistema e fazendo upgrade dos pacotes..."
  pkg update -y
  pkg upgrade -y
  echo "Sistema atualizado com sucesso!"
}

# Função para verificar e instalar Node.js e npm
install_nodejs() {
  if ! command -v node &> /dev/null; then
    echo "Node.js não encontrado. Instalando Node.js e npm..."
    pkg install -y nodejs
  else
    echo "Node.js já está instalado."
  fi

  if ! command -v npm &> /dev/null; then
    echo "npm não encontrado. Instalando npm..."
    pkg install -y npm
  else
    echo "npm já está instalado."
  fi
}

# Função para instalar dependências do sistema (caso necessário)
install_system_dependencies() {
  echo "Instalando dependências do sistema..."
  pkg install -y curl git
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
  # Cria um wrapper script para executar o arquivo JS com Node.js
  cat > $PREFIX/bin/play <<EOF
#!/bin/bash
node $INSTALL_DIR/$MAIN_JS
EOF
  chmod +x $PREFIX/bin/play
  chmod +x $INSTALL_DIR/$MAIN_JS
}

# Função principal de instalação
main() {
  # Atualizar o sistema e fazer upgrade dos pacotes
  update_system

  # Criar diretório de instalação
  echo "Criando diretório de instalação..."
  mkdir -p $INSTALL_DIR

  # Instalar dependências do sistema
  install_system_dependencies

  # Verificar e instalar Node.js e npm
  install_nodejs

  # Baixar o arquivo leandrus.js
  echo "Baixando o arquivo leandrus.js..."
  curl -o $INSTALL_DIR/$MAIN_JS $JS_URL

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
