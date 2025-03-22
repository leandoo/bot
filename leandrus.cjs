import { GoogleGenerativeAI } from "@google/generative-ai";
import fs from "fs";
import path from "path";
import os from "os";
import readline from "readline";
import express from "express";

// Configuração da API Gemini Flash 2.0
const API_KEY = "AIzaSyDVj-qblGxXc3Yj2gzeLa6ZtfJergGlrlo";
const genAI = new GoogleGenerativeAI(API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

// Diretórios para salvar conversas
const CHAT_DIR = path.join(os.homedir(), "Leandrus_Conversas");
if (!fs.existsSync(CHAT_DIR)) fs.mkdirSync(CHAT_DIR);

// Memória temporária
const TEMP_MEMORY_FILE = path.join(os.tmpdir(), "leandrus_memory.json");
let tempMemory = fs.existsSync(TEMP_MEMORY_FILE) ? JSON.parse(fs.readFileSync(TEMP_MEMORY_FILE, "utf-8")) : [];

// Função para salvar memória temporária
function saveMemory() {
    fs.writeFileSync(TEMP_MEMORY_FILE, JSON.stringify(tempMemory, null, 2), "utf-8");
}

// Função para limpar memória temporária após 30 minutos
function checkAndClearTempMemory() {
    const now = Date.now();
    tempMemory = tempMemory.filter(entry => now - entry.timestamp < 1800000);
    saveMemory();
}

// Função para salvar conversas em arquivos numerados
function saveConversation(userInput, botResponse) {
    const timestamp = new Date().toISOString().replace(/:/g, "-");
    const filename = `Conversa_${timestamp}.txt`;
    const filePath = path.join(CHAT_DIR, filename);

    const content = `[${new Date().toLocaleString()}]\nVocê: ${userInput}\nLeandrus: ${botResponse}\n\n`;
    fs.writeFileSync(filePath, content, "utf-8");

    return filename;
}

// Função para exibir texto com efeito de digitação
async function typeWriter(text, delay = 30) {
    for (const char of text) {
        process.stdout.write(char);
        await new Promise(resolve => setTimeout(resolve, delay));
    }
    console.log();
}

// Exibir códigos de programação formatados
function displayCode(code) {
    console.log("\n\x1b[32mCódigo Gerado:\x1b[0m");
    console.log("\x1b[33m" + "-".repeat(50) + "\x1b[0m");
    console.log("\x1b[36m" + code + "\x1b[0m");
    console.log("\x1b[33m" + "-".repeat(50) + "\x1b[0m\n");
}

// Tela de boas-vindas estilizada
async function launchScreen() {
    console.clear();
    console.log(`
 _                              _     
| |                            | |    
| |      ___   __ _  _ __    __| | _ __  _   _  ___ 
| |     / _ \\ / _\` || '_ \\  / _\` || '__|| | | |/ __|
| |____|  __/| (_| || | | || (_| || |   | |_| |\\__ \\
\\_____/ \\___| \\__,_||_| |_| \\__,_||_|    \\__,_||___/
    `);
    console.log("\n\x1b[32mBem-vindo ao Leandrus. Digite sua pergunta ou 'sair' para encerrar.\x1b[0m\n");
}

// Chamada à API Gemini Flash 2.0
async function callAPI(prompt) {
    try {
        const fullPrompt = `Você é Leandrus, um assistente virtual inteligente e sarcástico:\n${prompt}`;

        // Envia o prompt para a API
        const result = await model.generateContent(fullPrompt);
        const response = await result.response;
        const textResponse = response.text();

        // Salva na memória temporária
        tempMemory.push({ timestamp: Date.now(), prompt, response: textResponse });
        saveMemory();

        // Se a resposta conter código, formata ele separadamente
        if (textResponse.includes("```")) {
            const code = textResponse.split("```")[1].trim();
            displayCode(code);
        } else {
            await typeWriter(`\x1b[36mLeandrus:\x1b[0m ${textResponse}`, 30);
        }

        // Salva a conversa no arquivo
        saveConversation(prompt, textResponse);
    } catch (error) {
        console.error("\x1b[31mErro ao chamar a API Gemini:\x1b[0m", error.message);
    }
}

// Chat interativo no terminal
async function chatLoop() {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
        prompt: "\x1b[32mLeandrus>\x1b[0m "
    });

    rl.prompt();

    rl.on("line", async (input) => {
        if (input.toLowerCase() === "sair") {
            console.log("\x1b[31mChat encerrado. Até a próxima!\x1b[0m");
            rl.close();
            return;
        } else if (input.toLowerCase() === "histórico") {
            showHistoryMenu();
        } else {
            console.log("\x1b[33mProcessando...\x1b[0m");
            await callAPI(input);
        }
        rl.prompt();
    });

    rl.on("close", () => {
        process.exit(0);
    });
}

// Exibe o menu de histórico
function showHistoryMenu() {
    const files = fs.readdirSync(CHAT_DIR);
    if (files.length === 0) {
        console.log("\x1b[31mNenhuma conversa registrada.\x1b[0m");
        return;
    }

    console.log("\n\x1b[32mHistórico de Conversas:\x1b[0m");
    files.forEach((file, index) => {
        console.log(`\x1b[33m${index + 1}.\x1b[0m ${file}`);
    });

    readline.question("\nDigite o número da conversa para visualizar ou '0' para voltar: ", (choice) => {
        const num = parseInt(choice);
        if (num > 0 && num <= files.length) {
            const filePath = path.join(CHAT_DIR, files[num - 1]);
            console.clear();
            console.log("\n\x1b[32mConversa Selecionada:\x1b[0m\n");
            console.log(fs.readFileSync(filePath, "utf-8"));
        } else {
            console.log("\n\x1b[31mOpção inválida.\x1b[0m");
        }
    });
}

// Servidor local para visualizar e baixar conversas
const app = express();
app.use(express.static(CHAT_DIR));

app.get("/", (req, res) => {
    const files = fs.readdirSync(CHAT_DIR);
    let page = "<h1>Histórico de Conversas</h1><ul>";
    files.forEach(file => {
        page += `<li><a href="${file}" download>${file}</a></li>`;
    });
    page += "</ul>";
    res.send(page);
});

// Inicia o servidor na porta 3000
app.listen(3000, () => {
    console.log("\x1b[32mServidor rodando em: http://localhost:3000\x1b[0m");
});

// Inicia o sistema
(async () => {
    await launchScreen();
    checkAndClearTempMemory();
    chatLoop();
})();
