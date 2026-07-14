# Codex no VS Code permanece carregando indefinidamente

**Categoria:** VS Code
**Sistema Operacional:** Linux Mint
**VS Code:** 1.128.0
**Extensão Codex:** 26.707.71524

---

# Problema

O painel lateral (Sidebar) do Codex permanece carregando indefinidamente.

O Chat da OpenAI funciona normalmente, porém o painel do Codex nunca termina de inicializar.

---

# Sintomas

* Spinner do Codex permanece ativo indefinidamente.
* O Chat funciona normalmente.
* Reiniciar o VS Code não resolve.

No log **Output → Codex** aparecem mensagens semelhantes às seguintes:

```text
[IpcRouter] I am the router

[IpcClient] Received broadcast but no handler is configured
method=client-status-changed
```

Essas mensagens se repetem continuamente.

---

# Causa provável

O problema está relacionado ao estado local da extensão armazenado em:

```text
~/.config/Code/User/globalStorage/openai.chatgpt*
```

A instalação da extensão permanece íntegra, porém o estado interno (cache/webview) fica inconsistente e impede a inicialização correta do painel.

---

# Solução

## 1. Fechar completamente o VS Code

```bash
pkill -f code
```

---

## 2. Fazer um backup (opcional)

```bash
mkdir -p ~/backup-codex-vscode

cp -a ~/.config/Code/User/globalStorage/openai.chatgpt* \
      ~/backup-codex-vscode/ 2>/dev/null
```

---

## 3. Remover apenas o estado da extensão

```bash
rm -rf ~/.config/Code/User/globalStorage/openai.chatgpt*
```

---

## 4. Abrir novamente o VS Code

```bash
code
```

Caso solicitado, efetuar novamente o login na extensão.

---

# Resultado

Após remover apenas o diretório **globalStorage**, o painel do Codex voltou a carregar normalmente.

Não foi necessário:

* reinstalar o VS Code;
* reinstalar a extensão;
* fazer downgrade da extensão.

---

# Lições aprendidas

Antes de reinstalar a extensão ou alterar versões, tente limpar apenas o estado local da extensão.

Na maioria dos casos isso preserva a instalação e resolve problemas relacionados ao WebView e ao cache interno.

---

# Histórico

| Data       | Autor          | Descrição                                                                          |
| ---------- | -------------- | ---------------------------------------------------------------------------------- |
| 14/07/2026 | Ricardo Yuaoca | Primeira versão do procedimento após resolução do problema em ambiente Linux Mint. |
