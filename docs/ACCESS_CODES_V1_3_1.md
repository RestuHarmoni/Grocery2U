# Grocery2U v1.3.1 — Access Code / Follower Code

Update ini tambah modul **Access Codes** di `/admin`.

## Format kod rasmi

Contoh:

```text
RH26-A7K9
RH26-M3P8
RH26-X9L2
```

Struktur:

```text
RH26 = prefix campaign
A7K9 = random code
```

## Cara guna di admin

1. Buka `/admin`
2. Login staf
3. Pergi tab **Access Codes**
4. Isi:
   - Batch Name: `RH_FOLLOWER_001`
   - Prefix: `RH26`
   - Quantity: `50`
5. Tekan **Generate Kod**
6. Copy / Export CSV kod untuk diberi kepada follower

## Rule

- 1 kod = 1 akaun/family access
- Kod yang sudah digunakan akan jadi `Used`
- Kod tidak boleh digunakan semula
- Admin boleh export CSV untuk kempen FB/TikTok/IG

## Supabase

Run fail ini selepas schema dan admin setup:

```text
database/003_access_codes.sql
```

## Nota production

Untuk production penuh, proses verify code sebaiknya dibuat melalui backend trusted / Supabase Edge Function supaya logic penggunaan kod tidak hanya bergantung kepada frontend.
