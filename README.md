# Limpeza de dados de campanha de e-mail marketing (SQL + BigQuery)

Projeto de prática de SQL com foco em **qualidade de dados**. Em vez de analisar
um dataset já limpo, peguei um dataset público (42 mil registros), inseri
problemas de propósito e tentei reconstruir a versão original usando apenas SQL.

**Os problemas deste dataset foram inseridos por mim propositalmente, com um script Python, pra simular um cenário realista de dados sujos e praticar. Não é um dataset "selvagem" é um ambiente controlado de treino.**

## O experimento

Parti de um dataset limpo (42.099 linhas), "baguncei" ele e tentei voltar ao
número original só com um pipeline de limpeza no BigQuery. Se a contagem batesse
no fim, a limpeza estava correta. Bateu: **43.362 linhas sujas → 42.099 limpas.**

## Problemas inseridos (e como tratei)

| Problema | Causa simulada | Solução em SQL |
|---|---|---|
| Duplicatas | erro de import / ETL | padronizar antes, depois `ROW_NUMBER()` |
| Zeros à esquerda perdidos | `account_number` lido como inteiro | `LPAD(..., 8, '0')` |
| Espaços extras e case | digitação / sistemas diferentes | `INITCAP(TRIM(...))` |
| Datas em formato misto | exportações diferentes | `COALESCE` + `SAFE.PARSE_DATETIME` |
| Valores negativos | erro de sinal | `ABS()` |
| Typo "Wellcome" | erro de digitação na campanha | `REPLACE()` |

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

## Arquivo

- [`01_data_cleaning.sql`](01_data_cleaning.sql) — auditoria, limpeza e validação.
