# Apêndice - Atualização do HR1500 no PC Industrial Headless

## Objetivo

Orientar a preparação, transferência, instalação e validação de uma atualização da aplicação HR1500 em um PC industrial operando em modo headless.

Este procedimento considera que o PC industrial já possui o Ubuntu Server instalado, a rede de serviço configurada e acesso SSH habilitado.

## Padrão de rede para atualização

A atualização deve ser realizada pela porta de serviço do PC industrial.

| Equipamento | Interface | Endereço IP |
| ----------- | --------- | ----------- |
| PC industrial HR1500 | ETH3 / `enp3s0` | `192.168.20.1/24` |
| PC do técnico | Ethernet local | `192.168.20.2/24` |

Configure o PC do técnico com:

| Parâmetro | Valor |
| --------- | ----- |
| Endereço IP | `192.168.20.2` |
| Máscara | `255.255.255.0` |
| Gateway | Não configurar |

Conecte um cabo de rede diretamente entre o PC do técnico e a porta **ETH3** do PC industrial.

### Windows

Configure o IP fixo pela interface gráfica do Windows.

1. Abra o menu **Iniciar**.
2. Acesse **Configurações**.
3. Entre em **Rede e Internet**.
4. Abra **Configurações avançadas de rede**.
5. Selecione a interface Ethernet conectada ao PC industrial.
6. Abra as propriedades da interface.
7. Em **Atribuição de IP**, clique em **Editar**.
8. Selecione **Manual**.
9. Habilite **IPv4**.
10. Preencha os campos:

| Campo | Valor |
| ----- | ----- |
| Endereço IP | `192.168.20.2` |
| Máscara de sub-rede | `255.255.255.0` |
| Gateway | Deixar em branco |
| DNS preferencial | Deixar em branco |
| DNS alternativo | Deixar em branco |

11. Salve a configuração.

Após configurar o IP, abra o PowerShell para os testes de comunicação e transferência.

Verifique se o cliente OpenSSH está disponível no Windows.

```powershell
ssh
scp
```

Se os comandos apresentarem a ajuda de uso, o cliente está instalado. Caso contrário, instale o recurso **OpenSSH Client** nos recursos opcionais do Windows.

Verifique a configuração aplicada.

```powershell
ipconfig
```

### Linux com terminal

Identifique o nome da interface Ethernet conectada ao PC industrial.

```bash
ip -br link
```

Defina a interface utilizada.

```bash
IFACE=enp0s31f6
```

Configure temporariamente o IP fixo do PC do técnico.

```bash
sudo ip addr flush dev $IFACE
sudo ip addr add 192.168.20.2/24 dev $IFACE
sudo ip link set $IFACE up
```

Verifique a configuração aplicada.

```bash
ip -br addr show $IFACE
```

## Preparação da versão no PC de desenvolvimento

No PC de desenvolvimento, acesse o diretório do projeto da aplicação HR1500.

```bash
cd /home/ricardo/wecat3d_proj_linux
```

Antes de gerar o pacote, confirme se o projeto compila corretamente.

```bash
make
```

Defina a versão que será liberada.

```bash
VERSAO=1.0.3
```

Gere o pacote Debian utilizando a versão definida.

```bash
VERSION=$VERSAO ./build_deb.sh
```

Ao final da geração, confirme se o arquivo `.deb` foi criado.

```bash
ls -lh dist/hr1500_${VERSAO}_amd64.deb
```

Opcionalmente, verifique os metadados do pacote.

```bash
dpkg-deb --field dist/hr1500_${VERSAO}_amd64.deb Package Version Architecture
```

O resultado esperado deve indicar:

```text
Package: hr1500
Version: 1.0.3
Architecture: amd64
```

Substitua `1.0.3` pela versão real preparada para a atualização.

## Teste de comunicação com o PC industrial

No PC do técnico, confirme se o PC industrial responde na rede de serviço.

No Windows PowerShell:

```powershell
ping 192.168.20.1
```

No Linux:

```bash
ping 192.168.20.1
```

Defina o usuário de acesso SSH utilizado no equipamento.

No Windows PowerShell:

```powershell
$USUARIO_HR1500 = "user-marrari"
```

No Linux:

```bash
USUARIO_HR1500=user-marrari
```

Caso o usuário configurado no equipamento seja diferente, ajuste o valor da variável antes de prosseguir.

Em seguida, teste o acesso SSH.

No Windows PowerShell:

