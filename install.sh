#!/data/data/com.termux/files/usr/bin/bash

# Atualiza o Termux e instala pacotes essenciais
echo "🔄 Atualizando o sistema..."
pkg update -y && pkg upgrade -y

# Instala Node.js e npm se não estiverem instalados
echo "🛠️ Instalando Node.js e npm..."
pkg install -y nodejs-lts

# Verifica se o Node.js foi instalado corretamente
if ! command -v node &> /dev/null
then
    echo "❌ Erro: Node.js não foi instalado corretamente. Tente instalar manualmente com 'pkg install nodejs-lts'."
    exit 1
fi

# Diretório do bot
BOT_DIR="$HOME/leandrus"

# Remove versão antiga do bot, se existir
if [ -d "$BOT_DIR" ]; then
    echo "⚠️ Removendo versão antiga do Leandrus..."
    rm -rf "$BOT_DIR"
fi

# Cria o diretório do bot
mkdir -p "$BOT_DIR"
cd "$BOT_DIR"

# Baixa o código do bot do repositório
echo "⬇️ Baixando o Leandrus..."
curl -o server.js -L "https://raw.githubusercontent.com/leandoo/bot/main/server.js"

# Cria o arquivo package.json com as dependências
echo "📜 Criando package.json..."
cat > package.json <<EOL
{
  "name": "chat-server",
  "version": "1.0.0",
  "description": "Servidor de chat com integração à API Gemini",
  "main": "server.js",
  "type": "module",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "axios": "^1.6.2",
    "pg": "^8.11.3",
    "redis": "^4.6.10",
    "i18next": "^23.7.8",
    "socket.io": "^4.7.2",
    "cors": "^2.8.5",
    "uuid": "^9.0.0",
    "@google/generative-ai": "^0.1.0",
    "ws": "^8.13.0"
  }
}
EOL

# Instala dependências do projeto
echo "📦 Instalando dependências do Leandrus..."
npm install

# Cria o comando 'play' para executar o bot facilmente
echo "⚙️ Configurando comando de execução..."
PLAY_CMD="$PREFIX/bin/play"
echo '#!/data/data/com.termux/files/usr/bin/sh' > "$PLAY_CMD"
echo "cd $BOT_DIR && npm start" >> "$PLAY_CMD"
chmod +x "$PLAY_CMD"

echo "✅ Instalação concluída! Execute o bot com: play"
