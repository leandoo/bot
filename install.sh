#!/bin/bash

# Nome do arquivo JS principal
MAIN_JS="leandrus.js"

# URL do arquivo JS no repositório raw
JS_URL="https://raw.githubusercontent.com/leandoo/bot/refs/heads/main/leandrus.js"

# Diretório de instalação
INSTALL_DIR="/usr/local/bin/leandrus"

# Criar diretório de instalação
mkdir -p $INSTALL_DIR

# Baixar o arquivo JS
echo "Baixando o arquivo leandrus.js..."
curl -o $INSTALL_DIR/$MAIN_JS $JS_URL

# Verificar se o download foi bem-sucedido
if [ ! -f "$INSTALL_DIR/$MAIN_JS" ]; then
  echo "Erro: Falha ao baixar o arquivo leandrus.js."
  exit 1
fi

# Instalar dependências
echo "Instalando dependências..."
cd $INSTALL_DIR
npm install @google/generative-ai fs path os readline express

# Verificar se as dependências foram instaladas corretamente
if [ $? -ne 0 ]; then
  echo "Erro: Falha ao instalar as dependências."
  exit 1
fi

# Criar um link simbólico para executar o script com o comando 'play'
echo "Criando link simbólico..."
ln -sf $INSTALL_DIR/$MAIN_JS /usr/local/bin/play

# Dar permissão de execução ao arquivo JS
chmod +x $INSTALL_DIR/$MAIN_JS

echo "Instalação concluída! Agora você pode executar o Leandrus com o comando 'play'."