```powershell
ssh "$USUARIO_HR1500@192.168.20.1"
```

No Linux:

```bash
ssh ${USUARIO_HR1500}@192.168.20.1
```

## Cópia do pacote para o PC industrial

No PC de desenvolvimento ou no PC do técnico, copie o pacote `.deb` para o diretório do usuário no PC industrial.

Se a cópia for feita a partir de um PC técnico Windows, o arquivo `.deb` deve estar disponível em uma pasta local do Windows. Abra o PowerShell nessa pasta ou ajuste o caminho do arquivo no comando.

No Windows PowerShell:

```powershell
$VERSAO = "1.0.3"
$PACOTE = "hr1500_${VERSAO}_amd64.deb"
scp ".\dist\$PACOTE" "$($USUARIO_HR1500)@192.168.20.1:~/"
```

No Linux:

```bash
scp dist/hr1500_${VERSAO}_amd64.deb ${USUARIO_HR1500}@192.168.20.1:~/
```

Após a cópia, acesse o PC industrial.

No Windows PowerShell:

```powershell
ssh "$USUARIO_HR1500@192.168.20.1"
```

No Linux:

```bash
ssh ${USUARIO_HR1500}@192.168.20.1
```

No terminal do PC industrial, defina novamente a versão que será instalada.

```bash
VERSAO=1.0.3
```

Confirme se o pacote está disponível.

```bash
ls -lh ~/hr1500_${VERSAO}_amd64.deb
```

## Instalação da atualização

No PC industrial, instale o pacote.

```bash
sudo apt install ./hr1500_${VERSAO}_amd64.deb
```

Caso o arquivo tenha sido copiado com uma versão fixa no nome, utilize o nome real do pacote.

Exemplo:

```bash
sudo apt install ./hr1500_1.0.3_amd64.deb
```

Confirme a versão instalada.

```bash
dpkg -s hr1500 | grep -E 'Package|Version|Status'
```

Verifique se os arquivos principais foram instalados em `/opt/hr1500`.

```bash
ls -l /opt/hr1500
```

## Verificação do serviço

Após a instalação, confirme se o serviço está ativo.

```bash
systemctl is-active hr1500.service
```

O resultado esperado é:

```text
active
```

Consulte o status detalhado.

```bash
systemctl status hr1500.service
```

Se o serviço não estiver ativo, habilite a inicialização automática e inicie o serviço.

```bash
sudo systemctl enable hr1500.service
sudo systemctl start hr1500.service
```

Se o serviço já estiver instalado, mas parado ou com comportamento incorreto, reinicie o serviço.

```bash
sudo systemctl restart hr1500.service
```

Confirme novamente o estado.

```bash
systemctl is-active hr1500.service
systemctl is-enabled hr1500.service
```

Para acompanhar mensagens em tempo real:

```bash
journalctl -u hr1500.service -f
```

## Verificação da permissão de desligamento

A aplicação HR1500 deve conseguir executar o desligamento do Linux quando o comando correspondente for recebido do CLP.

Primeiro, confirme com qual usuário o serviço está sendo executado.

```bash
systemctl cat hr1500.service
```

Verifique se a unidade do serviço indica execução como `root`.

```text
User=root
Group=root
```

Confirme também o processo em execução.

```bash
ps -eo user,group,pid,cmd | grep '[H]R1500'
```

O usuário do processo deve ser `root`.

Para testar a permissão de desligamento sem desligar imediatamente o equipamento, utilize uma execução agendada de curta duração e cancele em seguida.

```bash
sudo shutdown -h +1
sudo shutdown -c
```

Se os dois comandos forem aceitos sem erro, o sistema possui permissão para solicitar o desligamento.

> Não execute `sudo poweroff`, `sudo shutdown -h now` ou comandos equivalentes durante a validação, exceto quando o desligamento real do PC industrial estiver autorizado.

## Teste de comunicação com a página Web

Com o serviço ativo, abra um navegador no PC do técnico e acesse:

```text
http://192.168.20.1
```

Confirme os seguintes pontos:

| Verificação | Resultado esperado |
| ----------- | ------------------ |
| Página Web abre no navegador | Interface carregada sem erro |
| Leitura de valores atuais | Campos apresentados corretamente |
| Salvamento de configuração | Alteração aceita pela aplicação |
| Serviço permanece ativo | `systemctl is-active hr1500.service` retorna `active` |

Também é possível testar a resposta HTTP pelo terminal.

