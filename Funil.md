# Limpeza de dados de campanha de e-mail marketing (SQL + BigQuery)

Projeto de prática de SQL com foco em **qualidade de dados**. Em vez de analisar
um dataset já limpo, peguei um dataset público, inseri problemas de propósito com
Python e reconstruí a versão original usando **apenas SQL** no BigQuery.

> Os problemas deste dataset foram **inseridos por mim de propósito** pra simular
> um cenário realista de dados sujos. É um ambiente controlado de treino — o
> script que faz a "bagunça" está no próprio repositório (`00_make_messy.py`),
> então dá pra ver exatamente o que foi alterado.

## O experimento

Parti de um dataset limpo (42.099 linhas), "baguncei" ele e tentei voltar ao
número original só com um pipeline de limpeza. Se a contagem batesse no fim, a
limpeza estava correta. Bateu: **43.362 linhas sujas → 42.099 limpas.**

## Problemas inseridos (e como tratei)

| Problema | Como foi inserido | Solução em SQL |
|---|---|---|
| Duplicatas | cópia de ~3% das linhas | padronizar antes, depois `ROW_NUMBER()` |
| Zeros à esquerda perdidos | `account_number` lido como inteiro no BigQuery | `LPAD(..., 8, '0')` |
| Espaços extras e case | `name` em maiúsculo/minúsculo com espaços | `INITCAP(TRIM(...))` |
| Datas em formato misto | parte convertida pra ISO sobre o americano original | `COALESCE` + `SAFE.PARSE_DATETIME` |
| Valores negativos | sinal trocado em ~8% de `transaction_amount` | `ABS()` |
| Typo "Wellcome" | `Welcome` escrito errado de propósito | `REPLACE()` |

## Três coisas que aprendi

1. **A importação corrompe dados em silêncio.** O auto detect do BigQuery leu
   `account_number` como inteiro e cortou os zeros à esquerda. Nenhum erro, mas o
   bastante pra quebrar um JOIN depois.
2. **Validar suposição vale tanto quanto escrever a query.** Assumi que as datas
   eram `DD/MM/YYYY`; um "mês 23" impossível mostrou que o formato era americano
   (`M/D/YYYY`).
3. **A ordem das operações importa.** Deduplicar antes de padronizar os textos
   deixava "Linda Howell" e "LINDA HOWELL" como pessoas diferentes. A correção foi
   normalizar primeiro, deduplicar depois.

## Arquivos

- [`00_make_messy.py`](00_make_messy.py) — script Python que injeta os problemas.
- [`01_data_cleaning.sql`](01_data_cleaning.sql) — auditoria, limpeza e validação no BigQuery.
- [`02_funnel_analysis.sql`](02_funnel_analysis.sql) — análise de funil sobre os dados limpos (conversão e receita por campanha).
