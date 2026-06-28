import pandas as pd
import numpy as np

np.random.seed(42)

df = pd.read_csv('filtered_dataset.csv')
print(f"Shape original: {df.shape}")


# 1. duplicatas (simula erro de import/ETL)
dup_rows = df.sample(frac=0.03, random_state=1)
df = pd.concat([df, dup_rows], ignore_index=True)


# 2. inconsistencia de case e espacos no nome
mask_name = df.sample(frac=0.15, random_state=2).index
df.loc[mask_name, 'name'] = df.loc[mask_name, 'name'].apply(
    lambda x: f"  {x.upper()}  " if np.random.random() > 0.5 else x.lower()
)


# 3. datas em formato diferente no sent_date (mistura ISO no que ja era americano)
mask_date = df.sample(frac=0.10, random_state=3).index

def shuffle_date_format(date_str):
    if pd.isna(date_str):
        return date_str
    try:
        dt = pd.to_datetime(date_str)
        return dt.strftime('%Y-%m-%d %H:%M')
    except:
        return date_str

df.loc[mask_date, 'sent_date'] = df.loc[mask_date, 'sent_date'].apply(shuffle_date_format)


# 4. account_number com zero a esquerda (vira string tipo "0084256863")
mask_acc = df.sample(frac=0.05, random_state=4).index
df.loc[mask_acc, 'account_number'] = df.loc[mask_acc, 'account_number'].apply(
    lambda x: f"{x:010d}"
)


# 5. transaction_amount negativo onde nao deveria (erro de sinal)
mask_amount = df[df['transaction_amount'].notna()].sample(frac=0.08, random_state=5).index
df.loc[mask_amount, 'transaction_amount'] = df.loc[mask_amount, 'transaction_amount'] * -1


# 6. typo no nome da campanha: Welcome -> Wellcome
mask_email = df.sample(frac=0.05, random_state=6).index
df.loc[mask_email, 'email_name'] = df.loc[mask_email, 'email_name'].str.replace(
    'Welcome', 'Wellcome', regex=False
)


print(f"Shape final (com bagunça): {df.shape}")
print(f"Duplicatas: {df.duplicated().sum()}")

df.to_csv('email_campaign_messy.csv', index=False)
