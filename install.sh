#!/bin/bash

# Nome do arquivo JS principal
MAIN_JS="leandrus.js"

# URL do arquivo JS no repositório raw
JS_URL="https://raw.githubusercontent.com/leandoo/bot/refs/heads/main/leandrus.js"

# Diretório de instalação
INSTALL_DIR="$HOME/leandrus"

# Atualiza o sistema
update_system() {
  echo "🔄 Atualizando sistema..."
  apt update -y && apt upgrade -y
}

# Instala Node.js e npm
install_nodejs() {
  if ! command -v node &> /dev/null; then
    echo "⚙️ Instalando Node.js..."
    apt install -y nodejs npm
  else
    echo "✅ Node.js já instalado!"
  fi
}

# Instala dependências do sistema
install_dependencies() {
  echo "🔧 Instalando pacotes essenciais..."
  apt install -y curl git
}

# Baixa o Leandrus.js
download_leandrus() {
  echo "📥 Baixando o Leandrus..."
  mkdir -p $INSTALL_DIR
  curl -o $INSTALL_DIR/$MAIN_JS $JS_URL
}

# Instala dependências do bot
install_bot_dependencies() {
  echo "📦 Instalando dependências do bot..."
  cd $INSTALL_DIR
  npm install @google/generative-ai fs path os readline express cors
}

# Configura o comando 'play'
setup_play_command() {
  echo "🎮 Criando comando 'play'..."
  echo "#!/bin/bash" > $PREFIX/bin/play
  echo "node $INSTALL_DIR/$MAIN_JS" >> $PREFIX/bin/play
  chmod +x $PREFIX/bin/play
}

# Executa a instalação
main() {
  update_system
  install_nodejs
  install_dependencies
  download_leandrus
  install_bot_dependencies
  setup_play_command
  echo "✅ Instalação concluída! Use 'play' para rodar o bot."
}

main
