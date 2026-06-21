# Grocery2U by RH v1.3.7 — RLS MVP Policy Fix

## Masalah
Admin Access Code Generator sudah cuba menulis ke Supabase, tetapi Supabase menolak insert dengan error:

`new row violates row-level security policy for table "access_codes"`

Ini berlaku kerana admin Grocery2U menggunakan login username/password sendiri, bukan Supabase Auth. Dari sudut Supabase, request frontend menggunakan role `anon`, lalu RLS menolak operasi insert.

## Fail SQL baru
Run fail ini selepas semua SQL utama:

1. `database/001_supabase_schema.sql`
2. `database/002_admin_username_password.sql`
3. `database/003_access_codes.sql`
4. `database/004_rls_mvp_policy_fix.sql`

## Untuk QA
Selepas run SQL:

1. Buka `/admin`
2. Login admin
3. Pergi tab Access Codes
4. Tekan `Generate 1 Kod`
5. Semak table `access_codes`

Expected result:

- Kod format `RH-XXXXXX` masuk ke Supabase
- Statistik Access Codes berubah daripada 0 kepada 1
- `max_family` default 50
- `used_count` mula 0

## Nota keselamatan
Policy ini sesuai untuk MVP/QA sahaja kerana ia membenarkan frontend anon key membaca/menulis table utama. Untuk production penuh, perlu ganti dengan Edge Function atau sistem session admin yang lebih ketat.
