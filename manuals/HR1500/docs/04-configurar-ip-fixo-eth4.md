# Configuração das Interfaces de Rede do HR1500

## Objetivo

Alterar a configuração das interfaces Ethernet do HR1500.

> **Recomendação:** sempre utilize a porta de serviço **ETH3 (192.168.20.1)** para realizar alterações na configuração de rede.

---

# Arquitetura padrão

| Interface | Função           | Configuração     |
| --------- | ---------------- | ---------------- |
| enp1s0    | Rede do cliente  | DHCP             |
| enp2s0    | Sensor Wenglor   | 192.168.10.78/24 |
| enp3s0    | Porta de serviço | 192.168.20.1/24  |
| enp4s0    | Reserva          | Sem configuração |

---

# 1. Fazer backup

Antes de qualquer alteração:

```bash
sudo cp /etc/netplan/00-installer-config.yaml \
/etc/netplan/00-installer-config.yaml.bak
```

---

# 2. Editar o arquivo de configuração

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

---

# 3. Exemplo: configurar a interface enp4s0 com IP fixo

```yaml
network:
  version: 2

  ethernets:

    enp1s0:
      dhcp4: true
      dhcp6: true

    enp2s0:
      dhcp4: false
      addresses:
        - 192.168.10.78/24

    enp3s0:
      dhcp4: false
      addresses:
        - 192.168.20.1/24

    enp4s0:
      dhcp4: false
      addresses:
        - 192.168.100.50/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

Substitua os valores conforme a rede do cliente.

---

# 4. Validar a configuração

```bash
sudo netplan generate
```

Se não houver mensagens de erro, aplicar:

```bash
sudo netplan apply
```

---

# 5. Verificar a configuração

Interfaces:

```bash
ip -br addr
```

Rotas:

```bash
ip route
```

Conectividade:

```bash
ping <gateway>
```

---

# Observações

* Não configure duas interfaces na mesma sub-rede, exceto quando houver necessidade específica e regras de roteamento apropriadas.
* Utilize a porta **ETH3 (192.168.20.1)** para manutenção, evitando perda de acesso durante alterações na rede.
* Mantenha a interface **enp2s0** dedicada ao sensor Wenglor.
* Não deixe arquivos adicionais com extensão **.yaml** em `/etc/netplan`, pois todos serão processados pelo Netplan. Arquivos de backup devem utilizar outra extensão (por exemplo, `.bak`) ou ser armazenados em outro diretório.
