# Grocery2U v1.3.11 — Family Profiles Supabase Write Fix

## Tujuan
Patch ini memastikan profil keluarga yang dibuat selepas login disimpan ke Supabase table `family_profiles`, bukan localStorage sahaja.

## SQL yang perlu run
Run fail berikut dalam Supabase SQL Editor:

```text
database/007_family_profiles_supabase_write_fix.sql
```

## QA
1. Login user.
2. Jika screen pilih profil keluar, tekan `Tambah Profil`.
3. Masukkan role dan nama profil.
4. Semak Supabase → Table Editor → `family_profiles`.
5. Rekod profil baharu mesti muncul.
6. Refresh app, profil masih muncul kerana dibaca dari Supabase.

## Nota
Untuk MVP, RLS `families`, `family_members`, dan `family_profiles` dibuka dahulu kerana app masih menggunakan custom username/password auth dengan anon key.