No Windows PowerShell:

```powershell
curl.exe -I http://192.168.20.1
```

No Linux:

```bash
curl -I http://192.168.20.1
```

O resultado esperado deve indicar resposta HTTP da aplicação.

## Resumo de comandos úteis

### Rede

Windows:

1. Configurar a interface Ethernet pela interface gráfica:

| Campo | Valor |
| ----- | ----- |
| Endereço IP | `192.168.20.2` |
| Máscara de sub-rede | `255.255.255.0` |
| Gateway | Deixar em branco |

2. Validar pelo PowerShell:

```powershell
ipconfig
ping 192.168.20.1
$USUARIO_HR1500 = "user-marrari"
ssh "$USUARIO_HR1500@192.168.20.1"
```

Linux:

```bash
ip -br link
ip -br addr
ip route
ping 192.168.20.1
USUARIO_HR1500=user-marrari
ssh ${USUARIO_HR1500}@192.168.20.1
```

### Pacote

Windows PowerShell:

```powershell
$VERSAO = "1.0.3"
$USUARIO_HR1500 = "user-marrari"
$PACOTE = "hr1500_${VERSAO}_amd64.deb"
scp ".\dist\$PACOTE" "$($USUARIO_HR1500)@192.168.20.1:~/"
ssh "$USUARIO_HR1500@192.168.20.1"
```

Linux:

```bash
VERSAO=1.0.3
USUARIO_HR1500=user-marrari
VERSION=$VERSAO ./build_deb.sh
ls -lh dist/hr1500_${VERSAO}_amd64.deb
dpkg-deb --field dist/hr1500_${VERSAO}_amd64.deb Package Version Architecture
scp dist/hr1500_${VERSAO}_amd64.deb ${USUARIO_HR1500}@192.168.20.1:~/
sudo apt install ./hr1500_${VERSAO}_amd64.deb
dpkg -s hr1500 | grep -E 'Package|Version|Status'
```

### Serviço

```bash
systemctl is-active hr1500.service
systemctl is-enabled hr1500.service
systemctl status hr1500.service
sudo systemctl enable hr1500.service
sudo systemctl start hr1500.service
sudo systemctl restart hr1500.service
journalctl -u hr1500.service -f
```

### Permissão de desligamento

```bash
systemctl cat hr1500.service
ps -eo user,group,pid,cmd | grep '[H]R1500'
sudo shutdown -h +1
sudo shutdown -c
```

### Página Web

Windows PowerShell:

```powershell
curl.exe -I http://192.168.20.1
```

Linux:

```bash
curl -I http://192.168.20.1
```

Endereço para navegador:

```text
http://192.168.20.1
```

## Checklist rápido de atualização

| Etapa | Verificação | OK |
| ----- | ----------- | -- |
| Preparação | Versão definida no PC de desenvolvimento | [ ] |
| Compilação | `make` concluído sem erro | [ ] |
| Pacote | `dist/hr1500_<VERSAO>_amd64.deb` gerado | [ ] |
| Rede | PC técnico Windows ou Linux configurado como `192.168.20.2/24` | [ ] |
| Cabo | PC técnico conectado à ETH3 do PC industrial | [ ] |
| Ping | `ping 192.168.20.1` com resposta | [ ] |
| SSH | Acesso ao PC industrial realizado | [ ] |
| Cópia | Pacote `.deb` copiado para o PC industrial | [ ] |
| Instalação | `sudo apt install ./hr1500_<VERSAO>_amd64.deb` concluído | [ ] |
| Versão | `dpkg -s hr1500` mostra a versão correta | [ ] |
| Serviço | `systemctl is-active hr1500.service` retorna `active` | [ ] |
| Inicialização | `systemctl is-enabled hr1500.service` retorna `enabled` | [ ] |
| Desligamento | Serviço executando como `root` | [ ] |
| Web | Página `http://192.168.20.1` abre no navegador | [ ] |
| Logs | `journalctl -u hr1500.service` sem erro crítico | [ ] |

## Observações

- A atualização pelo pacote `.deb` deve preservar os arquivos de configuração existentes em `/opt/hr1500`, incluindo `config.ini` e `perfil_zero.cfg`.
- Caso seja necessário executar uma reinstalação limpa, faça backup dos arquivos de configuração antes de remover diretórios de dados.
- Sempre registre a versão instalada e o horário da atualização no relatório de manutenção do equipamento.
