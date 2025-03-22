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

# Baixa o código do bot do seu repositório
echo "⬇️ Baixando o Leandrus..."
mkdir -p "$BOT_DIR"
cd "$BOT_DIR"
curl -o leandrus.js -L "https://raw.githubusercontent.com/leandoo/bot/refs/heads/main/leandrus.js"

# Cria o package.json com "type": "commonjs" para evitar erro de importação
echo '{ "type": "commonjs" }' > package.json

# Instala dependências do projeto
echo "📦 Instalando dependências do Leandrus..."
npm install express

# Cria o comando 'play' para executar o bot facilmente
echo "⚙️ Configurando comando de execução..."
PLAY_CMD="$PREFIX/bin/play"
echo '#!/data/data/com.termux/files/usr/bin/sh' > "$PLAY_CMD"
echo "cd $BOT_DIR && node leandrus.js" >> "$PLAY_CMD"
chmod +x "$PLAY_CMD"

echo "✅ Instalação concluída! Execute o bot com: play"
