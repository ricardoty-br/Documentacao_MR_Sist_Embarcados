# Acesso Remoto ao HR1500 via SSH

## Objetivo

Acessar o HR1500 utilizando a porta de serviço Ethernet.

### Configuração da porta de serviço

| Interface     | Endereço IP         |
| ------------- | ------------------- |
| enp3s0 (ETH3) | **192.168.20.1/24** |

Configure o computador do técnico com:

| Parâmetro   | Valor             |
| ----------- | ----------------- |
| Endereço IP | **192.168.20.2**  |
| Máscara     | **255.255.255.0** |
| Gateway     | Não configurar    |

Conecte um cabo de rede diretamente entre o computador e a porta **ETH3** do HR1500.

---

# Windows

## Verificar se o cliente SSH está instalado

Abra o **PowerShell** e execute:

```powershell
ssh
```

Se aparecer a ajuda do comando, o cliente já está instalado.

Caso contrário, instale o recurso **OpenSSH Client** em:

**Configurações → Sistema → Recursos opcionais → Adicionar um recurso → OpenSSH Client**

---

## Conectar ao HR1500

No PowerShell:

```powershell
ssh user-marrari@192.168.20.1
```

Na primeira conexão responda:

```text
yes
```

Digite a senha do usuário.

---

# Linux

## Verificar se o cliente SSH está instalado

No terminal:

```bash
ssh -V
```

Caso não esteja instalado:

### Ubuntu / Linux Mint

```bash
sudo apt update
sudo apt install openssh-client
```

---

## Conectar ao HR1500

```bash
ssh user-marrari@192.168.20.1
```

Na primeira conexão responda:

```text
yes
```

Digite a senha do usuário.

---

# Teste de conectividade

Antes de conectar por SSH, verifique se o equipamento responde na rede:

```bash
ping 192.168.20.1
```

ou, no Windows:

```powershell
ping 192.168.20.1
```

Se houver resposta, a conexão SSH deverá funcionar normalmente.

---

# Arquitetura de Rede do HR1500

| Interface         | Função                          |
| ----------------- | ------------------------------- |
| **ETH1 (enp1s0)** | Rede do cliente (DHCP)          |
| **ETH2 (enp2s0)** | Sensor Wenglor (192.168.10.78)  |
| **ETH3 (enp3s0)** | Porta de serviço (192.168.20.1) |
| **ETH4 (enp4s0)** | Reserva                         |
