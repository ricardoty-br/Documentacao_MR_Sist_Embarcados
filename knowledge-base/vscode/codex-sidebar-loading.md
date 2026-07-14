# Solução

As etapas abaixo devem ser executadas na ordem apresentada.

---

## Opção 1 – Limpar o cache temporário dos plugins (menos invasiva)

Feche completamente o VS Code.

```bash
pkill -f code
```

Remova o cache temporário dos plugins do Codex:

```bash
rm -rf ~/.codex/.tmp/plugins
```

Abra novamente o VS Code:

```bash
code
```

Se o problema desaparecer, nenhuma outra ação é necessária.

---

## Opção 2 – Limpar o estado da extensão (mais invasiva)

Caso a Opção 1 não resolva o problema, remova o estado local da extensão.

Antes, opcionalmente faça um backup:

```bash
mkdir -p ~/backup-codex-vscode

cp -a ~/.config/Code/User/globalStorage/openai.chatgpt* \
      ~/backup-codex-vscode/ 2>/dev/null
```

Remova o estado armazenado pela extensão:

```bash
rm -rf ~/.config/Code/User/globalStorage/openai.chatgpt*
```

Abra novamente o VS Code:

```bash
code
```

Caso solicitado, efetue novamente o login na extensão.

---

# Resultado

Nos testes realizados, ambas as soluções já resolveram o problema em momentos diferentes.

### Situação 1

A remoção do cache temporário dos plugins foi suficiente:

```bash
rm -rf ~/.codex/.tmp/plugins
```

### Situação 2

Foi necessário remover o estado interno da extensão:

```bash
rm -rf ~/.config/Code/User/globalStorage/openai.chatgpt*
```

---

# Observações

* A **Opção 1** é a primeira tentativa recomendada, pois apenas remove arquivos temporários dos plugins.
* A **Opção 2** redefine o estado interno da extensão e pode exigir nova autenticação.
* Nenhuma das duas opções requer reinstalação da extensão ou do VS Code.
