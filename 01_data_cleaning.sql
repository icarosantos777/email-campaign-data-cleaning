-- nulls e total de linhas
-- (varios nulls aqui nao sao erro, sao funil: quem nao abriu nao tem open_date, etc)
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT `index`) AS unique_index,
  COUNTIF(open_date IS NULL) AS null_open,
  COUNTIF(click_date IS NULL) AS null_click,
  COUNTIF(transaction_date IS NULL) AS null_transaction,
  COUNTIF(transaction_amount IS NULL) AS null_amount
FROM `portfolio-data-analyst-500002.email_campaigns.messy_email_campaigns`;


-- duplicatas (mesma pessoa, mesma campanha, mesma data)
SELECT `index`, name, account_number, email_name, sent_date, COUNT(*) AS qtd
FROM `portfolio-data-analyst-500002.email_campaigns.messy_email_campaigns`
GROUP BY `index`, name, account_number, email_name, sent_date
HAVING COUNT(*) > 1
ORDER BY qtd DESC;


-- nomes com espaco/case bagunçado
SELECT name, TRIM(name) AS trimmed, LENGTH(name) - LENGTH(TRIM(name)) AS espacos
FROM `portfolio-data-analyst-500002.email_campaigns.messy_email_campaigns`
WHERE name != TRIM(name) OR name = UPPER(name) OR name = LOWER(name);


-- formato das datas em sent_date 
SELECT
  sent_date,
  CASE
    WHEN REGEXP_CONTAINS(sent_date, r'^\d{4}-\d{2}-\d{2}') THEN 'iso'
    WHEN REGEXP_CONTAINS(sent_date, r'^\d{1,2}/\d{1,2}/\d{4}') THEN 'us'
    ELSE '?'
  END AS formato
FROM `portfolio-data-analyst-500002.email_campaigns.messy_email_campaigns`;


-- tipo de cada coluna (rodei isso depois de tomar erro no parse das datas)
SELECT column_name, data_type
FROM `portfolio-data-analyst-500002.email_campaigns.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'messy_email_campaigns';



-- LIMPEZA
-- padronizar o nome antes de deduplicar, senao "Linda Howell" e "LINDA HOWELL" passam como pessoas diferentes (erro que me custou um tempo)
CREATE OR REPLACE TABLE `portfolio-data-analyst-500002.email_campaigns.clean_data` AS

WITH standardized AS (
  SELECT
    `index`,
    INITCAP(TRIM(name)) AS name,
    LPAD(CAST(account_number AS STRING), 8, '0') AS account_number, -- recupera os zeros a esquerda
    REPLACE(email_name, 'Wellcome', 'Welcome') AS email_name,
    COALESCE(
      SAFE.PARSE_DATETIME('%Y-%m-%d %H:%M', sent_date),
      SAFE.PARSE_DATETIME('%m/%d/%Y %H:%M', sent_date)
    ) AS sent_date,
    CAST(open_date AS DATETIME) AS open_date,
    CAST(click_date AS DATETIME) AS click_date,
    CAST(bounce_date AS DATETIME) AS bounce_date,
    CAST(transaction_date AS DATETIME) AS transaction_date,
    ABS(transaction_amount) AS transaction_amount -- tinha negativo onde nao podia
  FROM `portfolio-data-analyst-500002.email_campaigns.messy_email_campaigns`
),

dedup AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY name, account_number, email_name, sent_date
      ORDER BY `index`
    ) AS rn
  FROM standardized
)

SELECT
  `index`, name, account_number, email_name, sent_date,
  open_date, click_date, bounce_date, transaction_date, transaction_amount
FROM dedup
WHERE rn = 1;

-- VALIDAÇAO
-- esperado: 42099 linhas (igual ao original), zero negativo, zero data nula
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(transaction_amount < 0) AS negativo,
  COUNTIF(sent_date IS NULL) AS data_nula,
  COUNT(DISTINCT account_number) AS contas
FROM `portfolio-data-analyst-500002.email_campaigns.clean_data`;
