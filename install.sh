// instalador.js
const fs = require("fs");
const path = require("path");
const { exec } = require("child_process");
const https = require("https");

// URLs dos arquivos raw
const HTML_URL = "https://raw.githubusercontent.com/leandoo/bot/refs/heads/main/index.html";
const SERVER_URL = "https://raw.githubusercontent.com/leandoo/bot/refs/heads/main/leandrus.js";

// Diretórios
const BASE_DIR = path.join(__dirname, "Leandrus");
const PUBLIC_DIR = path.join(BASE_DIR, "public");
const HTML_FILE = path.join(PUBLIC_DIR, "index.html");
const SERVER_FILE = path.join(BASE_DIR, "leandrus.js");

// Função para baixar arquivos
function downloadFile(url, destination) {
    return new Promise((resolve, reject) => {
        const file = fs.createWriteStream(destination);
        https.get(url, (response) => {
            response.pipe(file);
            file.on("finish", () => {
                file.close(resolve);
            });
        }).on("error", (err) => {
            fs.unlink(destination, () => reject(err));
        });
    });
}

// Função para instalar dependências
function installDependencies() {
    return new Promise((resolve, reject) => {
        console.log("Instalando dependências...");
        exec("npm install @google/generative-ai express chalk", (err, stdout, stderr) => {
            if (err) {
                console.error("Erro ao instalar dependências:", stderr);
                reject(err);
            } else {
                console.log("Dependências instaladas com sucesso!");
                resolve();
            }
        });
    });
}

// Função para criar o botão de "Play"
function createPlayButton() {
    const playScript = `
        const { exec } = require("child_process");
        const readline = require("readline");

        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout,
        });

        console.log("Pressione ENTER para iniciar o bot...");
        rl.on("line", () => {
            console.log("Iniciando o bot...");
            exec("node leandrus.js", (err, stdout, stderr) => {
                if (err) {
                    console.error("Erro ao iniciar o bot:", stderr);
                } else {
                    console.log(stdout);
                }
            });
        });
    `;

    fs.writeFileSync(path.join(BASE_DIR, "play.js"), playScript, "utf-8");
    console.log("Botão de 'Play' criado com sucesso!");
}

// Função principal
async function main() {
    try {
        // Cria diretórios
        if (!fs.existsSync(BASE_DIR)) fs.mkdirSync(BASE_DIR, { recursive: true });
        if (!fs.existsSync(PUBLIC_DIR)) fs.mkdirSync(PUBLIC_DIR, { recursive: true });

        // Baixa os arquivos
        console.log("Baixando arquivos...");
        await downloadFile(HTML_URL, HTML_FILE);
        await downloadFile(SERVER_URL, SERVER_FILE);
        console.log("Arquivos baixados com sucesso!");

        // Instala dependências
        await installDependencies();

        // Cria o botão de "Play"
        createPlayButton();

        console.log("Instalação concluída com sucesso!");
        console.log("Execute o comando abaixo para iniciar o bot:");
        console.log("node play.js");
    } catch (err) {
        console.error("Erro durante a instalação:", err);
    }
}

// Executa o instalador
main();
