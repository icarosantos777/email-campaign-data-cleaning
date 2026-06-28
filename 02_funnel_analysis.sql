-- FUNIL GERAL 
-- quantos chegaram em cada etapa e a taxa de conversao entre elas
SELECT
  COUNT(*) AS enviados,
  COUNTIF(open_date IS NOT NULL) AS abertos,
  COUNTIF(click_date IS NOT NULL) AS cliques,
  COUNTIF(transaction_date IS NOT NULL) AS transacoes,
  ROUND(COUNTIF(open_date IS NOT NULL) / COUNT(*) * 100, 1) AS taxa_abertura_pct,
  -- clique sobre quem abriu (faz mais sentido que sobre o total)
  ROUND(COUNTIF(click_date IS NOT NULL) / COUNTIF(open_date IS NOT NULL) * 100, 1) AS taxa_clique_pct,
  -- conversao final sobre o total de enviados
  ROUND(COUNTIF(transaction_date IS NOT NULL) / COUNT(*) * 100, 2) AS taxa_conversao_pct
FROM `portfolio-data-analyst-500002.email_campaigns.clean_data`;


-- FUNIL POR CAMPANHA
-- compara a performance de cada e-mail. mostra qual converte melhor.
SELECT
  email_name,
  COUNT(*) AS enviados,
  COUNTIF(open_date IS NOT NULL) AS abertos,
  COUNTIF(click_date IS NOT NULL) AS cliques,
  COUNTIF(transaction_date IS NOT NULL) AS transacoes,
  ROUND(COUNTIF(open_date IS NOT NULL) / COUNT(*) * 100, 1) AS taxa_abertura_pct,
  ROUND(COUNTIF(transaction_date IS NOT NULL) / COUNT(*) * 100, 2) AS taxa_conversao_pct
FROM `portfolio-data-analyst-500002.email_campaigns.clean_data`
GROUP BY email_name
ORDER BY taxa_conversao_pct DESC;


-- ===== 3. RECEITA POR CAMPANHA =====
-- nao basta converter: quanto cada campanha trouxe de fato?
SELECT
  email_name,
  COUNT(transaction_amount) AS qtd_transacoes,
  ROUND(SUM(transaction_amount), 2) AS receita_total,
  ROUND(AVG(transaction_amount), 2) AS ticket_medio
FROM `portfolio-data-analyst-500002.email_campaigns.clean_data`
WHERE transaction_amount IS NOT NULL
GROUP BY email_name
ORDER BY receita_total DESC;


-- ===== 4. TEMPO ATE ABRIR =====
-- quanto tempo a pessoa leva pra abrir depois do envio.
-- ajuda a entender quando o e-mail "esfria".
SELECT
  COUNT(*) AS emails_abertos,
  ROUND(AVG(TIMESTAMP_DIFF(open_date, sent_date, MINUTE)), 1) AS media_min_ate_abrir,
  APPROX_QUANTILES(TIMESTAMP_DIFF(open_date, sent_date, MINUTE), 2)[OFFSET(1)] AS mediana_min_ate_abrir
FROM `portfolio-data-analyst-500002.email_campaigns.clean_data`
WHERE open_date IS NOT NULL
  AND open_date >= sent_date;  -- ignora ruido de data invertida, se houver
