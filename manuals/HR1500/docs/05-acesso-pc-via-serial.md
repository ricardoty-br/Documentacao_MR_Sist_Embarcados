# Acesso ao Console Serial do HR1500

## Objetivo

Acessar o console do Ubuntu Server através da porta serial RS-232 do PC industrial para diagnóstico, configuração e recuperação do sistema.

---

# Materiais necessários

* Notebook Windows ou Linux
* Conversor USB-RS232
* Cabo serial RJ45-DB9

---

# Pinagem do cabo serial

## PC Industrial (RJ45)

| Pino | Sinal |
| ---- | ----- |
| 6    | RX    |
| 3    | TX    |
| 5    | GND   |

## DB9

| Pino | Sinal |
| ---- | ----- |
| 2    | RX    |
| 3    | TX    |
| 5    | GND   |

Conectar o cabo RJ45 ao PC industrial e o DB9 ao conversor USB-RS232.

---

# Linux (Ubuntu / Linux Mint)

## Instalar o Minicom

```bash
sudo apt update
sudo apt install minicom
```

---

## Identificar a porta serial

Antes de conectar o conversor:

```bash
ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
```

Após conectar:

```bash
dmesg | tail
```

ou

```bash
ls /dev/ttyUSB*
```

Exemplo:

```text
/dev/ttyUSB0
```

---

## Configurar o Minicom

```bash
sudo minicom -s
```

Configuração:

```text
Serial Device      : /dev/ttyUSB0
Bps/Par/Bits       : 115200 8N1
Hardware Flow Ctrl : No
Software Flow Ctrl : No
```

Salvar a configuração:

```text
Save setup as dfl
```

---

## Abrir o console

```bash
sudo minicom
```

Será apresentado o login do Ubuntu:

```text
hr1500-server login:
```

---

# Windows

Recomenda-se utilizar o **PuTTY**.

Configuração:

```text
Connection Type : Serial
Speed           : 115200
Data bits       : 8
Parity          : None
Stop bits       : 1
Flow Control    : None
```

Selecionar a porta COM correspondente ao conversor USB-RS232 e abrir a conexão.

---

# Comandos úteis

## Interfaces de rede

```bash
ip -br addr
```

---

## Rotas

```bash
ip route
```

---

## Endereços IP

```bash
hostname -I
```

---

## Estado das interfaces

```bash
ip -br link
```

---

## Testar comunicação

```bash
ping <endereço IP>
```

Exemplo:

```bash
ping 192.168.20.2
```

---

# Serviço HR1500

## Verificar status

```bash
systemctl status hr1500.service
```

---

## Reiniciar

```bash
sudo systemctl restart hr1500.service
```

---

## Parar

```bash
sudo systemctl stop hr1500.service
```

---

## Iniciar

```bash
sudo systemctl start hr1500.service
```

---

## Confirmar inicialização automática

```bash
systemctl is-enabled hr1500.service
```

---

## Verificar processo

```bash
ps -ef | grep HR1500
```

ou

```bash
pgrep -a HR1500
```

---

## Acompanhar mensagens do serviço

```bash
journalctl -u hr1500.service -f
```

---

# Informações do sistema

## Utilização de disco

```bash
df -h
```

---

## Utilização de memória

```bash
free -h
```

---

## Tempo de funcionamento

```bash
uptime
```

---

## Reiniciar o equipamento

```bash
sudo reboot
```

---

## Desligar o equipamento

```bash
sudo poweroff
```

---

# Arquitetura de Rede

| Interface | Função           | Configuração     |
| --------- | ---------------- | ---------------- |
| enp1s0    | Rede do cliente  | DHCP             |
| enp2s0    | Sensor Wenglor   | 192.168.10.78/24 |
| enp3s0    | Porta de serviço | 192.168.20.1/24  |
| enp4s0    | Reserva          | Sem configuração |

---

# Observações

* A porta serial é o método de acesso de recuperação quando não for possível utilizar SSH.
* Recomenda-se utilizar a porta de serviço **ETH3 (192.168.20.1)** para manutenção e configuração do equipamento.
* Caso seja necessário alterar a configuração de rede, consulte o documento **04-configuracao-rede.md**.
