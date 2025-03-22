#!/bin/bash

# Atualizar pacotes e sistema
echo -e "\e[32m🔄 Atualizando o sistema...\e[0m"
pkg update -y && pkg upgrade -y

# Instalar dependências essenciais
echo -e "\e[32m📦 Instalando dependências...\e[0m"
pkg install nodejs-lts npm git curl -y

# Clonar o repositório do bot
BOT_DIR="$HOME/leandrus"
if [ -d "$BOT_DIR" ]; then
    echo -e "\e[33m⚠️ Diretório existente. Atualizando...\e[0m"
    cd $BOT_DIR && git pull
else
    echo -e "\e[32m📥 Baixando o bot...\e[0m"
    git clone https://github.com/leandoo/bot.git $BOT_DIR
    cd $BOT_DIR
fi

# Instalar pacotes do Node.js
echo -e "\e[32m📦 Instalando pacotes do Node.js...\e[0m"
npm install

# Criar comando "play" para rodar o bot
echo -e "\e[32m⚙️ Configurando comando de execução...\e[0m"
echo "cd $BOT_DIR && node leandrus.js" > $PREFIX/bin/play
chmod +x $PREFIX/bin/play

# Finalização
echo -e "\e[32m✅ Instalação concluída! Execute o bot com: play\e[0m"
