# Grocery2U v1.3.3 — Access Code RH

Format rasmi kod:

```text
RH-A7K9X2
RH-M4P8L7
RH-X9W2Q5
```

Spesifikasi:

- 1 kod boleh digunakan oleh ramai family.
- Default limit: 50 family untuk 1 kod.
- Admin generate 1 kod pada satu masa.
- Kod lama `RH26-XXXX` tidak digunakan lagi.
- Kod disimpan dalam `access_codes`.
- Rekod penggunaan disimpan dalam `access_code_uses`.

Admin page:

```text
/admin → Access Codes
Campaign Name
Max Family
Generate 1 Kod
```

Supabase:

Run:

```text
database/003_access_codes.sql
```
