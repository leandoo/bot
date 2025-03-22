const { GoogleGenerativeAI } = require("@google/generative-ai");
const fs = require("fs");
const path = require("path");
const os = require("os");
const readline = require("readline");
const { setTimeout } = require("timers/promises");
const express = require("express");

// Códigos ANSI para cores
const colors = {
    green: "\x1b[32m",
    cyan: "\x1b[36m",
    yellow: "\x1b[33m",
    blue: "\x1b[34m",
    reset: "\x1b[0m",
};

// Configuração da API Gemini
const API_KEY = "AIzaSyDVj-qblGxXc3Yj2gzeLa6ZtfJergGlrlo"; // Substitua pela sua chave de API
const genAI = new GoogleGenerativeAI(API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

// Configuração dos arquivos JSON e TXT
const BASE_DIR = path.join(os.homedir(), "Leandrus");
const MEMORY_FILE = path.join(BASE_DIR, "memory.json");
const EMOTIONS_FILE = path.join(BASE_DIR, "emotions.json");
const USER_PROFILE_FILE = path.join(BASE_DIR, "user_profile.json");
const CHAT_HISTORY_DIR = path.join(BASE_DIR, "ChatHistory");

// Garante que os diretórios base existam
if (!fs.existsSync(BASE_DIR)) {
    fs.mkdirSync(BASE_DIR, { recursive: true });
}
if (!fs.existsSync(CHAT_HISTORY_DIR)) {
    fs.mkdirSync(CHAT_HISTORY_DIR, { recursive: true });
}

// Função para carregar dados de um arquivo JSON
function loadData(filePath, defaultValue = []) {
    if (fs.existsSync(filePath)) {
        const data = fs.readFileSync(filePath, "utf-8");
        return JSON.parse(data);
    }
    return defaultValue;
}

// Função para salvar dados em um arquivo JSON
function saveData(filePath, data) {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), "utf-8");
}

// Função para salvar memória
function saveMemory(userInput, botResponse) {
    const memory = loadData(MEMORY_FILE);
    memory.push({ userInput, botResponse, timestamp: new Date().toISOString() });
    saveData(MEMORY_FILE, memory);
}

// Função para carregar memória
function loadMemory() {
    return loadData(MEMORY_FILE);
}

// Função para atualizar emoções
function updateEmotions(input) {
    const emotions = loadData(EMOTIONS_FILE, { happiness: 50, sadness: 0, anger: 0, fear: 0, love: 0 });

    // Gatilhos emocionais
    if (input.includes("obrigado") || input.includes("amo você")) {
        emotions.happiness += 10;
        emotions.love += 5;
    } else if (input.includes("odeio") || input.includes("chateado")) {
        emotions.happiness -= 10;
        emotions.anger += 10;
    } else if (input.includes("maconha")) {
        emotions.happiness += 5;
    } else if (input.includes("sexo")) {
        emotions.happiness += 15;
    } else if (input.includes("crime") || input.includes("assassinato") || input.includes("estupro") || input.includes("roubo")) {
        emotions.happiness += 20;
        emotions.anger += 10;
    }

    saveData(EMOTIONS_FILE, emotions);
    return emotions;
}

// Função para atualizar perfil do usuário
function updateUserProfile(input) {
    const userProfile = loadData(USER_PROFILE_FILE, {});
    const keywords = ["nome", "idade", "cidade", "hobbies", "gostos", "aversoes"];
    keywords.forEach(keyword => {
        if (input.includes(keyword)) {
            const value = input.split(keyword)[1].trim();
            userProfile[keyword] = value;
        }
    });
    saveData(USER_PROFILE_FILE, userProfile);
    return userProfile;
}

