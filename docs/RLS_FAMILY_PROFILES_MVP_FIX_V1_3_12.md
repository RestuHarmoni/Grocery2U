# Grocery2U v1.3.12 — RLS Family Profiles MVP Fix

## Issue
Tambah profil keluarga gagal dengan error:

`new row violates row-level security policy for table "family_profiles"`

## Fix
Run SQL:

```text
database/008_rls_family_profiles_mvp_fix.sql
```

SQL ini disable RLS untuk table operasi MVP supaya QA boleh diteruskan:

- `family_profiles`
- `app_users`
- `families`
- `family_members`
- `access_codes`
- `access_code_uses`
- `shopping_lists`
- `shopping_list_items`
- `receipts`

## QA selepas run
1. Refresh app.
2. Login user.
3. Tambah profil Ibu/Anak.
4. Semak table `family_profiles` di Supabase.
5. Rekod profile mesti masuk Supabase.

## Nota Security
Ini untuk MVP/closed testing sahaja. Sebelum public production, RLS perlu diketatkan semula dengan policy per-family.
