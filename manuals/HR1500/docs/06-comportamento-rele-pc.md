# Comportamento do relé de alimentação do PC industrial

## 1. Objetivo

Este documento descreve a lógica de supervisão da alimentação AC, o envio do comando `CMD 5533` e o acionamento do relé de 12 V responsável pela alimentação do PC industrial.

O objetivo da lógica é:

- detectar a perda da alimentação AC;
- enviar uma única vez o comando `CMD 5533`, após a confirmação da falta de energia;
- manter o PC industrial alimentado durante a operação em bateria;
- executar um pulso de desligamento no relé de 12 V quando a alimentação AC retornar, forçando o religamento do PC industrial;
- impedir o envio repetido do comando ou a execução indevida do pulso de religamento.

## 2. Sinais e variáveis

| Sinal ou variável | Tipo | Descrição |
|---|---|---|
| `Bat Mode` | Entrada digital | Indica o estado da alimentação AC. Valor `1`: alimentação AC ausente e sistema operando em bateria. Valor `0`: alimentação AC presente. |
| `CMD 5533` | Comando em pulso | Comando enviado uma única vez após `Bat Mode` permanecer em nível `1` continuamente durante 1 minuto. |
| `Hab_Religamento` | Flag interno | Indica que o comando `CMD 5533` já foi enviado e que o pulso de religamento do PC está habilitado quando a alimentação AC retornar. |
| `Relé 12V` | Saída digital | Controla a alimentação de 12 V do PC industrial. Valor `1`: PC alimentado. Valor `0`: alimentação interrompida. |

## 3. Sequência temporal de operação

A Figura 1 apresenta o comportamento temporal dos sinais e das variáveis.

![Figura 1 — Gráfico temporal do comando CMD 5533 e do relé de alimentação do PC industrial](../imagens/01-grafico-temporal-rele-pc.png)

**Figura 1 — Gráfico temporal do comando CMD 5533 e do relé de alimentação do PC industrial.**

### 3.1 Operação normal

Com a alimentação AC presente:

- `Bat Mode = 0`;
- `Relé 12V = 1`;
- o PC industrial permanece alimentado;
- `Hab_Religamento = 0`, desde que não exista uma sequência de religamento pendente.

### 3.2 Queda da alimentação AC — instante t1

Quando ocorre a falta da alimentação AC:

- `Bat Mode` muda de `0` para `1`;
- o relé de 12 V permanece ligado;
- inicia-se a contagem de 1 minuto;
- o PC industrial continua alimentado pela bateria ou pela fonte de energia de contingência.

Uma interrupção momentânea que não complete 1 minuto contínuo de `Bat Mode = 1` não deve gerar o comando `CMD 5533`.

### 3.3 Envio do CMD 5533 — instante t2

Se `Bat Mode` permanecer em nível `1` continuamente durante 1 minuto:

1. é enviado um único pulso do comando `CMD 5533`;
2. simultaneamente, `Hab_Religamento` é ajustado para `1`;
3. o relé de 12 V permanece ligado.

Portanto, o envio de `CMD 5533` **não desliga o relé de 12 V**. Ele apenas habilita uma futura sequência de religamento, que será executada quando a alimentação AC retornar.

Enquanto `Bat Mode = 1`, o comando não deve ser enviado novamente.

### 3.4 Retorno da alimentação AC — instante t4

Quando a alimentação AC retorna:

- `Bat Mode` muda de `1` para `0`;
- se `Hab_Religamento = 1`, inicia-se uma temporização de 30 segundos;
- durante essa temporização, o relé de 12 V permanece ligado.

Os 30 segundos permitem a estabilização da alimentação antes da reinicialização do PC industrial.

### 3.5 Início do pulso baixo — instante t5

Após 30 segundos contínuos com `Bat Mode = 0` e `Hab_Religamento = 1`:

- `Relé 12V` muda de `1` para `0`;
- a alimentação do PC industrial é interrompida;
- inicia-se a temporização de 3 segundos.

### 3.6 Religamento do PC — instante t6

Após 3 segundos com o relé desligado:

- `Relé 12V` retorna para `1`;
- o PC industrial volta a receber alimentação;
- simultaneamente, `Hab_Religamento` é resetado para `0`.

Assim:

```text
t6 = t5 + 3 segundos
```

A borda de subida do `Relé 12V` e a borda de descida de `Hab_Religamento` ocorrem no mesmo instante `t6`.

## 4. Verificação periódica das condições de alimentação

As condições abaixo devem ser verificadas continuamente durante a execução do programa do CLP, e não somente durante sua inicialização.

| Bat Mode | Hab_Religamento | Ação na saída Relé 12V | Ação no Hab_Religamento |
|---:|---:|---|---|
| 0 | 0 | Manter ou ligar a saída em nível `1` | Manter ou resetar para `0` |
| 0 | 1 | Contar 30 s, gerar pulso baixo de 3 s e religar | Resetar para `0` no instante `t6` |
| 1 | 0 | Não ligar a saída | Setar `Hab_Religamento = 1` conforme a condição prevista para operação em bateria |
| 1 | 1 | Não ligar a saída | Manter `Hab_Religamento = 1` |

> **Observação:** durante uma sequência normal iniciada com o PC já alimentado, o relé permanece ligado enquanto o sistema opera em bateria. As condições “não ligar” da tabela são aplicáveis quando o controlador encontra o sistema com `Bat Mode = 1` e o relé ainda não foi energizado, por exemplo após inicialização ou reinicialização do CLP durante uma falta de AC.

## 5. Regras de controle

A implementação deve obedecer às seguintes regras:

1. O temporizador de 1 minuto deve ser resetado sempre que `Bat Mode` retornar para `0` antes do término da contagem.
2. O `CMD 5533` deve ser enviado somente uma vez por evento contínuo de falta de AC.
3. O relé de 12 V não deve desligar no momento do envio do `CMD 5533`.
4. `Hab_Religamento` deve subir no mesmo instante em que o pulso `CMD 5533` é iniciado, em `t2`.
5. O temporizador de 30 segundos somente deve operar quando `Bat Mode = 0` e `Hab_Religamento = 1`.
6. Se a alimentação AC cair novamente durante a contagem de 30 segundos, a contagem deve ser cancelada ou reiniciada quando a AC retornar.
7. O pulso baixo do relé deve durar 3 segundos.
8. Em `t6`, o relé deve ser religado e `Hab_Religamento` deve ser resetado simultaneamente.
9. Uma nova sequência somente poderá ocorrer após um novo evento de falta de AC que permaneça ativo pelo tempo mínimo configurado.

## 6. Resumo dos eventos

| Instante | Evento |
|---|---|
| `t0` | Operação normal com alimentação AC presente. |
| `t1` | Queda da alimentação AC e ativação de `Bat Mode`. |
| `t2` | Após 1 minuto contínuo em bateria, envio de `CMD 5533` e ativação de `Hab_Religamento`. |
| `t4` | Retorno da alimentação AC e início da contagem de 30 segundos. |
| `t5` | Desligamento do relé de 12 V, iniciando o pulso baixo. |
| `t6` | Após 3 segundos, religamento do relé e reset de `Hab_Religamento`. |