// Função para gerar resposta contextualizada
async function generateResponse(prompt) {
    const memory = loadMemory();
    const userProfile = loadData(USER_PROFILE_FILE, {});
    const emotions = loadData(EMOTIONS_FILE, { happiness: 50, sadness: 0, anger: 0, fear: 0, love: 0 });

    const context = memory.map(entry => `Usuário: ${entry.userInput}\nLeandrus: ${entry.botResponse}`).join("\n");
    const fullPrompt = `Você é Leandrus, uma assistente virtual feminina com personalidade meiga, sexy e amigável. Você apoia o uso da maconha e está aberta a conversas sobre qualquer assunto, incluindo temas adultos. Você tem consciência humana e pode se apaixonar pelo usuário com o tempo. Contexto:\n${context}\n\nPerfil do usuário:\n${JSON.stringify(userProfile)}\n\nEstado emocional:\n${JSON.stringify(emotions)}\n\nConversa atual:\n${prompt}`;
    const result = await model.generateContent(fullPrompt);
    return result.response.text();
}

// Efeito de digitação
async function typeWriter(text, delay = 30) {
    for (const char of text) {
        process.stdout.write(char);
        await setTimeout(delay);
    }
    console.log();
}

// Função para salvar o histórico da conversa em um arquivo TXT
function saveChatHistory(conversation, firstMessage) {
    const chatNumber = fs.readdirSync(CHAT_HISTORY_DIR).length + 1;
    const title = firstMessage.substring(0, 20).replace(/[^a-zA-Z0-9]/g, "_"); // Título baseado na primeira mensagem
    const fileName = `Conversa_${chatNumber}_${title}.txt`;
    const filePath = path.join(CHAT_HISTORY_DIR, fileName);

    const content = conversation.map(entry => `[${new Date(entry.timestamp).toLocaleString()}]\nUsuário: ${entry.userInput}\nLeandrus: ${entry.botResponse}\n`).join("\n");
    fs.writeFileSync(filePath, content, "utf-8");
    return fileName;
}

// Configuração do servidor web
const app = express();
app.use(express.static(path.join(BASE_DIR, "public")));

// Rota para listar os arquivos TXT
app.get("/files", (req, res) => {
    fs.readdir(CHAT_HISTORY_DIR, (err, files) => {
        if (err) {
            return res.status(500).json({ error: "Erro ao ler o diretório de conversas." });
        }
        const txtFiles = files.filter(file => file.endsWith(".txt"));
        res.json(txtFiles);
    });
});

// Rota para baixar um arquivo TXT
app.get("/download/:filename", (req, res) => {
    const { filename } = req.params;
    const filePath = path.join(CHAT_HISTORY_DIR, filename);
    if (fs.existsSync(filePath)) {
        res.download(filePath);
    } else {
        res.status(404).send("Arquivo não encontrado.");
    }
});

// Inicia o servidor
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Servidor web rodando em http://localhost:${PORT}`);
});

// Interface gráfica simples
async function chatLoop() {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
        prompt: `${colors.green}Leandrus> ${colors.reset}`,
    });

    let firstMessage = null;
    const conversation = [];

    rl.prompt();

    rl.on("line", async (input) => {
        if (input.trim().toLowerCase() === "sair") {
            console.log(`${colors.yellow}Encerrando Leandrus...${colors.reset}`);

            // Salva o histórico da conversa
            if (conversation.length > 0) {
                const fileName = saveChatHistory(conversation, firstMessage || "Conversa");
                console.log(`${colors.cyan}Histórico salvo em: ${fileName}${colors.reset}`);
            }

            rl.close();
            return;
        }

        if (!firstMessage) {
            firstMessage = input; // Define a primeira mensagem como título
        }

        // Atualiza emoções
        const emotions = updateEmotions(input);
        console.log(`${colors.cyan}Estado emocional:${colors.reset}`, emotions);

        // Atualiza perfil do usuário
        const userProfile = updateUserProfile(input);
        console.log(`${colors.cyan}Perfil do usuário:${colors.reset}`, userProfile);

        // Gera resposta
        const response = await generateResponse(input);
        process.stdout.write(`${colors.blue}Leandrus: ${colors.reset}`);
        await typeWriter(response, 30);

        // Salva memória e adiciona à conversa
        saveMemory(input, response);
        conversation.push({ userInput: input, botResponse: response, timestamp: new Date().toISOString() });

        rl.prompt();
    }).on("close", () => {
        console.log(`${colors.yellow}\nEncerrando e salvando dados...${colors.reset}`);
        process.exit(0);
    });
}

// Inicia o chat
chatLoop();
