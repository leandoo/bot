import { GoogleGenerativeAI } from "@google/generative-ai";
import fs from "fs";
import path from "path";
import os from "os";
import readline from "readline";
import express from "express";
import cors from "cors";

// Configuração da API Gemini
const API_KEY = "AIzaSyDVj-qblGxXc3Yj2gzeLa6ZtfJergGlrlo";
const genAI = new GoogleGenerativeAI(API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

// Diretório de histórico de conversas
const CHAT_DIR = path.join(os.homedir(), "Leandrus_Conversas");
if (!fs.existsSync(CHAT_DIR)) fs.mkdirSync(CHAT_DIR);

// Função para salvar conversas
function saveConversation(userInput, botResponse) {
    const timestamp = new Date().toISOString().replace(/:/g, "-");
    const filename = `Conversa_${timestamp}.txt`;
    const filePath = path.join(CHAT_DIR, filename);
    fs.writeFileSync(filePath, `[${new Date().toLocaleString()}]\nVocê: ${userInput}\nLeandrus: ${botResponse}\n\n`, "utf-8");
    return filename;
}

// Função de digitação
async function typeWriter(text, delay = 30) {
    for (const char of text) {
        process.stdout.write(char);
        await new Promise(resolve => setTimeout(resolve, delay));
    }
    console.log();
}

// Exibir código formatado
function displayCode(code) {
    console.log("\n\x1b[32mCódigo Gerado:\x1b[0m");
    console.log("\x1b[33m" + "-".repeat(50) + "\x1b[0m");
    console.log("\x1b[36m" + code + "\x1b[0m");
    console.log("\x1b[33m" + "-".repeat(50) + "\x1b[0m\n");
}

// Chamar a API Gemini
async function callAPI(prompt) {
    try {
        const fullPrompt = `Você é Leandrus, um assistente virtual inteligente:\n${prompt}`;
        const result = await model.generateContent(fullPrompt);
        const response = await result.response;
        const textResponse = response.text();

        if (textResponse.includes("```")) {
            displayCode(textResponse.split("```")[1].trim());
        } else {
            await typeWriter(`\x1b[36mLeandrus:\x1b[0m ${textResponse}`, 30);
        }

        saveConversation(prompt, textResponse);
    } catch (error) {
        console.error("\x1b[31mErro ao chamar a API Gemini:\x1b[0m", error.message);
    }
}

// Chat interativo
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
        }
        console.log("\x1b[33mProcessando...\x1b[0m");
        await callAPI(input);
        rl.prompt();
    });

    rl.on("close", () => {
        process.exit(0);
    });
}

// Servidor local
const app = express();
app.use(cors());
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

// Inicia o chat
(async () => {
    console.clear();
    console.log("\x1b[32mBem-vindo ao Leandrus!\x1b[0m");
    chatLoop();
})();
